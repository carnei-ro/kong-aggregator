local BasePlugin = require "kong.plugins.base_plugin"
local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")

local plugin = BasePlugin:extend()

local responses = require "kong.tools.responses"
local utils = require "kong.tools.utils"
local meta = require "kong.meta"
local http = require "resty.http"
local cjson = require "cjson.safe"
local ngx = ngx
local resty_http = require 'resty.http'
local pp = require 'pl.pretty'
local re_match = ngx.re.match
local string_upper = string.upper
local table_concat = table.concat

local function do_request(url, params)
  local httpc = resty_http:new()
  local res, err = httpc:request_uri(url, params)

  if err then
    ngx.log(ngx.ERR, "tem erro")
    return responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
  end

  if not res then
    ngx.log(ngx.ERR, "nao teve response")
    return responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
  end

  if res.status == 200 and re_match(string_upper(res.headers["content-type"]), '^APPLICATION/JSON') then
    body = cjson.decode(res.body)
    return nil,res.status,res.body,res.headers
  end

  return nil, 400, '{"message": "status is not 200 or content-type is not application/json"}', {}
end

local function set_header(header, value)
  if not ngx.header[header] then
    ngx.header[header] = value
  end
end

local function override_header(header,value)
  if ngx.header[header] then
    ngx.header[header]=nil
  end
  ngx.header[header]=value
end

local function generate_body(content, headers, conf)
  local body={}

  if conf.merge_body then
    for i = 1, #conf.urls do
      body=utils.table_merge(body, cjson.decode(content[i]))
    end
    --body=pp.write(body)
    body=cjson.encode(body)
    return body
  end

  body = table_concat(content, ", ")
  local b={}
  for i =1 , #content do
    h=cjson.encode(headers[i])
    b[i]=table_concat({'[{ "headers": ', h, '}, {"body": ', content[i], '}]'})
    if i < #content then
      local a=b[i]
      b[i]=table_concat({a, ', '})
    end
  end
  s=table_concat(b)
  body = table_concat({'[', s , ']'})
  return body
end

local function send(content, headers, conf)
  ngx.status = 200
  body = generate_body(content, headers, conf)

  set_header('Content-Length', #body)
  override_header('Content-Type', 'application/json')

  ngx.say(body)

  return ngx.exit(ngx.status)
end


function plugin:new()
  plugin.super.new(self, plugin_name)
end


function plugin:access(conf)
  plugin.super.access(self)

  local upstream_uri = ngx.var.upstream_uri == "/" and "" or ngx.var.upstream_uri
  local params=cjson.decode(conf.params)

  local err={}
  local status={}
  local content={}
  local headers={}

  -- TODO: assyn (semaphores)
  for i = 1, #conf.urls do
    err[i], status[i], content[i], headers[i] = do_request(conf.urls[i] .. upstream_uri, params[i])
  end

  return send(content, headers, conf)
end


plugin.PRIORITY = 750
plugin.VERSION = "0.1-1"


return plugin

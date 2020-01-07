local cjson = require "cjson.safe"
local Errors = require "kong.dao.errors"

return {
  fields = {
    urls = {type = "array", default = { "https://httpbin.org/anything", "http://mockbin.com/request" }, required = true},
    params = { type = "string", required = true, default = '[ {"ssl_verify": false, "headers": {"x-hakuna": "matata", "x-foo": "bar" }, "method": "POST", "body": "a=1&b=2" }, {"ssl_verify": false, "headers": {"content-type": "application/json"  } } ]'  },
    merge_body = { type = "boolean", required = true, default = false }
  },
  self_check = function(schema, plugin_t, dao, is_updating)
    local params = cjson.decode(plugin_t.params)
    if #params == #plugin_t.urls then
      return true
    else
      return false, Errors.schema("'params' must be a JSON. Number of objects in 'params' must match number of objects in 'urls'")
    end
  end
}

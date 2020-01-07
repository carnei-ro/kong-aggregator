# Kong plugin template
====================

## Description

summary: Aggregator plugin

Fire a request to n destinations.
Aggregates the responses in a collection of object with headers and bodies, or aggregates the bodies in only one object.

```console
foo@bar:~$ http POST localhost:8001/services name=aggregator url='http://it-does-not-matter.com'

foo@bar:~$ http POST localhost:8001/services/aggregator/routes paths:='["/aggregator"]'

foo@bar:~$ http POST localhost:8001/services/aggregator/plugins name=aggregator config.urls:='["https://httpbin.org/anything","http://mockbin.com/request"]' config.params="[ {\"ssl_verify\": false, \"headers\": {\"x-hakuna\": \"matata\", \"x-foo\": \"bar\" }, \"method\": \"POST\", \"body\": \"a=1&b=2\" }, {\"ssl_verify\": false, \"headers\": {\"content-type\": \"application/json\"  } } ]"

foo@bar:~$ http GET localhost:8000/aggregator
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 2509
Content-Type: application/json
Date: Mon, 04 Feb 2019 23:25:06 GMT
Server: kong/0.14.1

[
    [
        {
            "headers": {
                "Access-Control-Allow-Credentials": "true",
                "Access-Control-Allow-Origin": "*",
                "Connection": "keep-alive",
                "Content-Length": "393",
                "Content-Type": "application/json",
                "Date": "Mon, 04 Feb 2019 23:25:05 GMT",
                "Server": "gunicorn/19.9.0",
                "Via": "1.1 vegur"
            }
        },
        {
            "body": {
                "args": {},
                "data": "a=1&b=2",
                "files": {},
                "form": {},
                "headers": {
                    "Connection": "close",
                    "Content-Length": "7",
                    "Host": "httpbin.org",
                    "User-Agent": "lua-resty-http/0.12 (Lua) ngx_lua/10013",
                    "X-Foo": "bar",
                    "X-Hakuna": "matata"
                },
                "json": null,
                "method": "POST",
                "origin": "177.68.230.36",
                "url": "https://httpbin.org/anything"
            }
        }
    ],
    [
        {
            "headers": {
                "Access-Control-Allow-Credentials": "true",
                "Access-Control-Allow-Headers": "host,connection,x-forwarded-for,x-forwarded-proto,x-forwarded-host,x-forwarded-port,x-real-ip,kong-cloud-request-id,kong-client-id,user-agent,content-type,x-request-id,via,connect-time,x-request-start,total-route-time",
                "Access-Control-Allow-Methods": "GET",
                "Access-Control-Allow-Origin": "*",
                "Connection": "keep-alive",
                "Content-Length": "989",
                "Content-Type": "application/json; charset=utf-8",
                "Date": "Mon, 04 Feb 2019 23:25:06 GMT",
                "Etag": "W/\"3dd-agSQchAK1kJp32/xoRvyuQ\"",
                "Kong-Cloud-Request-ID": "4cf5c698d14765c118aad3990b2fa458",
                "Server": "openresty/1.13.6.2",
                "Vary": "Accept, Accept-Encoding",
                "Via": "kong/0.34-enterprise-edition",
                "X-Kong-Proxy-Latency": "1",
                "X-Kong-Upstream-Latency": "8",
                "X-Kong-Upstream-Status": "200",
                "X-Powered-By": "mockbin"
            }
        },
        {
            "body": {
                "bodySize": 0,
                "clientIPAddress": "177.68.230.36",
                "cookies": {},
                "headers": {
                    "connect-time": "0",
                    "connection": "close",
                    "content-type": "application/json",
                    "host": "mockbin.com",
                    "kong-client-id": "mockbineast",
                    "kong-cloud-request-id": "4cf5c698d14765c118aad3990b2fa458",
                    "total-route-time": "0",
                    "user-agent": "lua-resty-http/0.12 (Lua) ngx_lua/10013",
                    "via": "1.1 vegur",
                    "x-forwarded-for": "177.68.230.36, 54.209.226.208",
                    "x-forwarded-host": "mockbin.com",
                    "x-forwarded-port": "80",
                    "x-forwarded-proto": "http",
                    "x-real-ip": "177.68.230.36",
                    "x-request-id": "15fbf513-1a0b-4f30-9d93-e94489126c4c",
                    "x-request-start": "1549322706745"
                },
                "headersSize": 540,
                "httpVersion": "HTTP/1.1",
                "method": "GET",
                "postData": {
                    "mimeType": "application/json",
                    "params": [],
                    "text": ""
                },
                "queryString": {},
                "startedDateTime": "2019-02-04T23:25:06.749Z",
                "url": "http://mockbin.com/request"
            }
        }
    ]
]


foo@bar:~$ http PATCH localhost:8001/plugins/$(http -b GET localhost:8001/services/aggregator/plugins | jq -r .data[].id) config.merge_body:=true config.urls:='["https://httpbin.org/anything","http://mockbin.com/request"]' config.params="[ {\"ssl_verify\": false, \"headers\": {\"x-hakuna\": \"matata\", \"x-foo\": \"bar\" }, \"method\": \"POST\", \"body\": \"a=1&b=2\" }, {\"ssl_verify\": false, \"headers\": {\"content-type\": \"application/json\"  } } ]"

foo@bar:~$ http GET localhost:8000/aggregator
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 916
Content-Type: application/json
Date: Mon, 04 Feb 2019 23:30:43 GMT
Server: kong/0.14.1

{
    "args": {},
    "bodySize": 0,
    "clientIPAddress": "177.68.230.36",
    "cookies": {},
    "data": "a=1&b=2",
    "files": {},
    "form": {},
    "headers": {
        "connect-time": "4",
        "connection": "close",
        "content-type": "application/json",
        "host": "mockbin.com",
        "kong-client-id": "mockbineast",
        "kong-cloud-request-id": "460987643e87fb9b12fdda550e92b5b9",
        "total-route-time": "0",
        "user-agent": "lua-resty-http/0.12 (Lua) ngx_lua/10013",
        "via": "1.1 vegur",
        "x-forwarded-for": "177.68.230.36, 18.204.28.183",
        "x-forwarded-host": "mockbin.com",
        "x-forwarded-port": "80",
        "x-forwarded-proto": "http",
        "x-real-ip": "177.68.230.36",
        "x-request-id": "f2eb6f18-a4c1-49d3-bd28-d0c14e376479",
        "x-request-start": "1549323043519"
    },
    "headersSize": 539,
    "httpVersion": "HTTP/1.1",
    "json": null,
    "method": "GET",
    "origin": "177.68.230.36",
    "postData": {
        "mimeType": "application/json",
        "params": {},
        "text": ""
    },
    "queryString": {},
    "startedDateTime": "2019-02-04T23:30:43.529Z",
    "url": "http://mockbin.com/request"
}
```



### Warning:

- Summary in README.md file must starts with "summary: ".
- It can NOT have double quotes '"'.

## Install

Copy the ".rock" to a Kong machine/docker and run `luarocks install ${NAME}-${VERSION}.all.rock`. The ".rock" will be generated after a `make build`.

## Developing

Use `make start` to start a Kong environment (docker) and bind the directory.
You can edit your ".lua" files, **save them**, and run `make kong-reload` to reload it to Kong with the updates.

If you change the plugin version, you must run `make reconfigure`

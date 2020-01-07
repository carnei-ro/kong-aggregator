package = "kong-aggregator"
version = "0.1-1"

source = {
 url    = "git@github.com:carnei-ro/kong-aggregator.git",
 branch = "master"
}

description = {
  summary = "Aggregator plugin",
}

dependencies = {
  "lua ~> 5.1"
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.kong-aggregator.schema"] = "src/schema.lua",
    ["kong.plugins.kong-aggregator.handler"] = "src/handler.lua",
  }
}

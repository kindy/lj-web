local ffi = require 'ffi'

local MODE = {
    LUNCH = 1,
    SERVER = 2,
}

module(..., package.seeall)

-- mode:
--  * MODE.LUNCH
--  * MODE.SERVER
local mode = ngx and MODE.SERVER or MODE.LUNCH

--[[
.app
:cancel() - close the connect
:get_body() - close the connect
.var.? - see nginx wiki's variable & more
--]]
local req = {
    new = function()
    end;
}

--[[
.req
:say ''
:say {a, b, flush=nil}
:print ''
:print {}
:printf {format, variables, named_variables=.., _flush=nil}
:sleep(seconds) - float
:flush(wait?)
:sendfile {path, chunksize}
:sendfiles {}
--]]
local resp = {
    new = function()
    end;
}

--[[
:new {listen=80, server_name=''}
.env
:route {path, fn, method='*' | 'get|post', ci_match=false, prefix_match=false, route_at=1|2}
    * ci_match -> case insensitive match
    * route_at -> match 1 first and then 2 (Don't pass other number)
        default: 2
    * param_defaults = {}
    * path_as_patt = false
:route_many { {}, {} }
:has_route(path)
:request {path, method, headers={}, body=nil, pass_output=false}
:request_many { {path, method, headers={}, body=nil, pass_output=false}, {} }
:request_any { {path, method, headers={}, body=nil, pass_output=false}, {} }
:run {listen=80, server_name='abc.com'}
--]]
local _apps = {}
local app = {
    new = function(app)
        local app_ = {
            new = false;
            -- {pattern, fn, method, ci_match, prefix_match}
            routes = { {}, {} };
        }
        table.insert(_apps, app_)

        setmetatable(app_, {
            __index = app
        })

        return app_
    end;

    run_level = 'info';

    route = function(self, arg)
        local path, fn = arg[1], arg[2]
        local at = arg.match_at or 2

        local routes = self.routes[at]
        if not routes then
            routes = {}
            self.routes[at] = routes
        end

        table.insert(routes, {
            self:compile_patt(path), fn, method = arg.method,
            ci_match = arg.ci_match, prefix_match = arg.prefix_match,
        })

        return self
    end;

    compile_patt = function(self, path, arg)
        return {
            patt = path,
            matchs = {};
        }
    end;

    route_many = function(self, routes)
        for _, route in ipairs(routes) do
            self:route(route)
        end

        return self
    end;

    has_route = function(self, path)
        return self:find_route(path) ~= nil
    end;

    find_route = function(self, path)
        for _, route in ipairs(self.routes) do
            if string.match(path, route[1].patt) then
                return route
            end
        end
    end;

    _handle_access = function(app)
    end;

    _handle_rewrite = function(app)
    end;

    _handle_content = function(app)
    end;

    _handle_log = function(app)
    end;

}


local default_app = app:new()

new_app = function(...)
    return app:new(...)
end

for _, fname in ipairs{'route', 'route_many', 'has_route', 'request', 'request_many', 'request_any', 'run'} do
    _M[fname] = function(...)
        default_app[fname](default_app, ...)
    end
end


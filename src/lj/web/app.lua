local util = require 'lj.web.util'

local lrender, strf = util.lrender, util.strf

--[[
:new {listen=80, server_name=''}
.env
:add_filter {phase, fn, run_at=2}

:route {path, fn, method='*' | 'get|post', ci_match=false, prefix_match=false, run_at=1|2, use_global_filter=true, filter=nil}
    * ci_match -> case insensitive match
    * run_at -> match 1 first and then 2 (Don't pass other number)
        default: 2
    * param_defaults = {}
    * path_as_patt = false

:route_many { {}, {} }
:has_route(path)
:find_route(path)
:request {path, method, headers={}, body=nil, pass_output=false}
:request_many { {path, method, headers={}, body=nil, pass_output=false}, {} }
:request_any { {path, method, headers={}, body=nil, pass_output=false}, {} }
:run {listen=80, server_name='abc.com'}
--]]

local _apps = {}

local app = {
    run_level = 'info';
}

function app.get_apps()
    return _apps
end

function app:new()
    local app_ = {
        new = false;
        -- {pattern, fn, method, ci_match, prefix_match}
        routes = { {}, {} };
    }
    table.insert(_apps, app_)

    setmetatable(app_, { __index = self })

    return app_
end


function app:route(arg)
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
end

function app:compile_patt(path, arg)
    return {
        patt = path,
        matchs = {};
    }
end

function app:has_route(path)
    return self:find_route(path) ~= nil
end

function app:find_route(path)
    for _, route in ipairs(self.routes) do
        if string.match(path, route[1].patt) then
            return route
        end
    end
end

function app:_handle_set()
end

function app:_handle_access()
end

function app:_handle_rewrite()
end

function app:_handle_content()
end

function app:_handle_header_filter()
end

function app:_handle_body_filter()
end

function app:_handle_log()
end

function app:generate_conf(srv, config)
    local ctx = {}

    return lrender([[
    server {
        listen       83;
        server_name  localhost;

        root   html;

        location / {
            index  index.html index.htm;
        }

    }
]], ctx)

end

return app


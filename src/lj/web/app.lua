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

local _app_id = 0
local _apps = {}

local app = {
    run_level = 'info';
}

function app.get_apps()
    return _apps
end

function app.empty_other_apps(app_ids)
    -- FIXME: impl this
end

function app:new(config)
    _app_id = _app_id + 1
    local app_ = {
        new = false;
        id = _app_id;

        -- {pattern, fn, method, ci_match, prefix_match}
        routes = { {}, {} };
        config = config or {};
    }
    _apps[_app_id] = app_
    app_.config.app_id = _app_id

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

function app._handle_set(app_id)
end

function app._handle_access(app_id)
end

function app._handle_rewrite(app_id)
end

function app._handle_content(app_id)
    -- local app_ = _apps[app_id]

    ngx.say('hello', ngx.var.uri)
end

function app._handle_header_filter(app_id)
end

function app._handle_body_filter(app_id)
end

function app._handle_log(app_id)
end

function app:generate_conf(srv, config)
    local ctx = {}
    ctx.app_id = self.id
    ctx.listen = 9090
    -- ctx.server_name = 'localhost';

    local con = lrender(self.conf_tmpl, ctx)
    -- print('app tmpl', con)
    return con

end

app.conf_tmpl = [[
    server {
        listen       <?= listen ?>;
        <? if server_name then ?>server_name  <?= server_name ?>;<? end ?>

        <? if app_root then ?>root  <?= app_root ?>;<? end ?>

        location / {
            index  index.html index.htm;

            rewrite_by_lua "require 'lj.web.app'._handle_rewrite(<?= app_id ?>)";
            access_by_lua "require 'lj.web.app'._handle_access(<?= app_id ?>)";
            content_by_lua "require 'lj.web.app'._handle_content(<?= app_id ?>)";
            log_by_lua "require 'lj.web.app'._handle_log(<?= app_id ?>)";
            header_filter_by_lua "require 'lj.web.app'._handle_header_filter(<?= app_id ?>)";
            body_filter_by_lua "require 'lj.web.app'._handle_body_filter(<?= app_id ?>)";
        }

    }
]]


return app


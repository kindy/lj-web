local web_req, web_resp = require 'lj.web.req', require 'lj.web.resp'
local web_route = require 'lj.web.route'

local util = require 'lj.web.util'

local lrender, strf = util.lrender, util.strf

--[[
:new {listen=80, server_name=''}
.env

:route {path, fn, method='*' | 'get|post', path_as_pcre=false, comment=nil, name=nil}
    * path_as_pcre - true | false
        * pcre_flag=''
    * param_defaults = {}
    * path -> string or string[]
    * fn -> handle function

    example:
    '/:name'
    '/<name>s'
    '^/', path_as_pcre=true -> match any path

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

function app:get_req()
    local req = ngx.ctx._ljweb
    if not req then
        print 'new req'
        req = web_req:new(self)
        print 'req.resp create'
        local resp = web_resp:new(req)
        print 'req.resp assign'
        req.resp = resp
        print 'req.resp done'
        ngx.ctx._ljweb = req
    end

    return req
end

function _get_app(app_id)
    local app_ = _apps[app_id]
    if app_ and not app_._inited then
        app_._inited = true
        app_:init_xx(nil, nil)
    end

    return app_
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
        routes = {};
        config = config or {};
    }
    _apps[_app_id] = app_
    app_.config.app_id = _app_id

    setmetatable(app_, { __index = self })

    return app_
end

function app:route(arg)
    local path, fn = arg[1], arg[2]
    local at = arg.run_at or 2

    -- TODO: record the caller info
    table.insert(self.routes, web_route:new(arg))

    return self
end

-- FIXME: use other re instead of ngx.re
function app:init_xx(srv, config)
    for _, route in ipairs(self.routes) do
        if route.init then
            route:init()
        end
    end
end

function app:has_route(path)
    return self:find_route(path) ~= nil
end

function app:find_route(path, all, req)
    local routes
    if all then
        routes = {}
    end

    for _, route in ipairs(self.routes) do
        util.printf('route._patt [%d]: %s', _, route._patt)

        if route:match(path, req) then
            -- string.match(path, route[1].patt) then
            if all then
                table.insert(routes, route)
            else
                return route
            end
        end
    end

    if all then
        return routes
    else
        return nil
    end
end

function app._handle_set(app_id)
end

function app._handle_access(app_id)
end

function app._handle_rewrite(app_id)
end

function app._handle_content(app_id)
    local app_ = _get_app(app_id)

    local req_ = app:get_req()
    print('uri:', req_.uri)
    local route_ = app_:find_route(req_.uri, false, req_)
    print('route_:', route_ and 'obj' or 'nil')

    -- ngx.say('hello', ngx.var.uri)
    print 'before handle content'
    if route_ then
        route_.fn(req_, req_.resp, req_.param or {})
    end
    print 'after handle content'

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


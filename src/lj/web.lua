local ffi = require 'ffi'

local config = require 'lj.web.config'
local srv, app = require 'lj.web.app', require 'lj.web.srv'

local MODE = {
    LUNCH = 1,
    SERVER = 2,
}

local web = {}

-- mode:
--  * MODE.LUNCH
--  * MODE.SERVER
local mode = ngx and MODE.SERVER or MODE.LUNCH

function web.new_srv(...)
    return srv:new(...)
end

function web.new_app(...)
    return app:new(...)
end

web.default_srv = new_srv()
web.default_app = new_app()

function web.run_srvs(srvs)
    for _, srv in ipairs(srvs) do
        srv:run()
    end

    os.exit()
end

function web.run_all_srv()
    web.run_srvs(srv.get_srvs())
end

function web.run_apps(apps)
    for _, app_define in ipairs(apps) do
        web.default_srv:add_app(unpack(app_define))
    end

    web.run_srvs { web.default_srv }
end

function web.run(config)
    web.run_apps { {web.default_app, config} }
end


-- short fn name for app
for _, fname in ipairs{'route', 'route_many', 'has_route'} do
    web[fname] = function(...)
        local app = web.default_app
        app[fname](app, ...)
    end
end

return web


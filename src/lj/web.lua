local ffi = require 'ffi'

local web_config = require 'lj.web.config'
local web_srv, app = require 'lj.web.srv', require 'lj.web.app'
local util = require 'lj.web.util'

local web = {}

function web.new_srv(...)
    return web_srv:new(...)
end

function web.new_app(...)
    return app:new(...)
end

function web.config(cfgs, v)
    if type(cfgs) ~= 'table' and v ~= nil then
        cfgs = { [cfgs] = v }
    end

    for k, v in pairs(cfgs) do
        web_config[k] = v
    end
end

web.default_srv = web.new_srv()
web.default_app = web.new_app()

-- cmd mode
if web_config.mode == 'srv' then
    function web.run_srvs(srvs)
        web_srv.get_and_empty_other(web_config.srv_id):init()
    end

else
    function web.run_srvs(srvs)
        for _, srv in ipairs(srvs) do
            srv:run()
        end

        -- TODO: print all nginx server's pid
        os.exit()
    end

end

function web.run_all_srv()
    web.run_srvs(web_srv.get_srvs())
end

function web.run_apps(apps)
    for _, app_define in ipairs(apps) do
        web.default_srv:add_app(unpack(app_define))
    end

    web.run_srvs { web.default_srv }
end

function web.run(start_file, config)
    web_config.start_file = util.path.abspath(start_file)
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


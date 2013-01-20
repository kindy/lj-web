local posix = require 'posix'
local ffi = require 'ffi'

local web_config = require 'lj.web.config'
local web_srv, app = require 'lj.web.srv', require 'lj.web.app'
local util = require 'lj.web.util'


if false then
debug.sethook(function(typ, line, count)
    util.printf('[%s], %s() :%s', typ, debug.getinfo(2, 'n').name, line or '-')
    -- getinfo(2)..
end, 'c')
end

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


local function check_srv_status(pids)
    print 'servers status:\n'
    local chars, char_idx = { '|', '/', '-', '\\' }, 1
    while true do
        local s, c = {}, chars[char_idx]

        for _, pid in ipairs(pids) do
            table.insert(s, util.strf('%d %s', pid, c))
        end

        io.stderr:write('\r' .. table.concat(s, '\t\t'))

        char_idx = char_idx + 1
        if char_idx > #chars then
            char_idx = 1
        end

        posix.nanosleep(0, 1e6 * 80)
    end
end

-- cmd mode
if web_config.mode == 'srv' then
    function web.run_srvs(srvs) return end

else
    function web.run_srvs(srvs)
        local pids = {}
        for _, srv in ipairs(srvs) do
            table.insert(pids, srv:run())
        end

        check_srv_status(pids)
        -- TODO: print all nginx server's pid
        print 'all server start'
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

function web.run(config)
    if not config then config = {} end

    if web_config.mode == 'srv' then
        web.run_apps { {web.default_app, config} }
        return
    end

    if not config[1] then
        web.last_run_config = config
        return
    end

    -- if app.lua use web.run(), we just open the nginx process(do not fork)
    web_config.no_fork = true
    web_config.start_file = util.path.abspath(config[1])

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


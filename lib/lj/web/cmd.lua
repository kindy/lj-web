local posix = require 'posix'
local getopt = require 'lj.web.alt_getopt'
local util = require 'lj.web.util'

local web_cmd = {}

function web_cmd.run(arg)
    local cmd = arg[1]

    if cmd and web_cmd['cmd_' .. cmd] then
        arg.cmd = cmd
        table.remove(arg, 1)
        arg.cwd = posix.getcwd()

        return web_cmd['cmd_' .. cmd](arg)
    end
end

function web_cmd.cmd_ss(arg)
    local ngx_conf = require 'lj.web.ngx_conf'

    local optarg, optidx = getopt.get_opts(arg, 'l:', {})
    local port = 9000

    if optarg.l then
        local n = string.match(optarg.l, ':?(%d+)$')
        port = tonumber(n)
    end

    local conf = ngx_conf.get_default_conf()
    local srv = ngx_conf.find_first(conf, 'http server')
    ngx_conf.find_first(srv, 'listen')[2] = port
    ngx_conf.find_first(srv, 'root')[2] = arg.cwd
    local loc = ngx_conf.find_first(srv, 'location')
    table.insert(loc[3], {'autoindex', 'on'})

    local p = os.tmpname()
    posix.unlink(p)
    posix.mkdir(p)

    util.printf('nginx run prefix: %s, visit: http://localhost:%d', p, port)
    ngx_conf.run_srv {p .. '/', conf, no_fork = true}
end

function web_cmd.cmd_run(arg)
    local web = require 'lj.web'

    local file = arg[1]
    if not file then
        file = 'app.lua'
    end

    local stat, msg = posix.stat(file)
    if not stat then
        error(msg)
    end

    loadfile(file)()
    -- print(web.last_run_config)
    if web.last_run_config then
        web.last_run_config[1] = file
        web.run(web.last_run_config)
    end

end

function web_cmd.cmd_init(arg)
    error 'not impl.'
end

return web_cmd


local posix = require 'posix'
local util = require 'lj.web.util'

local lrender, strf = util.lrender, util.strf

local _srv_id = 0
local _srvs = {}

local srv = {}

function srv.get_srvs()
    return _srvs
end

function srv:new(config)
    _srv_id = _srv_id + 1
    local srv_ = {
        new = false;
        id = _srv_id;

        apps = {};
        config = config;
    }
    _srvs[_srv_id] = srv_

    setmetatable(srv_, { __index = self })

    return srv_
end

function srv:add_app(app, config)
    table.insert(self.apps, {app = app, config = config})
end

function srv:get_rt_prefix()
    return strf('%s/srv-%s/', posix.getcwd(), tostring(self.name or self.id))
end

function srv:run(config)

    if config then
        local orig_config = self.config
        if orig_config then
            setmetatable(config, { __index = orig_config })
        end
        self.config = config
    end

    local conf = self:generate_conf()
    if not conf then
        return error 'generate conf fail'
    end

    self:_make_dirs()
    self:_write_conf(conf)
    return self:_start_srv()
end

function srv:generate_conf()
    local ctx = {}
    ctx.apps = {}

    for _, app_define in ipairs(self.apps) do
        table.insert(ctx.apps, app_define.app:generate_conf(self, app_define.config))
    end

    setmetatable(ctx, { __index = self.config })

    return lrender(self.conf_tmpl, ctx)
end

function srv:_make_dirs()
    local p = self:get_rt_prefix()

    local s, msg = posix.stat(p)
    if not s then
        s, msg = posix.mkdir(p)
        if not s then
            return msg
        end
    end

    for _, dir in ipairs{'logs', 'conf'} do
        local d = p .. dir
        local s, msg = posix.stat(d)
        if not s then
            s, msg = posix.mkdir(d)
            if not s then
                return msg
            end
        end
    end

end

function srv:_write_conf(conf)
    io.open(self:get_rt_prefix() .. 'conf/nginx.conf', 'w'):write(conf)
end

-- return pid
function srv:_start_srv()
    local pid = posix.fork()

    if pid == 0 then
        self.ppid = posix.getpid 'ppid'

        posix.execp(self._get_nginx_bin(), strf('-p %s', self:get_rt_prefix), '-c conf/nginx.conf')
    end

    return pid
end

srv.conf_tmpl = [[
{{#user}}user  {{ user }}{{/user};
worker_processes  1;
#error_log  logs/error.log  info;
#pid        logs/nginx.pid;
events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    sendfile        on;

    keepalive_timeout  65;

    gzip  on;

    {{#apps}}
    {{.}}
    {{/apps}}
}
]]


return srv


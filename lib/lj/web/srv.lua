local posix = require 'posix'
local util = require 'lj.web.util'
local web_config = require 'lj.web.config'
local ngx_conf = require 'lj.web.ngx_conf'

local lrender, strf = util.lrender, util.strf

local _srv_id = 0
local _srvs = {}

local srv = {}

function srv.get_srvs()
    return _srvs
end

function srv.get_and_empty_other(srv_id)
    local srv_
    for idx, srv in ipairs(_srvs) do
        if srv.id == srv_id then
            srv_ = srv
        else
            _srvs[idx] = nil
        end
    end

    return srv_
end

function srv:new(config)
    _srv_id = _srv_id + 1
    local srv_ = {
        new = false;
        id = _srv_id;

        apps = {};
        config = config or {};
    }
    _srvs[_srv_id] = srv_
    srv_.config.srv_id = _srv_id

    setmetatable(srv_, { __index = self })

    return srv_
end

function srv:add_app(app, config)
    table.insert(self.apps, {app = app, config = config})
end

function srv:get_rt_prefix()
    local vardir = strf('%s/var', posix.getcwd())

    local s, msg = posix.stat(vardir)
    if not s then
        s, msg = posix.mkdir(vardir)
        if not s then
            error(msg)
        end
    end

    return strf('%s/srv-%s/', vardir, tostring(self.name or self.id))
end

-- srv mode, init, like optmize all apps' route, call all apps' 'init' filter
function srv:init()
    for idx, app_define in ipairs(self.apps) do
        local app = app_define.app
        if app.init then
            app:init(self, app_define.config)
        end
        print('app', idx)
    end
    print 'run server init'
end

-- cmd mode, start nginx server
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
        error 'generate conf fail'
    end

    local p = self:get_rt_prefix()

    return ngx_conf.run_srv {p, conf, no_fork = web_config.no_fork}
end

function srv:generate_conf()
    local ctx = {}
    ctx.start_file = string.gsub(web_config.start_file, '"', '\\"')
    ctx.nginx_prefix = self:get_ngx_prefix()
    ctx.apps = {}
    local app_ids = {}

    for _, app_define in ipairs(self.apps) do
        table.insert(ctx.apps, app_define.app:generate_conf(self, app_define.config))
        table.insert(app_ids, app_define.app.id)
    end

    ctx.app_ids = table.concat(app_ids, ',')

    setmetatable(ctx, { __index = self.config })

    -- print(self.conf_tmpl, '__apps', ctx.apps[1].app)

    return lrender(self.conf_tmpl, ctx)
end


function srv:get_ngx_prefix()
    return '/usr/local/openresty/nginx/'
end


srv.conf_tmpl = [==[
<? if user then ?>user  <?= user ?>;<? end ?>
worker_processes  1;
error_log  logs/error.log  debug;

#pid        logs/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       <?= nginx_prefix ?>conf/mime.types;
    default_type  application/octet-stream;

    sendfile        on;

    keepalive_timeout  65;

    gzip  on;

    lua_package_path "/Users/kindy/h/github/kindy/lj-web/lib/?.lua;/usr/local/openresty/lualib/?.lua;;";
    lua_package_cpath "/usr/local/openresty/lualib/?.so;;";

    resolver 8.8.8.8;

    init_by_lua "require 'lj.web.srv'.init_srv{
        srv_id = <?= srv_id ?>,
        start_file = [=[<?= start_file ?>]=],
        app_ids = { <?= app_ids ?> },
    }";

<? for _, app in ipairs(apps) do ?>
<?= app ?>
<? end ?>

}

]==]


function srv.init_srv(config)
    -- srv | cmd
    web_config.mode = 'srv'
    web_config.srv_id = config.srv_id
    web_config.app_ids = config.app_ids
    web_config.start_file = config.start_file
    loadfile(config.start_file)()

    srv.get_and_empty_other(web_config.srv_id):init()

end


return srv


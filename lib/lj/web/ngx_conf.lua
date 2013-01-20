local util = require 'lj.web.util'
local json = require 'cjson'

module(..., package.seeall)

--[[
]]

local function escape_arg(arg)
    return string.find(arg, [=[[%s'\"]]=]) and string.gsub(arg, [[(['\])]], function(c)
        return '\\' .. c
    end) or arg
end

function dir_to_conf(dir, level)
    local buf = {}
    if not level then level = 0 end
    local len = #dir
    local lastarg = dir[len]
    local is_block = type(lastarg) == 'table'
    local indent_space = string.rep(' ', level * 4)

    for i = 1, len - (is_block and 1 or 0) do
        table.insert(buf, escape_arg(dir[i]))
    end

    if not is_block then
        return indent_space .. table.concat(buf, ' ') .. ';'
    else
        return (indent_space .. table.concat(buf, ' ') .. ' {\n' ..
            block_to_conf(lastarg, level + 1) .. indent_space .. '}'
        )
    end

end

function block_to_conf(block, level)
    local buf = {}
    if not level then level = 0 end

    for _, dir in ipairs(block) do
        table.insert(buf, dir_to_conf(dir, level))
    end

    return table.concat(buf, '\n') .. '\n'
end

function get_default_conf(typ)
    local conf = {
        {'worker_processes', 1};
        {'error_log', 'logs/error.log', 'debug'};
    }
    local ev_conf = {'events', {
        {'worker_connections', 1024};
    }}

    local http_conf = {'http', {
        {'include', '/usr/local/openresty/nginx/conf/mime.types'};
        {'default_type', 'application/octet-stream'};
        {'sendfile', 'on'};
        {'gzip', 'on'};
        {'resolver', '8.8.8.8'};
    }};

    local srv_conf = {'server', {
        {'listen', 9001};

        {'root', 'html'};
        {'location', '/', {
        }};
    }}

    if typ == 'srv' then
        return srv_conf
    end

    table.insert(conf, ev_conf)
    table.insert(http_conf[2], srv_conf)
    table.insert(conf, http_conf)

    return conf
end

function make_ngx_dirs(p)
    local s, msg = posix.stat(p)
    if not s then
        s, msg = posix.mkdir(p)
        if not s then
            error(msg)
        end
    end

    for _, dir in ipairs{'logs', 'conf'} do
        local d = p .. dir
        s, msg = posix.stat(d)
        if not s then
            s, msg = posix.mkdir(d)
            if not s then
                error(msg)
            end
        end
    end

end

function write_conf(file, conf)
    local f = io.open(file, 'wb')
    f:write(conf)
    f:close()
end

-- ngx_prefix, conf, ngx_bin='/usr/openresty/nginx/sbin/nginx', no_fork=false
-- mkdir -p ngx_prefix/ ngx_prefix/conf ngx_prefix/logs
-- write conf to ngx_prefix/conf/nginx.conf
-- start nginx -p ngx_prefix/ -c conf/nginx.conf
-- return pid
function run_srv(arg)
    local rt_prefix, conf = arg[1], arg[2]

    -- print('rt_prefix:', rt_prefix, ' conf:', conf)

    if type(conf) == 'table' then
        conf = block_to_conf(conf)
    end

    local conf_file = 'conf/nginx.conf'

    make_ngx_dirs(rt_prefix)
    write_conf(rt_prefix .. conf_file, conf)

    local cmd = {
        arg.ngx_bin or '/usr/local/openresty/nginx/sbin/nginx',
        '-p', rt_prefix,
        '-c', conf_file
    }
    -- util.printf('[%d] run: %s\n\n', posix.getpid 'pid', table.concat(cmd, ' '))

    if arg.no_fork then
        table.insert(cmd, '-g')
        table.insert(cmd, 'master_process off; daemon off;')
        local ok, msg = posix.exec(unpack(cmd))
        if not ok then
            print(msg)
        end
        print '!!!! oh, what happen 1 !!!!'
    else
        local pid = posix.fork()

        if pid == 0 then
            -- self.ppid = posix.getpid 'ppid'

            posix.exec(unpack(cmd))
            print '!!!! oh, what happen 2 !!!!'
        else
            return pid
        end

    end
end

function find_first_one(c, name)
    -- print('finding: ', json.encode(c), name)

    local block = type(c[1]) == 'string' and c[#c] or c

    if (not block) or (type(block) ~= 'table') then
        -- print 'block type error'
        return nil
    end

    -- print('block: ', json.encode(block))
    for idx, dir in ipairs(block) do
        -- print('iter dir: ', idx, json.encode(dir), dir[1])
        if dir[1] == name then
            return dir, idx
        end
    end

    return nil
end

function find_first(c, name)
    local block = c

    for name_ in string.gmatch(name, '([^ ]+)') do
        if not block then
            return nil
        end
        block = find_first_one(block, name_)
    end

    return block
end


local posix = require 'posix'

local util = {
    path = {};
}
local _path = util.path

local ltp = require 'ltp.template'
function util.lrender(tmpl, ctx)
    local str = assert(ltp.compile_template_as_function(tmpl, '<?', '?>'))
    -- print('tmpl', str)
    local fn = assert(loadstring(str))()

    local ret = {}
    ctx.table = table
    ctx.ipairs = ipairs
    setfenv(fn, ctx)
    fn(ret)

    return table.concat(ret)
end

function util.printf(...)
    print(string.format(...))
end

function util.strf(...)
    return string.format(...)
end

function _path.join(a, ...)
    local path = {a}
    for _, b in ipairs{...} do
        if b:sub(1, 1) == '/' then
            path = {b}
        else
            table.insert(path, b)
        end
    end

    return table.concat(path, '/')
end

function _path.normpath(path)
    local slash, dot = '/', '.'

    if path == '' then
        return dot
    end

    local initial_slashes = (path:sub(1, 1) == slash) and slash or false
    if initial_slashes and (path:sub(2, 2) == slash) and (path:sub(3, 3) ~= slash) then
        initial_slashes = slash .. slash
    end

    -- print(initial_slashes)

    new_comps = {}
    for comp in string.gmatch(path, '[^' .. slash .. ']+') do
        if comp ~= '' and comp ~= '.' then
            if (comp ~= '..') or (not initial_slashes and #new_comps == 0) or (#new_comps > 0 and new_comps[-1] == '..') then
                table.insert(new_comps, comp)
            else
                table.remove(new_comps)
            end
        end

        -- print(comp, unpack(new_comps))
    end

    path = table.concat(new_comps, slash)
    if initial_slashes then
        path = initial_slashes .. path
    end

    return path or dot
end

function _path.isabs(path)
    return path:sub(1, 1) == '/'
end

function _path.abspath(path)
    if not _path.isabs(path) then
        local cwd = posix.getcwd()
        path = _path.join(cwd, path)
    end
    -- print(path)

    return _path.normpath(path)
end

return util


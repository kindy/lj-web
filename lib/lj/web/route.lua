local util = require 'lj.web.util'

local _get_from_objs = util.get_from_objs

local route = {}


local _route_id = 0
function route:new(arg)
    _route_id = _route_id + 1
    local route_ = {
        new = false;
        _id = _route_id;
    }

    route_.fn = arg[2]

    if arg.path_as_pcre then
        route_.path_as_pcre = true
        route_.match = self.pcre_match
        route_._patt = arg[1]
        route_.pcre_flag = arg.pcre_flag or ''
    else
        route_.path_as_pcre = false
        route_.match = self.lua_match
        -- do this at server & app init, because only rt has ngx
        local path = arg[1]
        route_.init = function(self)
            print('route init, path: ', path)
            self._patt, self._patt_names = self.compile_patt(route_, path)
        end
    end

    setmetatable(route_, { __index = self })

    return route_
end

--[[
/ -> ^/$
/abc -> ^/abc$
/:abc -> ^/[^/]+$, {'abc'}
/<ab>c -> ^/[^/]+c$, {'ab'}
/:ab/:c -> ^/[^/]+/[^/]+$, {'ab', 'c'}

-- escape with prefix ':':
/a::b -> ^/a:b$
/:<ab>c -> ^/<ab>c$

:([:<]) -> $1, nil
:([a-zA-Z_$]+) -> ([^/]+), $1
<([a-zA-Z_$]+)> -> ([^/]+), $1
]]
function route:compile_patt(path)
    local names = {}

    local midx = 0
    path = ngx.re.gsub(path, ':([:<])|:([a-zA-Z_$]+)|<([a-zA-Z_$]+)>', function(m)
        print('route compile: ', path, unpack(m))

        if m[1] then
            return m[1]
        else
            midx = midx + 1
            names[m[2] or m[3]] = midx
            return '([^/]+)'
        end
    end)

    return '^' .. path .. '$', names

end

function route:lua_match(path, req)
    util.printf('lua match path: %s, patt: %s, req: %s', path, self._patt, tostring(req))

    local m = {string.match(path, self._patt)}

    -- TODO: move req.param to lj.web.app
    if m and #m > 0 then
        if req then
            local param = {}
            for name, idx in pairs(self._patt_names) do
                util.printf('match name: %s, id: %d, val: %s', name, idx, m[idx])
                param[name] = m[idx]
            end

            setmetatable(param, { __index = _get_from_objs{m, req.param_defaults} })
            req.param = param
        end

        return true
    else
        if req then
            req.param = {}
        end

        return false
    end
end

function route:pcre_match(path, req)
    local m = ngx.re.match(path, self._patt, self.pcre_flag)

    if m then
        if req then
            local param = {}
            setmetatable(param, { __index = _get_from_objs{m, req.param_defaults} })
            req.param = m
        end

        return true
    else
        if req then
            req.param = nil
        end

        return false
    end
end


return route


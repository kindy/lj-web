--[[
.app
:cancel() - close the connect
:get_body()
.uri
.method
.http_version
.ua
.cookie -> not iterable table
.session -> not iterable & rw table
.var.? - see nginx wiki's variable & more
--]]

local req = {}

function req:new(app)
    local req_ = {
        _create_phase = ngx.get_phase()
    }
    req_.app = app
    req_.attrs = self.attrs

    setmetatable(req_, {
        __index = function(self, key)
            print('req __index', key)
            local setget = self.attrs[key]
            if setget ~= nil then
                if setget[1] then
                    return setget[1](self, key)
                else
                    return nil
                end
            else
                return req[key]
            end
        end;

        __newindex = function(self, key, val)
            print('req __newindex', key, tostring(val), tostring(self.attrs))
            local setget = self.attrs[key]
            if setget ~= nil then
                if setget[2] then
                    setget[2](self, key, val)
                else
                    error('key [' .. key .. '] not writeable')
                end
            else
                rawset(self, key, val)
            end
        end;
    })

    return req_
end

req.attrs = {
    uri = { function(self, key)
        return ngx.var.uri
    end, false };
    -- ^ false means not support write
}


return req


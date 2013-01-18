--[[
.req
:say ''
:say {a, b, flush=nil}
:print ''
:print {}
:printf {format, variables, named_variables=.., _flush=nil}
:sleep(seconds) - float
:flush(wait?)
:sendfile {path, chunksize}
:sendfiles {}
--]]

local resp = {}

function resp:new(req)
    local resp_ = {
        req = req;
    }

    setmetatable(resp_, { __index = self })

    return resp_
end

function resp:say(arg)
    ngx.say(unpack(arg))
end

function resp:printf(arg)
    ngx.print(string.format(unpack(arg)))
end


return resp


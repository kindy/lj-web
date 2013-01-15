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

function resp:new()
end


return resp


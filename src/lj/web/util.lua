local util = {}

local lustache = require 'lustache'
function util.lrender(...)
    return lustache:render(...)
end

function util.strf(...)
    return string.format(...)
end

return util


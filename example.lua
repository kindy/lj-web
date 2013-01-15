
local web = require 'lj.web'

web.add_filter {'access|rewrite', function(req)
end}

web.route {'/', function(req, resp)
    resp.say 'hello, resty web!'
    resp.flush(true)
    resp.sleep(1)
    resp.say ':)'
end}

local count = 0
web.route {'/:name', function(req, resp, param)
    count = count + 1
    resp.printf {'hello, the %d visitor, %(name)s!\n', count, name = param.name}
end}

web.route_base {
    path_prefix = '/blog',
    method = '*',
    route_at = 1,
}:route {'/?', function(req, resp)
    x
end}

web.run()


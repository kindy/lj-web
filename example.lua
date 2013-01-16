
package.path = '/Users/kindy/h/github/kindy/lj-web/src/?.lua;/usr/local/openresty/lualib/?.lua;;'
package.cpath = '/usr/local/openresty/lualib/?.so;;'

local web = require 'lj.web'

web.route {'/', function(req, resp)
    resp.say 'hello, resty web!'
end}

local count = 0
web.route {'/:name', function(req, resp, param)
    count = count + 1
    resp.printf {'hello, the %d visitor, %(name)s!\n', count, name = param.name}
end}

web.run(arg[0])

-- web.add_filter {'access|rewrite', function(req)
-- end}

-- web.route_base {
--     path_prefix = '/blog',
--     method = '*',
--     route_at = 1,
-- }:route {'/?', function(req, resp)
--     x
-- end}


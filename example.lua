
local web = require 'lj.web'

web.route {'/', function(req, resp, param)
    resp:say {'hello, resty web!'}
end}

web.route {'/baidu', function(req, resp, param)
    local http = require "resty.http"
    local hc = http:new()

    local ok, code, headers, status, body  = hc:request { url = "http://www.baidu.com/", }

    resp:say {ok, code, body}
end}

web.route {'/hello/:name', function(req, resp, param)
    resp:printf {'hello, %s!\n', param.name or 'nil'}
    print 'abc end'
end}

web.run()


# Lightweight Web Framework Based On ngx_openresty

## Example

```
local web = require 'lj.web'

web.route {'/hello/:name', function(req, resp, param)
    resp:printf {'hello, %s!\n', param.name}
end}

web.run()
```


## How To Get Start

```
# install ngx_openresty first, see http://openresty.org/#Installation quick step:
$ curl -O http://agentzh.org/misc/nginx/ngx_openresty-1.2.6.1.tar.gz
$ tar zxf ngx_openresty-1.2.6.1.tar.gz
$ cd ngx_openresty-1.2.6.1/
# you should use --with-luajit
# if you install other path than /usr/local/openresty, you should change the path in following step too
$ ./configure --with-luajit --prefix=/usr/local/openresty && make && sudo make install

# the real step to install lj-web
$ curl -O http://kindy.github.com/lj-web/files/lj-web-0.0.1rc1.tar.gz
$ tar zxf lj-web-0.0.1rc.tar.gz
$ cd lj-web-0.0.1rc1/
# please fix the openresty install path to match you system
$ sudo make install OPENRESTY_PREFIX=/usr/local/openresty
# I think you'd like to add the bin to you $PATH

# you can try the ngx_openresty version "python -m SimpleHTTPServer" (ss means "simple server")
$ lj-web ss
# precess ctrl+C to quit, or you want to use different port like this:
$ lj-web ss -l:9002

# you can try the example.lua app in the dist dir (type ctrl+C to quit):
$ lj-web run example.lua
# open a new shell:
$ curl -sv localhost:9090/baidu

# that's it, now.
```


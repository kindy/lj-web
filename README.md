# Lightweight Web Framework Based On ngx_openresty

## Example

```
local web = require 'lj.web'

web.route {'/hello/:name', function(req, resp, param)
    resp:printf {'hello, %s!\n', param.name}
end}

web.run()



## How To Get Start (design)

```
$ wget kindy.github.com/lj-web/files/lj-web-full-v0.0.1.tar.bz2
$ tar jxf lj-web-full-v0.0.1.tar.bz2
$ cd lj-web-full-v0.0.1/
$ ./configure --prefix=/opt/lj-web/ && make && sudo make install

$ export PATH=/opt/lj-web/bin:$PATH
$ mkdir -p ~/lj-web-app/ && cd ~/lj-web-app/
# create app.lua
$ lj-web init
$ lj-web run
```


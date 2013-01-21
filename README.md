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

### install ngx_openresty first

see http://openresty.org/#Installation

quick step:

```
# filesize: 2.9M
$ curl -O http://agentzh.org/misc/nginx/ngx_openresty-1.2.6.1.tar.gz
$ tar zxf ngx_openresty-1.2.6.1.tar.gz
$ cd ngx_openresty-1.2.6.1/
# you should use --with-luajit
# if you install other path than /usr/local/openresty, you should change the path in following step too
$ ./configure --with-luajit --prefix=/usr/local/openresty && make && sudo make install
```

### install lj-web

```
# filesize: 28K
$ curl -O http://kindy.github.com/lj-web/files/lj-web-0.0.1rc1.tar.gz
$ tar zxf lj-web-0.0.1rc.tar.gz
$ cd lj-web-0.0.1rc1/
# please fix the openresty install path to match you system
$ sudo make install OPENRESTY_PREFIX=/usr/local/openresty
# I think you'd like to add the bin to you $PATH
```

### try lj-web

the ngx_openresty version "python -m SimpleHTTPServer" (ss means "simple server")

```
# precess ctrl+C to quit, or you want to use different port like this:
$ lj-web ss
$ lj-web ss -l:9002
```

run the example app

```
# you can try the example.lua app in the dist dir (type ctrl+C to quit):
# port is 9090, and, it can not be modify now, sorry for that.
$ lj-web run example.lua
# open a new shell:
$ curl -v localhost:9090/baidu
$ curl -v localhost:9090/hello/lj-web
```

that's it.


## Copyright and License

This module is licensed under the BSD license.

Copyright (C) 2013, by "Kindy Lin" <kindy61@gmail.com>.

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


## See Also

* the ngx_openresty site: http://openresty.org

## Thanks

* Chaoslawful (github.com/chaoslawful)
* Agentzh (github.com/agentzh)


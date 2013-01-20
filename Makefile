.PHONY: t deps deps-posix deps-ltp clean-deps dist

OR_PREFIX=/usr/local/openresty
PREFIX=`pwd`
V=0.0.1a1

t:
	echo $(PREFIX)
	echo $(OR_PREFIX)

deps: deps-posix deps-ltp

deps-posix: lib/posix_c.so lib/posix.lua

lib/posix_c.so: deps/luaposix/lposix.c
	gcc deps/luaposix/lposix.c -shared -o lib/posix_c.so -fPIC -Wall -L$(OR_PREFIX)/luajit/lib -lluajit-51

lib/posix.lua: deps/luaposix/posix.lua
	cp deps/luaposix/posix.lua lib/posix.lua

deps-ltp:
	rm -rf lib/ltp && cp -r deps/ltp lib/

clean-deps:
	rm -rf lib/ltp lib/posix_c.so lib/posix.lua

dist:
	git tag v$(V) && (git archive --prefix=lj-web-$(V)/ v$(V) | gzip >lj-web-$(V).tar.gz)


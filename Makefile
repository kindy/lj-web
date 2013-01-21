.PHONY: t deps deps-posix deps-ltp clean-deps dist install config all

V=0.0.1a1

OPENRESTY_PREFIX=/usr/local/openresty
LUA_INCLUDE_DIR ?= $(OPENRESTY_PREFIX)/luajit/include/luajit-2.0
LUA_LIB_DIR ?= $(OPENRESTY_PREFIX)/lualib

INSTALL ?= install
CC ?= gcc
CFLAGS ?= -g -O3 -Wall -pedantic
override CFLAGS += -fpic -I$(LUA_INCLUDE_DIR)

## Linux/BSD
#LDFLAGS +=  -shared
## OSX
LDFLAGS +=  -bundle -undefined dynamic_lookup

all: deps config

install: all
	$(INSTALL) -d $(LUA_LIB_DIR)/lj/web
	$(INSTALL) lib/lj/web.lua $(LUA_LIB_DIR)/lj/
	$(INSTALL) lib/lj/web/*.lua $(LUA_LIB_DIR)/lj/web/
	$(INSTALL) lib/*.lua $(LUA_LIB_DIR)/
	$(INSTALL) lib/*.so $(LUA_LIB_DIR)/

	$(INSTALL) -d $(OPENRESTY_PREFIX)/bin

	$(INSTALL) .build/lj-web $(OPENRESTY_PREFIX)/bin/
	$(INSTALL) .build/config.lua $(LUA_LIB_DIR)/lj/web/

	echo 'Install Finish...'
	echo 'Please add "'$(OPENRESTY_PREFIX)/bin'" to your $$PATH'
	echo 'You can use [ echo "export PATH=$(OPENRESTY_PREFIX)/bin:$$PATH" >>~/.bashrc ] to do this.'
	echo 'Your $$PATH is:'
	echo $$PATH | tr ':' '\n' | sort | sed 's/^/  /' | sed 's:^  $(OPENRESTY_PREFIX)/bin$$:* $(OPENRESTY_PREFIX)/bin:'

deps: deps-posix deps-ltp

deps-posix: lib/posix_c.so lib/posix.lua

lib/posix_c.so: deps/luaposix/lposix.o
	$(CC) $(LDFLAGS) -o $@ $^

lib/posix.lua: deps/luaposix/posix.lua
	cp deps/luaposix/posix.lua lib/posix.lua

deps-ltp:
	rm -rf lib/ltp && cp -r deps/ltp lib/

clean-deps:
	rm -rf lib/ltp lib/posix_c.so lib/posix.lua

dist:
	git tag v$(V) && (git archive --prefix=lj-web-$(V)/ v$(V) | gzip >lj-web-$(V).tar.gz)

config:
	rm -rf .build && mkdir -p .build
	cat bin/lj-web.tpl | sed 's:__luajit_bin__:$(OPENRESTY_PREFIX)/luajit/bin/luajit:g' | sed 's:__lualib_dir__:$(LUA_LIB_DIR)/:g'  >.build/lj-web
	sed 's:__version__:$(V):g' lib/lj/web/config.lua >.build/config.lua


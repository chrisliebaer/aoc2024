SHELL := /bin/bash
PROJECT_ROOT = $(shell pwd)
LUAJIT = luajit
LUASRC = $(shell find . -name '*.lua')
LUACFILES = $(LUASRC:.lua=.luac)
LUA_PATH := $(PROJECT_ROOT)/src/?.luac;$(PROJECT_ROOT)/src/?/init.luac;$(LUA_PATH)

.PHONY: precompile
precompile: $(LUACFILES)

.PHONY: clean
clean:
	rm -f $(LUACFILES)
	
%.luac: %.lua
	$(LUAJIT) -b $< $@

DAYS = $(shell seq 1 24)
DAY_TARGETS = $(foreach DAY,$(DAYS),day$(DAY))
.PHONY: $(DAY_TARGETS)
#$(DAY_TARGETS): export LUA_PATH := $(LUA_PATH) - does not work, gets sent to compiler which fails to find it's own modules
$(DAY_TARGETS): $(LUACFILES)
	time $(LUAJIT) -e "package.path = '$(LUA_PATH)' .. package.path" src/days/day$(@:day%=%).luac

#
#   esp-vxworks-default.mk -- Makefile to build Embedthis ESP for vxworks
#

NAME                  := esp
VERSION               := 5.4.1
PROFILE               ?= default
ARCH                  ?= $(shell echo $(WIND_HOST_TYPE) | sed 's/-.*$(ME_ROOT_PREFIX)/')
CPU                   ?= $(subst X86,PENTIUM,$(shell echo $(ARCH) | tr a-z A-Z))
OS                    ?= vxworks
CC                    ?= cc$(subst x86,pentium,$(ARCH))
LD                    ?= ld
CONFIG                ?= $(OS)-$(ARCH)-$(PROFILE)
BUILD                 ?= build/$(CONFIG)
LBIN                  ?= $(BUILD)/bin
PATH                  := $(LBIN):$(PATH)

ME_COM_COMPILER       ?= 1
ME_COM_EST            ?= 0
ME_COM_HTTP           ?= 1
ME_COM_LIB            ?= 1
ME_COM_LINK           ?= 1
ME_COM_MATRIXSSL      ?= 0
ME_COM_MBEDTLS        ?= 0
ME_COM_MDB            ?= 1
ME_COM_MPR            ?= 1
ME_COM_NANOSSL        ?= 0
ME_COM_OPENSSL        ?= 1
ME_COM_OSDEP          ?= 1
ME_COM_PCRE           ?= 1
ME_COM_SQLITE         ?= 1
ME_COM_SSL            ?= 1
ME_COM_VXWORKS        ?= 1
ME_COM_WINSDK         ?= 1

ME_COM_OPENSSL_PATH   ?= "/usr/lib"

ifeq ($(ME_COM_EST),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_LIB),1)
    ME_COM_COMPILER := 1
endif
ifeq ($(ME_COM_LINK),1)
    ME_COM_COMPILER := 1
endif
ifeq ($(ME_COM_OPENSSL),1)
    ME_COM_SSL := 1
endif

export WIND_HOME      ?= $(WIND_BASE)/..
export PATH           := $(WIND_GNU_PATH)/$(WIND_HOST_TYPE)/bin:$(PATH)

CFLAGS                += -fno-builtin -fno-defer-pop -fvolatile -w
DFLAGS                += -DVXWORKS -DRW_MULTI_THREAD -D_GNU_TOOL -DCPU=PENTIUM $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_COM_COMPILER=$(ME_COM_COMPILER) -DME_COM_EST=$(ME_COM_EST) -DME_COM_HTTP=$(ME_COM_HTTP) -DME_COM_LIB=$(ME_COM_LIB) -DME_COM_LINK=$(ME_COM_LINK) -DME_COM_MATRIXSSL=$(ME_COM_MATRIXSSL) -DME_COM_MBEDTLS=$(ME_COM_MBEDTLS) -DME_COM_MDB=$(ME_COM_MDB) -DME_COM_MPR=$(ME_COM_MPR) -DME_COM_NANOSSL=$(ME_COM_NANOSSL) -DME_COM_OPENSSL=$(ME_COM_OPENSSL) -DME_COM_OSDEP=$(ME_COM_OSDEP) -DME_COM_PCRE=$(ME_COM_PCRE) -DME_COM_SQLITE=$(ME_COM_SQLITE) -DME_COM_SSL=$(ME_COM_SSL) -DME_COM_VXWORKS=$(ME_COM_VXWORKS) -DME_COM_WINSDK=$(ME_COM_WINSDK) 
IFLAGS                += "-I$(BUILD)/inc -I$(WIND_BASE)/target/h -I$(WIND_BASE)/target/h/wrn/coreip"
LDFLAGS               += '-Wl,-r'
LIBPATHS              += -L$(BUILD)/bin
LIBS                  += -lgcc

DEBUG                 ?= debug
CFLAGS-debug          ?= -g
DFLAGS-debug          ?= -DME_DEBUG
LDFLAGS-debug         ?= -g
DFLAGS-release        ?= 
CFLAGS-release        ?= -O2
LDFLAGS-release       ?= 
CFLAGS                += $(CFLAGS-$(DEBUG))
DFLAGS                += $(DFLAGS-$(DEBUG))
LDFLAGS               += $(LDFLAGS-$(DEBUG))

ME_ROOT_PREFIX        ?= deploy
ME_BASE_PREFIX        ?= $(ME_ROOT_PREFIX)
ME_DATA_PREFIX        ?= $(ME_VAPP_PREFIX)
ME_STATE_PREFIX       ?= $(ME_VAPP_PREFIX)
ME_BIN_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_INC_PREFIX         ?= $(ME_VAPP_PREFIX)/inc
ME_LIB_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_MAN_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_SBIN_PREFIX        ?= $(ME_VAPP_PREFIX)
ME_ETC_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_WEB_PREFIX         ?= $(ME_VAPP_PREFIX)/web
ME_LOG_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_SPOOL_PREFIX       ?= $(ME_VAPP_PREFIX)
ME_CACHE_PREFIX       ?= $(ME_VAPP_PREFIX)
ME_APP_PREFIX         ?= $(ME_BASE_PREFIX)
ME_VAPP_PREFIX        ?= $(ME_APP_PREFIX)
ME_SRC_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/src/$(NAME)-$(VERSION)


TARGETS               += $(BUILD)/bin/esp-compile.json
TARGETS               += $(BUILD)/bin/esp.out
ifeq ($(ME_COM_SSL),1)
    TARGETS           += $(BUILD)/bin
endif
TARGETS               += $(BUILD)/bin/espman.out

unexport CDPATH

ifndef SHOW
.SILENT:
endif

all build compile: prep $(TARGETS)

.PHONY: prep

prep:
	@echo "      [Info] Use "make SHOW=1" to trace executed commands."
	@if [ "$(CONFIG)" = "" ] ; then echo WARNING: CONFIG not set ; exit 255 ; fi
	@if [ "$(ME_APP_PREFIX)" = "" ] ; then echo WARNING: ME_APP_PREFIX not set ; exit 255 ; fi
	@if [ "$(WIND_BASE)" = "" ] ; then echo WARNING: WIND_BASE not set. Run wrenv.sh. ; exit 255 ; fi
	@if [ "$(WIND_HOST_TYPE)" = "" ] ; then echo WARNING: WIND_HOST_TYPE not set. Run wrenv.sh. ; exit 255 ; fi
	@if [ "$(WIND_GNU_PATH)" = "" ] ; then echo WARNING: WIND_GNU_PATH not set. Run wrenv.sh. ; exit 255 ; fi
	@[ ! -x $(BUILD)/bin ] && mkdir -p $(BUILD)/bin; true
	@[ ! -x $(BUILD)/inc ] && mkdir -p $(BUILD)/inc; true
	@[ ! -x $(BUILD)/obj ] && mkdir -p $(BUILD)/obj; true
	@[ ! -f $(BUILD)/inc/me.h ] && cp projects/esp-vxworks-default-me.h $(BUILD)/inc/me.h ; true
	@if ! diff $(BUILD)/inc/me.h projects/esp-vxworks-default-me.h >/dev/null ; then\
		cp projects/esp-vxworks-default-me.h $(BUILD)/inc/me.h  ; \
	fi; true
	@if [ -f "$(BUILD)/.makeflags" ] ; then \
		if [ "$(MAKEFLAGS)" != "`cat $(BUILD)/.makeflags`" ] ; then \
			echo "   [Warning] Make flags have changed since the last build" ; \
			echo "   [Warning] Previous build command: "`cat $(BUILD)/.makeflags`"" ; \
		fi ; \
	fi
	@echo "$(MAKEFLAGS)" >$(BUILD)/.makeflags

clean:
	rm -f "$(BUILD)/obj/edi.o"
	rm -f "$(BUILD)/obj/esp.o"
	rm -f "$(BUILD)/obj/espAbbrev.o"
	rm -f "$(BUILD)/obj/espConfig.o"
	rm -f "$(BUILD)/obj/espFramework.o"
	rm -f "$(BUILD)/obj/espHtml.o"
	rm -f "$(BUILD)/obj/espRequest.o"
	rm -f "$(BUILD)/obj/espTemplate.o"
	rm -f "$(BUILD)/obj/est.o"
	rm -f "$(BUILD)/obj/estLib.o"
	rm -f "$(BUILD)/obj/http.o"
	rm -f "$(BUILD)/obj/httpLib.o"
	rm -f "$(BUILD)/obj/mdb.o"
	rm -f "$(BUILD)/obj/mprLib.o"
	rm -f "$(BUILD)/obj/openssl.o"
	rm -f "$(BUILD)/obj/pcre.o"
	rm -f "$(BUILD)/obj/removeFiles.o"
	rm -f "$(BUILD)/obj/sdb.o"
	rm -f "$(BUILD)/obj/sqlite.o"
	rm -f "$(BUILD)/obj/sqlite3.o"
	rm -f "$(BUILD)/obj/watchdog.o"
	rm -f "$(BUILD)/bin/esp-compile.json"
	rm -f "$(BUILD)/bin/esp.out"
	rm -f "$(BUILD)/bin"
	rm -f "$(BUILD)/bin/libesp.out"
	rm -f "$(BUILD)/bin/libhttp.out"
	rm -f "$(BUILD)/bin/libmpr.out"
	rm -f "$(BUILD)/bin/libpcre.out"
	rm -f "$(BUILD)/bin/libsql.out"
	rm -f "$(BUILD)/bin/libmpr-openssl.a"
	rm -f "$(BUILD)/bin/espman.out"

clobber: clean
	rm -fr ./$(BUILD)

#
#   init
#

init: $(DEPS_1)
	if [ ! -d /usr/include/openssl ] ; then echo ; \
	echo Install libssl-dev to get /usr/include/openssl ; \
	exit 255 ; \
	fi

#
#   edi.h
#
DEPS_2 += src/edi.h

$(BUILD)/inc/edi.h: $(DEPS_2)
	@echo '      [Copy] $(BUILD)/inc/edi.h'
	mkdir -p "$(BUILD)/inc"
	cp src/edi.h $(BUILD)/inc/edi.h

#
#   esp.h
#
DEPS_3 += src/esp.h

$(BUILD)/inc/esp.h: $(DEPS_3)
	@echo '      [Copy] $(BUILD)/inc/esp.h'
	mkdir -p "$(BUILD)/inc"
	cp src/esp.h $(BUILD)/inc/esp.h

#
#   est.h
#
DEPS_4 += src/est/est.h

$(BUILD)/inc/est.h: $(DEPS_4)
	@echo '      [Copy] $(BUILD)/inc/est.h'
	mkdir -p "$(BUILD)/inc"
	cp src/est/est.h $(BUILD)/inc/est.h

#
#   me.h
#

$(BUILD)/inc/me.h: $(DEPS_5)

#
#   osdep.h
#
DEPS_6 += src/osdep/osdep.h
DEPS_6 += $(BUILD)/inc/me.h

$(BUILD)/inc/osdep.h: $(DEPS_6)
	@echo '      [Copy] $(BUILD)/inc/osdep.h'
	mkdir -p "$(BUILD)/inc"
	cp src/osdep/osdep.h $(BUILD)/inc/osdep.h

#
#   mpr.h
#
DEPS_7 += src/mpr/mpr.h
DEPS_7 += $(BUILD)/inc/me.h
DEPS_7 += $(BUILD)/inc/osdep.h

$(BUILD)/inc/mpr.h: $(DEPS_7)
	@echo '      [Copy] $(BUILD)/inc/mpr.h'
	mkdir -p "$(BUILD)/inc"
	cp src/mpr/mpr.h $(BUILD)/inc/mpr.h

#
#   http.h
#
DEPS_8 += src/http/http.h
DEPS_8 += $(BUILD)/inc/mpr.h

$(BUILD)/inc/http.h: $(DEPS_8)
	@echo '      [Copy] $(BUILD)/inc/http.h'
	mkdir -p "$(BUILD)/inc"
	cp src/http/http.h $(BUILD)/inc/http.h

#
#   mdb.h
#
DEPS_9 += src/mdb.h

$(BUILD)/inc/mdb.h: $(DEPS_9)
	@echo '      [Copy] $(BUILD)/inc/mdb.h'
	mkdir -p "$(BUILD)/inc"
	cp src/mdb.h $(BUILD)/inc/mdb.h

#
#   pcre.h
#
DEPS_10 += src/pcre/pcre.h

$(BUILD)/inc/pcre.h: $(DEPS_10)
	@echo '      [Copy] $(BUILD)/inc/pcre.h'
	mkdir -p "$(BUILD)/inc"
	cp src/pcre/pcre.h $(BUILD)/inc/pcre.h

#
#   sqlite3.h
#
DEPS_11 += src/sqlite/sqlite3.h

$(BUILD)/inc/sqlite3.h: $(DEPS_11)
	@echo '      [Copy] $(BUILD)/inc/sqlite3.h'
	mkdir -p "$(BUILD)/inc"
	cp src/sqlite/sqlite3.h $(BUILD)/inc/sqlite3.h

#
#   edi.h
#

src/edi.h: $(DEPS_12)

#
#   edi.o
#
DEPS_13 += src/edi.h
DEPS_13 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/edi.o: \
    src/edi.c $(DEPS_13)
	@echo '   [Compile] $(BUILD)/obj/edi.o'
	$(CC) -c -o $(BUILD)/obj/edi.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/edi.c

#
#   esp.h
#

src/esp.h: $(DEPS_14)

#
#   esp.o
#
DEPS_15 += src/esp.h

$(BUILD)/obj/esp.o: \
    src/esp.c $(DEPS_15)
	@echo '   [Compile] $(BUILD)/obj/esp.o'
	$(CC) -c -o $(BUILD)/obj/esp.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/esp.c

#
#   espAbbrev.o
#
DEPS_16 += src/esp.h

$(BUILD)/obj/espAbbrev.o: \
    src/espAbbrev.c $(DEPS_16)
	@echo '   [Compile] $(BUILD)/obj/espAbbrev.o'
	$(CC) -c -o $(BUILD)/obj/espAbbrev.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/espAbbrev.c

#
#   espConfig.o
#
DEPS_17 += src/esp.h

$(BUILD)/obj/espConfig.o: \
    src/espConfig.c $(DEPS_17)
	@echo '   [Compile] $(BUILD)/obj/espConfig.o'
	$(CC) -c -o $(BUILD)/obj/espConfig.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/espConfig.c

#
#   espFramework.o
#
DEPS_18 += src/esp.h

$(BUILD)/obj/espFramework.o: \
    src/espFramework.c $(DEPS_18)
	@echo '   [Compile] $(BUILD)/obj/espFramework.o'
	$(CC) -c -o $(BUILD)/obj/espFramework.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/espFramework.c

#
#   espHtml.o
#
DEPS_19 += src/esp.h
DEPS_19 += src/edi.h

$(BUILD)/obj/espHtml.o: \
    src/espHtml.c $(DEPS_19)
	@echo '   [Compile] $(BUILD)/obj/espHtml.o'
	$(CC) -c -o $(BUILD)/obj/espHtml.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/espHtml.c

#
#   espRequest.o
#
DEPS_20 += src/esp.h

$(BUILD)/obj/espRequest.o: \
    src/espRequest.c $(DEPS_20)
	@echo '   [Compile] $(BUILD)/obj/espRequest.o'
	$(CC) -c -o $(BUILD)/obj/espRequest.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/espRequest.c

#
#   espTemplate.o
#
DEPS_21 += src/esp.h

$(BUILD)/obj/espTemplate.o: \
    src/espTemplate.c $(DEPS_21)
	@echo '   [Compile] $(BUILD)/obj/espTemplate.o'
	$(CC) -c -o $(BUILD)/obj/espTemplate.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/espTemplate.c

#
#   est.o
#
DEPS_22 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/est.o: \
    src/mpr-est/est.c $(DEPS_22)
	@echo '   [Compile] $(BUILD)/obj/est.o'
	$(CC) -c -o $(BUILD)/obj/est.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/mpr-est/est.c

#
#   est.h
#

src/est/est.h: $(DEPS_23)

#
#   estLib.o
#
DEPS_24 += src/est/est.h

$(BUILD)/obj/estLib.o: \
    src/est/estLib.c $(DEPS_24)
	@echo '   [Compile] $(BUILD)/obj/estLib.o'
	$(CC) -c -o $(BUILD)/obj/estLib.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/est/estLib.c

#
#   http.h
#

src/http/http.h: $(DEPS_25)

#
#   http.o
#
DEPS_26 += src/http/http.h

$(BUILD)/obj/http.o: \
    src/http/http.c $(DEPS_26)
	@echo '   [Compile] $(BUILD)/obj/http.o'
	$(CC) -c -o $(BUILD)/obj/http.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/http/http.c

#
#   httpLib.o
#
DEPS_27 += src/http/http.h
DEPS_27 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/httpLib.o: \
    src/http/httpLib.c $(DEPS_27)
	@echo '   [Compile] $(BUILD)/obj/httpLib.o'
	$(CC) -c -o $(BUILD)/obj/httpLib.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/http/httpLib.c

#
#   mdb.h
#

src/mdb.h: $(DEPS_28)

#
#   mdb.o
#
DEPS_29 += $(BUILD)/inc/http.h
DEPS_29 += src/edi.h
DEPS_29 += src/mdb.h
DEPS_29 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/mdb.o: \
    src/mdb.c $(DEPS_29)
	@echo '   [Compile] $(BUILD)/obj/mdb.o'
	$(CC) -c -o $(BUILD)/obj/mdb.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/mdb.c

#
#   mpr.h
#

src/mpr/mpr.h: $(DEPS_30)

#
#   mprLib.o
#
DEPS_31 += src/mpr/mpr.h

$(BUILD)/obj/mprLib.o: \
    src/mpr/mprLib.c $(DEPS_31)
	@echo '   [Compile] $(BUILD)/obj/mprLib.o'
	$(CC) -c -o $(BUILD)/obj/mprLib.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/mpr/mprLib.c

#
#   openssl.o
#
DEPS_32 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/openssl.o: \
    src/mpr-openssl/openssl.c $(DEPS_32)
	@echo '   [Compile] $(BUILD)/obj/openssl.o'
	$(CC) -c -o $(BUILD)/obj/openssl.o $(CFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(ME_COM_OPENSSL_PATH)/include" src/mpr-openssl/openssl.c

#
#   pcre.h
#

src/pcre/pcre.h: $(DEPS_33)

#
#   pcre.o
#
DEPS_34 += $(BUILD)/inc/me.h
DEPS_34 += src/pcre/pcre.h

$(BUILD)/obj/pcre.o: \
    src/pcre/pcre.c $(DEPS_34)
	@echo '   [Compile] $(BUILD)/obj/pcre.o'
	$(CC) -c -o $(BUILD)/obj/pcre.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/pcre/pcre.c

#
#   removeFiles.o
#

$(BUILD)/obj/removeFiles.o: \
    package/windows/removeFiles.c $(DEPS_35)
	@echo '   [Compile] $(BUILD)/obj/removeFiles.o'
	$(CC) -c -o $(BUILD)/obj/removeFiles.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" package/windows/removeFiles.c

#
#   sdb.o
#
DEPS_36 += $(BUILD)/inc/http.h
DEPS_36 += src/edi.h

$(BUILD)/obj/sdb.o: \
    src/sdb.c $(DEPS_36)
	@echo '   [Compile] $(BUILD)/obj/sdb.o'
	$(CC) -c -o $(BUILD)/obj/sdb.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/sdb.c

#
#   sqlite3.h
#

src/sqlite/sqlite3.h: $(DEPS_37)

#
#   sqlite.o
#
DEPS_38 += $(BUILD)/inc/me.h
DEPS_38 += src/sqlite/sqlite3.h

$(BUILD)/obj/sqlite.o: \
    src/sqlite/sqlite.c $(DEPS_38)
	@echo '   [Compile] $(BUILD)/obj/sqlite.o'
	$(CC) -c -o $(BUILD)/obj/sqlite.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/sqlite/sqlite.c

#
#   sqlite3.o
#
DEPS_39 += $(BUILD)/inc/me.h
DEPS_39 += src/sqlite/sqlite3.h

$(BUILD)/obj/sqlite3.o: \
    src/sqlite/sqlite3.c $(DEPS_39)
	@echo '   [Compile] $(BUILD)/obj/sqlite3.o'
	$(CC) -c -o $(BUILD)/obj/sqlite3.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/sqlite/sqlite3.c

#
#   watchdog.o
#
DEPS_40 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/watchdog.o: \
    src/watchdog/watchdog.c $(DEPS_40)
	@echo '   [Compile] $(BUILD)/obj/watchdog.o'
	$(CC) -c -o $(BUILD)/obj/watchdog.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/watchdog/watchdog.c

#
#   esp-compile.json
#
DEPS_41 += src/esp-compile.json

$(BUILD)/bin/esp-compile.json: $(DEPS_41)
	@echo '      [Copy] $(BUILD)/bin/esp-compile.json'
	mkdir -p "$(BUILD)/bin"
	cp src/esp-compile.json $(BUILD)/bin/esp-compile.json

ifeq ($(ME_COM_SQLITE),1)
#
#   libsql
#
DEPS_42 += $(BUILD)/inc/sqlite3.h
DEPS_42 += $(BUILD)/obj/sqlite3.o

$(BUILD)/bin/libsql.out: $(DEPS_42)
	@echo '      [Link] $(BUILD)/bin/libsql.out'
	$(CC) -r -o $(BUILD)/bin/libsql.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/sqlite3.o" $(LIBS) 
endif

ifeq ($(ME_COM_SSL),1)
#
#   openssl
#
DEPS_43 += $(BUILD)/obj/openssl.o

$(BUILD)/bin/libmpr-openssl.a: $(DEPS_43)
	@echo '      [Link] $(BUILD)/bin/libmpr-openssl.a'
	ar -cr $(BUILD)/bin/libmpr-openssl.a "$(BUILD)/obj/openssl.o"
endif

ifeq ($(ME_COM_EST),1)
#
#   libest
#
DEPS_44 += $(BUILD)/inc/osdep.h
DEPS_44 += $(BUILD)/inc/est.h
DEPS_44 += $(BUILD)/obj/estLib.o

$(BUILD)/bin/libest.a: $(DEPS_44)
	@echo '      [Link] $(BUILD)/bin/libest.a'
	ar -cr $(BUILD)/bin/libest.a "$(BUILD)/obj/estLib.o"
endif

ifeq ($(ME_COM_SSL),1)
#
#   est
#
ifeq ($(ME_COM_EST),1)
    DEPS_45 += $(BUILD)/bin/libest.a
endif
DEPS_45 += $(BUILD)/obj/est.o

$(BUILD)/bin/libmpr-estssl.a: $(DEPS_45)
	@echo '      [Link] $(BUILD)/bin/libmpr-estssl.a'
	ar -cr $(BUILD)/bin/libmpr-estssl.a "$(BUILD)/obj/est.o"
endif

#
#   libmpr
#
DEPS_46 += $(BUILD)/inc/osdep.h
ifeq ($(ME_COM_SSL),1)
ifeq ($(ME_COM_OPENSSL),1)
    DEPS_46 += $(BUILD)/bin/libmpr-openssl.a
endif
endif
ifeq ($(ME_COM_SSL),1)
ifeq ($(ME_COM_EST),1)
    DEPS_46 += $(BUILD)/bin/libmpr-estssl.a
endif
endif
DEPS_46 += $(BUILD)/inc/mpr.h
DEPS_46 += $(BUILD)/obj/mprLib.o

ifeq ($(ME_COM_OPENSSL),1)
    LIBS_46 += -lmpr-openssl
    LIBPATHS_46 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
ifeq ($(ME_COM_SSL),1)
    LIBS_46 += -lssl
    LIBPATHS_46 += -L"$(ME_COM_OPENSSL_PATH)"
endif
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_46 += -lcrypto
    LIBPATHS_46 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_46 += -lmpr-estssl
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_46 += -lmpr-openssl
    LIBPATHS_46 += -L"$(ME_COM_OPENSSL_PATH)"
endif

$(BUILD)/bin/libmpr.out: $(DEPS_46)
	@echo '      [Link] $(BUILD)/bin/libmpr.out'
	$(CC) -r -o $(BUILD)/bin/libmpr.out $(LDFLAGS) $(LIBPATHS)  "$(BUILD)/obj/mprLib.o" $(LIBPATHS_46) $(LIBS_46) $(LIBS_46) $(LIBS) 

ifeq ($(ME_COM_PCRE),1)
#
#   libpcre
#
DEPS_47 += $(BUILD)/inc/pcre.h
DEPS_47 += $(BUILD)/obj/pcre.o

$(BUILD)/bin/libpcre.out: $(DEPS_47)
	@echo '      [Link] $(BUILD)/bin/libpcre.out'
	$(CC) -r -o $(BUILD)/bin/libpcre.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/pcre.o" $(LIBS) 
endif

ifeq ($(ME_COM_HTTP),1)
#
#   libhttp
#
DEPS_48 += $(BUILD)/bin/libmpr.out
ifeq ($(ME_COM_PCRE),1)
    DEPS_48 += $(BUILD)/bin/libpcre.out
endif
DEPS_48 += $(BUILD)/inc/http.h
DEPS_48 += $(BUILD)/obj/httpLib.o

ifeq ($(ME_COM_OPENSSL),1)
    LIBS_48 += -lmpr-openssl
    LIBPATHS_48 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
ifeq ($(ME_COM_SSL),1)
    LIBS_48 += -lssl
    LIBPATHS_48 += -L"$(ME_COM_OPENSSL_PATH)"
endif
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_48 += -lcrypto
    LIBPATHS_48 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_48 += -lmpr-estssl
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_48 += -lmpr-openssl
    LIBPATHS_48 += -L"$(ME_COM_OPENSSL_PATH)"
endif

$(BUILD)/bin/libhttp.out: $(DEPS_48)
	@echo '      [Link] $(BUILD)/bin/libhttp.out'
	$(CC) -r -o $(BUILD)/bin/libhttp.out $(LDFLAGS) $(LIBPATHS)  "$(BUILD)/obj/httpLib.o" $(LIBPATHS_48) $(LIBS_48) $(LIBS_48) $(LIBS) 
endif

#
#   libesp
#
ifeq ($(ME_COM_SQLITE),1)
    DEPS_49 += $(BUILD)/bin/libsql.out
endif
ifeq ($(ME_COM_HTTP),1)
    DEPS_49 += $(BUILD)/bin/libhttp.out
endif
DEPS_49 += $(BUILD)/inc/edi.h
DEPS_49 += $(BUILD)/inc/esp.h
DEPS_49 += $(BUILD)/inc/mdb.h
DEPS_49 += $(BUILD)/obj/edi.o
DEPS_49 += $(BUILD)/obj/espAbbrev.o
DEPS_49 += $(BUILD)/obj/espConfig.o
DEPS_49 += $(BUILD)/obj/espFramework.o
DEPS_49 += $(BUILD)/obj/espHtml.o
DEPS_49 += $(BUILD)/obj/espRequest.o
DEPS_49 += $(BUILD)/obj/espTemplate.o
DEPS_49 += $(BUILD)/obj/mdb.o
DEPS_49 += $(BUILD)/obj/sdb.o

ifeq ($(ME_COM_OPENSSL),1)
    LIBS_49 += -lmpr-openssl
    LIBPATHS_49 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
ifeq ($(ME_COM_SSL),1)
    LIBS_49 += -lssl
    LIBPATHS_49 += -L"$(ME_COM_OPENSSL_PATH)"
endif
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_49 += -lcrypto
    LIBPATHS_49 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_49 += -lmpr-estssl
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_49 += -lmpr-openssl
    LIBPATHS_49 += -L"$(ME_COM_OPENSSL_PATH)"
endif

$(BUILD)/bin/libesp.out: $(DEPS_49)
	@echo '      [Link] $(BUILD)/bin/libesp.out'
	$(CC) -r -o $(BUILD)/bin/libesp.out $(LDFLAGS) $(LIBPATHS)  "$(BUILD)/obj/edi.o" "$(BUILD)/obj/espAbbrev.o" "$(BUILD)/obj/espConfig.o" "$(BUILD)/obj/espFramework.o" "$(BUILD)/obj/espHtml.o" "$(BUILD)/obj/espRequest.o" "$(BUILD)/obj/espTemplate.o" "$(BUILD)/obj/mdb.o" "$(BUILD)/obj/sdb.o" $(LIBPATHS_49) $(LIBS_49) $(LIBS_49) $(LIBS) 

#
#   espcmd
#
ifeq ($(ME_COM_SQLITE),1)
    DEPS_50 += $(BUILD)/bin/libsql.out
endif
DEPS_50 += $(BUILD)/bin/libesp.out
DEPS_50 += $(BUILD)/obj/esp.o

ifeq ($(ME_COM_OPENSSL),1)
    LIBS_50 += -lmpr-openssl
    LIBPATHS_50 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
ifeq ($(ME_COM_SSL),1)
    LIBS_50 += -lssl
    LIBPATHS_50 += -L"$(ME_COM_OPENSSL_PATH)"
endif
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_50 += -lcrypto
    LIBPATHS_50 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_50 += -lmpr-estssl
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_50 += -lmpr-openssl
    LIBPATHS_50 += -L"$(ME_COM_OPENSSL_PATH)"
endif

$(BUILD)/bin/esp.out: $(DEPS_50)
	@echo '      [Link] $(BUILD)/bin/esp.out'
	$(CC) -o $(BUILD)/bin/esp.out $(LDFLAGS) $(LIBPATHS)  "$(BUILD)/obj/esp.o" $(LIBPATHS_50) $(LIBS_50) $(LIBS_50) $(LIBS) -Wl,-r 

ifeq ($(ME_COM_HTTP),1)
#
#   httpcmd
#
DEPS_51 += $(BUILD)/bin/libhttp.out
DEPS_51 += $(BUILD)/obj/http.o

ifeq ($(ME_COM_OPENSSL),1)
    LIBS_51 += -lmpr-openssl
    LIBPATHS_51 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
ifeq ($(ME_COM_SSL),1)
    LIBS_51 += -lssl
    LIBPATHS_51 += -L"$(ME_COM_OPENSSL_PATH)"
endif
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_51 += -lcrypto
    LIBPATHS_51 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_51 += -lmpr-estssl
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_51 += -lmpr-openssl
    LIBPATHS_51 += -L"$(ME_COM_OPENSSL_PATH)"
endif

$(BUILD)/bin/http.out: $(DEPS_51)
	@echo '      [Link] $(BUILD)/bin/http.out'
	$(CC) -o $(BUILD)/bin/http.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/http.o" $(LIBPATHS_51) $(LIBS_51) $(LIBS_51) $(LIBS) -Wl,-r 
endif

#
#   import-certs
#

import-certs: $(DEPS_52)

ifeq ($(ME_COM_SSL),1)
#
#   install-certs
#
DEPS_53 += src/certs/samples/ca.crt
DEPS_53 += src/certs/samples/ca.key
DEPS_53 += src/certs/samples/dh.pem
DEPS_53 += src/certs/samples/ec.crt
DEPS_53 += src/certs/samples/ec.key
DEPS_53 += src/certs/samples/roots.crt
DEPS_53 += src/certs/samples/self.crt
DEPS_53 += src/certs/samples/self.key
DEPS_53 += src/certs/samples/test.crt
DEPS_53 += src/certs/samples/test.key

$(BUILD)/bin: $(DEPS_53)
	@echo '      [Copy] $(BUILD)/bin'
	mkdir -p "$(BUILD)/bin"
	cp src/certs/samples/ca.crt $(BUILD)/bin/ca.crt
	cp src/certs/samples/ca.key $(BUILD)/bin/ca.key
	cp src/certs/samples/dh.pem $(BUILD)/bin/dh.pem
	cp src/certs/samples/ec.crt $(BUILD)/bin/ec.crt
	cp src/certs/samples/ec.key $(BUILD)/bin/ec.key
	cp src/certs/samples/roots.crt $(BUILD)/bin/roots.crt
	cp src/certs/samples/self.crt $(BUILD)/bin/self.crt
	cp src/certs/samples/self.key $(BUILD)/bin/self.key
	cp src/certs/samples/test.crt $(BUILD)/bin/test.crt
	cp src/certs/samples/test.key $(BUILD)/bin/test.key
endif

#
#   watchdog
#
DEPS_54 += $(BUILD)/bin/libmpr.out
DEPS_54 += $(BUILD)/obj/watchdog.o

ifeq ($(ME_COM_OPENSSL),1)
    LIBS_54 += -lmpr-openssl
    LIBPATHS_54 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
ifeq ($(ME_COM_SSL),1)
    LIBS_54 += -lssl
    LIBPATHS_54 += -L"$(ME_COM_OPENSSL_PATH)"
endif
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_54 += -lcrypto
    LIBPATHS_54 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_54 += -lmpr-estssl
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_54 += -lmpr-openssl
    LIBPATHS_54 += -L"$(ME_COM_OPENSSL_PATH)"
endif

$(BUILD)/bin/espman.out: $(DEPS_54)
	@echo '      [Link] $(BUILD)/bin/espman.out'
	$(CC) -o $(BUILD)/bin/espman.out $(LDFLAGS) $(LIBPATHS)  "$(BUILD)/obj/watchdog.o" $(LIBPATHS_54) $(LIBS_54) $(LIBS_54) $(LIBS) -Wl,-r 

#
#   installPrep
#

installPrep: $(DEPS_55)
	if [ "`id -u`" != 0 ] ; \
	then echo "Must run as root. Rerun with "sudo"" ; \
	exit 255 ; \
	fi

#
#   stop
#

stop: $(DEPS_56)

#
#   installBinary
#

installBinary: $(DEPS_57)

#
#   start
#

start: $(DEPS_58)

#
#   install
#
DEPS_59 += installPrep
DEPS_59 += stop
DEPS_59 += installBinary
DEPS_59 += start

install: $(DEPS_59)

#
#   uninstall
#
DEPS_60 += stop

uninstall: $(DEPS_60)

#
#   version
#

version: $(DEPS_61)
	echo $(VERSION)


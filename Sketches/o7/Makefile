#
# Simple Makefile for compiling Oberon-7 programs using OBNC.
# Set the list of executables in PROG_NAMES. The rest can probably
# stay as is if all modules are in the same directory. 
#
VERSION = $(shell if [ -f VERSION ]; then cat VERSION; else echo "0.0.0"; fi)
PROG_NAMES = o7
BUILD_NAME = Artemis-Compiler
TEST_NAMES = ORSTest ORBTest ORGTest ORPTest ConfigTest
MODULES = $(shell ls *.Mod)
DOCS= README.md LICENSE INSTALL.txt
OC = env OBNC_IMPORT_PATH=".:../:../np" obnc

# Defaults
OS = $(shell uname)
ARCH = $(shell uname -m)
PREFIX = $(OBNC_PREFIX)
LIBDIR = $(OBNC_LIBDIR)
BINDIR = $(OBNC_PREFIX)/bin

# Overrides
oc =
ifneq ($(oc), )
  OC =  $(OC)
endif

os =
ifneq ($(os), )
  OS = $(os)
endif

arch =
ifneq ($(arch), )
  ARCH = $(arch)
endif

prefix =
ifneq ($(prefix), )
  PREFIX = $(prefix)
  LIBDIR = $(prefix)/lib
  BINDIR = $(prefix)/bin
endif

libdir =
ifneq ($(libdir), )
  LIBDIR = $(prefix)/lib
endif

bindir =
ifneq ($(bindir), )
  BINDIR = $(bindir)
endif


all: cfg.Mod $(PROG_NAMES)

cfg.Mod:
	sh mkcfg.sh os=$(OS) arch=$(ARCH) prefix=$(PREFIX) libdir=$(LIBDIR)

$(PROG_NAMES): $(MODULES)
	$(OC) -o $@ $@.Mod

$(TEST_NAMES): $(MODULE)
	$(OC) -o $@ $@.Mod

full_test: .FORCE clean cfg.Mod test

test: cfg.Mod $(TEST_NAMES)
	@for FNAME in $(TEST_NAMES); do ./$$FNAME; done

docs: .FORCE
	obncdoc

clean: .FORCE
	@if [ -f cfg.Mod ]; then rm cfg.Mod; fi
	@if [ -d dist ]; then rm -fR dist; fi
	@if [ -d .obnc ]; then rm -fR .obnc; fi
	@for FNAME in $(PROG_NAMES); do if [ -f $$FNAME ]; then rm $$FNAME; fi; done
	@for FNAME in $(TEST_NAMES); do if [ -f $$FNAME ]; then rm $$FNAME; fi; done

install: $(PROG_NAMES)
	@if [ ! -d $(BINDIR) ]; then mkdir -p $(BINDIR); fi
	@for FNAME in $(PROG_NAMES); do cp $$FNAME $(BINDIR)/; done

uninstall: .FORCE
	@for FNAME in $(PROG_NAMES); do if [ -f "$(BINDIR)/$$FNAME" ]; then rm "$(BINDIR)/$$FNAME"; fi; done

dist: $(PROG_NAMES) 
	@if [ ! -d dist/$(BUILD_NAME) ]; then mkdir -p dist/$(BUILD_NAME); fi
	@if [ ! -d dist/$(BUILD_NAME)/bin ]; then mkdir -p dist/$(BUILD_NAME)/bin; fi
	@for FNAME in $(PROG_NAMES); do cp -p $$FNAME dist/$(BUILD_NAME)/bin/; done
	@for FNAME in $(MODULES) $(DOCS) Makefile; do cp -p $$FNAME dist/$(BUILD_NAME)/;done
	@cd dist && zip -r $(BUILD_NAME)-$(OS)-$(ARCH).zip $(BUILD_NAME)/*

.FORCE:

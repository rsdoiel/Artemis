#
# Simple Makefile for compiling Oberon-7 programs using OBNC.
# Set the list of executables in PROG_NAMES. The rest can probably
# stay as is if all modules are in the same directory. 
#
VERSION = $(shell if [ -f VERSION ]; then cat VERSION; else echo "0.0.0"; fi)
BUILD_NAME = Artemis-Modules-NP
PROG_NAMES =
TEST_NAMES = ClockTest UnixTest DirentTest SocketTest
MODULES = $(shell ls *.obn)
DOCS= README.md ../LICENSE ../INSTALL.txt

# Defaults
#OC = obnc
OC = env OBNC_IMPORT_PATH=".:../" obnc
OS = $(shell uname)
ARCH = $(shell uname -m)
PREFIX = /usr/local
LIBDIR = $(PREFIX)/lib
BINDIR = $(PREFIX)/bin

# Overrides
oc =
ifneq ($(oc), )
  OC = $(oc)
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
  LIBDIR = $(libdir)
endif

bindir =
ifneq ($(bindir), )
  BINDIR = $(bindir)
endif

all: $(PROG_NAMES)

$(PROG_NAMES): $(MODULES)
	$(OC) -o $@ $@.obn

$(TEST_NAMES): $(MODULE)
	$(OC) -o $@ $@.obn

full_test: .FORCE clean test

test: $(TEST_NAMES)
	@for FNAME in $(TEST_NAMES); do env OS=$(OS) ARCH=$(ARCH) ./$$FNAME; done

docs: .FORCE
	obncdoc

clean: .FORCE
	@if [ -d dist ]; then rm -fR dist; fi
	@if [ -d .obnc ]; then rm -fR .obnc; fi
	@if [ -d ../ports/po2013/.obnc ]; then rm -fR ../ports/po2013/.obnc; fi
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

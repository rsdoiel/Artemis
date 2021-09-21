#
# Simple Makefile for compiling Oberon-7 programs using OBNC.
# Set the list of executables in PROG_NAMES. The rest can probably
# stay as is if all modules are in the same directory. 
#
VERSION = $(shell jq .version codemeta.json | cut -d \" -f 2)
BUILD_NAME = Artemis-Modules
PROG_NAMES = #$(shell ls -1 *CmdLn.Mod | sed -E 's/CmdLn\.Mod')
TEST_NAMES = $(shell ls -1 *Test.Mod | sed -E 's/\.Mod//g' )
MODULES = $(shell ls -1 *.Mod)
DOCS= codemeta.json CITATION.cff README.md LICENSE INSTALL.txt
HTML_FILES=$(shell find . -type f | grep -E '.html')

#OC = env OBNC_IMPORT_PATH="." obnc
# Defaults
OC = obnc
OS = $(shell uname)
ARCH = $(shell uname -m)
PREFIX = /usr/local
LIBDIR = $(PREFIX)/lib
BINDIR = $(PREFIX)/bin

# Handle Git and commit messages
BRANCH = $(shell git branch | grep '* ' | cut -d\  -f 2)
MSG = Quick Save
ifneq ($(msg),)
	MSG = $(msg)
endif

# Overrides
oc =
ifneq ($(oc),)
	OC = $(oc)
endif

os =
ifneq ($(os),)
	OS = $(os)
endif

EXT =
ifeq ($(OS),Windows)
	EXT = .exe
endif

arch =
ifneq ($(arch),)
	ARCH = $(arch)
endif

prefix =
ifneq ($(prefix),)
	PREFIX = $(prefix)
	LIBDIR = $(prefix)/lib
	BINDIR = $(prefix)/bin
endif

libdir =
ifneq ($(libdir),)
  LIBDIR = $(libdir)
endif

bindir =
ifneq ($(bindir),)
  BINDIR = $(bindir)
endif

build: $(TEST_NAMES) # $(PROG_NAMES)

$(PROG_NAMES): $(MODULES)
	@mkdir -p bin
	$(OC) -o "bin/$@$(EXT)" "$@.Mod"

$(TEST_NAMES): .FORCE
	$(OC) -o "$@$(EXT)" "$@.Mod"

full_test: .FORCE clean test

test: Tests.Mod $(TEST_NAMES)
	@for FNAME in $(TEST_NAMES); do env OS=$(OS) ARCH=$(ARCH) "./$${FNAME}"; done

docs: .FORCE
	obncdoc

clean: .FORCE
	@if [ -d dist ]; then rm -fR dist; fi
	@if [ -d .obnc ]; then rm -fR .obnc; fi
	@for FNAME in $(PROG_NAMES); do if [ -f "bin/$${FNAME}$(EXT)" ]; then rm -v "bin/$${FNAME}"; fi; done
	@for FNAME in $(TEST_NAMES); do if [ -f "$${FNAME}$(EXT)" ]; then rm -v "$${FNAME}"; fi; done

web_clean:
	@for FNAME in $(HTML_FILES) ; do if [ -f "$${FNAME}" ]; then rm -v "$${FNAME}"; fi; done

install: $(PROG_NAMES)
	@if [ ! -d $(BINDIR) ]; then mkdir -p $(BINDIR); fi
	@for FNAME in $(PROG_NAMES); do cp -v "bin/$${FNAME}$(EXT)" $(BINDIR)/; done

uninstall: .FORCE
	@for FNAME in $(PROG_NAMES); do if [ -f "$(BINDIR)/$${FNAME}$(EXT)" ]; then rm "$(BINDIR)/$${FNAME}$(EXT)"; fi; done

dist: $(PROG_NAMES) 
	@if [ ! -d dist/$(BUILD_NAME) ]; then mkdir -p dist/$(BUILD_NAME); fi
	@if [ ! -d dist/$(BUILD_NAME)/bin ]; then mkdir -p dist/$(BUILD_NAME)/bin; fi
	@for FNAME in $(PROG_NAMES); do cp -p $$FNAME dist/$(BUILD_NAME)/bin/; done
	@for FNAME in $(MODULES) $(DOCS) Makefile; do cp -p $$FNAME dist/$(BUILD_NAME)/;done
	@cd dist && zip -r $(BUILD_NAME)-$(OS)-$(ARCH).zip $(BUILD_NAME)/*



save:
	git commit -am "$(MSG)"
	git push origin $(BRANCH)

status:
	git status

website: web_clean README.md page.tmpl css/site.css
	obncdoc
	cp -vp css/site.css obncdoc/style.css
	./mk_website.py

publish: web_clean clean
	obncdoc
	cp -vp css/site.css obncdoc/style.css
	./mk_website.py
	./publish.bash


.FORCE:

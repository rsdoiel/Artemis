#
# Simple Makefile for using with Ofront+ compiler.
#

# FIXME: Need to figure out how to detect the information
# needed to set the flags correctly for Ofront+
# Questions to get sorted: 
# 
# 1. Set up import paths for modules (e.g. pure Oberon, Ofront specific)
# 2. Where are the standard modules or do I need to write them?
#

# Defaults
#OC = ofont+
OC=$(shell which ofront+)

OPT = -7

MODULES = $(shell ls -1 *.Mod | grep -v -E Test.Mod | sed -E "s/.Mod$$//")

TEST_NAMES = $(shell ls -1 *.Mod | grep -E Test.Mod | sed -E "s/.Mod$$//")

PROG_NAMES = #$(shell ls -1 *CmdLn.Mod | sed -E "s/.CmdLn.Mod$$//")

PLATFORM = $(shell uname -i)

OS = $(shell uname)

OPT =

ifeq ($(PLATFORM), x86_64)
	OPT = -7 -88 -s
else ifeq ($(PLATFORM), x86_32)
	OPT = -7 -44 -s
else ifeq ($(PLATFORM), arm7)
	OPT = -7 -48 -s
endif

EXT =

ifeq ($(OS), Windows)
	EXT = .exe
	OPT = -7 -s -48
endif


build: modules test programs

modules: $(MODULES)

programs: $(PROG_NAMES)

$(MODULES):
	@mkdir -p bin
	$(OC) $(OPT) $@.Mod

$(PROG_NAMES): $(MODULES)
	@mkdir -p bin
	$(OC) $(OPT) $@.Mod

$(TEST_NAMES): .FORCE
	$(OC) $(OPT) "$@.Mod" -m

full_test: .FORCE clean test

test: ../Tests.Mod $(TEST_NAMES)
	@for FNAME in $(TEST_NAMES); do "./$${FNAME}"; done

clean: .FORCE
	@for FNAME in $(PROG_NAMES); do if [ -f "$${FNAME}$(EXT)" ]; then rm -v "$${FNAME}$(EXT)"; fi; done
	@for FNAME in $(PROG_NAMES); do if [ -f "$${FNAME}.c" ] || [ -f "$${FNAME}.h" ] || [ -f "$${FNAME}.sym" ]; then rm -v "$${FNAME}.(c|h|sym)"; fi; done
	@for FNAME in $(TEST_NAMES); do if [ -f "$${FNAME}$(EXT)" ]; then rm -v "$${FNAME}$(EXT)"; fi; done
	@for FNAME in $(TEST_NAMES); do if [ -f "$${FNAME}.c" ] || [ -f "$${FNAME}.h" ] || [ -f "$${FNAME}.sym" ]; then rm -v "$${FNAME}.(c|h|sym)"; fi; done
	@for FNAME in $(MODULES); do if [ -f "$${FNAME}.c" ] || [ -f "$${FNAME}.h" ] || [ -f "$${FNAME}.sym" ]; then rm -v "$${FNAME}.(c|h|sym)"; fi; done

save:
	git commit -am "$(MSG)"
	git push origin $(BRANCH)

status:
	git status

.FORCE:

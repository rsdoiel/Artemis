#
# Simple Makefile for using with ofront+ compiler.
#

# Defaults
#OC = ofont+
OC=$(shell which ofront+)

MODULES = $(shell ls -1 ../*.Mod | grep -v -E Test.Mod | sed -E "s/.Mod$$//")

TEST_NAMES = $(shell ls -1 ../*.Mod | grep -E Test.Mod | sed -E "s/.Mod$$//")


build: $(TEST_NAMES) test

$(PROG_NAMES): $(MODULES)
	@mkdir -p bin
	$(OC) -s7 -48 $@.Mod

$(TEST_NAMES): .FORCE
	$(OC) -s7 -48 "$@.Mod" -m

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

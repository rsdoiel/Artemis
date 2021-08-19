
OS = $(shell uname)

SUDO_USER = $$SUDO_USER

SHARE_LIBS =

#FIXME: Compiling under macOS is failing right now. This is true for
# both static and dynamic compilations.
#
# Per https://spivey.oriel.ox.ac.uk/corner/How_to_add_primitives_to_OBC
#GCC_SO_OPT = -m32 -fPIC -shared -I /usr/local/lib/obc
#ifeq ($(OS),Darwin)
#  GCC_SO_OPT = -m32 -fPIC -bundle -undefined dynamic_lookup -I /usr/local/lib/obc
#endif

PROGRAMS = helloworld clocktest converttest argstest envtest

build: $(SHARE_LIBS) $(PROGRAMS) ../Tests.m

#../Tests.m: ../Tests.Mod
#	echo '(** Copied from ../Tests.Mod, DO NOT edit *)' >../Tests.m
#	#cat ../Tests.Mod >>../Tests.m

clocktest: ../Tests.m artEnv.m artClock.m ClockTest.m
	obc -07 -c ../Tests.m
	obc -07 -c artClock.m
	obc -07 -c artClock.c
	obc -07 -c artEnv.m
	obc -07 -c ClockTest.m
	obc -07 -C -o clocktest ../Tests.m artClock.m artClock.o artEnv.m ClockTest.m

converttest: ../Tests.m ConvertTest.m artConvert.m
	obc -07 -c ../Tests.m
	obc -07 -c artConvert.m
	obc -07 -c artConvert.c
	obc -07 -c ConvertTest.m
	obc -07 -C -o converttest artConvert.m artConvert.o ../Tests.m ConvertTest.m 

argstest: ../Tests.m artArgs.m ArgsTest.m
	obc -07 -o argstest artArgs.m ../Tests.m ArgsTest.m

envtest: ../Tests.m artEnv.m EnvTest.m
	obc -07 -o envtest artEnv.m ../Tests.m EnvTest.m

helloworld: helloworld.m
	obc -07 -o helloworld helloworld.m


test: $(PROGRAMS)
	./helloworld
	env OS=$(OS) SUDO_USER=$(SUDO_USER) ./clocktest
	./argstest one two three
	env GOOD_NIGHT=Irine ./envtest
	./converttest

clean: .FORCE
	@for FNAME in $(shell ls -1 *.bak *~ *.o a.out 2>/dev/null); do rm $$FNAME; done
	@for FNAME in $(PROGRAMS); do if [ -f $$FNAME ]; then rm $$FNAME; fi; done
	@for FNAME in $(SHARED_LIBS); do if [ -f $$FNAME ]; then rm $$FNAME; fi; done
	@for FNAME in $(shell ls -1 *.k 2>/dev/null); do rm $$FNAME; done
	@for FNAME in $(shell ls -1 *.so 2>/dev/null); do rm $$FNAME; done

full_test: clean test


.FORCE:

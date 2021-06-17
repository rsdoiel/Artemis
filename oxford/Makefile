
OS = $(shell uname)

SUDO_USER = $$SUDO_USER

SHARE_LIBS = Clock.so extConvert.so

PROGRAMS = helloworld clocktest converttest argstest envtest

build: $(SHARE_LIBS) $(PROGRAMS) ../Tests.m

Clock.so: Clock.m Clock.c
	obc -07 -c Clock.m
	gcc -fPIC -shared Clock.c -o Clock.so

../Tests.m: ../Tests.Mod
	echo '(** Copied from ../Tests.Mod, DO NOT edit *)' >../Tests.m
	cat ../Tests.Mod >>../Tests.m

extConvert.so: extConvert.m extConvert.c
	obc -07 -c extConvert.m
	gcc -fPIC -shared extConvert.c -o extConvert.so

clocktest: ../Tests.m Clock.so extEnv.m Clock.m ClockTest.m
	obc -07 -o clocktest ../Tests.m Clock.m extEnv.m ClockTest.m

converttest: ../Tests.m extConvert.so ConvertTest.m
	obc -07 -o converttest extConvert.m ../Tests.m ConvertTest.m

argstest: ../Tests.m extArgs.m ArgsTest.m
	obc -07 -o argstest extArgs.m ../Tests.m ArgsTest.m

envtest: ../Tests.m extEnv.m EnvTest.m
	obc -07 -o envtest extEnv.m ../Tests.m EnvTest.m

helloworld: helloworld.m
	obc -07 -o helloworld helloworld.m


test: $(PROGRAMS)
	./helloworld
	env OS=$(OS) SUDO_USER=$(SUDO_USER) ./clocktest
	./argstest one two three
	env GOOD_NIGHT=Irine ./envtest
	./converttest

clean: .FORCE
	@for FNAME in $(shell ls -1 *.bak *~ a.out 2>/dev/null); do rm $$FNAME; done
	@for FNAME in $(PROGRAMS); do if [ -f $$FNAME ]; then rm $$FNAME; fi; done
	@for FNAME in $(SHARED_LIBS); do if [ -f $$FNAME ]; then rm $$FNAME; fi; done
	@for FNAME in $(shell ls -1 *.k 2>/dev/null); do rm $$FNAME; done
	@for FNAME in $(shell ls -1 *.so 2>/dev/null); do rm $$FNAME; done

full_test: clean test


.FORCE:

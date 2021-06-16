
OS = $(shell uname)

SUDO_USER = $$SUDO_USER

SHARE_LIBS = Clock.so extConvert.so

PROGRAMS = helloworld clocktest converttest argstest envtest

build: $(SHARE_LIBS) $(PROGRAMS)

Clock.so: Clock.m Clock.c
	obc -07 -c Clock.m
	gcc -fPIC -shared Clock.c -o Clock.so

extConvert.so: extConvert.m extConvert.c
	obc -07 -c extConvert.m
	gcc -fPIC -shared extConvert.c -o extConvert.so

argstest: extArgs.m ArgsTest.m
	obc -07 -o argstest extArgs.m ../Tests.Mod ArgsTest.m

envtest: extEnv.m EnvTest.m
	obc -07 -o envtest extEnv.m ../Tests.Mod EnvTest.m

converttest: extConvert.m ConvertTest.m extConvert.so
	obc -07 -o converttest extConvert.m ../Tests.Mod ConvertTest.m

helloworld: helloworld.m
	obc -07 -o helloworld helloworld.m

clocktest: Clock.so extEnv.m ../Tests.Mod Clock.m ClockTest.m
	obc -07 -o clocktest Clock.m ../Tests.Mod extEnv.m ClockTest.m

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

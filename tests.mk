include linking.mk

CFLAGS=$(T2_CFLAGS) $(T2_CXX_FLAGS) $(INCLUDE_SWITCHES)

TESTS=t2_hello_world t2_windowing
LTESTS=$(addprefix $(LIB)/,$(TESTS))


# Tests linking
$(LIB)/t2_hello_world: $(PWD)/tests/hello_world.cpp tests.mk
	$(CXX) $(CFLAGS) $< $(LDFLAGS) -o $(LIB)/t2_hello_world
	@echo To test $@ cd to $(LIB) and run from there

$(LIB)/t2_windowing: $(PWD)/tests/windowing.cpp tests.mk
	$(CXX) $(CFLAGS) $< $(LDFLAGS) -o $(LIB)/t2_windowing
	@echo To test $@ cd to $(LIB) and run from there

tests: $(LTESTS)

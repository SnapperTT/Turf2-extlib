#include <extlib/include/libbacktrace/backtrace.h>
#include <cstdio>
#include <cstring>

// Tests printing a stacktrace. This will be mangled
	
void bt(struct backtrace_state *state) {
	backtrace_print(state, 0, stdout);
	}

void error_callback(void *data, const char *msg, int errnum) {
	fprintf(stderr, "ERROR: %s (%d)", msg, errnum);
	}

void test_function (int value) {
	backtrace_state * bs = backtrace_create_state (NULL, 0,
						&error_callback, NULL);
	bt(bs);
	}

int main(int argv, char** args) {
	test_function(1);
	return 1;
	}

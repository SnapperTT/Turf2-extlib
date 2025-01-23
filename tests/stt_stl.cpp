#define STT_STL_DEBUG 1
#define STT_STL_DEBUG_MEMORY 1
#include <extlib/include/stt-stl/stt-stl.h>
#define STT_STL_IMPL 1 // needed here for .lzz to include #src

#include <cstdio>
#include <iostream>
#include <type_traits>

#define STT_STL_IMPL 1
#include <extlib/include/stt-stl/stt-stl.h>

#include <string>
#include <vector>


namespace stt {
	template <typename T>
	using small_vector64 = small_vector<T, 64, uint16_t>;
	}
	
	
int main (int argc, char ** argv) {
	static stt::crt_allocator alloc;
	stt::setDefaultAllocator(&alloc);
	
	// integer test
	stt::vector32<int> ivec;
	for (int i = 0; i < 40; ++i) {
		ivec.push_back(i);
		}
	for (int i = 0; i < 40; ++i)
		printf("%d %d\n", i, ivec[i]);
	
	
	// vector of containers (strings) test
	stt::string24 str = "foo";
	stt::vector32<stt::string24> vec;
	for (int i = 0; i < 40; ++i) {
		if (i % 10 == 0)
			str = "foo";
		else
			str += "bar";
		vec.push_back(str);
		}
	for (int i = 0; i < 40; ++i)
		printf("%d %s\n", i, vec[i].c_str());
	
	
	// vector of vector tree test
	const int nItter = 10000;
	for (int cc = 0; cc < nItter; ++cc) { // do a bunch of itterations to slam the allocator
		stt::vector24<stt::vector24<int>> vbase;
		for (int i = 0; i < 10; ++i) {
			stt::vector24<int> foo;
			for (int j = i * 10 + i*i + 10; j >= 0; --j) {
				foo.push_back(j);
				}
			vbase.push_back(foo);
			}
		if (cc == nItter-1) {
			for (int i = 0; i < 10; ++i) {
				printf("%d %d\n", i, vbase[i].size());
				}
			}
		}
	
	printf("End of stt_stl\n");
	
	return 0;
	}


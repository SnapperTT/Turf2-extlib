# Makes CTags from all libraries
CTAGS = ctags
CTAGS_FILE = ctags

# Adjust as needed: which subdirectories to scan
CTAGS_LZZ_HPP_DIRS = stt-stl/src sdl-stb-font/src vecgui/src bgfx-header-extension-library/src sttr/src stt-obj nanovg-command-buffer 
CTAGS_H_DIRS = bgfx/include /usr/include/SDL3/
CTAGS_BULLET_COMMON_HEADERS = bullet/src/btBulletCollisionCommon.h \
                              bullet/src/btBulletDynamicsCommon.h
                        
.PHONY: ctags
ctags:
	@echo "Generating $(CTAGS_FILE)..."
	@find $(CTAGS_LZZ_HPP_DIRS) -type f \( -name "*.lzz" -o -name "*.hpp" \) -not -lname '*' \
		| $(CTAGS) --languages=C++ --langmap=C++:+.lzz -L - \
			-f $(CTAGS_FILE).part1 --tag-relative=yes
	@find $(CTAGS_H_DIRS) -maxdepth 1-type f -name "*.h" -not -lname '*' \
		| $(CTAGS) --languages=C++ -L - \
			-f $(CTAGS_FILE).part2 --tag-relative=yes

	@echo "Parsing Bullet common headers..."
	grep -h '^#include "' $(CTAGS_BULLET_COMMON_HEADERS) \
		| sed -E 's/^#include "([^"]+)".*/\1/' \
		| while read hdr; do \
			find bullet -type f -path "*/$$hdr" -print; \
		  done \
		| sort -u \
		| $(CTAGS) --languages=C++ -L - \
			-f $(CTAGS_FILE).part3 --tag-relative=yes
	@cat $(CTAGS_FILE).part1 $(CTAGS_FILE).part2 $(CTAGS_FILE).part3 > $(CTAGS_FILE)
	@rm -f $(CTAGS_FILE).part1 $(CTAGS_FILE).part2 $(CTAGS_FILE).part3
	@echo "$(CTAGS_FILE) built."

.PHONY: clean-ctags
clean-ctags:
	rm -f $(CTAGS_FILE) $(CTAGS_FILE).part1 $(CTAGS_FILE).part2

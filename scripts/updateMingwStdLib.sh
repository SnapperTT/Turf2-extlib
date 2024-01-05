# Copy *.dll and *.dll.a files
# Invoke from /extlib
PWD=`pwd`
cp -arf /usr/x86_64-w64-mingw32/bin/*.dll /usr/x86_64-w64-mingw32/lib/*.dll.a $PWD/lib_win_x64/
cp -arf /usr/x86_64-w64-mingw32/bin/gdb.exe $PWD/bin_win64/



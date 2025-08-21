# Compiling on WSL for win32 (cdecl)

nasm -f win32 src/winapi_io.asm -o build/accumulate.obj && i686-w64-mingw32-gcc build/accumulate.obj -o main.exe -lkernel32 -lmsvcrt && rm build/accumulate.obj 


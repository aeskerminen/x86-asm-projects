# Compiling on WSL for win32 (cdecl)

nasm -f win32 accumulate.asm -o accumulate.obj && i686-w64-mingw32-gcc accumulate.obj -o main.exe -lkernel32 -lmsvcrt

# Goals

## 🟢 Beginner Level — Warmup & Fundamentals

Here the goal is to get comfortable with registers, instructions, calling conventions, and debugging in a disassembler.

1. **Hello World**

   * Write to stdout using Windows API (`WriteFile` or `MessageBoxA`).
   * Goal: learn about syscalls, stack setup, and calling conventions.

2. **Basic Calculator**

   * Implement add, sub, mul, div for integers.
   * Input from command line arguments (`argv`) or hardcoded values.
   * Goal: practice `add`, `sub`, `mul`, `div`, moving values into registers, handling signed vs unsigned.

3. **String Reverser**

   * Read a string from memory and reverse it in place.
   * Goal: pointer arithmetic, loops, string termination.

4. **Factorial / Fibonacci**

   * Iterative and recursive implementations.
   * Goal: understand stack frames, recursion, function calls in assembly.

---

## 🟡 Intermediate Level — Memory & OS Interaction

Here you start really feeling “assembly as a systems language.”

5. **File Reader/Writer**

   * Open a file, read contents, write them to another file.
   * Goal: practice Windows API usage (`CreateFile`, `ReadFile`, `WriteFile`).

6. **Command-Line Arguments Parser**

   * Implement a mini parser: count words, print them line by line.
   * Goal: dealing with Windows process startup and memory layout (`__getmainargs`, stack-based argv).

7. **Dynamic Memory Allocator** (mini `malloc`)

   * Use `HeapAlloc`/`HeapFree` or directly play with `VirtualAlloc`.
   * Goal: understand heap allocation, alignment, and low-level memory.

8. **String Library**

   * Write your own `strlen`, `strcpy`, `strcmp`.
   * Goal: pointer arithmetic mastery, performance optimization with `rep movsb`.

9. **Math Library Optimizations**

   * Implement fast square root, absolute value, bit shifts for multiply/divide by powers of 2.
   * Goal: bitwise tricks, using x87 FPU and SSE registers.

---

## 🔵 Advanced Level — Bigger Programs

Now we move into *full applications*.

10. **Windows PE Executable Patcher**

* Open an `.exe`, patch a string inside, save it.
* Goal: learn PE structure, offsets, memory mapping.

11. **Basic Shell / Command Interpreter**

* Read input, parse simple commands, call Windows APIs.
* Goal: learn about stdin handling, loops, branching, string parsing.

12. **Graphics Mode Project: Pixel Drawing**

* Use `Win32 GDI` to open a window and draw pixels/lines.
* Goal: understand stack setup for WinAPI window procedures, event loops.

13. **Mini Text Editor**

* Simple program that lets you type, edit, and save text to file.
* Goal: input handling, buffers, file I/O, cursor movement.

14. **Mandelbrot Renderer** (console ASCII or GDI window)

* Render fractals pixel by pixel.
* Goal: floating point math, optimization, loops.

---

## 🔴 Expert Level — Full Applications

Now you’re mixing your high-level programming experience with low-level control.

15. **Mini Assembler / Disassembler**

* Parse a subset of x86 mnemonics and translate to machine code (and back).
* Goal: deepen instruction encoding/decoding knowledge.

16. **Basic Game (Snake / Tetris / Pong)**

* Console-based or graphical (GDI).
* Goal: event loop, timing, collision detection, rendering.

17. **HTTP Web Server in Assembly**

* Open a socket, accept requests, return static HTML.
* Goal: Windows Sockets API, buffers, network byte order, protocol basics.

18. **Debugger (Tiny GDB Clone)**

* Open another process, set breakpoints, inspect registers/memory.
* Goal: Windows `DebugActiveProcess`, `ReadProcessMemory`, `WriteProcessMemory`.

19. **Minimal Kernel (Bootloader + Tiny OS)**

* Write an x86 boot sector that loads your own “kernel” and prints text.
* Goal: bare-metal assembly, BIOS interrupts, memory segmentation.

20. **3D Engine in Assembly** (stretch goal)

* Implement a wireframe renderer using linear algebra + SSE.
* Goal: master SIMD, transformations, performance optimization.

---
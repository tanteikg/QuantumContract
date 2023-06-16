TARGETS: QuGIF.exe  QuGIF.js

SHELL := /bin/bash

QuGIF.exe: QuGIF.c gifenc.h gifenc.c 
	gcc -g -Warray-bounds QuGIF.c gifenc.c -o QuGIF.exe 

QuGIF.js: QuGIF.c gifenc.c gifenc.h 
	source ~/dev/emsdk/emsdk_env.sh && emcc -s ALLOW_MEMORY_GROWTH -s MAXIMUM_MEMORY=4GB -DWASM gifenc.c QuGIF.c -o QuGIF.js -sEXPORTED_RUNTIME_METHODS=ccall -s FORCE_FILESYSTEM=1 

clean:
	rm QuGIF.exe QuGIF.js 

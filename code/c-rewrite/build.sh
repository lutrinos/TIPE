#!/bin/bash

# Build script for C implementation and shared library

CFLAGS="-O3 -fPIC -Wall -Wextra"
LDFLAGS="-lm"
SRCDIR="c-rewrite"

echo "Building C library..."

# Compile object files
gcc $CFLAGS -I$SRCDIR -c "$SRCDIR/request.c" -o request.o
gcc $CFLAGS -I$SRCDIR -c "$SRCDIR/table.c" -o table.o
gcc $CFLAGS -I$SRCDIR -c "$SRCDIR/hyper.c" -o hyper.o
gcc $CFLAGS -I$SRCDIR -c "$SRCDIR/main.c" -o main.o
gcc $CFLAGS -I$SRCDIR -c "$SRCDIR/wrapper.c" -o wrapper.o

if [ $? -ne 0 ]; then
    echo "Compilation failed!"
    exit 1
fi

# Create shared library
gcc -O3 -shared -o libyannakakis.so request.o table.o hyper.o main.o wrapper.o $LDFLAGS

if [ $? -ne 0 ]; then
    echo "Linking failed!"
    exit 1
fi

echo "Build successful! Created libyannakakis.so"

# Cleanup object files
rm -f request.o table.o hyper.o main.o wrapper.o

echo "Done!"

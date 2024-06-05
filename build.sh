#!/bin/bash

nasm -f elf32 -g -F dwarf search.asm -o search.o
ld -m elf_i386 -o search search.o

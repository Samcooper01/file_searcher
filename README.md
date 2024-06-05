# File Searcher

**File Searcher** is a simple command-line tool written in x86 32-bit assembly that searches for all instances of a provided string in a specified file.

## Purpose

The purpose of this tool is to search a specified file for a provided string and output the locations where the string is found.

## Usage

- To use File Searcher, run the provided ELF binary file **./search** to get the usage information.
```
scooper@scooper ~/Desktop/Assembly/file_searcher $ ./search 
Purpose:

Search file specified for string provided and output location where provided string is present.

Incorrect usage will output this:
Usage:

./search <FILENAME> <STRING TO SEARCH FOR>

Example output for string found:
#./search test.txt <STRING>
<STRING> found:
	Line: 19 -> and the music was <STRING> loud
	Line: 47 -> the keyboard was known for being <STRING> fast

Instances found: <NUM OF TIMES FOUND>
#

Example output for string not found:
#./search test.txt <STRING>
<STRING> not found in provided file.

Instances found: 0
#

SUPPORT:
Supports standard unformatted text file format (.txt)
ELF 64-bit LSB executable, x86-64

```

## Build code

Code is built by running bash script **./build.sh** or with the following: 


```
nasm -f elf32 -g -F dwarf search.asm -o search.o
ld -m elf_i386 -o search search.o
```
*the nasm command provided includes dwarf debug symbols

### Build Dependency List

- NASM: https://nasm.us/
- ld: https://www.ibm.com/docs/en/aix/7.2?topic=l-ld-command

#### Code Execution Summary
1. Command line argument parsing - ensure that the provided first arg is a valid filename and that two arguments are present. If either of these things are false output usage info.
2. Main loop - read 512 bytes of the file at a time and search for the first character of the search_string. If first character is found enter another loop which iterates over the next characters and breaks if ascii codes are not the same, if last character of search_string is found at correct index, enter print loop. Print loop find line number of character by parsing "/n" and outputs line number + buffer of characters between either "/n" and "/n" or "/n" and 0x0 (EOF). Once printed, return to mainloop and finish searching 512 byte buffer. Repeat parsing 512 byte buffers until end of file is reached.
3. Exit - Once end of file is reached and parsing has completed. Output number of times the string has been found and exit(0)

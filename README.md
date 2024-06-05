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
- You can also use the provided **./example.txt** file with whatever string you see in the file.
```
scooper@scooper ~/Desktop/Assembly/file_searcher $ ./search example.txt sam
	Line: 22 -> sam cooper was here
Instances found: 1
scooper@scooper ~/Desktop/Assembly/file_searcher $ ./search example.txt thanks
	Line: 45 -> anyways thanks
Instances found: 1
scooper@scooper ~/Desktop/Assembly/file_searcher $ ./search example.txt can
	Line: 2 -> not all the words reallyt mean anythign im just typing this so you can run my project for fun
	Line: 3 -> do you like words, i really like words. how fast can you run id imagine pretty fast
	Line: 5 -> you can include lots of newlines and spaces if you want heres an example
Instances found: 3
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

##### LIMITATIONS
 - In testing this, I found that sometimes inputting text with copy and paste would make the file unparsable. It seems that when you provide characters that aren't directly typed from your keyboard the behavior is SOMETIMES unpredictable. But in typing characters it seems to always work.
 - Max filename is 300 chars, which is more than windows and linux standard so should be fine.
 - String provided must be more than 1 character.
 - Binary provided includes debug symbols, if you wish to remove these you can just remove the -g and -F dwarf args from the nasm command provided.
 - build.sh script only works with the filename search.asm
 - In all honesty, I spent around only 12 hours on this project so if something doesn't work, womp womp. The purpose of this was
   just to get more experience using assembly so I can do a project thats actually cool.

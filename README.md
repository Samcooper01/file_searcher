# file_searcher
Simple command line tool written in x86 32 bit assembly to find all instances of a provided string from a provided filename.

Purpose:

Search file specified for string provided and output location where provided string is present.

Incorrect usage will output this:
Usage:

./search <FILENAME> <STRING_TO_SEARCH_FOR>

Example output for string found:
#./search test.txt <STRING>
	Line: 19 -> and the music was <STRING> loud
	Line: 47 -> the keyboard was known for being <STRING> fast

Instances found: <NUM OF TIMES FOUND>
#

Example output for string not found:
#./search test.txt <STRING>

Instances found: 0
#

SUPPORT:
Supports standard unformatted text file format (.txt)
ELF 32-bit LSB executable, x86
Max filename is 300 Bytes which is more than Windows and Linux commonly allow
A string must be greater than 1 character. 'a' is a char "ab" is a string in this application
The text in the filename must be typed from a keyboard. Non ascii text will not be parsed correctly

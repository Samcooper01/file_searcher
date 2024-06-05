section .data
    usage: db 'Purpose:', 0x0A, \
    0x0A, \
    \
    'Search file specified for string provided and output location where provided string is present.', 0x0A, \
    0x0A, \
    'Incorrect usage will output this:', 0x0A, \
    'Usage:', 0x0A, \
    0x0A, \
    './search <FILENAME> <STRING TO SEARCH FOR>', 0x0A, \
    0x0A, \
    'Example output for string found:', 0x0A, \
    '#./search test.txt <STRING>', 0x0A, \
    '<STRING> found:', 0x0A, \
    '	Line: 19 -> and the music was <STRING> loud', 0x0A, \
    '	Line: 47 -> the keyboard was known for being <STRING> fast', 0x0A, \
    0x0A, \
    'Instances found: <NUM OF TIMES FOUND>', 0x0A, \
    '#', 0x0A, \
    0x0A, \
    'Example output for string not found:', 0x0A, \
    '#./search test.txt <STRING>', 0x0A, \
    '<STRING> not found in provided file.', 0x0A, \
    0x0A, \
    'Instances found: 0', 0x0A, \
    '#', 0x0A, \
    0x0A, \
    'SUPPORT:', 0x0A, \
    'Supports standard unformatted text file format (.txt)', 0x0A, \
    'ELF 64-bit LSB executable, x86-64', 0x0A, \
    0x0A, 0
    usage_len:  equ $-usage
    error_file_unable_open: db 'ERROR: Filename provided was not able to be opened', 0x0A, 0
    error_file_unable_open_len: equ $-error_file_unable_open
    file_read_size: dd 512
    match_found_0: db '	Line: ',0
    match_found_0_len: equ $-match_found_0
    match_found_1: db ' -> ',0
    match_found_1_len: equ $-match_found_1
    newline: db 0x0a
    instances_found: db 'Instances found: ',0
    instances_found_len: equ $-instances_found

section .bss
    filename_ptr   resb    32 
    search_string_ptr   resb 32
    file_descriptor resb 32
    file_ptr_offset  resb    32
    line_counter    resb    32
    total_line_counter resb    32
    line_counter_ascii_backwards  resb    128
    line_counter_ascii_forwards resb    128
    line_counter_ascii_num_digits   resb    32
    last_char_search_string resb    8
    buffer_index    resb    32
    num_matches resb    32
    file_read_buffer    resb    512


section .text
    global _start


_start:
    ;check for argc
    mov eax, [esp]
    cmp eax, 3
    jne wrong_command_line_args

    ;get args
    mov esi, [esp + 12]
    mov edi, search_string_ptr
    mov [edi], esi

    mov esi, [esp + 8]
    mov [filename_ptr], esi

    ;try to open filename in read only mode
    mov eax, 5
	mov ebx, [filename_ptr]
	xor ecx, ecx
	xor edx, edx
	int 0x80

    ;ensure file able to open
    cmp eax, 3
    jne write_file_unable_to_open

    ;store file descriptor
    mov [file_descriptor], eax
    mov eax, 0
    mov [file_ptr_offset], eax
    
    ;get last char of string provided
    xor eax, eax
    xor ebx, ebx
    mov edi, [search_string_ptr]
    while_not_last_char:
        mov al, [edi + ebx]
        inc ebx
        cmp al, 0x00
        jne while_not_last_char
    mov dl, [edi + ebx -2]
    mov [last_char_search_string], dl
    
    mov eax, 0
    mov [num_matches], eax

    ;READ 512 bytes at a time until we reach EOF (CTRL-D) (ASCII: 0x04)
    while_not_EOF:
        mov eax, 3
        mov ebx, [file_descriptor]
        mov ecx, file_read_buffer
        mov edx, [file_read_size]
        int 0x80
        mov bl, [file_read_buffer]
        cmp bl, 0x00
        je EOF ;if file is empty
        mov eax, [total_line_counter]
        cmp eax, 0
        jne skip
        call inc_line_counter
        skip:
        xor eax, eax
        xor esi, esi
        xor ebx, ebx
        mov [buffer_index], eax
        while_not_end_of_buffer:
            xor esi, esi
            xor ebx, ebx
            xor ecx, ecx
            xor edx, edx
            mov eax, [buffer_index]
            mov bl, [file_read_buffer + eax]
            cmp bl, 0x0A
            jne not_newline
            call inc_line_counter
            not_newline:
            mov edx, [search_string_ptr]
            mov cl, [edx]
            inc eax
            mov [buffer_index], eax
            cmp ebx, ecx
            jne no_match
            while_next_char_matches:
                cmp bl, 0x00
                je write_file_unable_to_open
                xor ebx, ebx
                xor ecx, ecx
                inc esi
                mov bl, [file_read_buffer + esi + eax -1]
                mov edx, [search_string_ptr]
                mov cl, [edx + esi]
                cmp bl, cl
                jne no_match
                mov ecx, last_char_search_string
                xor edi, edi
                mov edi, [ecx]
                and edi, 0x000000FF
                cmp ebx, edi
                jne while_next_char_matches
                je match_found
            no_match:
            cmp ebx, 0x00
            jne while_not_end_of_buffer

        mov eax, [file_ptr_offset]
        add eax, 511
        mov [file_ptr_offset], eax

        ;move file pointer to the 512th byte
        mov eax, 19
        mov ebx, [file_descriptor]
        mov ecx, [file_ptr_offset]
        mov edx, 0
        int 0x80

        mov eax, 0
        mov [buffer_index], eax

        mov eax, [total_line_counter]
        mov ebx, [line_counter]
        add eax, ebx
        mov [total_line_counter], eax
        mov eax, 0
        mov [line_counter], eax

        xor ebx, ebx
        mov ebx, 512
        for_512_times:
            mov al, 0
            mov [file_read_buffer + ebx], al
            dec ebx
            cmp ebx, 0
            jne for_512_times

        mov ebx, [file_ptr_offset]
        add ebx, 512
        mov [file_ptr_offset], ebx

        mov al, 0
        mov [file_read_buffer], al
        jmp while_not_EOF

    EOF:

    mov ecx, [num_matches]
    cmp ecx, 0
    jne no_matches


    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    no_matches:

    mov eax, 4
    mov ebx, 1
    mov ecx, instances_found
    mov edx, instances_found_len
    int 0x80

    mov ecx, [num_matches]
    add ecx, '0'
    mov [num_matches], ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, num_matches
    mov edx, 32
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    exit:
    ; Exit the program
    mov eax, 1
    xor edi, edi
    int 0x80

inc_line_counter:
    mov edi, [line_counter]
    inc edi
    mov [line_counter], edi
    ret

match_found:
    mov eax, [num_matches]
    inc eax
    mov [num_matches], eax
    xor eax, eax
    mov eax, 4
    mov ebx, 1
    mov ecx, match_found_0
    mov edx, match_found_0_len
    int 0x80

    xor eax, eax
    xor ecx, ecx
    mov eax, [total_line_counter]
    mov edx, [line_counter]
    add eax, edx
    mov ecx, 10
    xor edx, edx
    xor esi, esi
    convert_multiple_digits_to_ascii:
        idiv ecx
        add dl, '0'
        mov [line_counter_ascii_backwards + esi], dl
        inc esi
        sub dl, '0'
        xor edx, edx
        cmp eax, 0
        jne convert_multiple_digits_to_ascii

    mov [line_counter_ascii_num_digits], esi

    xor eax, eax
    xor edi, edi
    mov esi, [line_counter_ascii_num_digits]
    flip_forwards:
        xor edx, edx
        mov dl, [line_counter_ascii_backwards + esi -1]
        dec esi
        mov [line_counter_ascii_forwards + eax], edx
        inc eax
        inc edi
        cmp esi, 0
        jne flip_forwards

    mov eax, 4
    mov ebx, 1
    mov ecx, line_counter_ascii_forwards
    mov edx, 128    ; num of lines is locked to 128 digits, didnt include in README.txt cause so 10^128 is huge
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, match_found_1
    mov edx, match_found_1_len
    int 0x80

    ;now get all the text from the line at line_counter

    xor eax, eax
    mov edi, [line_counter]
    mov esi, [total_line_counter]
    cmp esi, 0
    je first_run
    inc edi
    first_run:
    xor esi, esi
    inc esi
    while_not_at_line:
        mov bl, [file_read_buffer + eax]
        cmp bl, 0x0a
        jne not_line_feed
        inc esi
        not_line_feed:
        inc eax
        cmp esi, edi
        jne while_not_at_line

    xor esi, esi
    mov esi, eax
    mov eax, [line_counter]
    cmp eax, 1
    jne skip_dec
    dec esi
    skip_dec:
    while_not_EOLINE:
        mov edx, file_read_buffer
        mov edi, [edx + esi]
        and edi, 0x000000FF
        cmp edi, 0x0a
        je EOLINE
        cmp edi, 0x0
        je EOLINE
        xor ecx, ecx
        add edx, esi
        mov ecx, edx
        mov eax, 4
        mov ebx, 1
        mov edx, 1
        int 0x80
        inc esi
        jmp while_not_EOLINE

    EOLINE:

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    jmp no_match


;copy characters from one address to another address
copy_string:
    push ebp
    mov ebp, esp

    mov esi, [ebp+8]

    mov esp, ebp
    pop ebp
    ret


wrong_command_line_args:
    ;write usage to stdout
    ;doesn't return, exits program
    mov eax, 4
    mov ebx, 1
    mov ecx, usage
    mov edx, usage_len
    int 0x80

    mov eax, 1
    xor edi, edi
    int 0x80

write_file_unable_to_open:
    mov eax, 4
    mov ebx, 1
    mov ecx, error_file_unable_open
    mov edx, error_file_unable_open_len
    int 0x80

    mov eax, 1
    xor edi, edi
    int 0x80

extern puts
extern printf
extern strlen

section .data
filename: db "./input.dat",0
inputlen: dd 2263
fmtstr: db "Key: %d",0xa,0

section .text
global main


; Function for task 1 used for decoding
xor_strings:
    push ebp
    mov ebp, esp

    mov edi, [ebp + 12]   ; Address of the first string
    mov esi, [ebp + 8]    ; Address of the second string

xor_byte:
    mov bl, byte [esi]    
    cmp bl, 0             ; Is checked if it is the end of the string
    je end_xor_strings    ; If it reached the end of the string, the function will end

    xor bl, byte [edi]    ; xor between each byte from each string
    mov byte [edi], bl    ; The bytes in the first string are updated with their decoded values
    
    inc esi               ; Increment the pointer in the second string
    inc edi               ; Increment the pointer in the first string  
    
    jmp xor_byte

end_xor_strings:
    leave
    ret


; Function for task 2 used for decoding
rolling_xor:
    push ebp
    mov ebp, esp

    mov edi, [ebp + 8]    ; Address of the string
    mov al, byte [edi]    ; Value of the first byte in the string
    
roll_xor_byte:
    inc edi
    
    mov bl, byte [edi]
    cmp bl, 0             ; Is checked if it is the end of the string
    je end_rolling_xor    ; If it reached the end of the string, the function will end
    
    xor al, bl
    mov byte [edi], al
    mov al, bl            ; Copy of the previous value of the current byte
    
    jmp roll_xor_byte
    
end_rolling_xor:
    leave
    ret
    

; Function for task 3 used for decoding
xor_hex_strings:
    push ebp
    mov ebp, esp

    mov edi, [ebp + 12]   ; Address of the second string
    mov esi, [ebp + 8]    ; Address of the first string
    mov edx, edi          ; Copy for the address of the second string

xor_hex:
    ; The xor_hex_word is called to convert the current 
    ; 2 bytes of the second string from hex to decimal
    push edi
    call xor_hex_word

    ; The xor_hex_word is called to convert the current 
    ; 2 bytes of the first string from hex to decimal
    push esi
    call xor_hex_word

    pop esi               ; Get back the address for the first string
    pop edi               ; Get back the address for the second string

    ; Xor the new values obtained from the previous conversion
    mov al, byte [esi]      
    mov bl, byte [edi]

    ; Move the new value at the pointer of the current location in the second string
    xor al, bl
    mov byte [edx], al

    inc edx

    add edi, 2
    add esi, 2

    cmp byte [esi], 0    ; Check if it is the end of the string
    jne xor_hex

    mov byte [edx], 0    ; Add the string terminator 

    leave
    ret


; Auxiliar function used by xor_hex_strings function that converts from hex to dec
xor_hex_word:
    push ebp
    mov ebp, esp

    mov edi, [esp + 8]   ; Address of the string

    xor al, al
    mov al, byte [edi]   ; Copy of the first byte in the string

    cmp al, '9'          ; Check if it is a number or a letter to convert it in decimal
    jbe multiply
    sub al, 'a' - 10 - '0'

multiply:               
    sub al, '0'
    
    mov bl, 16           ; Multiply the number by 16  
    mul bl
    mov bl, al
    
    inc edi              ; Move to the second byte in the string
    xor al, al
    
    mov al, byte [edi]
    
    cmp al, '9'          ; Check if it is a number or a letter to convert it in decimal
    jbe sum
    sub al, 'a' - 10 - '0'
    
sum:                     ; Add it to the value from the first byte
    sub al, '0' 
    add bl, al

    dec edi
    mov byte [edi], bl   ; Move the new value in decimal at the current pointer in the string

    leave
    ret


; Function for task 4 used for decoding
base32decode:
    push ebp
    mov ebp, esp

    mov esi, [ebp + 8]   ; Address of the string
    mov edi, esi         ; Copy of the address of the string
    xor edx, edx

    ; Is computed the length of the string
    push edi
    call strlen
    pop edi
    
    mov ebx, eax         ; The value of the length is moved in ebx

decode:
    cmp byte [edi], 'A'  ; Check if it is a number or a letter to convert it in its number from the table 
    jb number
    
    mov al, byte [edi]   ; Each character is converted to its specific number from the table
    sub al, 'A'             
    mov byte [edi], al  
    
convert:
    inc edi 
    inc edx
    cmp edx, ebx         ; Checks if the current index is equal to the length of the string
    jb decode

    mov edi, esi
    xor edx, edx
    
    ; Is computed the number of steps needed to decode the characters from the pair of 8 bytes
    mov ecx, ebx
    shr ecx, 3
  
    jmp base32           ; Jumps to deconding after all the conversions were done
    
number:                 
    mov al, byte [edi]   ; The current character is checked if it is a number or a letter
    cmp al, '='
    jne not_number
    xor al, al           ; Converts a character representing a number to the number it represents in the table
    add al, '0' - 24
    
not_number:
    sub al, '0' -  24    ; Converts a character representing a number to the number it represents in the table
    mov byte [edi], al
    jmp convert

base32:
    push esi            ; The address of the string is pushed on the stack
    push edi            ; Pointer to the current position in the string is pushed on the stack
    call decode8bytes   ; The string will be decoded 8 bytes at a time from which will result 5 characters
    add esp, 8

    inc edx
    cmp edx, ecx        ; Checks if it is the final step
    jb base32

    leave
    ret


; Auxiliar function used by base32code function that decodes 8 bytes into 5 characters from the string
decode8bytes:
    push ebp
    mov ebp, esp
    
    mov edi, [esp + 8]  ; Pointer to the current position in the string 
    mov esi, [esp + 12] ; Address of the string
    
    ;Decoding the first character
    mov ah, byte [esi]
    inc esi
    shl ah, 3
    
    mov al, byte [esi]
    inc esi
    mov bl, al
    
    shr bl, 2
    add ah, bl
    
    mov byte [edi], ah
    inc edi

    ;Decoding the seond character
    shl al, 6
    
    mov ah, byte [esi]
    inc esi
    
    shl ah, 1
    add al, ah
    
    mov ah, byte [esi]
    inc esi
    
    mov bl, ah
    shr bl, 4
    
    add al, bl
    mov byte [edi], al
    inc edi

    ;Decoding the third character
    shl ah, 4
    
    mov al, byte [esi]
    inc esi
    mov bl, al
    
    shr bl, 1
    add ah, bl
    
    mov byte [edi], ah
    inc edi
    
    ;Decoding the fourth character
    shl al, 7
    
    mov ah, byte [esi]
    inc esi
    shl ah, 2
    
    add al, ah
    
    mov ah, byte [esi]
    inc esi
    mov bl, ah
    
    shr bl, 3
    add al, bl
    
    mov byte [edi], al
    inc edi

    ;Decoding the fifth character
    shl ah, 5
    
    mov al, byte [esi]
    inc esi

    add ah, al
    mov byte [edi], ah
    inc edi

    leave
    ret


; Function for task 5 used for decoding
bruteforce_singlebyte_xor:
    push ebp
    mov ebp, esp

    mov ecx, [ebp + 12] ; Address of the key for decoding
    mov esi, [ebp + 8]  ; Address of the string

    mov edi, esi
    mov byte [ecx], 0   ; Key is 0 at the beginning

bruteforce_key:
    xor eax, eax
    mov al, byte [ecx]

    cmp al, 0xff        ; Checks if key has the biggest value
    je end_bruteforce
    
    inc al              ; The key is incremented
    mov byte [ecx], al

xor_singlebyte:     
    mov al, byte [ecx]  ; Xor between each byte in the string and the current checked key
    xor al, byte [edi]

    mov byte [edi], al
    inc edi

    cmp byte [edi], 0   ; Checks if it is the final character in the string
    jnz xor_singlebyte

    push esi
    call search_for_force ; The function is called to search for the word "force" in the string
    add esp, 4
    
    cmp eax, 0          ; Checks the returned value
    je end_bruteforce   ; If the returned value is 0, the the string was found and the function can end
    
    mov ecx, [ebp + 12] ; Address of the key
    mov esi, [ebp + 8]  ; Address of the string

    mov edi, esi

reverse_xor:            ; If the key was not found the string is reset to the initial values
    mov al, byte [ecx]
    xor al, byte [edi]

    mov byte [edi], al
    inc edi

    cmp byte [edi], 0
    jnz reverse_xor
    
    mov edi, esi
    jmp bruteforce_key

end_bruteforce:
    leave
    ret


; Auxiliar function used by bruteforce_singlebyte_xor function that searches for word "force" in the string
search_for_force:
    push ebp
    mov ebp, esp

    xor ebx, ebx
    mov edi, [ebp + 8]   ; Address of the string 
    cld

search:
    ; Is computed the length of the string
    push edi
    call strlen
    pop edi
    
    mov ecx, eax         ; Copy of the length in ecx
    cmp byte [edi], 0    ; Check if it is the end of the string
    je fail
    
    mov al, 'f'          ; Search for f until first occurrence
    repne scasb
    
    cmp byte [edi], 0    ; Checks if it is the end of the string
    je fail
          
    cmp byte [edi], 'o'  ; Checks if the next character is 'o'
    jne search
    
    inc edi
    cmp byte [edi], 'r'  ; Checks if the next character is 'r'
    jne search
    
    inc edi
    cmp byte [edi], 'c'  ; Checks if the next character is 'c'
    jne search
    
    inc edi
    cmp byte [edi], 'e'  ; Checks if the next character is 'e'
    jne search
    jmp success

fail:
    mov ebx, 1

success:
    mov eax, ebx

    leave
    ret
    

; Function for task 6 used for decoding
break_substitution:
    push ebp
    mov ebp, esp
    
    mov esi, [ebp + 8]    ; Address for the string
    mov edi, [ebp + 12]   ; Address for the substitution table
    
    mov eax, edi          ; Copy of the address of the table
    add eax, 8            ; Get the address for the ' ' character
    
    mov ebx, esi
    
    push ebx              ; Add on the stack the address for the string
    push eax              ; Add on the stack the address for the space character
    call replace_character ; Call the replace function for the space character
    add esp, 8
    
    mov eax, edi          ; Copy of the address of the table
    add eax, 26           ; Get the address for the '.' character
    
    mov ebx, esi
    
    push ebx              ; Add on the stack the address for the string
    push eax              ; Add on the stack the address for the '.' character
    call replace_character ; Call the replace function for the dot character
    add esp, 8
    
    xor ecx, ecx
    
replace_characters:       ; Replace all the over characters
    mov ebx, esi
    mov eax, edi
    add eax, ecx
    push ecx
    
    push ebx              ; Add on the stack the address for the string
    push eax              ; Add on the stack the address for the current character
    call replace_character ; Call replace function for the current character
    add esp, 8
    
    pop ecx
    add ecx, 2
    cmp ecx, 56            ; Checks if it is the last character to be replaced
    jne replace_characters
    
    push edi               ; Add on the stack the address for the table
    call upper_to_lower_character ; Call the function to replace the letters from upper case to lower case
    add esp, 4
    
    push esi               ; Add on the stack the address for the string
    call upper_to_lower_character ; Call the function to replace the letters from upper case to lower case
    add esp, 3
    
    leave
    ret


; Auxiliar function used by break_substitution function that replaces a character
; in the text with its match in the substitution table
replace_character:
    push ebp
    mov ebp, esp
    
    mov ecx, [esp + 12]     ; Address for the string
    mov edx, [esp + 8]      ; Address for the character

replace_space:
    mov bl, byte [edx + 1]  ; Copy of the current character
    cmp byte [ecx], bl      ; Checks if the character should be replaced
    je replace
    
continue_replace_space:
    inc ecx
    cmp byte [ecx], 0       ; Checks if it is the end of the string
    jnz replace_space
    
    jmp end_substitution
    
replace:
    mov bl, byte [edx]      ; Replaces the character with its substitution
    mov byte [ecx], bl
    jmp continue_replace_space
    
end_substitution:
    leave
    ret


; Auxiliar function used by break_substitution function that converts letters
; from upper case to lower case      
upper_to_lower_character:
    push ebp
    mov ebp, esp
    
    mov edi, [ebp + 8]       ; Address for the string

replace_upper:
    mov al, byte [edi]       ; Checks if it is a letter and not a space or a dot
    cmp al, 'A'
    jge bigger
    
continue_replace_upper_to_lower:
    inc edi
    cmp byte [edi], 0        ; Checks if it is the end of the string
    jnz replace_upper
    
    jmp end_upper_to_lower
    
bigger:
    cmp al, 'a'              ; Checks if it is a big letter
    jnl continue_replace_upper_to_lower
 
    add al, 32               ; Converts from upper case to lower case
    mov byte [edi], al       ; Updates the value of the character
    jmp continue_replace_upper_to_lower

end_upper_to_lower:
    leave
    ret


; Main function
main:
    mov ebp, esp; for correct debugging
    push ebp
    mov ebp, esp
    sub esp, 2300

    ; fd = open("./input.dat", O_RDONLY);
    mov eax, 5
    mov ebx, filename
    xor ecx, ecx
    xor edx, edx
    int 0x80

	; Read(fd, ebp-2300, inputlen);
	mov ebx, eax
	mov eax, 3
	lea ecx, [ebp-2300]
	mov edx, [inputlen]
	int 0x80

	; Close(fd);
	mov eax, 6
	int 0x80

	; All input.dat contents are now in ecx (address on stack)

        push ecx       ; The starting address is saved on the stack

	; TASK 1: Simple XOR between two byte streams   

        ; Is computed the length of the first string
        push ecx
        call strlen
        add esp, 4

        push eax            ; The length of the first string is saved on the stack
        mov ecx, [esp + 4]
        
        push ecx            ; The address for the first string is added on the stack
        inc eax
        add ecx, eax        ; Is computed the address for the second string
        push ecx            ; The address for the second string is added on the stack
        call xor_strings    ; Call the function that decodes the string
        add esp, 8

        mov ecx, [esp + 4]  ; The address for the first sring is moved back in ecx
        
	; Print the first resulting string
	push ecx
	call puts
	add esp, 4

	; TASK 2: Rolling XOR

        pop eax             ; The length of the first string is moved back in eax
        pop ecx             ; The address for the first string is moved back in ecx
        
        inc eax             ; Is computed the address for the string needed for task 2
        add ecx, eax
        add ecx, eax        
        
        push ecx            ; The address for the string used at task 2 is saved on the stack
        
	push ecx            ; The string address pushed on the stack
	call rolling_xor    ; Call the function that decodes the string
    	add esp, 4

        mov ecx, [esp]      ; The address for the third string is moved back in ecx
      
	; Print the second resulting string        
	push ecx
	call puts
	add esp, 4

	; TASK 3: XORing strings represented as hex strings

        mov ecx, [esp]      ; The address for the third string is moved back in ecx
        
        
        ; Is computed the length of the third string
        push ecx 
        call strlen
        add esp, 4
        
        pop ecx             ; Is computed the address for the fourth string
        add ecx, eax
        inc ecx
        
        push ecx            ; The address for the fourth string is saved on the stack
        
        ; Is computed the length of the fourth string        
        push ecx
        call strlen
        add esp, 4

        push eax            ; The length of the fourth string is saved on the stack
        mov ecx, [esp + 4]  ; The address for the fourth string is moved back in ecx

        push ecx            ; The address for the fourth string is added on the stack
        inc eax
        add ecx, eax        ; Is computed the address of the fifth string
        push ecx            ; The address for the fifth string is added on the stack
        call xor_hex_strings; Call the function that decodes the string
        add esp, 8

        mov ecx, [esp + 4]  ; The address for the fourth string is moved back in ecx

	; Print the third resulting string
	push ecx
	call puts
	add esp, 4

	; TASK 4: decoding a base32-encoded string

        mov eax, [esp]      ; The length of the fourth string is moved back in eax
        mov ecx, [esp + 4]  ; The address for the fourth string is moved back in ecx
        add esp, 8

        inc eax             ; Is computed the address of the fifth string
        add ecx, eax
        add ecx, eax

        push ecx            ; Address for the fifth string

        push ecx            ; Is computed the length of the fifth string
        call strlen
        add esp, 4

        push eax            ; The length of the string is saved on the stack

        mov ecx, [esp + 4]  ; The address of the string is moved back in ecx

        push ecx            ; The address of the string is pushed on the stack
	call base32decode   ; Call the function that decodes the string
	add esp, 4

        mov ecx, [esp + 4]  ; The address of the string is moved back in ecx

	; Print the third resulting string
	push ecx           
	call puts
	add esp, 4

	; TASK 5: Find the single-byte key used in a XOR encoding

        pop eax             ; The length of the fifth string is moved back in eax
        pop ecx             ; The address of the fifth string is moved back in ecx

        add ecx, eax        ; The address of the sixth string is computed
        inc ecx

        push ecx
        sub esp, 1          ; Space for the key

        push esp            ; The address of the key is pushed on the stack
	push ecx            ; The address of the string is pushed on the stack
	call bruteforce_singlebyte_xor ; Call the function that decodes the string
	add esp, 8

	; Print the fifth resulting string and the found key value
        mov ecx, [esp + 1]
        
        ; Print the fifth resulting string
        push ecx
        call puts
        add esp, 4

        xor eax, eax
        mov al, byte [esp]
        add esp, 1
        
        ; Print the key
        push eax
	push fmtstr
	call printf
	add esp, 8

	; TASK 6: Break substitution cipher

        mov ecx, [esp]

        push ecx            ; Compute the length of the sixth string
        call strlen
        add esp, 4

        pop ecx             ; Compute the address of the
        add ecx, eax
        inc ecx

        push ecx            ; Address for the fifth string

        ; Create the substitution table in the stack
        sub esp, 56
        mov byte [esp + 56], 0
        mov byte [esp + 55], 'x'
        mov byte [esp + 54], '.'
        mov byte [esp + 53], 'c'
        mov byte [esp + 52], ' '
        mov byte [esp + 51], 'v'
        mov byte [esp + 50], 'Z'
        mov byte [esp + 49], 'z'
        mov byte [esp + 48], 'Y'
        mov byte [esp + 47], 'b'
        mov byte [esp + 46], 'X'
        mov byte [esp + 45], 'n'
        mov byte [esp + 44], 'W'
        mov byte [esp + 43], 'j'
        mov byte [esp + 42], 'V'
        mov byte [esp + 41], 'm'
        mov byte [esp + 40], 'U'
        mov byte [esp + 39], 'k'
        mov byte [esp + 38], 'T'
        mov byte [esp + 37], 'l'
        mov byte [esp + 36], 'S'
        mov byte [esp + 35], 's'
        mov byte [esp + 34], 'R'
        mov byte [esp + 33], 'a'
        mov byte [esp + 32], 'Q'
        mov byte [esp + 31], 'd'
        mov byte [esp + 30], 'P'
        mov byte [esp + 29], 'g'
        mov byte [esp + 28], 'O'
        mov byte [esp + 27], '.'
        mov byte [esp + 26], 'N'
        mov byte [esp + 25], 'h'
        mov byte [esp + 24], 'M'
        mov byte [esp + 23], 'f'
        mov byte [esp + 22], 'L'
        mov byte [esp + 21], 'p'
        mov byte [esp + 20], 'K'
        mov byte [esp + 19], 'o'
        mov byte [esp + 18], 'J'
        mov byte [esp + 17], 'i'
        mov byte [esp + 16], 'I'
        mov byte [esp + 15], 'y'
        mov byte [esp + 14], 'H'
        mov byte [esp + 13], 't'
        mov byte [esp + 12], 'G'
        mov byte [esp + 11], 'u'
        mov byte [esp + 10], 'F'
        mov byte [esp + 9], ' '
        mov byte [esp + 8], 'E'
        mov byte [esp + 7], 'e'
        mov byte [esp + 6], 'D'
        mov byte [esp + 5], 'w'
        mov byte [esp + 4], 'C'
        mov byte [esp + 3], 'r'
        mov byte [esp + 2], 'B'
        mov byte [esp + 1], 'q'
        mov byte [esp], 'A'

        mov eax, esp
        push eax            ; Copy of the address for the substitution table

	push eax            ; Add on the stack the address for the substitution table
	push ecx            ; Add on the stack the address for the string
	call break_substitution ; Call the function that decodes the string

        pop ecx

	; Print final solution (after some trial and error)
	push ecx
	call puts
	add esp, 4
        
        pop eax
        
	; Print substitution table
	push eax
	call puts
	add esp, 4

	; Phew, finally done
    xor eax, eax
    leave
    ret

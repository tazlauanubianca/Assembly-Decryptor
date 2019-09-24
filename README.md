# Assembly decryptor

The program follows the structure of the skeleton for decoding
strings from each task.

## I. Xor Strings

The function receives as parameters the starting addresses of the two
strings. The two strings travel together until the meeting
the string terminator and xor is made between the two values. The value
the obtained is saved on the corresponding position of the initial string.

## II. Rolling Xor

The function receives as a parameter the address of the string to be decoded.
The byte string is traveled until the string terminator is met. Is made
xor between the value of the current byte and the previous byte, being preserved
also a copy of the old value to be used in the next step.

## III. Xor Hex Strings

The function receives as a parameter the two strings of repre-
zentand numbers in base 16. The two strings are crossed simultaneously and
two characters are converted to base 10, xor between
them, and the result will be saved in one byte. Thus, the length of the string
initially theoretically it will be halved. Basically, it will keep
the size and only half of its characters will be modified at the end
them putting the string terminator to stop displaying only the characters
changed.
The function is used by an auxiliary function that receives as a parameter
just one string and performs the conversion of two characters from base 16 to base 10,
and to keep the value obtained, an auxiliary counter is used
only increases when a new value is entered.

## IV. Base32decode

The function receives as a parameter the address of the string. First of all
character in string is replaced by its corresponding numeric value from
table. Then groups of 8 bytes will be converted, each of which will result
5 characters. As in the previous task, a pointer will be held indicating the position
keep current in the string when it is filled with the values obtained.
The function is used by an auxiliary function that processes the groups
of 8 bytes in transforming them into the original message.

## V. Bruteforce singlebyte xor

The function receives as a parameter the address of the string and the address of the key
decryption. Each key is tested in turn and xor between
each byte in the string and the key being tested. After accomplishing this
operations an auxiliary function looks in the result string if the word is found
"Force". If the function is found terminates, if not then it will be done again
xor between the bytes of the string and the key to restore the string to the form
initial.


## VI. Break replacement

The function receives as parameters the address of the string and the address of the decryption table.
loud. First, the function will replace the spaces and points in the given string so that they do not
there is confusion about future replacements. The tables at the beginning will replace the letters
encrypted from the text with the ones in the real alphabet, but in large letters to be done
the difference between letters already replaced and those in the initial message. At the end of it all
the letters, both from the decryption table and from the string will be transformed into
lowercase letters with the help of an auxiliary function.

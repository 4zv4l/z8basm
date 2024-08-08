# z8basm

assembler for z8b

## Implementation

Currently the only implementation is in Perl and very ugly.

## Example

Example source code:
```
start:
    push 5
    pop  A
    push 2
    pop  B
    add  A B ; add B into A 
    push 4
    pop  C
    cmp  C A
    jmpz #end2
    ; this is a comment


end1:
    push 33
    pop B
end2:
    push 1

    pop  B
```

- the `start:` is optional, just make it prettier :)

Then to assemble: `./z8basm.pl [file]`.

The `a.out` generated file is now ready to be ran by `z8b`.

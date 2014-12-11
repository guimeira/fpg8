;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This program is written in the Chip-8 assembly language and is used to test    ;
;the Verilog implementation through a test fixture.                             ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;==Test the clear screen function==
CLS

;==Test the function calls, jumps and returns==
CALL TEST_CALL
JP TEST_JMP
JMP_RETURN: JP CONTINUE_TEST

TEST_CALL: RET

TEST_JMP: JP JMP_RETURN

CONTINUE_TEST:
;==Test skip functions==
LD V1,10
SE V1,10
LD V2,5 ;should be skipped
SE V1,20
LD V2,50 ;should be executed
SNE V2,0
LD V3,4 ;should be skipped
SNE V2,50
LD V3,65 ;should be executed
LD V8,0
LD V9,0
SE V8,V9
LD V8,29 ;should be skipped
SE V8,V1
LD V8,10 ;should be executed
SNE V8,V1
LD V8,23 ;should be skipped
SNE V8,V1
LD V8,90 ;should be executed

;==Test arithmetic==
LD V1,0
ADD V1,209
LD V2,53
OR V1,V2
AND V1,V2
XOR V1,V2
LD V1,50
LD V2,60
ADD V1,V2 ;add without carry
LD V1,200
LD V2,100
ADD V1,V2 ;add with carry
LD V1,100
LD V2,40
SUB V1,V2 ;sub without borrow
LD V1,40
LD V2,100
SUB V2,V1 ;sub with borrow
LD V1,100
LD V2,40
SUBN V1,V2 ;subn with borrow
LD V1,40
LD V2,100
SUBN V1,V2 ;subn without borrow
LD V1,2
SHR V1
SHR V1
SHL V1
SHL V1

;==Test data transfer between regs==
LD V1,100
LD V0,20
LD V1,V0
LD I,123
ADD I,V1
LD V1,5
LD F,V1

;==Test data transfer to memory and BCD function==
LD V1,200
LD I,200
ADD I,V1
LD V1,124
LD B,V1
LD V2,[I] ;read BCD results to V0,V1,V2
LD [I],VF ;store all registers
LD V0,0
LD V1,0
LD V2,0
LD V3,0
LD V4,0
LD V5,0
LD V6,0
LD V7,0
LD V8,0
LD V9,0
LD VA,0
LD VB,0
LD VC,0
LD VD,0
LD VE,0
LD VF,0
LD VF,[I] ;restore all registers from memory

;==Invoke screen scrolling functions==
SCD 3
SCR
SCL

;==Change screen mode==
HIGH
LOW

;==Exit==
EXT

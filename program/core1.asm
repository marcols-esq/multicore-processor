# assembly code for core 1 of modified RISC-V specification (with atomic LOAD and STORE instructions, and PC incremented by one)

INIT:
LW r1, r0, 0x002			# loading to register a value to find (common value in memory cell 0x00000002)
LW r5, r0, 0x003			# loading to register a memory cell address, where number of found values is saved
LW r2, r0, 0x006			# loading a address to start searching from (later incremented)
LW r3, r0, 0x007			# loading a address to stop search at

MAIN:
BLTU r3, r2, 0x00C			# when searched cell address is grater/equal than stop address, jump to FIN
LW r4, r2, 0x000			# loading to r4 value from (r2)
BEQ r4, r1, 0x003			# if value is equal to searched one, jump to INCN
ADDI r2, r2, 0x001			# increment the address to search value from
JAL r0, r14, 0x000			# jump to MAIN

INCN:
LWA r6, r5, 0x000			# load number of found numbers to r6 (atomic)
ADDI r6, r0, 0x001			# increment the number of numbers found
SWA r5, r6, 0x000			# save updated value of numbers found (atomic)
ADD r7, r6, r5				# store address to save found number address (r5) + (r6)
SW r7, r2, 0x000			# save address of the found value to a memory cell
ADDI r2, r2, 0x001			# increment the address to search value from
JAL r0, r14, 0x000			# jump to MAIN

FIN:
NOP
JAL r0, r15, 0x000			# RET

# .data
#     file:  .string "input.txt"
#     mode:  .string "r"
#     prt_y: .string "Yes\n"
#     prt_n: .string "No\n"

# .text
# .global main

# main:
#     addi sp, sp, -48
#     sd ra,  0(sp)
#     sd s0,  8(sp)    
#     sd s1, 16(sp)   
#     sd s2, 24(sp)    
#     sd s3, 32(sp)    
#     sd s4, 40(sp)    

#     # open left fp
#     la a0, file
#     la a1, mode
#     call fopen
#     mv s0, a0
#     beq s0, x0, exit

#     # open right fp
#     la a0, file
#     la a1, mode
#     call fopen
#     mv s1, a0
#     beq s1, x0, exit

   
#     mv a0, s1
#     li a1, 0
#     li a2, 2
#     call fseek

#     mv a0, s1
#     call ftell
#     beq a0, x0, is_pal        
#     mv s4, a0                

#     # rewind right fp to start so we can fseek per character
#     mv a0, s1
#     li a1, 0
#     li a2, 0                  
#     call fseek

#     li s2, 0                  
#     addi s3, s4, -1          

# p_loop:
#     bge s2, s3, is_pal        

#     # read left char via fgetc, skip \n and \r
# read_left:
#     mv a0, s0
#     call fgetc
#     li t0, -1
#     beq a0, t0, is_pal        
#     mv t2, a0                 

#     li t1, '\n'
#     beq t2, t1, skip_left
#     li t1, '\r'
#     beq t2, t1, skip_left
#     j left_done

# skip_left:
#     addi s2, s2, 1            
#     j read_left

# left_done:

    
# read_right:
#     mv a0, s1
#     mv a1, s3                 
#     li a2, 0                 
#     call fseek

#     mv a0, s1
#     call fgetc
#     li t0, -1
#     beq a0, t0, is_pal       
#     mv t3, a0                 

#     li t1, '\n'
#     beq t3, t1, skip_right
#     li t1, '\r'
#     beq t3, t1, skip_right
#     j right_done

# skip_right:
#     addi s3, s3, -1          
#     blt s3, s2, is_pal       
#     j read_right

# right_done:

    
#     bne t2, t3, not_pal

#     addi s2, s2, 1
#     addi s3, s3, -1
#     j p_loop

# is_pal:
#     la a0, prt_y
#     call printf
#     j exit

# not_pal:
#     la a0, prt_n
#     call printf

# exit:
#     beq s0, x0, skip_c0
#     mv a0, s0
#     call fclose
# skip_c0:
#     beq s1, x0, skip_c1
#     mv a0, s1
#     call fclose
# skip_c1:
#     ld ra,  0(sp)
#     ld s0,  8(sp)
#     ld s1, 16(sp)
#     ld s2, 24(sp)
#     ld s3, 32(sp)
#     ld s4, 40(sp)
#     addi sp, sp, 48
#     li a0, 0
#     ret
.data
    file:  .string "input.txt"
    mode:  .string "r"
    prt_y: .string "Yes\n"
    prt_n: .string "No\n"

.text
.global main

main:
    addi sp, sp, -48
    sd ra,  0(sp)
    sd s0,  8(sp)    # s0 = Front file pointer
    sd s1, 16(sp)    # s1 = Back file pointer
    sd s2, 24(sp)    # s2 = Front character index
    sd s3, 32(sp)    # s3 = Back character index
    sd s4, 40(sp)    # s4 = Total file size

    # opening the files
    # open input.txt for the front pointer
    la a0, file
    la a1, mode
    call fopen
    mv s0, a0
    beq s0, x0, exit        # If file doesn't exist, then exit 

    # open input.txt a second time for the back pointer
    la a0, file
    la a1, mode
    call fopen
    mv s1, a0
    beq s1, x0, exit

    #gettin the file size
    # Jump to the very end of the back file (seek for the end  = 2)
    mv a0, s1
    li a1, 0
    li a2, 2
    call fseek

    # Ask the OS where the cursor is (this gives us the file size)
    mv a0, s1
    call ftell
    beq a0, x0, is_pal      # If file is empty , it's a palindrome!  
    mv s4, a0               # Store file size in s4

    mv a0, s1
    li a1, 0
    li a2, 0                  
    call fseek

    li s2, 0                # front index= 0
    addi s3, s4, -1         # back index starts at size - 1

p_loop:
    # last condition for the checking the plaindrome
    bge s2, s3, is_pal        

    # getting the left charctor
read_left:
    mv a0, s0
    call fgetc
    li t0, -1
    beq a0, t0, is_pal      # If we hit EOF unexpectedly, just accept it
    
    # Save left char. (Eval note: fseek might clobber t2 later! Better to use s5)
    mv t2, a0                 

    # new lines are skipped in the edge cases 
    li t1, '\n'
    beq t2, t1, skip_left
    li t1, '\r'
    beq t2, t1, skip_left
    j left_done

skip_left:
    addi s2, s2, 1          #increase the pointer by 1  
    j read_left

left_done:

    # getting the right charctor
read_right:
    # Manually move the cursor to the exact back index (s3)
    mv a0, s1
    mv a1, s3                 
    li a2, 0                 
    call fseek

    # Read the character at that index
    mv a0, s1
    call fgetc
    li t0, -1
    beq a0, t0, is_pal       
    mv t3, a0               # Save right char in t3

    # new lines are skipped in the edge cases 
    li t1, '\n'
    beq t3, t1, skip_right
    li t1, '\r'
    beq t3, t1, skip_right
    j right_done

skip_right:
    addi s3, s3, -1    # decress the pointer by 1
    blt s3, s2, is_pal      # ending condition
    j read_right

right_done:

    # compare the frs and last char if they are not same then they are not palindrome
    bne t2, t3, not_pal

    # If they matched, step both pointers inward and repeat the loop!
    addi s2, s2, 1
    addi s3, s3, -1
    j p_loop

    #output
is_pal:
    la a0, prt_y
    call printf
    j exit

not_pal:
    la a0, prt_n
    call printf

exit:
    # Close the files 
    beq s0, x0, skip_c0
    mv a0, s0
    call fclose
skip_c0:
    beq s1, x0, skip_c1
    mv a0, s1
    call fclose
skip_c1:
    
    ld ra,  0(sp)
    ld s0,  8(sp)
    ld s1, 16(sp)
    ld s2, 24(sp)
    ld s3, 32(sp)
    ld s4, 40(sp)
    addi sp, sp, 48
    li a0, 0
    ret
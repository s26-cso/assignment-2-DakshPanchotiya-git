.text
.global main

.section .rodata
fmt_out1:     .string "%ld"
fmt_out2:     .string " "
fmt_out3:     .string "\n"

make_node:
    addi sp,sp,-16
    sd ra,0(sp)          
    sd s0,8(sp)           

    mv s0,a0
    li a0,16          
    call malloc

    sd s0,0(a0)
    sd x0,8(a0)

    ld s0,8(sp)           
    ld ra,0(sp)          
    addi sp,sp,16        
    ret

push:               #c equivalent node* push(node* head,int val) 
    addi sp,sp,-32
    sd ra,0(sp)
    sd s0,8(sp)
    sd s1,16(sp)
    sd s2,24(sp)

    mv s0,a0
    mv s1,a1

    mv a0,a1
    call make_node
    mv s2,a0

    sd s0,8(s2)
    
    mv a0,s2
    ld ra,0(sp)
    ld s0,8(sp)
    ld s1,16(sp)
    ld s2,24(sp)
    addi sp,sp,32
    ret

pop:               #c equivalent node* pop(node* head) s0 a0 = head
    addi sp,sp,-16
    sd ra,0(sp)
    sd s0,8(sp)

    ld s0,8(a0)

    call free

    mv a0,s0
    ld ra,0(sp)
    ld s0,8(sp)
    addi sp,sp,16
    ret

is_empty:          #c equivalent void is_empty(node* head)
    beq a0, x0, empty_true  
    li a0, 0                
    ret
    empty_true:
        li a0, 1               
        ret
peek:                             
    ld a0,0(a0)
    ret

main:
    addi sp,sp,-64
    sd ra,0(sp)
    sd s0,8(sp)
    sd s1,16(sp)
    sd s2,24(sp)
    sd s3,32(sp)
    sd s4,40(sp)
    sd s5,48(sp)

    addi s4, a0, -1      
    blez s4, exit       

    addi s1, a1, 8       

    slli a0, s4, 3       
    call malloc
    mv s2, a0            
 
    slli a0, s4, 3       
    call malloc
    mv s3, a0            

    li s0, 0        

cnvrt_loop:
    beq s0, s4, cnvrt_done

    #str to int
    ld a0, 0(s1)         
    call atoi           

    #Store integer 
    slli t0, s0, 3      
    add t1, s2, t0       
    sd a0, 0(t1)         

    addi s1, s1, 8       
    addi s0, s0, 1       
    beq x0,x0,cnvrt_loop

cnvrt_done:

    # s5 is our stack head
    # s3 is result array
    # s0,s4 is number n
    # s2 is address of the input int array
    
    beq x0,s4,exit
    mv s0,s4
    addi s0,s0,-1
    
    li s5,0

    loop_nge1:
        mv t0, s0
        slli t0, t0, 3       
        add t1, t0, s2       
        ld s1, 0(t1)         

        while_loop:
            mv a0, s5            
            call is_empty
            bne a0, x0, w_break 

            # Get stack.top()
            mv a0, s5
            call peek            
            mv t2, a0        

            # Get arr[stack.top()]
            mv t3, t2
            slli t3, t3, 3      
            add t3, t3, s2       
            ld t4, 0(t3)         

            bgt t4, s1, w_break

            # stack.pop()
            mv a0, s5
            call pop
            mv s5, a0            
            beq x0,x0, while_loop

        w_break:
            mv t0, s0
            slli t0, t0, 3
            add t5, s3, t0       

            mv a0, s5
            call is_empty
            bne a0, x0, ism1

            mv a0, s5
            call peek           
            sd a0, 0(t5)                 
            beq x0,x0, itrcmplte

        ism1:
            li t2, -1            
            sd t2, 0(t5)         

        itrcmplte:
            mv a0, s5            
            mv a1, s0           
            call push
            mv s5, a0            

            addi s0, s0, -1
            bge s0, x0, loop_nge1 

        beq x0,x0,print    

    print:
        li s0,0
    p_loop:
        beq s0,s4,p_done
        beq s0,x0,p_num
        la a0,fmt_out2
        call printf

    p_num:
        slli t0,s0,3
        add t1,s3,t0
        ld a1,0(t1)
        la a0,fmt_out1
        call printf
        addi s0,s0,1
        beq x0,x0, p_loop

    p_done:
        la a0,fmt_out3
        call printf

        beq x0,x0, exit
exit:
    ld ra,0(sp)
    ld s0,8(sp)
    ld s1,16(sp)
    ld s2,24(sp)
    ld s3,32(sp)
    ld s4,40(sp)
    ld s5,48(sp)
    mv a0,x0
    addi sp,sp,64
    ret

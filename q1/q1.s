.text
.globl make_node
.globl insert
.globl get
.globl getAtMost

make_node:
    addi sp,sp,-16
    sd ra,8(sp)           
    sd s0,0(sp)

    mv s0,a0
    li a0,24              
    call malloc

    sd s0,0(a0)           
    sd x0,8(a0)
    sd x0,16(a0)

    ld s0,0(sp)
    ld ra,8(sp)
    addi sp,sp,16
    ret

insert:
    addi sp,sp,-48       
    sd ra,40(sp)
    sd s0,32(sp)
    sd s1,24(sp)
    sd s2,16(sp)
    sd s3,8(sp)

    mv s0,a0
    mv s1,a1

    beq s0,x0,next0

    mv s2,s0
    li s3,0

    loop_ins:
        beq s2,x0,next

        ld t2,0(s2)       
        beq s1,t2,ins_done
        blt s1,t2,left
        blt t2,s1,right

        left:
            mv s3,s2
            ld s2,8(s2)   
            j loop_ins
        right:
            mv s3,s2
            ld s2,16(s2)  
            j loop_ins

    next0:
        mv a0,s1
        call make_node

        ld s0,32(sp)
        ld s1,24(sp)
        ld s2,16(sp)
        ld s3,8(sp)
        ld ra,40(sp)
        addi sp,sp,48
        ret

    next:
        ld t3,0(s3)
        blt s1,t3,left2
        blt t3,s1,right2

        left2:
            mv a0,s1
            call make_node

            sd a0,8(s3)   
            mv a0,s0

            ld s0,32(sp)
            ld s1,24(sp)
            ld s2,16(sp)
            ld s3,8(sp)
            ld ra,40(sp)
            addi sp,sp,48
            ret

        right2:
            mv a0,s1
            call make_node

            sd a0,16(s3)  
            mv a0,s0

            ld s0,32(sp)
            ld s1,24(sp)
            ld s2,16(sp)
            ld s3,8(sp)
            ld ra,40(sp)
            addi sp,sp,48
            ret

    ins_done:
        mv a0,s0

    ld s0,32(sp)
    ld s1,24(sp)
    ld s2,16(sp)
    ld s3,8(sp)
    ld ra,40(sp)
    addi sp,sp,48
    ret

get:
    addi sp,sp,-32        
    sd ra,24(sp)
    sd s0,16(sp)
    sd s1,8(sp)
    sd s2,0(sp)

    mv s0,a0
    mv s1,a1
    mv s2,s0

    loop_get:
        beq s2,x0,not_found
        ld t2,0(s2)       
        beq t2,s1,found

        blt s1,t2,left_g
        blt t2,s1,right_g

        left_g:
            ld s2,8(s2)   
            j loop_get

        right_g:
            ld s2,16(s2)  
            j loop_get

    found:
        mv a0,s2
        ld s2,0(sp)
        ld s1,8(sp)
        ld s0,16(sp)
        ld ra,24(sp)
        addi sp,sp,32
        ret

    not_found:
        mv a0,x0
        ld s2,0(sp)
        ld s1,8(sp)
        ld s0,16(sp)
        ld ra,24(sp)
        addi sp,sp,32
        ret

getAtMost:
    addi sp,sp,-48
    sd ra,40(sp)
    sd s0,32(sp)
    sd s1,24(sp)
    sd s2,16(sp)
    sd s3,8(sp)

    mv s0,a0
    mv s1,a1

    li s3,-1
    mv s2,a1

    beq s2,x0,gm_ret

    loop_gm:
        ld t1,0(s2)       

        beq t1,s0,retatk

        blt s0,t1,lefttoget
        blt t1,s0,righttoget

        retatk:
            mv a0,s0
            ld s3,8(sp)
            ld s2,16(sp)
            ld s1,24(sp)
            ld s0,32(sp)
            ld ra,40(sp)
            addi sp,sp,48
            ret

        lefttoget:
            ld s2,8(s2)   
            bne s2,x0,loop_gm
            j gm_ret

        righttoget:
            mv s3,t1
            ld s2,16(s2)  
            bne s2,x0,loop_gm

    gm_ret:
    mv a0,s3
    ld s3,8(sp)
    ld s2,16(sp)
    ld s1,24(sp)
    ld s0,32(sp)
    ld ra,40(sp)
    addi sp,sp,48
    ret

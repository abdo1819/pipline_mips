and $t5 $t5 $0
ori $t1  $t1 -1
ori $t7 $t7 -1###error
ori $t5 $t5 1###true
sra $t2  $t1 10
srl $t3 $t1  10
beq $t3 $t2 EQ
NQ:  sw $t5 0($0)
j END

 
EQ: sw $t7 0($0)
j END

 
  
   
   END: 
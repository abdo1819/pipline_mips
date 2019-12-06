and $t1, $t1,$0				
li $t2 0x41800888				
sw $t2 , 80($0)				
lwc1 $f2 ,80($0)				
						
and $t1, $t1,$0						


neg.s $f3 $f2 				
swc1 $f3 ,88($0)						

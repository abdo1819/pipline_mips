addi $1 , $0 ,0
ori $1 , $1 , 0xaafa
sw $1 , 80($0) # here i got 32'b[?16*0]1010101011111010? in the address stored at $0+80
addi $2 , $0 , 0xffff # $2 = 8'b11111111
sh $2 , 80($0) # store new byte at $0+80 where $1 was save expecting ($0+80) 
			   # to be 32'b[?16*0]1111111111111111
lw $2 , 80($0) # here $2 should equal 32'b[?16*0]1111111111111111
sw $2 , 80($0) # here  i will check if it working by checking 
			   # the value of $2 with my testbench
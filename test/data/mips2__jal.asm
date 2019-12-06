#Assembly Code
main: ori $t0, $0, 0x8000      #34088000 //t0 = 0x8000
      addi $t1, $0, -32768     #20098000 //t1 = 0x-8000
      ori $t2, $t0, 0x8001     #350a8001 //t2 = 0x8001
      beq $t0, $t1, there      #11090005 //t0!=t1 don't take
      slt $t3, $t1, $t0        #0128582a //t3 = 1
      jal here                 #15600001 //t3!=0 take
      j there                  #08100009 --
here: sub $t2, $t2, $t0        #01485022 //t2=8001-8000=1
      ori $t0, $t0, 0xFF       #350800ff //t0=0x80ff
      there: add $t3, $t3, $t2 #016a5820 //t3 = 2
      sub $t0, $t2, $t0        #01484022 //t0 =0xFFFF7F02
      sw $t0, 84($0)          #ad680052

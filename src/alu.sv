module alu(input  logic [31:0] a, b,
        input logic [4:0] shamt,
        input  logic [4:0]  alucontrol,
        output logic [31:0] result);

logic [31:0] bout, sum;
logic [4:0] shift;
assign bout = alucontrol[2] ? ~b : b; //for subtraction set alucontrol[2] to 1
assign sum = a + bout + alucontrol[2];
assign shift = alucontrol[0] ? shamt : a[4:0]; //for shift varaible alucontrol[0] = 0   

always_comb
 case (alucontrol) inside
   5'b?0?00: result = a & bout; //and 00000/ 
   5'b?0?01: result = a | bout; //or  00001
   5'b?0?10: result = sum;      //sub 00110/add 00010
   5'b?0?11: result = sum[31];  //slt 
   5'b01?0?: result = b << shift;  //sll 01000/sllv 01001
   5'b01?1?: result = b >> shift;  //srl 01010
   5'b11?1?: result = b >>>shift;  //sra 11010
 endcase

endmodule


module alu_require(input logic [31:0] a,b,
            input logic [4:0] shamt,
            input logic [4:0] f,
            output logic [31:0] y,
            output logic  zero,
            output logic [63:0] result);

logic [31:0] Q, Q1, R, R1;
logic finish, finish1;



divfile dv(a,b,Q,R,finish);
divufile dvu(a,b,Q1,R1,finish1);

always_comb
        case(f)
        5'b00000: y=a&b;
        5'b00001: y=a|b;
        5'b00010: y=a+b;
        5'b00011: y=(b<<shamt);//sll
        5'b00100: y=a+(~b);
        5'b00101: y=a|(~b);
        5'b00110: y=a-b;
        5'b00111: //slt
        begin
                y=a-b;
                y=y[31]?'b1:'b0;
        end
        5'b01000: y = (b<<16); //lui
        5'b01001: y = a^b ; //xor  
        5'b01010: begin     //blez
                if((a[31]==1)|(a==0))
                        y=0 ;
                else
                        y=1;
                end
 
        5'b01011: y = ( b >> (a[4:0]) ); //srlv
        5'b01100: y=(b>>shamt); //srl
        5'b01101: y = ( $signed(b) >>> (a[4:0]) ); //srav
        5'b01110: y = a<b; //sltiu
        5'b01111: y = ( b << (a[4:0]) ); //srlv
        5'b10000: begin  //bgtz
          if (a>0)
            y=0;
          else
            y=1;
          end
        5'b10001: y=(b>>>shamt); // sra
        5'b10010: y = ( b << (a[4:0]) ); //sllv
        5'b10011: result = $signed(a) * $signed(b);  //mult
        5'b10100: y=~(a|b); // nor
        5'b10101: result = a * b; //multu
        5'b10110: begin result[31:0] <= Q; result[63:32] <= R; end //div
        5'b10111: begin result[31:0] <= Q1; result[63:32] <= R1; end //divu


        default: y=0;
        endcase


        assign zero =~(|y);


endmodule




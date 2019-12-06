module alu(input logic [31:0] a,b,
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



module alu_legacy(input  logic [31:0] a, b,
           input  logic [2:0]  alucontrol,
           output logic [31:0] result);

  logic [31:0] bout, sum;

  assign bout = alucontrol[2] ? ~b : b;
  assign sum = a + bout + alucontrol[2];

  always_comb
    case (alucontrol[1:0])
      2'b00: result = a & bout;
      2'b01: result = a | bout;
      2'b10: result = sum;
      2'b11: result = sum[31];
    endcase

endmodule

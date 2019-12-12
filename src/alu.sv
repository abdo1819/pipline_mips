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

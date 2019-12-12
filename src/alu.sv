module alu(input  logic [31:0] a, b,
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


module maindec(input   logic  [5:0] op,
    output  logic       memtoreg, memwrite,
    output  logic       branch, bne, alusrc,
    output  logic       regdst, regwrite,
    output  logic       jump, extend,
    output  logic [1:0] aluop);

logic [10:0] controls;
assign {regwrite, regdst, alusrc,
branch, bne, memwrite,
memtoreg, jump, extend, aluop} = controls;

always_comb
case(op)
6'b000000: controls <= 11'b11000000011; //Rtyp
6'b100011: controls <= 11'b10100010100; //LW
6'b101011: controls <= 11'b00100100100; //SW
6'b000100: controls <= 11'b00010000001; //BEQ
6'b001000: controls <= 11'b10100000100; //ADDI
6'b000010: controls <= 11'b00000001000; //J
6'b000101: controls <= 11'b00001000001; //BNE
6'b001101: controls <= 11'b10100000010; //ORI
default:   controls <= 11'bxxxxxxxxxxx; //???
endcase
endmodule

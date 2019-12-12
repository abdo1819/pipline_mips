`include "src/constants.sv"
module aludec(input   logic   [5:0] funct,
    input   logic   [1:0] aluop,
    output  logic  [4:0] alucontrol);

always_comb
case(aluop)
2'b00: alucontrol <= `EXE_ADD;  // add (for lw/sw/addi) 
2'b01: alucontrol <= `EXE_SUB;  //  sub (for beq/bne)
2'b10: alucontrol <= `EXE_OR;  //or (for ori)
default: case(funct)          // RTYPE
6'b100000: alucontrol <= `EXE_ADD; // ADD
6'b100010: alucontrol <= `EXE_SUB; // SUB
6'b100100: alucontrol <= `EXE_AND; // AND
6'b100101: alucontrol <= `EXE_OR; // OR
6'b101010: alucontrol <= `EXE_SLT; // SLT
6'b100011: alucontrol <= `EXE_SUB; //subu
6'b000010: alucontrol <= `EXE_SRL; //srl
6'b000011: alucontrol <= `EXE_SRA; //sra
6'b000100: alucontrol <= `EXE_SLLV; //sllv
default:   alucontrol <= 5'bxxxxx; // ???
endcase
endcase
endmodule

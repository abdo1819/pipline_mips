
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






module maindec_require(input logic [5:0] op,funct,
    output logic memtoreg, [1:0]memwrite,
    output logic branch, 
    output logic [1:0] alusrc,
    output logic regdst, regwrite,
    output logic jump,jr,
    output logic ne,
    output logic [1:0]half,
    output logic b,
    output logic [3:0] aluop,
    output logic lbu, link, spregwrite,mf, resmove, spaddr,
	output logic [3:0] fpu_control,
	output logic fpu_mem_write,
	output logic fp_regwrite,
	output logic mem_to_fp,fp_regdst);


	logic [29:0] controls;

    assign resmove = funct[3];
    assign spaddr = funct[1];

assign {regwrite, regdst, alusrc, branch, memwrite,
        memtoreg, jump,jr, aluop, ne, half, b, lbu, link, spregwrite, mf, fpu_control, fpu_mem_write 
                                                                    ,fp_regwrite ,mem_to_fp ,fp_regdst} = controls;


always_comb

    case(op)
        6'b000000: begin
		 // RTYPE
		controls[29] <= funct[5] | ~funct[4]&~funct[3] | ~funct[3]&~funct[0] ; //regwrite
		controls[28:21] <= 8'b10000000;                     //regdst to jump
		controls[20] <= ~funct[5] & ~funct[4] & funct[3] & ~funct[2] & ~funct[1]; //jr
		controls[19:11] <= 9'b111100000;                    //aluop to lbu
		controls[10] <= ~funct[5] & ~funct[4] & funct[3] & ~funct[2] & ~funct[1] & funct[0]; //link
		controls[9] <= ~funct[5] & funct[4] & ~funct[2] & funct[0] | ~funct[5] & funct[4] & funct[3] & ~funct[2]; //spregwrite
		controls[8] <= ~funct[5] & funct[4] & ~funct[3] & ~funct[2] & ~funct[0]; //mf
		controls[7:0] <= 8'b0;
	end
	6'b010001: begin
		//F-type
		case(funct)
			6'b000000: controls <= 30'b000000000000000000000000000101; // fpu add
			6'b000001: controls <= 30'b000000000000000000000000010101; // fpu subtract 
			6'b000010: controls <= 30'b000000000000000000000000100101; // fpu multi
		    6'b000001: controls <= 30'b000000000000000000000000110101; // fpu division
            6'b000111: controls <= 30'b000000000000000000000001010101; // fpu neg
            6'b000101: controls <= 30'b000000000000000000000001000101; // fpu abs
        	
		endcase
	end
        6'b100011: controls <= 30'b100100010000000000000000000000; // LW
        6'b101011: controls <= 30'b000100100000000000000000000000; // SW
        6'b000100: controls <= 30'b000010000000010000000000000000; // BEQ
        6'b001000: controls <= 30'b100100000000000000000000000000; // ADDI
        6'b001001: controls <= 30'b100100000000000000000000000000; // ADDIU
        6'b001101: controls <= 30'b101100000000110000000000000000; // ORI
        6'b000010: controls <= 30'b000000001000000000000000000000; // J        
        6'b000101: controls <= 30'b000010000000011000000000000000;  // BNQ
        6'b100001: controls <= 30'b100100010000000010000000000000; // LH
        6'b100000: controls <= 30'b100100010000000011000000000000; // LB
        6'b100100: controls <= 30'b100100000000000000100000000000; // lbu
        6'b001100: controls <= 30'b101100000001110000000000000000; //andi
        6'b000011: controls <= 30'b100000001000000000010000000000; //jal
        6'b001111: controls <= 30'b100100000001000000000000000000; // LUI
        6'b001110: controls <= 30'b100100000001010000000000000000; // XORI
        6'b000110: controls <= 30'b000010000000100000000000000000; // Blez	     	
        6'b001010: controls <= 30'b100100000001100000000000000000; //slti
        6'b001011: controls <= 30'b100100000010000000000000000000; //sltiu
        6'b000111: controls <= 30'b000010000011100000000000000000; //bgtz
        6'b100101: controls <= 30'b100100010000000100000000000000; //lhu
        6'b101001: controls <= 30'b000101000000000000000000000000; // sh
        6'b101000: controls <= 30'b000101100000000000000000000000; // sb
    	6'b110001: controls <= 30'b000100000000000000000000000110; // fpu load word
	    6'b111001: controls <= 30'b000100100000000000000000001000; // fpu save word
		
					
		
        

        default:   controls <= 30'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; // illegal op

    endcase
endmodule



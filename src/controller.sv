//  `include "building_blocks/flopers.sv"
//  `include "decoders/*"
// //  `include "decoders/maindec.sv"

module controller(input   logic        clk, reset,
                  input   logic  [5:0] opD, functD,
                  input   logic        flushE, equalD, nequalD,
                  output  logic        memtoregE, memtoregM, 
                  output  logic       memtoregW, memwriteM,
                  output  logic        pcsrcD, branchD, bneD, alusrcE,
                  output  logic       regdstE, regwriteE, 
                  output  logic       regwriteM, regwriteW,
                  output  logic       jumpD, extendD,
                  output  logic [2:0] alucontrolE);
				  
 logic [1:0] aluopD;
 logic       memtoregD, memwriteD, alusrcD,
            regdstD, regwriteD;
 logic [2:0] alucontrolD;
 logic       memwriteE;
 maindec_legacy md(opD, memtoregD, memwriteD, branchD, bneD,
            alusrcD, regdstD, regwriteD, jumpD, extendD,
            aluopD);
 aludec_legacy  ad(functD, aluopD, alucontrolD);
 assign pcsrcD = (branchD & equalD) | (bneD & nequalD);
 
 // pipeline registers
 floprc #(8) regE(clk, reset, flushE,
                 {memtoregD, memwriteD, alusrcD, 
                  regdstD, regwriteD, alucontrolD}, 
                 {memtoregE, memwriteE, alusrcE, 
                  regdstE, regwriteE,  alucontrolE});
 flopr #(3) regM(clk, reset, 
                 {memtoregE, memwriteE, regwriteE},
                 {memtoregM, memwriteM, regwriteM});
 flopr #(2) regW(clk, reset, 
                 {memtoregM, regwriteM},
                 {memtoregW, regwriteW});
endmodule


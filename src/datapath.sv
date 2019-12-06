module datapath(input   logic         clk, reset,
                input   logic         memtoregE, memtoregM, memtoregW, 
                input   logic         pcsrcD, branchD, bneD,
                input   logic         alusrcE, regdstE,
                input   logic         regwriteE, regwriteM, regwriteW, 
                input   logic         jumpD, extendD,
                input   logic  [2:0]  alucontrolE,
                output  logic        equalD, nequalD,
                output  logic [31:0] pcF,
                input   logic  [31:0] instrF,
                output  logic [31:0] aluoutM, writedataM,
                input   logic  [31:0] readdataM,
                output  logic [5:0]  opD, functD,
                output  logic        flushE);

 logic        forwardaD, forwardbD;
 logic [1:0]  forwardaE, forwardbE;
 logic        stallF;
 logic [4:0]  rsD, rtD, rdD, rsE, rtE, rdE;
 logic [4:0]  writeregE, writeregM, writeregW;
 logic        flushD;
 logic [31:0] pcnextFD, pcnextbrFD, pcplus4F, pcbranchD;
 logic [31:0] signimmD, zeroimmD, immD, immE, signimmshD;
 logic [31:0] srcaD, srca2D, srcaE, srca2E;
 logic [31:0] srcbD, srcb2D, srcbE, srcb2E, srcb3E;
 logic [31:0] pcplus4D, instrD;
 logic [31:0] aluoutE, aluoutW;
 logic [31:0] readdataW, resultW;

 // hazard detection
 hazard    h(rsD, rtD, rsE, rtE, writeregE, writeregM, 
             writeregW,regwriteE, regwriteM, regwriteW, 
             memtoregE, memtoregM, branchD, bneD,
             forwardaD, forwardbD, forwardaE, 
             forwardbE,
             stallF, stallD, flushE);

 // next PC logic (operates in fetch and decode)
 mux2 #(32)  pcbrmux(pcplus4F, pcbranchD, pcsrcD, 
                     pcnextbrFD);
 mux2 #(32)  pcmux(pcnextbrFD,{pcplus4D[31:28], 
                   instrD[25:0], 2'b00}, 
                   jumpD, pcnextFD);

 // register file (operates in decode and writeback)
 regfile     rf(clk, regwriteW, rsD, rtD, writeregW,
                resultW, srcaD, srcbD);

// Fetch stage logic
 flopenr #(32) pcreg(clk, reset, ~stallF, 
                     pcnextFD, pcF);
 adder       pcadd1(pcF, 32'b100, pcplus4F);

// Decode stage 
 flopenr  #(32) r1D(clk, reset, ~stallD, pcplus4F,pcplus4D);
 flopenrc #(32) r2D(clk, reset, ~stallD, flushD, instrF, instrD);
 signext        se(instrD[15:0], signimmD);
 zeroext        ze(instrD[15:0], zeroimmD);
 mux2 #(32)     ext(zeroimmD, signimmD, extendD, immD);
 
 sl2         immsh(signimmD, signimmshD);
 adder       pcadd2(pcplus4D, signimmshD, pcbranchD);
 mux2 #(32)  forwardadmux(srcaD, aluoutM, forwardaD,srca2D);
 mux2 #(32)  forwardbdmux(srcbD, aluoutM, forwardbD,srcb2D);
 eqcmp       comp(srca2D, srcb2D, equalD);
 neqcmp      ncom(srca2D, srcb2D, nequalD);
 
 assign opD = instrD[31:26];
 assign functD = instrD[5:0];
 assign rsD = instrD[25:21];
 assign rtD = instrD[20:16];
 assign rdD = instrD[15:11];
 assign flushD = (pcsrcD & ~stallD) | jumpD;
 
 // Execute stage 
 floprc #(32) r1E(clk, reset, flushE, srcaD, srcaE);
 floprc #(32) r2E(clk, reset, flushE, srcbD, srcbE);
 floprc #(32) r3E(clk, reset, flushE, immD, immE);
 floprc #(5)  r4E(clk, reset, flushE, rsD, rsE);
 floprc #(5)  r5E(clk, reset, flushE, rtD, rtE);
 floprc #(5)  r6E(clk, reset, flushE, rdD, rdE);
 mux3 #(32)  forwardaemux(srcaE, resultW, aluoutM, forwardaE, srca2E);
 mux3 #(32)  forwardbemux(srcbE, resultW, aluoutM, forwardbE, srcb2E);
 mux2 #(32)  srcbmux(srcb2E, immE, alusrcE, srcb3E);
 alu         alu(srca2E, srcb3E, alucontrolE, aluoutE);
 mux2 #(5)   wrmux(rtE, rdE, regdstE, writeregE);
 
 // Memory stage
 flopr #(32) r1M(clk, reset, srcb2E, writedataM);
 flopr #(32) r2M(clk, reset, aluoutE, aluoutM);
 flopr #(5)  r3M(clk, reset, writeregE, writeregM);
 
 // Writeback stage
 flopr #(32) r1W(clk, reset, aluoutM, aluoutW);
 flopr #(32) r2W(clk, reset, readdataM, readdataW);
 flopr #(5)  r3W(clk, reset, writeregM, writeregW);
 mux2 #(32)  resmux(aluoutW, readdataW, memtoregW, resultW);
endmodule



module datapath_require(input logic clk, reset,
    input logic memtoreg, pcsrc,
    input logic [1:0] alusrc,
    input logic ne,
    input logic regdst, lbu, link,

    input logic regwrite, jump,jr, 
    input logic [1:0] half,
    input logic b,spregwrite, mf, resmove, spaddr,
    input logic [4:0] alucontrol,
    output logic zero,
    output logic [31:0] pc,
    input logic [31:0] instr,
    output logic [31:0] aluout, writedata,
    input logic [31:0] readdata,
    
    // fp
    
    
    input logic [3:0] fpucontrol ,
    
    input logic fpu_mem_write,fp_regwrite,mem_to_fp,fp_regdst
    );

logic [31:0] fpu_out;
logic [4:0] writereg,write_fpreg;
logic [31:0] pcnext, pcnextbr, pcplus4, pcbranch,pcnextj;
logic [31:0] signimm, signimmsh;
logic [31:0] srca, srcb;
logic [31:0] result,rd2,fp_wd3; // datamemory after the one byte design
logic [31:0] result_T; 
logic [31:0] bfresult ;
logic [4:0] outwrite;
logic [31:0] half_result_extended, half_result_extended0;
logic [31:0] hw_dataMemeoryOutput; // datamemory after the half word design
logic [31:0] one_byte_result_sign_extended;
logic [31:0] fp_srca,fp_srcb;
logic [63:0] specwd;
logic [31:0] firstresult;
logic [63:0] bigresult;
logic [31:0] highlowout;

mux2 #(64) resultormove({srca,srca}, bigresult, resmove, specwd);

highlow hl(clk, spregwrite, spaddr, specwd, highlowout);


// next PC logic
flopr #(32) pcreg(clk, reset, pcnext, pc);

adder pcadd1(pc, 32'b100, pcplus4); //normal +4

sl2 immsh(signimm, signimmsh); //jumb

adder pcadd2(pcplus4, signimmsh, pcbranch); //branch or jumb

//half
signext se2(result_T[15:0], half_result_extended); //extend sign
extnext ext0(result_T[15:0], half_result_extended0);
//mux after the halfword
// mux2 #(32) halfmux(result_T,half_result_extended,half,hw_dataMemeoryOutput);
mux3 #(32) halfmux(result_T,half_result_extended, half_result_extended0,half,hw_dataMemeoryOutput);
// one byte
signex #(24,8) se3(result_T[7:0], one_byte_result_sign_extended);
//mux after the one byte word
mux2 #(32) ob_mux(hw_dataMemeoryOutput,
        one_byte_result_sign_extended,
        b,
        bfresult);
mux2 #(32) jal_resmux(bfresult, pcplus4, link, firstresult);

mux2 #(32) movefrom(firstresult, highlowout, mf, result);

mux2 #(32) pcbrmux(pcplus4, pcbranch, pcsrc, pcnextbr);
mux2 #(32) pcmux(pcnextbr, {pcplus4[31:28],
        instr[25:0], 2'b00}, jump, pcnextj);
mux2 #(32) pcjrmux(pcnextj, srca, jr, pcnext);

regfile rf(clk, regwrite, instr[25:21], instr[20:16],
    writereg, result, srca, rd2);

mux2 #(5) wrmux(instr[20:16], instr[15:11],
        regdst, outwrite);
mux2 #(5) linkmux(outwrite, 5'b11111, link, writereg);
// mux2 #(32) resmux(aluout, readdata, memtoreg, result_T);
mux4 #(32) resmux(aluout, readdata, {24'b0,readdata[7:0]},{32'bx}, {lbu,memtoreg},result_T);////hey....:)from mux 2 to 4 and zero ext is modified with parameters ...good luck :)

signext se(instr[15:0], signimm); //extend sign

logic [31:0] extimm;
logic [31:0] zeroimm;
extnext ex(instr[15:0], zeroimm);
// ALU logic
mux2 #(32) srcbmux(rd2, extimm, alusrc[0], srcb);
mux2 #(32) extimux(signimm ,  zeroimm, alusrc[1], extimm);
alu alu(srca, srcb, instr[10:6], alucontrol, aluout, zero, bigresult); //inst[10:6] shamt


// Write data mux selector, either from regfile or fpregfile
mux2 #(32) fpmemmux(rd2,fp_srcb,fpu_mem_write,writedata); //overwrite rd2??
mux2 #(32) fw3(fpu_out,readdata,mem_to_fp,fp_wd3);
mux2 #(5) fwreg(instr[20:16],instr[10:6],fp_regdst,write_fpreg);
/* fpu and fpureg file  
note that mux that choose between regfile write data and fpwrite data isn't implemented yet
*/
fpregfile frf(clk, fp_regwrite, instr[15:11], instr[20:16],write_fpreg, fp_wd3, fp_srca, fp_srcb);
fpu fpu(clk,fpucontrol,fp_srca,fp_srcb,fpu_out);


endmodule
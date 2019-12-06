module zeroext(input  logic [15:0] a,
               output logic [31:0] y);
              
  assign y = {16'b0, a};
endmodule

module signext(input  logic [15:0] a,
               output logic [31:0] y);
              
  assign y = {{16{a[15]}}, a};
endmodule


//parameterized sign extenstion by abdullah khaled
module signex #(parameter extamount = 16,parameter inputsize = 16)
			   (input [inputsize-1:0]x,
			   output [inputsize+extamount-1:0]o);

assign o = {{extamount{x[inputsize-1]}},x};

endmodule



module flopr #(parameter WIDTH = 8)
              (input  logic             clk, reset,
               input  logic [WIDTH-1:0] d, 
               output logic [WIDTH-1:0] q);

  always_ff @(posedge clk, posedge reset)
    if (reset) q <= 0;
    else       q <= d;
endmodule


module flopenr #(parameter WIDTH = 8)
              (input  logic             clk, reset, en,
               input  logic [WIDTH-1:0] d, 
               output logic [WIDTH-1:0] q);

  always_ff @(posedge clk, posedge reset)
    if (reset)   q <= 0;
    else if (en) q <= d;
endmodule



module floprc #(parameter WIDTH = 8)
              (input   logic  clk, reset, clear,
               input   logic    [WIDTH-1:0] d, 
               output  logic   [WIDTH-1:0] q);
 always_ff @(posedge clk, posedge reset)
   if      (reset) q <= #1 0;
   else if (clear) q <= #1 0;
   else            q <= #1 d;
endmodule



module flopenrc #(parameter WIDTH = 8)
                (input   logic     clk, reset,
                 input   logic      en, clear,
                 input   logic  [WIDTH-1:0] d, 
                 output  logic [WIDTH-1:0] q);
 always_ff @(posedge clk, posedge reset)
   if      (reset) q <= #1 0;
   else if (clear) q <= #1 0;
   else if (en)    q <= #1 d;
endmodule

module imem(input   logic  [5:0]  a,
            output  logic [31:0] rd);
 logic  [31:0] RAM[63:0];
 initial
   begin
     $readmemh("memfile.dat",RAM);
   end
 assign rd = RAM[a]; // word aligned
endmodule



module dmem(input   logic         clk, we,
            input   logic  [31:0] a, wd,
            output  logic [31:0] rd);
 logic  [31:0] RAM[63:0];
 
 assign rd = RAM[a[31:2]]; // word aligned
 always_ff @(posedge clk)
   if (we)
     RAM[a[31:2]] <= wd;
endmodule

module regfile(input  logic        clk, 
               input  logic        we3, 
               input  logic [4:0]  ra1, ra2, wa3, 
               input  logic [31:0] wd3, 
               output logic [31:0] rd1, rd2);

  logic [31:0] rf[31:0];

  // three ported register file
  // read two ports combinationally
  // write third port on rising edge of clk
  // register 0 hardwired to 0
  // note: for pipelined processor, write third port
  // on falling edge of clk

  always_ff @(negedge clk)
    if (we3) rf[wa3] <= wd3;	

  assign rd1 = (ra1 != 0) ? rf[ra1] : 0;
  assign rd2 = (ra2 != 0) ? rf[ra2] : 0;
endmodule



module mux2 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, 
              input  logic             s, 
              output logic [WIDTH-1:0] y);

  assign y = s ? d1 : d0; 
endmodule



module mux3 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, d2,
              input  logic [1:0]       s, 
              output logic [WIDTH-1:0] y);

  assign #1 y = s[1] ? d2 : (s[0] ? d1 : d0); 
endmodule



module mux4 #(parameter WIDTH = 8)
             (input  logic [WIDTH-1:0] d0, d1, d2, d3,
              input  logic [1:0]       s, 
              output logic [WIDTH-1:0] y);

   always_comb
      case(s)
         2'b00: y <= d0;
         2'b01: y <= d1;
         2'b10: y <= d2;
         2'b11: y <= d3;
      endcase
endmodule


module adder(input  logic [31:0] a, b,
             output logic [31:0] y);

  assign y = a + b;
endmodule

module eqcmp(input  logic [31:0] a, b,
			 output logic y);
			 
	assign y = (a == b);
	
endmodule



module neqcmp(input  logic [31:0] a, b,
			 output logic y);
			 
	assign y = (a != b);
	
endmodule

module sl2(input  logic [31:0] a,
           output logic [31:0] y);

  // shift left by 2
  assign y = {a[29:0], 2'b00};
endmodule




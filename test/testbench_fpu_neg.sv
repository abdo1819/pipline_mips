module testbench_fpu_neg();

logic clk;
logic reset;
logic [31:0] writedata, dataadr;
logic [1:0]memwrite;
int i=0;
// instantiate device to be tested
top dut (clk, reset, writedata, dataadr, memwrite);

// initialize test
initial
    begin
    reset <= 1; # 22; reset <= 0;
    end

// generate clock to sequence tests
always
    begin
    clk <= 1; # 70; clk <= 0; # 70;
    end

// check results
always @(negedge clk)
    begin
        if (memwrite) begin
         
           
            if (dataadr === 88 & writedata === 32'hc1800888) begin
        	 
            
            		$display("succeed");
            		$stop;
                 end
    end
end
endmodule
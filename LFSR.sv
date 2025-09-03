
module LFSR (clk, reset, lfsr);
	input logic clk, reset;
	output logic [9:0] lfsr;
	
	always_ff @(posedge clk) begin
		if (reset)
			lfsr <= 10'b0;
		else
			lfsr <= {lfsr[8:0], ~(lfsr[9] ^ lfsr[6])};
	end
endmodule

module LFSR_testbench();
	logic clk, reset;
	logic [9:0] lfsr;
	
	LFSR dut (.clk(clk), .reset(reset), .lfsr(lfsr));
	
	parameter CLOCK_PERIOD = 100;
   initial begin
       clk <= 0;
       forever #(CLOCK_PERIOD / 2) clk <= ~clk; // Forever toggle the clock
   end
	
	initial begin
		reset = 1;
		@(posedge clk);
		reset = 0;
		@(posedge clk);
		
		repeat(100) @(posedge clk);
		$stop;
	end
endmodule




module cyberPlayer (clk, reset, SW, out);
	input logic clk, reset;
	input logic [8:0] SW;
	output logic out;
	
	logic [9:0] in;
	
	LFSR player (.clk(clk), .reset(reset), .lfsr(in));
	comparator comparing (.A({1'b0, SW[8:0]}), .B(in), .Agreater(out));
endmodule

module cyberPlayer_testbench();
	logic clk, reset;
	logic [8:0] SW;
	logic out;
	
	cyberPlayer test (.clk(clk), .reset(reset), .SW(SW), .out(out));
	
	parameter CLOCK_PERIOD = 100;
   initial begin
       clk <= 0;
       forever #(CLOCK_PERIOD / 2) clk <= ~clk; // Forever toggle the clock
   end
	
	initial begin
		SW[8:0] = 9'b0; // All switches are off
		@(posedge clk);
		
		// Reset
		reset <= 1; 
		@(posedge clk);
      reset <= 0; 
		@(posedge clk);
		SW = 9'b000000011; repeat(10) @(posedge clk);
		
		reset <= 1; 
		@(posedge clk);
      reset <= 0; 
		@(posedge clk);
		SW = 9'b000000111; repeat(10) @(posedge clk);
		
		reset <= 1; 
		@(posedge clk);
      reset <= 0; 
		@(posedge clk);
		SW = 9'b000001111; repeat(10) @(posedge clk);
		
		$stop;
	end
endmodule

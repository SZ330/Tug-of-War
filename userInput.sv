
module userInput (clk, reset, KEY, out);
	input logic clk, reset, KEY;
   output logic out;
   // logic ff1, ff2;
	 
	enum logic {on = 1'b1, off = 1'b0} ps, ns;
	 
	always_comb begin
		case (ps)
			off: ns = (KEY == 0) ? on : off;
			on: ns = (KEY == 1) ? off : on;
		endcase
	end
	 
	always_ff @(posedge clk) begin
		if (reset)
			ps <= off;
		else
			ps <= ns;
	end
	
	assign out = (ps == off && ns == on);
endmodule



module userInput_testbench();
	logic clk, reset, KEY;
	logic out;
	
	userInput player (clk, reset, KEY, out);
	
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end

	// Set up the inputs to the design. Each line is a clock cycle.
	initial begin
        // Reset
        reset <= 1; KEY <= 0; @(posedge clk);
        reset <= 0;          @(posedge clk);

        // Single button press
        KEY <= 0; repeat (2) @(posedge clk);
        KEY <= 1; repeat (2) @(posedge clk);
        KEY <= 0; repeat (2) @(posedge clk);
		  @(posedge clk);
		  @(posedge clk);
		  @(posedge clk);
		  @(posedge clk);
		  @(posedge clk);
		  KEY <= 0; repeat (2) @(posedge clk);
        KEY <= 1; repeat (2) @(posedge clk);
        KEY <= 0; repeat (2) @(posedge clk);
		  @(posedge clk);
		  @(posedge clk);
		  @(posedge clk);
		  @(posedge clk);
		$stop;
	end
endmodule

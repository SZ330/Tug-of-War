
module counters (clk, reset, win, score);
	input logic clk, reset, win;
	output logic [6:0] score;
	
	logic [2:0] counter;
	
	always_ff @(posedge clk) begin
		if (reset)
			counter <= 3'b000;
		else if (win & (counter != 3'b111))
			counter <= counter + 1'b1;
   end
	
	always_comb begin
		case(counter)
			3'b000: score = 7'b1000000;  // 0
			3'b001: score = 7'b1111001;  // 1
			3'b010: score = 7'b0100100;  // 2
			3'b011: score = 7'b0110000;  // 3
			3'b100: score = 7'b0011001;  // 4
			3'b101: score = 7'b0010010;  // 5
			3'b110: score = 7'b0000010;  // 6
			3'b111: score = 7'b1111000;  // 7
		endcase
	end
endmodule

module counters_testbench ();
	logic clk, reset, win;
	logic [6:0] score;
	
	counters count (.clk(clk), .reset(reset), .win(win), .score(score));
	
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
	
	initial begin
		// Initialize inputs
		clk <= 0;
		reset <= 0;
		win <= 0;
		@(posedge clk);

		// Test 1: Reset the counter
		reset <= 1;
		@(posedge clk);
		reset <= 0;
		@(posedge clk);

		win <= 1;
		@(posedge clk);
		win <= 0;
		@(posedge clk);

		win <= 1;
		@(posedge clk);
		win <= 0;
		@(posedge clk);
		
		win <= 1;
		@(posedge clk);
		win <= 0;
		@(posedge clk);
		
		win <= 1;
		@(posedge clk);
		win <= 0;
		@(posedge clk);
		
		win <= 1;
		@(posedge clk);
		win = 0;
		@(posedge clk);
		
		win <= 1;
		@(posedge clk);
		win <= 0;
		@(posedge clk);
		
		$stop;
	end
endmodule
	

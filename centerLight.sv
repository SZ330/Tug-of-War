module centerLight (clk, reset, L, R, NL, NR, lightOn);
	input logic clk, reset;
	input logic L, R, NL, NR;
	output logic lightOn;
	
	// L is true when left key is pressed, R is true when the right key
	// is pressed, NL is true when the light on the left is on, and NR
	// is true when the light on the right is on.
	// when lightOn is true, the center light should be on.
		
	enum logic {on = 1'b1, off = 1'b0} ps, ns;
	
	// State logic
	always_comb begin
		case (ps)
			on: ns = (L ^ R) ? off : on;
			off: ns = ((NL & R & ~L) | (NR & L & ~R)) ? on : off;
		endcase
	end
	
	
	// Output logic
	assign lightOn = (ps == on);
	
	
	// Flip flop
	always_ff @(posedge clk) begin
		if (reset)
			ps <= on;
		else 
			ps <= ns;
	end
endmodule


// Testbench for center light
module centerLight_testbench();
    logic clk, reset, L, R, NL, NR;
    logic lightOn;
    
    // Instantiate the module under test
    centerLight dut (.clk(clk), .reset(reset), .L(L), .R(R), .NL(NL), .NR(NR), .lightOn(lightOn));
    
    // Set up a simulated clock.
    parameter CLOCK_PERIOD = 100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD / 2) clk <= ~clk; // Forever toggle the clock
    end

    // Set up the inputs to the design.
    initial begin
        // Case 1: Reset
        reset <= 1; L <= 0; R <= 0; NL <= 0; NR <= 0; @(posedge clk);
        reset <= 0;                                  @(posedge clk);

        // Case 2: No button presses (light should remain on)
        L <= 0; R <= 0; NL <= 0; NR <= 0; repeat (2) @(posedge clk);

        // Left button press, NL on (light should turn off)
        L <= 1; R <= 0; NL <= 0; NR <= 0; repeat (2) @(posedge clk);
		  
		  // Left neighbor on and right button press (light should turn on)
        L <= 0; R <= 1; NL <= 1; NR <= 0; repeat (2) @(posedge clk);

        // Right button press, NR on (light should turn off)
        L <= 0; R <= 1; NL <= 0; NR <= 0; repeat (2) @(posedge clk);

        // Right neighbor on and left button press (light should turn on)
        L <= 1; R <= 0; NL <= 0; NR <= 1; repeat (2) @(posedge clk);
        
		  $stop; // Stop the simulation
    end
endmodule


module normalLight (clk, reset, L, R, NL, NR, lightOn);
	input logic clk, reset;
	input logic L, R, NL, NR;
	output logic lightOn;
	
	// L is true when left key is pressed, R is true when the right key
	// is pressed, NL is true when the light on the left is on, and NR
	// is true when the light on the right is on.
	// when lightOn is true, the center light should be on.
	
	 enum logic {OFF = 1'b0, ON = 1'b1} ps, ns;

    // Next state logic
    always_comb begin
        ns = ps; // Default to current state
        case (ps)
            OFF: ns = ((NL & R & ~L) | (NR & L & ~R)) ? ON : OFF;
            ON:  ns = (L ^ R) ? OFF : ON;
        endcase
    end

    // State flip-flop
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            ps <= OFF; // Reset to OFF state
        else
            ps <= ns;
    end

    // Output logic
    assign lightOn = (ps == ON);
endmodule

// Testbench for center light
module normalLight_testbench();
    logic clk, reset, L, R, NL, NR;
    logic lightOn;
    
    // Instantiate the module under test
    normalLight dut (.clk(clk), .reset(reset), .L(L), .R(R), .NL(NL), .NR(NR), .lightOn(lightOn));
    
    // Set up a simulated clock.
    parameter CLOCK_PERIOD = 100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD / 2) clk <= ~clk; // Forever toggle the clock
    end

    // Set up the inputs to the design.
    initial begin
        // Reset Behavior
        reset <= 1; L <= 0; R <= 0; NL <= 0; NR <= 0; @(posedge clk);
        reset <= 0; @(posedge clk);

		  
        // No button presses (light should remain off)
        repeat (2) @(posedge clk);

		  
        // Test Case 3: Left button press (light should turn off if it was on)
        L <= 1; R <= 0; NL <= 0; NR <= 0; @(posedge clk);
        L <= 0; @(posedge clk);

		  
        // Left neighbor on and right button press (light should turn on)
        NL <= 1; R <= 1; @(posedge clk);
        R <= 0; @(posedge clk);

		  
        // Right button press, NR off (light should turn off)
        NL <= 0; NR <= 0; L <= 0; R <= 1; @(posedge clk);
        R <= 0; @(posedge clk);

		  
        // Right neighbor on and left button press (light should turn on)
        NR <= 1; L <= 1; @(posedge clk);
        L <= 0; @(posedge clk);
		  
        $stop; // Stop the simulation
    end
endmodule

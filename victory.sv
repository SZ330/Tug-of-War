
module victory (clk, reset, leftKey, rightKey, leftLED, rightLED, player1Win, player2Win, playfieldReset);
	input logic clk, reset, leftKey, rightKey, leftLED, rightLED;
	output logic player1Win, player2Win, playfieldReset;
	logic [1:0] state;

   always_ff @(posedge clk) begin
		if (reset)
			state <= 2'b00;
      else begin
			if (leftLED & leftKey & ~rightKey)
				state <= 2'b01;
         else if (rightLED & rightKey & ~leftKey)
				state <= 2'b10;
		end
   end

   assign player1Win = (state == 2'b01);
   assign player2Win = (state == 2'b10);
   assign playfieldReset = (state != 2'b00);
endmodule 


module victory_testbench();
	 logic clk, reset, leftKey, rightKey, leftLED, rightLED, player1Win, player2Win, playfieldReset;
    
    victory won (.clk(clk), .reset(reset), .leftKey(leftKey), .rightKey(rightKey), .leftLED(leftLED), .rightLED(rightLED), .player1Win(player1Win), .player2Win(player2Win), .playfieldReset(playfieldReset));
    
    // Set up a simulated clock.
    parameter CLOCK_PERIOD = 100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD / 2) clk <= ~clk; // Forever toggle the clock
    end
	 
    initial begin
        clk = 0;
        reset = 0;
        leftKey = 0;
        rightKey = 0;
        leftLED = 0;
        rightLED = 0;
		  player1Win = 0;
		  player2Win = 0;
		  playfieldReset = 0;

        // Reset
        reset = 1;
        @(posedge clk);
        reset = 0;
        @(posedge clk);
		  
        // Player 1 wins
        leftLED = 1;
        leftKey = 1;
        rightKey = 0;
        repeat(5) @(posedge clk);

        // Reset again
        reset = 1;
		  leftKey = 0;
		  leftLED = 0;
		  @(posedge clk);
		  reset = 0;
        @(posedge clk);
		  @(posedge clk);

        // Player 2 wins
        rightLED = 1;
        rightKey = 1;
        leftKey = 0;
        repeat(5) @(posedge clk);

        $stop;
    end
endmodule

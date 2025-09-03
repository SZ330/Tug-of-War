
module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);
	input logic CLOCK_50; // 50MHz clock.
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY; 
	input logic [9:0] SW;
	logic left, right, player1Win, player2Win, playfieldReset, computerInput;
	
	assign HEX4 = 7'b1111111;
	assign HEX3 = 7'b1111111;
	assign HEX2 = 7'b1111111;
	assign HEX1 = 7'b1111111;

	// Generate clk off of clkSelect, whichClock picks rate.
	logic reset;
	logic [31:0] div_clk;
	
	assign reset = SW[9] | playfieldReset;
	
	parameter whichClock = 15; // 0.75 Hz clock
	clock_divider cdiv (.clock(CLOCK_50), .reset(reset), .divided_clocks(div_clk));
	
	logic clkSelect;
	
	// Clock selection; allows for easy switching between sim and board clocks
	// Detect when we're in Quartus and use the divided clock,
	// otherwise assume we're in ModelSim and use the fast clock
	`ifdef ALTERA_RESERVED_QIS
		assign clkSelect = div_clk[whichClock]; // for board
	`else
		assign clkSelect = CLOCK_50; // for simulation
	`endif
	
	cyberPlayer computer (.clk(clkSelect), .reset(reset), .SW(SW[8:0]), .out(computerInput));
	
	userInput player1 (.clk(clkSelect), .reset(reset), .KEY(~KEY[0]), .out(left));
	userInput player2 (.clk(clkSelect), .reset(reset), .KEY(computerInput), .out(right));
	
	centerLight center (.clk(clkSelect), .reset(reset), .L(left), .R(right), .NL(LEDR[4]), .NR(LEDR[6]), .lightOn(LEDR[5]));
		
	normalLight one (.clk(clkSelect), .reset(reset), .L(left), .R(right), .NL(1'b0), .NR(LEDR[2]), .lightOn(LEDR[1]));
	normalLight two (.clk(clkSelect), .reset(reset), .L(left), .R(right), .NL(LEDR[1]), .NR(LEDR[3]), .lightOn(LEDR[2]));
	normalLight three (.clk(clkSelect), .reset(reset), .L(left), .R(right), .NL(LEDR[2]), .NR(LEDR[4]), .lightOn(LEDR[3]));
	normalLight four (.clk(clkSelect), .reset(reset), .L(left), .R(right), .NL(LEDR[3]), .NR(LEDR[5]), .lightOn(LEDR[4]));
	normalLight six (.clk(clkSelect), .reset(reset), .L(left), .R(right), .NL(LEDR[5]), .NR(LEDR[7]), .lightOn(LEDR[6]));
	normalLight seven (.clk(clkSelect), .reset(reset), .L(left), .R(right), .NL(LEDR[6]), .NR(LEDR[8]), .lightOn(LEDR[7]));
	normalLight eight (.clk(clkSelect), .reset(reset), .L(left), .R(right), .NL(LEDR[7]), .NR(LEDR[9]), .lightOn(LEDR[8]));
	normalLight nine (.clk(clkSelect), .reset(reset), .L(left), .R(right), .NL(LEDR[8]), .NR(1'b0), .lightOn(LEDR[9]));
	
	victory won (.clk(clkSelect), .reset(reset), .leftKey(left), .rightKey(right), .leftLED(LEDR[1]), .rightLED(LEDR[9]), .player1Win(player1Win), .player2Win(player2Win), .playfieldReset(playfieldReset));
	counters player1Counter (.clk(clkSelect), .reset(SW[9]), .win(player1Win), .score(HEX0));
	counters player2Counter (.clk(clkSelect), .reset(SW[9]), .win(player2Win), .score(HEX5));
endmodule

module DE1_SoC_testbench();
	logic CLOCK_50;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;
	
	DE1_SoC dut (.CLOCK_50, .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .LEDR, .SW);
	
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50; // Forever toggle the clock
	end
	
	// Test the design.
	// 10 clock cycles for each pattern
	initial begin
		  // Initialize inputs
        KEY = 4'b1111; 
        SW = 10'b0; 
        @(posedge CLOCK_50);

        // Reset
        SW[9] = 1; 
        @(posedge CLOCK_50);
        SW[9] = 0; 
        @(posedge CLOCK_50);
		  
		  // Cyber player moves
		  SW[8:0] = 9'b111111111;
		  repeat (70) @(posedge CLOCK_50);
		  
		  // Reset and cyber player moves
        SW[9] = 1; 
        @(posedge CLOCK_50);
		  @(posedge CLOCK_50);
        SW[9] = 0; 
        @(posedge CLOCK_50);
		  @(posedge CLOCK_50);
		  SW[8:0] = 9'b000001111;
		  repeat (600) @(posedge CLOCK_50);
		  
		  repeat(100) @(posedge CLOCK_50);
		  // Player 1 moves right and wins
		  SW[9] = 1;
		  @(posedge CLOCK_50);
		  @(posedge CLOCK_50);
		  SW[9] = 0;
		  @(posedge CLOCK_50);
		  @(posedge CLOCK_50);
		  KEY[0] = 0; 
		  @(posedge CLOCK_50);
        KEY[0] = 1;
        @(posedge CLOCK_50);
		  KEY[0] = 0; 
		  @(posedge CLOCK_50);
        KEY[0] = 1; 
        @(posedge CLOCK_50);
		  KEY[0] = 0; 
		  @(posedge CLOCK_50);
        KEY[0] = 1; 
        @(posedge CLOCK_50);
		  KEY[0] = 0; 
		  @(posedge CLOCK_50);
        KEY[0] = 1; 
        @(posedge CLOCK_50);
		  KEY[0] = 0; 
		  @(posedge CLOCK_50);
        KEY[0] = 1; 
        @(posedge CLOCK_50);
		  KEY[0] = 0; 
		  @(posedge CLOCK_50);
        KEY[0] = 1; 
        @(posedge CLOCK_50);
		  KEY[0] = 1; 
        @(posedge CLOCK_50);
        
		  
		  // Simultaneous key presses (No movement)
//		  SW[9] = 1;
//		  @(posedge CLOCK_50);
//		  SW[9] = 0;
//		  @(posedge CLOCK_50);
//        KEY[3] = 0;
//        KEY[0] = 0;
//        repeat (5) @(posedge CLOCK_50);
//        KEY[3] = 1;
//        KEY[0] = 1;
//        @(posedge CLOCK_50);
		  
		  
		  // Left and right moves alternating
//		  SW[9] = 1;
//		  @(posedge CLOCK_50);
//		  SW[9] = 0;
//		  @(posedge CLOCK_50);
//		  
//		  KEY[3] = 0; 
//        @(posedge CLOCK_50);
//        KEY[3] = 1; 
//        @(posedge CLOCK_50);
//		  KEY[0] = 0; 
//        @(posedge CLOCK_50);
//        KEY[0] = 1; 
//        @(posedge CLOCK_50);
		  
		  
		  // Move to the right
//		  KEY[0] = 0; 
//        @(posedge CLOCK_50);
//        KEY[0] = 1; 
//        @(posedge CLOCK_50);
//		  KEY[0] = 0; 
//        @(posedge CLOCK_50);
//        KEY[0] = 1; 
//        @(posedge CLOCK_50);
//		  @(posedge CLOCK_50);
//		  @(posedge CLOCK_50);
//		  @(posedge CLOCK_50);
        
		  $stop;
	end
endmodule

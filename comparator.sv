
module comparator (A, B, Agreater);
	input logic [9:0] A, B;
	output logic Agreater;
	
	assign Agreater = (A > B);
endmodule

module comparator_testbench();
	logic [9:0] A, B;
	logic Agreater;
	
	comparator compare (.A(A), .B(B), .Agreater(Agreater));
	
	initial begin
		A = 10'b1111111111; B = 10'b0000000000; #10;
		A = 10'b0000000000; B = 10'b1111111111; #10;
		A = 10'b1111111111; B = 10'b1111111111; #10;
		$stop;
	end
endmodule

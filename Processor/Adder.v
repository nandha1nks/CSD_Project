
module Adder(
	input [31:0] in1,
	input [31:0] in2, 
	output [31:0] out);

	assign out = in1+in2;
endmodule 

module Adder_tb;
	reg [31:0] i1;
	reg [31:0] i2;
	wire [31:0] o;

	Adder test(i1, i2, o);
	
	initial begin 
		i1 = 32'h00000000;
		i2 = 32'h0f0f0f0f;
		#100
		i1 = 32'h000f0f0f;
		i2 = 32'hffffffff;
		#100
		i1 = 32'd0;
	end
endmodule 


module Mux5 (
	input [4:0] in1,
	input [4:0] in2, 
	input sel,
	output reg [4:0] out);
	
	always @(in1 or in2 or sel) begin
		if(sel == 0) begin out = in1; end
		else begin out = in2; end
	end
endmodule 

module Mux32 (
	input [31:0] in1,
	input [31:0] in2, 
	input sel,
	output reg [31:0] out);
	
	always @(in1 or in2 or sel) begin
		if(sel == 0) begin out = in1; end
		else begin out = in2; end
	end
endmodule 

module Mux32_tb;
	reg [31:0] i1;
	reg [31:0] i2;
	wire [31:0] o;
	reg sel;

	Mux32 test(i1, i2, sel, o);
		
	initial begin
		i1 = 32'd0;
		i2 = 32'd1;
		sel = 0;
		#100
		sel = 1;
		#100
		sel = 0;
	end
endmodule 
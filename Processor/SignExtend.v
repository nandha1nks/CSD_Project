
module SignExtend16(
	input [15:0] in,
	output reg [31:0] out);
	
	always @(in) begin
		out[15:0] = in;
		out[31:16] = {32{in[15]}};
	end
endmodule

module SignExtend16_tb;
	reg [15:0] in;
	wire[31:0] out;
	
	SignExtend16 test(in, out);

	initial begin
	in = 16'h0101;
	#100
	in = 16'hf101;
	#100
	in = 16'd0;
	end
endmodule 
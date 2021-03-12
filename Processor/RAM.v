
module RAM(
	input [31:0] address,
	input [31:0] in,
	input CONTROL_MEM_READ,
	input CONTROL_MEM_WRITE,
	output reg [31:0] out);

	reg [31:0] memory [31:0];

	always @(address or in or CONTROL_MEM_READ or CONTROL_MEM_WRITE) begin
		if (CONTROL_MEM_WRITE == 1) begin memory[address] = in; end
		if (CONTROL_MEM_READ == 1) begin out = memory[address]; end
	end
endmodule

module RAM_tb;
	reg [31:0] address;
	reg [31:0] in;
	reg CONTROL_MEM_READ;
reg CONTROL_MEM_WRITE;
	wire [31:0] out;

	RAM r(address,in,CONTROL_MEM_READ,CONTROL_MEM_WRITE,out);
	
	initial begin
	address = 32'h00000000;
	CONTROL_MEM_WRITE = 1;
	in = 32'h0f0f0f0f;
	#100
	CONTROL_MEM_READ = 1;
	#100
	$finish;
	end

endmodule

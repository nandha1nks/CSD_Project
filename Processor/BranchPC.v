
module BranchPC (
	input [31:0] pcPlus4,
	input [31:0] imm,
	output reg [31:0] branchPc);

	always @(pcPlus4 or imm) begin
		branchPc = pcPlus4 + (imm<<2);
	end
endmodule

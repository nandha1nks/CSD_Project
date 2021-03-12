
module Core
(
  input Clk,
  input [31:0] instruction,
  input [31:0] regData1,
  input [31:0] regData2,
  input [31:0] ramOutput,
  output reg CONTROL_REG_WRITE,
  output reg CONTROL_MEM_READ,
  output reg CONTROL_MEM_WRITE,
  output reg CONTROL_BRANCH,
  output reg [4:0] readReg1,
  output reg [4:0] readReg2,
  output [4:0] writeReg,
  output [31:0] aluOutput,
  output [31:0] writeRegData,
  output reg [31:0] PC
);

	reg CONTROL_REG_DST, CONTROL_ALU_SRC, CONTROL_MEM_TO_REG;
	reg CONTROL_JUMP, CONTROL_JUMP_REGISTER, CONTROL_LINK;
	wire CONTROL_BRANCH_SELECT;
	wire [5:0] CONTROL_ALU_BITS;

	reg [5:0] funct;
	wire [31:0] aluInput1;
	wire [31:0] aluInput2;
	wire aluZero;

	wire [31:0] pcPlus4;
	wire [31:0] jumpPc;
	wire [31:0] branchPc;
	wire [31:0] afterBranchPc;
	wire [31:0] nextPc;
	wire [31:0] afterJumpPc;

	reg [5:0]opcode;reg [4:0]s;reg [4:0]t;reg [4:0]d;reg [15:0]immediate;reg [4:0] shift;
	wire [31:0] signExtendedImmediate;

	Mux5 writeRegMux(t, d, CONTROL_REG_DST, writeReg);

	Mux32 alu1Mux(regData1, 32'd0, 1'b0, aluInput1);
	Mux32 alu2Mux(regData2, signExtendedImmediate, CONTROL_ALU_SRC, aluInput2);

	SignExtend16 immSignExtend(immediate, signExtendedImmediate);

	ALU_Control aluControl(opcode, funct, CONTROL_ALU_BITS);
	ALU alu(aluInput1, aluInput2, CONTROL_ALU_BITS, aluOutput, aluZero);

	reg [31:0] tempPc = 32'd0;
	reg [31:0] tempIns = 32'd0;
	Adder pcAdder(tempPc, 32'h00000004, pcPlus4);
	JumpPC gettingJumpPc(pcPlus4, tempIns, jumpPc);
	BranchPC gettingBranchPc(pcPlus4, signExtendedImmediate, branchPc);

	And branchAnd(aluZero, CONTROL_BRANCH, CONTROL_BRANCH_SELECT);
	Mux32 branchSelectPC(pcPlus4, branchPc, CONTROL_BRANCH_SELECT, afterBranchPc);
	Mux32 jumpSelectPC(afterBranchPc, jumpPc, CONTROL_JUMP, afterJumpPc);
	Mux32 jumpRegisterSelectPC(afterJumpPc, aluOutput, CONTROL_JUMP_REGISTER, nextPc);

	wire[31:0] afterMemOutput;
	Mux32 writeRegDataMux(aluOutput, ramOutput, CONTROL_MEM_TO_REG, afterMemOutput);
	Mux32 writeLinkPCMux(afterMemOutput, nextPc, CONTROL_LINK, writeRegData);
	
	initial begin PC = 32'h00000000; end
	
	always @(posedge Clk) begin
		tempPc = PC;
		tempIns = instruction;
		opcode = instruction[31:26];
		readReg1 = instruction[25:21];
		readReg2 = instruction[20:16];
		t = instruction[20:16];
		d = instruction[15:11];
		immediate = instruction[15:0];
		shift = instruction[10:6];
		funct = instruction[5:0];

		case(opcode)
			6'b000000:  begin     //R-Type Instruction
				CONTROL_REG_DST = 1;
				CONTROL_ALU_SRC = 0;
				CONTROL_REG_WRITE = 1;
				CONTROL_MEM_TO_REG = 0;
				CONTROL_MEM_READ = 0;
				CONTROL_MEM_WRITE = 0;
				CONTROL_BRANCH = 0;
				CONTROL_JUMP = 0;
				CONTROL_LINK = 0;
				if(funct == 6'b001000) begin CONTROL_JUMP_REGISTER = 1'b1; CONTROL_REG_WRITE = 1'b0; end
				else begin CONTROL_JUMP_REGISTER = 1'b0; CONTROL_REG_WRITE = 1'b1; end
				end
			6'b001000, 6'b001001, 6'b001100, 6'b001101, 6'b001010, 6'b001011, 6'b001110:  begin     //I-Type Instruction
				CONTROL_REG_DST = 0;
				CONTROL_ALU_SRC = 1;
				CONTROL_REG_WRITE = 1;
				CONTROL_MEM_TO_REG = 0;
				CONTROL_MEM_READ = 0;
				CONTROL_MEM_WRITE = 0;
				CONTROL_BRANCH = 0;
				CONTROL_JUMP = 0;
				CONTROL_LINK = 0;
				CONTROL_JUMP_REGISTER = 0;
				end
			6'b100000, 6'b100011: begin  //LW, LB
				CONTROL_REG_DST = 0;
				CONTROL_ALU_SRC = 1;
				CONTROL_REG_WRITE = 1;
				CONTROL_MEM_TO_REG = 1;
				CONTROL_MEM_READ = 1;
				CONTROL_MEM_WRITE = 0;
				CONTROL_BRANCH = 0;
				CONTROL_JUMP = 0;
				CONTROL_LINK = 0;
				CONTROL_JUMP_REGISTER = 0;
				end
			6'b101000, 6'b101011: begin  //SW, SB
				CONTROL_REG_DST = 0;
				CONTROL_ALU_SRC = 1;
				CONTROL_REG_WRITE = 0;
				CONTROL_MEM_TO_REG = 0;
				CONTROL_MEM_READ = 0;
				CONTROL_MEM_WRITE = 1;
				CONTROL_BRANCH = 0;
				CONTROL_JUMP = 0;
				CONTROL_LINK = 0;
				CONTROL_JUMP_REGISTER = 0;
				end
			6'b001111: begin  // lui
				CONTROL_REG_DST = 0;
				CONTROL_ALU_SRC = 1;
				CONTROL_REG_WRITE = 1;
				CONTROL_MEM_TO_REG = 0;
				CONTROL_MEM_READ = 0;
				CONTROL_MEM_WRITE = 0;
				CONTROL_BRANCH = 0;
				CONTROL_JUMP = 0;
				CONTROL_LINK = 0;
				CONTROL_JUMP_REGISTER = 0;
				end
			6'b000010: begin  // j
				CONTROL_REG_DST = 0;
				CONTROL_ALU_SRC = 0;
				CONTROL_REG_WRITE = 0;
				CONTROL_MEM_TO_REG = 0;
				CONTROL_MEM_READ = 0;
				CONTROL_MEM_WRITE = 0;
				CONTROL_BRANCH = 0;
				CONTROL_JUMP = 1;
				CONTROL_LINK = 0;
				CONTROL_JUMP_REGISTER = 0;
				end
			6'b000011: begin //jal
				d = 5'hff;
				CONTROL_REG_DST = 1;
				CONTROL_ALU_SRC = 0;
				CONTROL_REG_WRITE = 1;
				CONTROL_MEM_TO_REG = 0;
				CONTROL_MEM_READ = 0;
				CONTROL_MEM_WRITE = 0;
				CONTROL_BRANCH = 0;
				CONTROL_JUMP = 1;
				CONTROL_LINK = 1;
				CONTROL_JUMP_REGISTER = 0;
				end
			6'b000100, 6'b000111, 6'b000110, 6'b000101: begin //beq, bgtz, blez, bne
				CONTROL_REG_DST = 0;
				CONTROL_ALU_SRC = 0;
				CONTROL_REG_WRITE = 0;
				CONTROL_MEM_TO_REG = 0;
				CONTROL_MEM_READ = 0;
				CONTROL_MEM_WRITE = 0;
				CONTROL_BRANCH = 1;
				CONTROL_JUMP = 0;
				CONTROL_LINK = 0;
				CONTROL_JUMP_REGISTER = 0;
				end
			6'b000001: begin //bgez, bgezal
				CONTROL_REG_DST = 0;
				CONTROL_ALU_SRC = 0;
				CONTROL_REG_WRITE = 0;
				CONTROL_MEM_TO_REG = 0;
				CONTROL_MEM_READ = 0;
				CONTROL_MEM_WRITE = 0;
				CONTROL_BRANCH = 1;
				CONTROL_JUMP = 0;
				CONTROL_LINK = 0;
				CONTROL_JUMP_REGISTER = 0;

				if (t==6'b000000) begin funct=6'b110100; end
				if (t==6'b100000) begin CONTROL_LINK = 1; CONTROL_REG_DST = 1; d = 5'hff; funct=6'b110100; end
				if (t==6'b000001) begin funct=6'b110101; end
				if (t==6'b100001) begin CONTROL_LINK = 1; CONTROL_REG_DST = 1; d = 5'hff; funct=6'b110101; end
				end
		endcase
		#10
		PC = nextPc;
	end
endmodule 
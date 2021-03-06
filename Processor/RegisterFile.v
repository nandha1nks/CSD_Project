
module RegisterFile(
	input [4:0] readReg1,
	input [4:0] readReg2,
	input [4:0] writeReg,
	input [31:0] writeData,
	input CONTROL_REG_WRITE,
	output reg[31:0] readData1,
	output reg[31:0] readData2);

	reg [31:0] memory[7:0];

	initial begin 
		memory[0] = 32'h00000000;
		memory[2] = 32'h00000000;
		memory[3] = 32'h00000000;
		memory[4] = 32'h00000000;
		memory[5] = 32'h00000000;
		memory[6] = 32'h00000000;
		memory[7] = 32'h00000000;
		memory[1] = 32'h00000001;
	end

	always @(readReg1, readReg2 , writeReg , writeData , CONTROL_REG_WRITE) begin
		readData1 = memory[readReg1];
		readData2 = memory[readReg2];
		if(CONTROL_REG_WRITE == 1) begin #1 memory[writeReg] = writeData; end
	end
endmodule 

module RegisterFile_tb;
	reg [4:0] r1;reg[4:0] r2;reg[4:0] w;
	reg [31:0] wD;wire[31:0] rD1;wire [31:0] rD2;
	reg Control;

	RegisterFile register(r1, r2, w, wD, Control, rD1, rD2);

	initial begin
		r1 = 5'h00;
		r2 = 5'h01;
		w = 5'h00;
		wD = 32'hffffffff;
		Control = 1;
		#100
		Control = 0;
		wD = 32'hf0f0f0f0;
		#100
		Control = 1;
		w = 5'h01;
		r1 = 5'h01;
		#100
		r2 = 5'h00;
		r1 = 5'h01;
		#100
		$finish;
	end
endmodule 

module CPU;
	
	wire [31:0] ramOutput;
	wire [31:0] PC;
	wire [31:0] instruction;
	wire [4:0] readReg1;
	wire [4:0] readReg2;

	wire [4:0] writeReg;
	wire [31:0] writeRegData;
	wire [31:0] regData1;
	wire [31:0] regData2; 
	wire [31:0] aluOutput;


	reg Clk = 0;

	wire CONTROL_MEM_READ, CONTROL_MEM_WRITE, CONTROL_REG_WRITE, CONTROL_BRANCH;

	RAM ram (aluOutput, regData2, CONTROL_MEM_READ, CONTROL_MEM_WRITE, ramOutput);
	ROM rom (PC, instruction);
	RegisterFile register(readReg1, readReg2, writeReg, writeRegData, CONTROL_REG_WRITE, regData1, regData2);

	Core core(Clk,instruction, regData1, regData2, ramOutput, CONTROL_REG_WRITE, CONTROL_MEM_READ, CONTROL_MEM_WRITE,
  		CONTROL_BRANCH, readReg1, readReg2, writeReg, aluOutput, writeRegData, PC);

	//always begin #100 Clk = !Clk; end

	initial begin
		#10
		Clk = !Clk;
		#10
		Clk = !Clk;
		#10
		Clk = !Clk;
		#10
		Clk = !Clk;
		#10
		Clk = !Clk;
		#10
		Clk = !Clk;
		#10
		Clk = !Clk;
		#10
		Clk = !Clk;
		#10
		Clk = !Clk;
		#10
		Clk = !Clk;
		#10
		Clk = !Clk;
		#10
		Clk = !Clk;
		#10
		Clk = !Clk;
		#10
		Clk = !Clk;
		#10
		Clk = !Clk;
		#10
		Clk = !Clk;
		#10
		Clk = !Clk;
		#10
		Clk = !Clk;
		#10
		Clk = !Clk;
		#10
		Clk = !Clk;
		#10
		Clk = !Clk;
		#10
		Clk = !Clk;
		#10
		Clk = !Clk;
		#10
		Clk = !Clk;
	end
	
endmodule
	

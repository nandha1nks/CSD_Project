
module ROM (
	input [31:0] PC,
	output reg [31:0] instruction);

	reg [7:0] memory [63:0];

	initial begin 

		memory[0] = 8'b00111100; // lui $r0, 3
		memory[1] = 8'b00000010;
		memory[2] = 8'b00000000;
		memory[3] = 8'b00000011;

		memory[4] = 8'b00000000; // add $r1, $r0, $r0
		memory[5] = 8'b01000010;
		memory[6] = 8'b00011000;
		memory[7] = 8'b00100000;

		memory[8] = 8'b10101100; // sw $r1, $0(4)
		memory[9] = 8'b00000011;
		memory[10] = 8'b00000000;
		memory[11] = 8'b00000100;

		memory[12] = 8'b00010000; // beq $r0, $r0, -4
		memory[13] = 8'b01000010;
		memory[14] = 8'b11111111;
		memory[15] = 8'b11111100;

		memory[16] = 8'b00000000; // sllv $r2, $r0, $r0
		memory[17] = 8'b01000010;
		memory[18] = 8'b00100000;
		memory[19] = 8'b00000100;
		
		memory[20] = 8'b10001100; // lw $r3, $0, offset=0
		memory[21] = 8'b00000101;
		memory[22] = 8'b00000000;
		memory[23] = 8'b00000100;
		
		memory[24] = 8'b00000100; // bgezal, $0, (8)		
		memory[25] = 8'b00010001;
		memory[26] = 8'b00000000;
		memory[27] = 8'b00000001;

		memory[32] = 8'b00000011; // jr $31
		memory[33] = 8'b11100000;
		memory[34] = 8'b00000000;
		memory[35] = 8'b00001000; 

		memory[28] = 8'b00001100; // jal 5		
		memory[29] = 8'b01000000;
		memory[30] = 8'b00000000;
		memory[31] = 8'b00000100;
	end

	always @(PC) begin
		instruction[7:0] = memory[PC+3];
		instruction[15:8] = memory[PC+2];
		instruction[23:16] = memory[PC+1];
		instruction[31:24] = memory[PC];
	end
endmodule 

module ROM_tb;
	reg [31:0] PC;
	wire [31:0] instruction;

	ROM r(PC, instruction);

	initial begin
		PC = 32'h00000000;
		#100
		PC = 32'h00000004;
		#100
		PC = 32'h00000000;
	end
endmodule 
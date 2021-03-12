
module ALU_Control(
	input [5:0] opcode,
	input [5:0] funct,
	output reg[5:0] CONTROL_ALU_BITS);

	always @(opcode or funct) begin
		case(opcode)
			6'b000000: //R-Type
				begin CONTROL_ALU_BITS = funct; end
			6'b001000: //addi
				begin CONTROL_ALU_BITS = 6'b100000; end
			6'b001001: //addui
				begin CONTROL_ALU_BITS = 6'b100001; end
			6'b001100: //andi
				begin CONTROL_ALU_BITS = 6'b100100; end
			6'b001101: //ori
				begin CONTROL_ALU_BITS = 6'b100101; end
			6'b001010: //slti
				begin CONTROL_ALU_BITS = 6'b101010; end
			6'b001011: //sltiu
				begin CONTROL_ALU_BITS = 6'b101011; end
			6'b001110: //xori
				begin CONTROL_ALU_BITS = 6'b100110; end
			6'b100000, 6'b100011, 6'b101000, 6'b101011: //lw , lb, sw, sb
				begin CONTROL_ALU_BITS = 6'b100001; end
			6'b001111: //lui
				begin CONTROL_ALU_BITS = 6'b111000; end
			6'b000100: //beq
				begin CONTROL_ALU_BITS = 6'b110000; end
			6'b000101: //bne
				begin CONTROL_ALU_BITS = 6'b110001; end
			6'b000111: //bgtz
				begin CONTROL_ALU_BITS = 6'b110010; end
			6'b000110: //blez
				begin CONTROL_ALU_BITS = 6'b110011; end
			6'b000001: //bgez, bltz
				begin CONTROL_ALU_BITS = funct; end
			default: CONTROL_ALU_BITS = 6'bxxxxxx;
		endcase
	end
endmodule

module ALU_Control_tb;
	reg [5:0] o; reg[5:0] f; wire[5:0] co;
	ALU_Control aluControl(o, f, co);

	initial begin
		o = 6'b000000;
		f = 6'b100100;
		#100
		o = 6'b001000;
		#100
		o = 6'b001001;
		#100
		o = 6'b000000;
	end
endmodule

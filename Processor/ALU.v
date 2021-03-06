
module ALU (
	input signed [31:0] in1,
	input signed [31:0] in2,
	input [5:0] CONTROL_ALU_BITS,
	output reg[31:0] out, 
	output reg zero);
	
	reg [31:0] unsigned_in1;
	reg [31:0] unsigned_in2;


	always @(in1 or in2 or CONTROL_ALU_BITS) begin
		case(CONTROL_ALU_BITS) 
			6'b100000:   //ADD
				begin out = in1 + in2; zero = 1'b0; end
			6'b100001:   //ADDU
				begin 
					if (in1 < 16'd0) begin unsigned_in1 = -in1; end else begin unsigned_in1 = in1; end
					if (in2 < 16'd0) begin unsigned_in2 = -in2; end else begin unsigned_in2 = in2; end
					out = in1 + in2; zero = 1'b0; end 
			6'b100100:   //AND
				begin out = in1 & in2; zero = 1'b0; end
			6'b100101:   //OR
				begin out = in1 | in2; zero = 1'b0; end
			6'b100110:   //XOR
				begin out = in1 ^ in2; zero = 1'b0; end
			6'b100010:   //SUB
				begin out = in1 - in2; zero = 1'b0; end
			6'b100011:   //SUBU
				begin 
					if (in1 < 16'd0) begin unsigned_in1 = -in1; end else begin unsigned_in1 = in1; end
					if (in2 < 16'd0) begin unsigned_in2 = -in2; end else begin unsigned_in2 = in2; end
					out = in1 - in2; zero = 1'b0; end
			6'b000000, 6'b000100:   //SLL, SLV
				begin out = in1 << in2; zero = 1'b0; end
			6'b000011:   //SRA
				begin out = in1 >> in2; zero = 1'b0; end
			6'b000010:   //SRL
				begin if (in1 < 16'd0) begin unsigned_in1 = -in1; end else begin unsigned_in1 = in1; end
					out = in1 >> in2; zero = 1'b0; end
			6'b000110:   //SRLV
				begin out = in1 >> in2; zero = 1'b0; end
			6'b101010:  //SLT
				begin if (in1<in2) begin out = 32'd1; end else begin out = 32'd0; end zero=1'b0; end
			6'b101011:   //SLTU
				begin 
					if (in1 < 16'd0) begin unsigned_in1 = -in1; end else begin unsigned_in1 = in1; end
					if (in2 < 16'd0) begin unsigned_in2 = -in2; end else begin unsigned_in2 = in2; end
					if (unsigned_in1<unsigned_in2) begin out = 32'd1; end else begin out = 32'd0; end zero=1'b0; end
			6'b001000: //JUMP REGISTER
				begin out = in1; zero=1'b0; end
			6'b111000: //lui immediate shift
				begin out = in2; zero=1'b0; end
			6'b110000: // beq control
				begin out = 32'd0; zero = in1 == in2; end
			6'b110001: // bne control
				begin out = 32'd0; zero = in1 != in2; end
			6'b110010: // bgtz control
				begin out = 32'd0; zero = in1 > 32'd0; end
			6'b110011: // blez control
				begin out = 32'd0; zero = in1 <= 32'd0; end
			6'b110100: // bgez control
				begin out = 32'd0; zero = in1 >= 32'd0; end
			6'b110101: // bltz control
				begin out = 32'd0; zero = in1 < 32'd0; end
		endcase
	end
endmodule 

module ALU_tb;
	reg [31:0] in1;
	reg [31:0] in2;
	reg [5:0] Con;
	wire [31:0] out;
	wire zero;
	ALU alu(in1, in2, Con, out, zero);

	initial begin
		in1 = 32'h0fffffff;
		in2 = 32'hffffffff;
		Con = 6'b100000; //ADD
		#100;
		Con = 6'b100001; //ADDU
		#100;
		Con = 6'b100100; //AND
		#100;
		Con = 6'b100101; //OR
		#100;
		Con = 6'b100110; //XOR
		#100;
		Con = 6'b100010; //SUB
		#100;
		Con = 6'b100011; //SUBU
		#100;
		Con = 6'b000000; //SLL
		#100;
		Con = 6'b000100; //SLV 
		#100;
		Con = 6'b000011; //SRA
		#100;
		Con = 6'b000010; //SRL
		#100;
		Con = 6'b000110; //SRLV
		#100;
		Con = 6'b101010; //SLT
		#100;
		Con = 6'b101011; //SLTU
		#200
		Con = 6'b000000;
	end
endmodule 
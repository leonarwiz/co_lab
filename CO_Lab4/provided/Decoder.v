`timescale 1ns/1ps

module InstructionDecoder(
    opcode_i,
	  functionCode_i,
	  registerWrite_o,
	  ALUOperation_o,
	  ALUSrc_o,
	  registerDestination_o,
	  branch_o,
	  jump_o, 
	  memoryRead_o, 
	  memoryWrite_o,
	  memoryToRegister_o,
	  branchType_o
	);
     
//I/O ports
input  [6-1:0] opcode_i;
input  [6-1:0] functionCode_i;

output         registerWrite_o;
output [3-1:0] ALUOperation_o;
output         ALUSrc_o;
output         registerDestination_o;
output         branch_o;
output		     memoryRead_o, memoryWrite_o, jump_o, memoryToRegister_o;
output [2-1:0] branchType_o;
 
//Internal Signals
reg    [3-1:0] ALUOperation_o;
reg            ALUSrc_o;
reg            registerWrite_o;
reg            registerDestination_o;
reg            branch_o;
reg 		       memoryRead_o, memoryWrite_o, jump_o, memoryToRegister_o;
reg    [2-1:0] branchType_o;

//Main function
always @(*) begin
	case(opcode_i)
		// R-type instructions: add, sub, and, or, slt, jr
        6'b000000: begin
			{ ALUOperation_o, registerWrite_o, ALUSrc_o, registerDestination_o, branch_o } <= 7'b0101010;
			case(functionCode_i)
				6'b001000: begin // jr
					{ jump_o, memoryRead_o, memoryWrite_o, memoryToRegister_o, branchType_o } <= 6'b0000000;
				end
				default: begin
					{ jump_o, memoryRead_o, memoryWrite_o, memoryToRegister_o, branchType_o } <= 6'b100000;
				end
			endcase
		end
        // addi, lw, sw, beq, slti, jump, jal
        // Implement the cases similar to the example above
        default: begin
			{ ALUOperation_o, registerWrite_o, ALUSrc_o, registerDestination_o, branch_o } <= 7'bxxxxxxx;
			{ jump_o, memoryRead_o, memoryWrite_o, memoryToRegister_o, branchType_o } <= 6'bxxxxxx;
		end
	endcase
end

endmodule

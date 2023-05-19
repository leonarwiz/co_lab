`timescale 1ns/1ps

module ALU(
    operandA_i,
	  operandB_i,
	  operation_i,
	  result_o,
	  isZero_o
	  );
     
//I/O ports
input  [32-1:0]  operandA_i;
input  [32-1:0]	 operandB_i;
input  [4-1:0]   operation_i;

output [32-1:0]	 result_o;
output           isZero_o;

//Internal signals
reg    [32-1:0]  result_o;
wire             isZero_o;

//Parameter
assign isZero_o = (result_o == 0);

//Main function 
always @(operation_i, operandA_i, operandB_i) begin
    case (operation_i)
        4'b0000: result_o <= operandA_i & operandB_i;   // AND operation
        4'b0001: result_o <= operandA_i | operandB_i;   // OR operation
        4'b0010: result_o <= operandA_i + operandB_i;   // Addition
        4'b0011: result_o <= operandA_i ^ operandB_i;   // XOR operation
        4'b0110: result_o <= operandA_i - operandB_i;   // Subtraction
        4'b0111: result_o <= (operandA_i < operandB_i) ? 1 : 0;  // Less than operation
        4'b1110: result_o <= operandA_i * operandB_i;   // Multiplication
        default: result_o <= 0;
    endcase
end

endmodule

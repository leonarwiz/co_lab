`timescale 1ns/1ps

module ALU_Control(
    functionCode_i,
    ALUOperation_i,
    ALUControl_o
    );
          
//I/O ports 
input      [6-1:0] functionCode_i;
input      [3-1:0] ALUOperation_i;

output     [4-1:0] ALUControl_o;    
     
//Internal Signals
reg        [4-1:0] ALUControl_o;

       
//Select exact operation
always @(*) begin
   case (ALUOperation_i)
       3'b010: begin // R-format
           case (functionCode_i)
               6'b100000: ALUControl_o <= 4'b0010;    // add -> 0010
               6'b100010: ALUControl_o <= 4'b0110;    // sub -> 0110
               6'b100100: ALUControl_o <= 4'b0000;    // and -> 0000
               6'b100101: ALUControl_o <= 4'b0001;    // or    -> 0001
               6'b101010: ALUControl_o <= 4'b0111;    // slt   ->0111
               6'b001100: ALUControl_o <= 4'b1110;    // mult
               default:     ALUControl_o <= 4'bxxxx;
           endcase
       end
       3'b000:  ALUControl_o <= 4'b0010;                  // addi, lw, sw -> add
       3'b001:  ALUControl_o <= 4'b0110;                  // beq  -> sub
       3'b011:  ALUControl_o <= 4'b0111;                  // slti  -> slt
       default: ALUControl_o <= 4'bxxxx;
   endcase
end

endmodule

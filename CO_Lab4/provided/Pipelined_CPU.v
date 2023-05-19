`timescale 1ns / 1ps

module Pipelined_CPU(
    clk_i,
    rst_i
    );
    
/****************************************
I/O ports
****************************************/
input clk_i;
input rst_i;

/****************************************
Internal signal
****************************************/
/**** IF stage ****/
output wire [32-1:0] pc_pre, pc, pc_next0;
output wire [32-1:0] instruction;

//control signal
output wire PCsrc;

/**** ID stage ****/
output wire [32-1:0] pc_next0_s2, instruction_s2, rsData, rtData, signExtended;

//control signal
output wire MemtoReg, regDst, regWrite, branch, ALUsrc, Jump, MemRead, MemWrite;
output wire [2-1:0] BranchType;
output wire [3-1:0] ALUop;

/**** EX stage ****/
output wire [32-1:0] pc_next0_s3, leftShifted, pc_next1_s3;
output wire [32-1:0] rsData_s3, rtData_s3, MUX_ALUsrc, ALUresult;
output wire zero;
output wire [32-1:0] signExtended_s3;
output wire [4-1:0] ALUcontrol;
output wire [32-1:0] Instruction_s3;
output wire [5-1:0] writeReg1;

//control signal
output wire MemtoReg_s3, regDst_s3, regWrite_s3, branch_s3, ALUsrc_s3, MemRead_s3, MemWrite_s3;
output wire [3-1:0] ALUop_s3;

/**** MEM stage ****/
output wire [32-1:0] pc_next1_s4;
output wire zero_s4;
output wire [32-1:0] ALUresult_s4, rtData_s4, ReadData;
output wire [5-1:0] writeReg1_s4;

//control signal
output wire MemtoReg_s4, regWrite_s4, branch_s4, MemRead_s4, MemWrite_s4;

/**** WB stage ****/
output wire [32-1:0] ReadData_s5, ALUresult_s5, toReg;
output wire [5-1:0] writeReg1_s5;

//control signal
output wire MemtoReg_s5, regWrite_s5;
/*==================================================================*/
/*                              design                              */
/*==================================================================*/

//Instantiate the components in IF stage

MUX_2to1 #(.size(N)) Mux0( // Modify N, which is the total length of input/output
    .src1_i(pc_next0),
    .src2_i(pc_next1_s4),
    .select_i(PCsrc),
    .data_o(pc_pre)
);

ProgramCounter PC(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .pc_in_i(pc_pre),
    .pc_out_o(pc)
);

Instruction_Memory IM(
    .addr_i(pc),
    .instr_o(instruction)
);
			
Adder Add_pc(
    .src1_i(pc),
    .src2_i(32'd4),
    .sum_o(pc_next0)
);
		
Pipe_Reg #(.size(32 + 32)) IF_ID( // Modify N, which is the total length of input/output
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i({ pc_next0, instruction }),
    .data_o({ pc_next0_s2, instruction_s2 })
);


//Instantiate the components in ID stage

Reg_File RF(
    .clk_i(clk_i),      
    .rst_i(rst_i),     
    .RSaddr_i(instruction_s2[25:21]),  
    .RTaddr_i(instruction_s2[20:16]),  
    .RDaddr_i(writeReg1_s5),
    .RDdata_i(toReg), 
    .RegWrite_i(regWrite_s5),
    .RSdata_o(rsData), 
    .RTdata_o(rtData)     
);

Decoder Control(
    .opcode_i(instruction_s2[31:26]),
    .functionCode_i(instruction_s2[5:0]),
    .registerWrite_o(regWrite),
    .ALUOperation_o(ALUop),
    .ALUSrc_o(ALUsrc),
    .registerDestination_o(regDst),
    .branch_o(branch),
    .jump_o(Jump),
    .memoryRead_o(MemRead),
    .memoryWrite_o(MemWrite),
    .branchType_o(BranchType)
);

Sign_Extend SE(
    .data_i(instruction_s2[15:0]),
    .data_o(signExtended)
);

Pipe_Reg #(.size(7 * 1 + 3 + 5 * 32)) ID_EX( // Modify N, which is the total length of input/output
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i({ MemtoReg, regWrite, MemRead, branch, MemWrite, ALUsrc, ALUop, 
        regDst, pc_next0_s2, rsData, rtData, signExtended, instruction_s2 }),
    .data_o({ MemtoReg_s3, regWrite_s3, MemRead_s3, branch_s3, MemWrite_s3, ALUsrc_s3, ALUop_s3, 
        regDst_s3, pc_next0_s3, rsData_s3, rtData_s3, signExtended_s3, Instruction_s3 })
);


//Instantiate the components in EX stage

Shift_Left_Two_32 Shifter(
    data_i(signExtended_s3),
    data_o(leftShifted)
);

ALU ALU(
    operandA_i(rsData_s3),
    operandB_i(MUX_ALUsrc),
    operation_i(ALUcontrol),
    result_o(ALUresult),
    isZero_o(zero)
);
		
ALU_Ctrl ALU_Control(
    .functionCode_i(Instruction_s3[5:0]),
    .ALUOperation_i(ALUop_s3),
    .ALUControl_o(ALUcontrol)
);

MUX_2to1 #(.size(32)) Mux1( // Modify N, which is the total length of input/output
    .data0_i(rsData_s3),
    .data1_i(signExtended_s3),
    .select_i(ALUsrc_s3),
    .data_o(MUX_ALUsrc)
);
		
MUX_2to1 #(.size(5)) Mux2( // Modify N, which is the total length of input/output
    .data0_i(Instruction_s3[20:16]),
    .data1_i(Instruction_s3[15:11]),
    .select_i(regDst_s3),
    .data_o(writeReg1)
);

Adder Add_pc_branch(
    .src1_i(pc_next0_s3),
    .src2_i(leftShifted),
    .sum_o(pc_next1_s3)
);

Pipe_Reg #(.size(N)) EX_MEM( // Modify N, which is the total length of input/output
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i({ MemtoReg_s3, regWrite_s3, branch_s3, MemRead_s3, 
        MemWrite_s3, pc_next1_s3, zero, ALUresult, rtData_s3, writeReg1 }),
    .data_o({ MemtoReg_s4, regWrite_s4, branch_s4, MemRead_s4, 
        MemWrite_s4, pc_next1_s4, zero_s4, ALUresult_s4, rtData_s4, writeReg1_s4 })
);


//Instantiate the components in MEM stage

Data_Memory DM(
    .clk_i(clk_i),
    .addr_i(ALUresult_s4),
    .data_i(rtData_s4),
    .MemRead_i(MemRead_s4),
    .MemWrite_i(MemWrite_s4),
    .data_o(ReadData)
);

assign PCsrc = branch_s4 & zero_s4;

Pipe_Reg #(.size(N)) MEM_WB( // Modify N, which is the total length of input/output
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i({ MemtoReg_s4, regWrite_s4, ReadData, ALUresult_s4, writeReg1_s4 }),
    .data_o({ MemtoReg_s5, regWrite_s5, ReadData_s5, ALUresult_s5, writeReg1_s5 })
);


//Instantiate the components in WB stage

MUX_2to1 #(.size(N)) Mux3( // Modify N, which is the total length of input/output
    .data0_i(ALUresult_s5),
    .data1_i(ReadData_s5),
    .select_i(MemtoReg_s5),
    .data_o(toReg)
);


endmodule
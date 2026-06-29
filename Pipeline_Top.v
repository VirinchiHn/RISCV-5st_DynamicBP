`include "Fetch_Cycle.v"
`include "Decode_Cycle.v"
`include "Execute_Cycle.v"
`include "Memory_Cycle.v"
`include "Writeback_Cycle.v"    
`include "PC.v"
`include "PC_Adder.v"
`include "Mux.v"
`include "Instruction_Memory.v"
`include "Control_Unit_Top.v"
`include "Register_File.v"
`include "Sign_Extend.v"
`include "ALU.v"
`include "Data_Memory.v"
`include "Hazard_unit.v"
`include "Branch_Predictor.v"

module Pipeline_top(clk, rst);

    input clk, rst;

    // ADDED: dynamic branch prediction wires
    wire PredTakenD, PredTakenE;
    wire [31:0] PredTargetD, PredTargetE;

    wire BranchTakenE;
    wire MispredictE;
    wire [31:0] CorrectPCE;

    wire PCSrcE, RegWriteW, RegWriteE, ALUSrcE, MemWriteE, BranchE, RegWriteM, MemWriteM;
    wire JumpE, JalrE;

    wire [1:0] ResultSrcE, ResultSrcM, ResultSrcW;

    wire [2:0] ALUControlE;

    wire [2:0] funct3_E;

    wire [4:0] RD_E, RD_M, RDW;
    wire [31:0] PCTargetE, InstrD, PCD, PCPlus4D, ResultW, RD1_E, RD2_E, Imm_Ext_E, PCE, PCPlus4E, PCPlus4M, WriteDataM, ALU_ResultM;
    wire [31:0] PCPlus4W, ALU_ResultW, ReadDataW;
    wire [4:0] RS1_E, RS2_E;
    wire [1:0] ForwardBE, ForwardAE;

    // ADDED: stall and flush control signals from hazard unit
    wire StallF, StallD, FlushD, FlushE;
    

    // Fetch Stage
    fetch_cycle Fetch (
    .clk(clk), 
    .rst(rst), 

    .MispredictE(MispredictE),
    .CorrectPCE(CorrectPCE),

    .BranchE(BranchE),
    .BranchTakenE(BranchTakenE),
    .PCE(PCE),
    .PCTargetE(PCTargetE),

    .StallF(StallF),
    .StallD(StallD),
    .FlushD(FlushD),

    .InstrD(InstrD), 
    .PCD(PCD), 
    .PCPlus4D(PCPlus4D),

    .PredTakenD(PredTakenD),
    .PredTargetD(PredTargetD)
    );

    // Decode Stage
    decode_cycle Decode (
                        .clk(clk), 
                        .rst(rst),

                        // ADDED: convert ID/EX pipeline register to NOP on stall or taken branch/jump
                        .FlushE(FlushE),

                        .PredTakenD(PredTakenD),
                        .PredTargetD(PredTargetD),
                        .PredTakenE(PredTakenE),
                        .PredTargetE(PredTargetE),

                        .InstrD(InstrD), 
                        .PCD(PCD), 
                        .PCPlus4D(PCPlus4D), 
                        .RegWriteW(RegWriteW), 
                        .RDW(RDW), 
                        .ResultW(ResultW), 
                        .RegWriteE(RegWriteE), 
                        .ALUSrcE(ALUSrcE), 
                        .MemWriteE(MemWriteE), 
                        .ResultSrcE(ResultSrcE),
                        .BranchE(BranchE),
                        .JumpE(JumpE),
                        .JalrE(JalrE),
                        .funct3_E(funct3_E),
                        .ALUControlE(ALUControlE), 
                        .RD1_E(RD1_E), 
                        .RD2_E(RD2_E), 
                        .Imm_Ext_E(Imm_Ext_E), 
                        .RD_E(RD_E), 
                        .PCE(PCE), 
                        .PCPlus4E(PCPlus4E),
                        .RS1_E(RS1_E),
                        .RS2_E(RS2_E)
                    );

    // Execute Stage
    execute_cycle Execute (
                        .clk(clk), 
                        .rst(rst), 
                        .RegWriteE(RegWriteE), 
                        .ALUSrcE(ALUSrcE), 
                        .MemWriteE(MemWriteE), 
                        .ResultSrcE(ResultSrcE), 
                        .BranchE(BranchE),

                        .PredTakenE(PredTakenE),
                        .PredTargetE(PredTargetE),
                        .BranchTakenE(BranchTakenE),
                        .MispredictE(MispredictE),
                        .CorrectPCE(CorrectPCE),

                        .JumpE(JumpE),
                        .JalrE(JalrE),
                        .funct3_E(funct3_E),
                        .ALUControlE(ALUControlE), 
                        .RD1_E(RD1_E), 
                        .RD2_E(RD2_E), 
                        .Imm_Ext_E(Imm_Ext_E), 
                        .RD_E(RD_E), 
                        .PCE(PCE), 
                        .PCPlus4E(PCPlus4E), 
                        .PCSrcE(PCSrcE), 
                        .PCTargetE(PCTargetE), 
                        .RegWriteM(RegWriteM), 
                        .MemWriteM(MemWriteM), 
                        .ResultSrcM(ResultSrcM), 
                        .RD_M(RD_M), 
                        .PCPlus4M(PCPlus4M), 
                        .WriteDataM(WriteDataM), 
                        .ALU_ResultM(ALU_ResultM),
                        .ResultW(ResultW),
                        .ForwardA_E(ForwardAE),
                        .ForwardB_E(ForwardBE)
                    );
    
    // Memory Stage
    memory_cycle Memory (
                        .clk(clk), 
                        .rst(rst), 
                        .RegWriteM(RegWriteM), 
                        .MemWriteM(MemWriteM), 
                        .ResultSrcM(ResultSrcM), 
                        .RD_M(RD_M), 
                        .PCPlus4M(PCPlus4M), 
                        .WriteDataM(WriteDataM), 
                        .ALU_ResultM(ALU_ResultM), 
                        .RegWriteW(RegWriteW), 
                        .ResultSrcW(ResultSrcW), 
                        .RD_W(RDW), 
                        .PCPlus4W(PCPlus4W), 
                        .ALU_ResultW(ALU_ResultW), 
                        .ReadDataW(ReadDataW)
                    );

    // Write Back Stage
    writeback_cycle WriteBack (
                        .clk(clk), 
                        .rst(rst), 
                        .ResultSrcW(ResultSrcW), 
                        .PCPlus4W(PCPlus4W), 
                        .ALU_ResultW(ALU_ResultW), 
                        .ReadDataW(ReadDataW), 
                        .ResultW(ResultW)
                    );

    // Hazard Unit
    hazard_unit Forwarding_block (
                        .rst(rst), 
                        .RegWriteM(RegWriteM), 
                        .RegWriteW(RegWriteW),

                        // ADDED: load-use hazard detection inputs
                        .ResultSrcE(ResultSrcE),
                        .RD_E(RD_E),

                        .RD_M(RD_M), 
                        .RD_W(RDW), 
                        .Rs1_E(RS1_E), 
                        .Rs2_E(RS2_E),

                        // ADDED: source registers from decode stage for load-use hazard detection
                        .Rs1_D(InstrD[19:15]),
                        .Rs2_D(InstrD[24:20]),

                        // ADDED: branch/jump taken signal for static predict-not-taken flush
                        .MispredictE(MispredictE),

                        .ForwardAE(ForwardAE), 
                        .ForwardBE(ForwardBE),

                        // ADDED: stall and flush outputs
                        .StallF(StallF),
                        .StallD(StallD),
                        .FlushD(FlushD),
                        .FlushE(FlushE)
                        );

endmodule
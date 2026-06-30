module fetch_cycle(
    clk, rst,

    MispredictE,
    CorrectPCE,

    BranchE,
    BranchTakenE,
    PCE,
    PCTargetE,

    StallD,
    StallF,
    FlushD,

    InstrD,
    PCD,
    PCPlus4D,

    PredTakenD,
    PredTargetD
);

    input clk, rst;

    //recovery from execute stage when prediction is wrong
    input MispredictE;
    input [31:0] CorrectPCE;

    //branch predictor update info from execute stage
    input BranchE;
    input BranchTakenE;
    input [31:0] PCE;
    input [31:0] PCTargetE;

    input StallF;
    input StallD;
    input FlushD;

    output [31:0] InstrD;
    output [31:0] PCD, PCPlus4D;

    //prediction info carried to decode/execute
    output PredTakenD;
    output [31:0] PredTargetD;

    wire [31:0] PC_F, PCF, PCPlus4F;
    wire [31:0] InstrF;
    wire [31:0] PC_Next;

    wire PredTakenF;
    wire [31:0] PredTargetF;

    reg [31:0] InstrF_reg;
    reg [31:0] PCF_reg, PCPlus4F_reg;

    // IF/ID prediction pipeline registers
    reg PredTakenF_reg;
    reg [31:0] PredTargetF_reg;

    //dynamic branch predictor
    Branch_Predictor BP (
        .clk(clk),
        .rst(rst),

        .PCF(PCF),
        .PCPlus4F(PCPlus4F),
        .PredTakenF(PredTakenF),
        .PredTargetF(PredTargetF),

        .UpdateE(BranchE),
        .UpdatePCE(PCE),
        .ActualTakenE(BranchTakenE),
        .ActualTargetE(PCTargetE)
    );

    // Old: PC_Next = PCSrcE ? PCTargetE : PCPlus4F
    // New: normally follow predictor, but if execute says wrong, use CorrectPCE
    Mux PC_MUX (
        .a(PredTargetF),
        .b(CorrectPCE),
        .s(MispredictE),
        .c(PC_Next)
    );

    Mux STALL_MUX (
        .a(PC_Next),
        .b(PCF),
        .s(StallF),
        .c(PC_F)
    );

    PC_Module Program_Counter (
        .clk(clk),
        .rst(rst),
        .PC(PCF),
        .PC_Next(PC_F)
    );

    Instruction_Memory IMEM (
        .rst(rst),
        .A(PCF),
        .RD(InstrF)
    );

    PC_Adder PC_adder (
        .a(PCF),
        .b(32'h00000004),
        .c(PCPlus4F)
    );

    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            InstrF_reg <= 32'h00000000;
            PCF_reg <= 32'h00000000;
            PCPlus4F_reg <= 32'h00000000;

            PredTakenF_reg <= 1'b0;
            PredTargetF_reg <= 32'h00000000;
        end
        else if (FlushD == 1'b1) begin
            InstrF_reg <= 32'h00000000;
            PCF_reg <= 32'h00000000;
            PCPlus4F_reg <= 32'h00000000;

            //flush prediction info also
            PredTakenF_reg <= 1'b0;
            PredTargetF_reg <= 32'h00000000;
        end
        else if (StallD == 1'b1) begin
            InstrF_reg <= InstrF_reg;
            PCF_reg <= PCF_reg;
            PCPlus4F_reg <= PCPlus4F_reg;

            //hold prediction info during stall
            PredTakenF_reg <= PredTakenF_reg;
            PredTargetF_reg <= PredTargetF_reg;
        end
        else begin
            InstrF_reg <= InstrF;
            PCF_reg <= PCF;
            PCPlus4F_reg <= PCPlus4F;

            //pass prediction info with same instruction
            PredTakenF_reg <= PredTakenF;
            PredTargetF_reg <= PredTargetF;
        end
    end

    assign InstrD = (rst == 1'b0) ? 32'h00000000 : InstrF_reg;
    assign PCD = (rst == 1'b0) ? 32'h00000000 : PCF_reg;
    assign PCPlus4D = (rst == 1'b0) ? 32'h00000000 : PCPlus4F_reg;

    assign PredTakenD = (rst == 1'b0) ? 1'b0 : PredTakenF_reg;
    assign PredTargetD = (rst == 1'b0) ? 32'h00000000 : PredTargetF_reg;

endmodule

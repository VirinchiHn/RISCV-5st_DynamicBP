module execute_cycle(clk, rst, RegWriteE, ALUSrcE, MemWriteE, ResultSrcE, BranchE, JumpE, JalrE, funct3_E, ALUControlE, 
    RD1_E, RD2_E, Imm_Ext_E, RD_E, PCE, PCPlus4E, PredTakenE, PredTargetE, PCSrcE, PCTargetE, BranchTakenE, MispredictE, CorrectPCE,
    RegWriteM, MemWriteM, ResultSrcM, RD_M, PCPlus4M, WriteDataM, ALU_ResultM, ResultW, ForwardA_E, ForwardB_E);

    // Declaration I/Os
    input clk, rst, RegWriteE, ALUSrcE, MemWriteE, BranchE, JumpE, JalrE;

    input [1:0] ResultSrcE;
    //prediction info from decode stage
    input PredTakenE;
    input [31:0] PredTargetE;

    //branch funct3 coming from decode stage
    input [2:0] funct3_E;

    input [2:0] ALUControlE;
    input [31:0] RD1_E, RD2_E, Imm_Ext_E;
    input [4:0] RD_E;
    input [31:0] PCE, PCPlus4E;
    input [31:0] ResultW;
    input [1:0] ForwardA_E, ForwardB_E;

    // ADDED: correct PC to send back to fetch after misprediction
    output [31:0] CorrectPCE;
    output PCSrcE, BranchTakenE, MispredictE, RegWriteM, MemWriteM;
    output [1:0] ResultSrcM;

    output [4:0] RD_M; 
    output [31:0] PCPlus4M, WriteDataM, ALU_ResultM;
    output [31:0] PCTargetE;

    // Declaration of Interim Wires
    wire [31:0] Src_A, Src_B_interim, Src_B;
    wire [31:0] ResultE;
    wire [31:0] PCBranchTargetE;

    //extra ALU flags for branch decisions
    wire ZeroE, NegativeE, CarryE, OverFlowE;

    //final branch condition result
    //wire BranchTakenE;

    // Declaration of Register
    reg RegWriteE_r, MemWriteE_r;
    reg [1:0] ResultSrcE_r;

    reg [4:0] RD_E_r;
    reg [31:0] PCPlus4E_r, RD2_E_r, ResultE_r;

    // 3 by 1 Mux for Source A(FORWARDING)
    Mux_3_by_1 srca_mux (
                        .a(RD1_E),
                        .b(ResultW),
                        .c(ALU_ResultM),
                        .s(ForwardA_E),
                        .d(Src_A)
                        );

    // 3 by 1 Mux for Source B
    Mux_3_by_1 srcb_mux (
                        .a(RD2_E),
                        .b(ResultW),
                        .c(ALU_ResultM),
                        .s(ForwardB_E),
                        .d(Src_B_interim)
                        );

    // ALU Src Mux
    Mux alu_src_mux (
            .a(Src_B_interim),
            .b(Imm_Ext_E),
            .s(ALUSrcE),
            .c(Src_B)
            );

    // ALU Unit
    ALU alu (
            .A(Src_A),
            .B(Src_B),
            .Result(ResultE),
            .ALUControl(ALUControlE),

            //connect flags instead of leaving them open
            .OverFlow(OverFlowE),
            .Carry(CarryE),
            .Zero(ZeroE),
            .Negative(NegativeE)
            );

    // Branch/JAL Target Adder: PC + Immediate
    PC_Adder branch_adder (
            .a(PCE),
            .b(Imm_Ext_E),
            .c(PCBranchTargetE)
            );

    // JAL/JALR/Branch PC target selection
    // Branch and JAL use PC + Imm
    // JALR uses rs1 + Imm, which is ALU ResultE
    assign PCTargetE = (JalrE == 1'b1) ? ResultE : PCBranchTargetE;

    //branch condition logic using funct3
    assign BranchTakenE =
            (funct3_E == 3'b000) ? ZeroE :                    // beq
            (funct3_E == 3'b001) ? ~ZeroE :                   // bne
            (funct3_E == 3'b100) ? (NegativeE ^ OverFlowE) :  // blt
            (funct3_E == 3'b101) ? ~(NegativeE ^ OverFlowE) : // bge
            (funct3_E == 3'b110) ? ~CarryE :                  // bltu
            (funct3_E == 3'b111) ? CarryE :                   // bgeu
                                   1'b0;

    // Register Logic
    always @(posedge clk or negedge rst) begin
        if(rst == 1'b0) begin
            RegWriteE_r <= 1'b0; 
            MemWriteE_r <= 1'b0; 
            ResultSrcE_r <= 2'b00;

            RD_E_r <= 5'h00;
            PCPlus4E_r <= 32'h00000000; 
            RD2_E_r <= 32'h00000000; 
            ResultE_r <= 32'h00000000;
        end
        else begin
            RegWriteE_r <= RegWriteE; 
            MemWriteE_r <= MemWriteE; 
            ResultSrcE_r <= ResultSrcE;
            RD_E_r <= RD_E;
            PCPlus4E_r <= PCPlus4E; 
            RD2_E_r <= Src_B_interim; 
            ResultE_r <= ResultE;
        end
    end

    // Output Assignments

    //now supports beq, bne, blt, bge, bltu, bgeu, jal, jalr
    assign PCSrcE = (BranchE & BranchTakenE) | JumpE;

    // If actual control-flow says taken/jump, correct PC is actual target.
    // If branch is not taken, correct PC is PC + 4.
    assign CorrectPCE = PCSrcE ? PCTargetE : PCPlus4E;

    // Conditional branches are checked against prediction.
    // JAL/JALR are not predicted here, so redirect when JumpE is high.
    assign MispredictE =
            (BranchE &&
                (
                    (PredTakenE != BranchTakenE) ||
                    (BranchTakenE && (PredTargetE != PCTargetE))
                )
            )
            |
            (JumpE);

    assign RegWriteM = RegWriteE_r;
    assign MemWriteM = MemWriteE_r;
    assign ResultSrcM = ResultSrcE_r;
    assign RD_M = RD_E_r;
    assign PCPlus4M = PCPlus4E_r;
    assign WriteDataM = RD2_E_r;
    assign ALU_ResultM = ResultE_r;

endmodule

module decode_cycle(clk, rst, InstrD, PCD, PCPlus4D, PredTakenD, PredTargetD, RegWriteW, RDW, ResultW, RegWriteE, ALUSrcE, MemWriteE, ResultSrcE,
    BranchE, JumpE, JalrE, FlushE, funct3_E, ALUControlE, RD1_E, RD2_E, Imm_Ext_E, RD_E, PCE, PCPlus4E, RS1_E, RS2_E, PredTakenE, PredTargetE);

// Declaring I/O
    input clk, rst, RegWriteW;
    input [4:0] RDW;
    input [31:0] InstrD, PCD, PCPlus4D, ResultW;
    input FlushE;

    // prediction info from fetch
    input PredTakenD;
    input [31:0] PredTargetD;

    //prediction info going to execute
    output PredTakenE;
    output [31:0] PredTargetE;

    output RegWriteE,ALUSrcE,MemWriteE,BranchE,JumpE,JalrE;

    output [1:0] ResultSrcE;
    output [2:0] funct3_E;
    output [2:0] ALUControlE;
    output [31:0] RD1_E, RD2_E, Imm_Ext_E;
    output [4:0] RS1_E, RS2_E, RD_E;
    output [31:0] PCE, PCPlus4E;

    // Declare Interim Wires
    wire RegWriteD,ALUSrcD,MemWriteD,BranchD,JumpD,JalrD;

    wire [1:0] ResultSrcD;
    wire [1:0] ImmSrcD;
    wire [2:0] ALUControlD;
    wire [31:0] RD1_D, RD2_D, Imm_Ext_D;
    
    // carry prediction info in ID/EX register

    reg PredTakenD_r;
    reg [31:0] PredTargetD_r;

    // Declaration of Interim Register
    reg RegWriteD_r,ALUSrcD_r,MemWriteD_r,BranchD_r,JumpD_r,JalrD_r;
    reg [1:0] ResultSrcD_r;
    reg [2:0] ALUControlD_r;
    //pipeline funct3 into execute stage for beq/bne/blt/bge/bltu/bgeu
    reg [2:0] funct3_D_r;
    reg [31:0] RD1_D_r, RD2_D_r, Imm_Ext_D_r;
    reg [4:0] RD_D_r, RS1_D_r, RS2_D_r;
    reg [31:0] PCD_r, PCPlus4D_r;


    Control_Unit_Top control (
                            .Op(InstrD[6:0]),
                            .RegWrite(RegWriteD),
                            .ImmSrc(ImmSrcD),
                            .ALUSrc(ALUSrcD),
                            .MemWrite(MemWriteD),
                            .ResultSrc(ResultSrcD),
                            .Branch(BranchD),
                            .Jump(JumpD),
                            .Jalr(JalrD),
                            .funct3(InstrD[14:12]),
                            .funct7(InstrD[31:25]),
                            .ALUControl(ALUControlD)
                            );
    // Register File
    Register_File rf (
                        .clk(clk),
                        .rst(rst),
                        .WE3(RegWriteW),
                        .WD3(ResultW),
                        .A1(InstrD[19:15]),
                        .A2(InstrD[24:20]),
                        .A3(RDW),
                        .RD1(RD1_D),
                        .RD2(RD2_D)
                        );

    // Sign Extension
    Sign_Extend extension (
                        .In(InstrD[31:0]),
                        .Imm_Ext(Imm_Ext_D),
                        .ImmSrc(ImmSrcD)
                        );

    // Declaring Register Logic
    always @(posedge clk or negedge rst) begin
        if(rst == 1'b0 || FlushE == 1'b1) begin
            RegWriteD_r <= 1'b0;
            ALUSrcD_r <= 1'b0;
            MemWriteD_r <= 1'b0;

            
            ResultSrcD_r <= 2'b00;

            BranchD_r <= 1'b0;

            //reset jump signals
            JumpD_r <= 1'b0;
            JalrD_r <= 1'b0;
            
            funct3_D_r <= 3'b000;
            
            PredTakenD_r <= 1'b0;
            PredTargetD_r <= 32'h00000000;

            ALUControlD_r <= 3'b000;
            RD1_D_r <= 32'h00000000; 
            RD2_D_r <= 32'h00000000; 
            Imm_Ext_D_r <= 32'h00000000;
            RD_D_r <= 5'h00;
            PCD_r <= 32'h00000000; 
            PCPlus4D_r <= 32'h00000000;
            RS1_D_r <= 5'h00;
            RS2_D_r <= 5'h00;
        end
        else begin
            RegWriteD_r <= RegWriteD;
            ALUSrcD_r <= ALUSrcD;
            MemWriteD_r <= MemWriteD;
            ResultSrcD_r <= ResultSrcD;
            BranchD_r <= BranchD;

            //pipeline jump signals into Execute stage
            JumpD_r <= JumpD;
            JalrD_r <= JalrD;
            
            funct3_D_r <= InstrD[14:12];
           

            PredTakenD_r <= PredTakenD;
            PredTargetD_r <= PredTargetD;

            ALUControlD_r <= ALUControlD;
            RD1_D_r <= RD1_D; 
            RD2_D_r <= RD2_D; 
            Imm_Ext_D_r <= Imm_Ext_D;
            RD_D_r <= InstrD[11:7];
            PCD_r <= PCD; 
            PCPlus4D_r <= PCPlus4D;
            RS1_D_r <= InstrD[19:15];
            RS2_D_r <= InstrD[24:20];
        end
    end

    // Output assign statements
    assign RegWriteE = RegWriteD_r;
    assign ALUSrcE = ALUSrcD_r;
    assign MemWriteE = MemWriteD_r;
    assign ResultSrcE = ResultSrcD_r;
    assign BranchE = BranchD_r;

    // send Jump/Jalr to Execute stage
    assign JumpE = JumpD_r;
    assign JalrE = JalrD_r;
    
    assign PredTakenE = PredTakenD_r;
    assign PredTargetE = PredTargetD_r;
    
    assign funct3_E = funct3_D_r;
    assign ALUControlE = ALUControlD_r;
    assign RD1_E = RD1_D_r;
    assign RD2_E = RD2_D_r;
    assign Imm_Ext_E = Imm_Ext_D_r;
    assign RD_E = RD_D_r;
    assign PCE = PCD_r;
    assign PCPlus4E = PCPlus4D_r;
    assign RS1_E = RS1_D_r;
    assign RS2_E = RS2_D_r;
    
endmodule

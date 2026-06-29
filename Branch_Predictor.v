module Branch_Predictor(
    input clk,
    input rst,

    input  [31:0] PCF,
    input  [31:0] PCPlus4F,
    output        PredTakenF,
    output [31:0] PredTargetF,

    input         UpdateE,
    input  [31:0] UpdatePCE,
    input         ActualTakenE,
    input  [31:0] ActualTargetE
);

    reg [1:0]  BHT [0:63];
    reg        BTB_valid [0:63];
    reg [23:0] BTB_tag [0:63];
    reg [31:0] BTB_target [0:63];

    wire [5:0] indexF       = PCF[7:2];
    wire [23:0] tagF        = PCF[31:8];

    wire [5:0] updateIndexE = UpdatePCE[7:2];
    wire [23:0] updateTagE  = UpdatePCE[31:8];

    wire BTB_hitF = BTB_valid[indexF] && (BTB_tag[indexF] == tagF);

    // Predict taken only when BTB has valid matching target and BHT says taken
    assign PredTakenF = BTB_hitF && BHT[indexF][1];

    // If predicted taken, use BTB target. Otherwise go PC + 4
    assign PredTargetF = PredTakenF ? BTB_target[indexF] : PCPlus4F;

    integer i;

    always @(posedge clk or negedge rst) begin
        if (rst == 1'b0) begin
            for (i = 0; i < 64; i = i + 1) begin
                BHT[i]        <= 2'b01; // weakly not taken
                BTB_valid[i]  <= 1'b0;  // no branch targets known at reset
                BTB_tag[i]    <= 24'd0;
                BTB_target[i] <= 32'd0;
            end
        end
        else if (UpdateE == 1'b1) begin
            if (ActualTakenE == 1'b1) begin
                if (BHT[updateIndexE] != 2'b11)
                    BHT[updateIndexE] <= BHT[updateIndexE] + 1'b1;

                // Store target only after real taken branch is seen
                BTB_valid[updateIndexE]  <= 1'b1;
                BTB_tag[updateIndexE]    <= updateTagE;
                BTB_target[updateIndexE] <= ActualTargetE;
            end
            else begin
                if (BHT[updateIndexE] != 2'b00)
                    BHT[updateIndexE] <= BHT[updateIndexE] - 1'b1;
            end
        end
    end

endmodule
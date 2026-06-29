module hazard_unit(
    rst,
    RegWriteM,
    RegWriteW,
    ResultSrcE,
    RD_M,
    RD_W,
    RD_E,
    Rs1_E,
    Rs2_E,
    Rs1_D,
    Rs2_D,
    MispredictE,
    ForwardAE,
    ForwardBE,
    StallF,
    StallD,
    FlushD,
    FlushE
);

    input rst, RegWriteM, RegWriteW;

    // CHANGED: old input was PCSrcE. Now flush only on misprediction.
    input MispredictE;

    input [1:0] ResultSrcE;
    input [4:0] RD_M, RD_W, RD_E, Rs1_E, Rs2_E, Rs1_D, Rs2_D;

    output [1:0] ForwardAE, ForwardBE;
    output StallF, StallD, FlushD, FlushE;

    wire LoadUseHazard;

    assign LoadUseHazard =
            (ResultSrcE == 2'b01) &&
            (RD_E != 5'd0) &&
            ((RD_E == Rs1_D) || (RD_E == Rs2_D));

    assign StallF = LoadUseHazard;
    assign StallD = LoadUseHazard;

    // CHANGED:
    // Old: FlushD = PCSrcE
    // New: FlushD only when prediction was wrong
    assign FlushD = MispredictE;

    // CHANGED:
    // FlushE on either branch misprediction or load-use bubble
    assign FlushE = MispredictE | LoadUseHazard;

    assign ForwardAE = (rst == 1'b0) ? 2'b00 : 
                       ((RegWriteM == 1'b1) && (RD_M != 5'h00) && (RD_M == Rs1_E)) ? 2'b10 :
                       ((RegWriteW == 1'b1) && (RD_W != 5'h00) && (RD_W == Rs1_E)) ? 2'b01 :
                                                                                       2'b00;

    assign ForwardBE = (rst == 1'b0) ? 2'b00 : 
                       ((RegWriteM == 1'b1) && (RD_M != 5'h00) && (RD_M == Rs2_E)) ? 2'b10 :
                       ((RegWriteW == 1'b1) && (RD_W != 5'h00) && (RD_W == Rs2_E)) ? 2'b01 :
                                                                                       2'b00;

endmodule
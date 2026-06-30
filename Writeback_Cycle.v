

module writeback_cycle(clk, rst, ResultSrcW, PCPlus4W, ALU_ResultW, ReadDataW, ResultW);

// Declaration of IOs
input clk, rst;
input [1:0] ResultSrcW;
input [31:0] PCPlus4W, ALU_ResultW, ReadDataW;

output [31:0] ResultW;

Mux_3_by_1 result_mux (
    .a(ALU_ResultW),   // ResultSrcW = 2'b00
    .b(ReadDataW),     // ResultSrcW = 2'b01
    .c(PCPlus4W),      // ResultSrcW = 2'b10
    .s(ResultSrcW),
    .d(ResultW)
);
endmodule

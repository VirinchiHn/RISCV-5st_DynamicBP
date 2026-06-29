// Copyright 2023 MERL-DSU

//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at

//        http://www.apache.org/licenses/LICENSE-2.0

//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.

module writeback_cycle(clk, rst, ResultSrcW, PCPlus4W, ALU_ResultW, ReadDataW, ResultW);

// Declaration of IOs
input clk, rst;
input [1:0] ResultSrcW;
input [31:0] PCPlus4W, ALU_ResultW, ReadDataW;

output [31:0] ResultW;

// Declaration of Module
/*
Mux result_mux (    
                .a(ALU_ResultW),
                .b(ReadDataW),
                .s(ResultSrcW),
                .c(ResultW)
                );
                */
Mux_3_by_1 result_mux (
    .a(ALU_ResultW),   // ResultSrcW = 2'b00
    .b(ReadDataW),     // ResultSrcW = 2'b01
    .c(PCPlus4W),      // ResultSrcW = 2'b10
    .s(ResultSrcW),
    .d(ResultW)
);
endmodule

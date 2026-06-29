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
/*
module Main_Decoder(Op,RegWrite,ImmSrc,ALUSrc,MemWrite,ResultSrc,Branch,Jump,Jalr,ALUOp);
    input [6:0]Op;
    output RegWrite,ALUSrc,MemWrite,Branch,Jump,Jalr;
    output [1:0]ImmSrc,ResultSrc,ALUOp;

    assign RegWrite = (Op == 7'b0000011 | Op == 7'b0110011 | Op == 7'b0010011 ) ? 1'b1 :
                                                              1'b0 ;
    assign ImmSrc = (Op == 7'b0100011) ? 2'b01 : 
                    (Op == 7'b1100011) ? 2'b10 :    
                                         2'b00 ;
    assign ALUSrc = (Op == 7'b0000011 | Op == 7'b0100011 | Op == 7'b0010011) ? 1'b1 :
                                                            1'b0 ;
    assign MemWrite = (Op == 7'b0100011) ? 1'b1 :
                                           1'b0 ;
    assign ResultSrc = (Op == 7'b0000011) ? 1'b1 :
                                            1'b0 ;
    assign Branch = (Op == 7'b1100011) ? 1'b1 :
                                         1'b0 ;
    assign ALUOp = (Op == 7'b0110011) ? 2'b10 :
                   (Op == 7'b1100011) ? 2'b01 :
                                        2'b00 ;

endmodule
*/

module Main_Decoder(Op,RegWrite,ImmSrc,ALUSrc,MemWrite,ResultSrc,Branch,Jump,Jalr,ALUOp);

    input [6:0]Op;

    output RegWrite,ALUSrc,MemWrite,Branch,Jump,Jalr;
    output [1:0]ImmSrc,ResultSrc,ALUOp;

    // RegWrite
    assign RegWrite =
            (Op == 7'b0000011 |     // lw
             Op == 7'b0110011 |     // R-type
             Op == 7'b0010011 |     // I-type
             Op == 7'b1101111 |     // jal
             Op == 7'b1100111)      // jalr
             ? 1'b1 : 1'b0;

    // ImmSrc
    // 00 = I-type
    // 01 = S-type
    // 10 = B-type
    // 11 = J-type

    assign ImmSrc =
            (Op == 7'b0100011) ? 2'b01 :   // sw
            (Op == 7'b1100011) ? 2'b10 :   // branch
            (Op == 7'b1101111) ? 2'b11 :   // jal
                                2'b00 ;    // lw/addi/jalr

    // ALUSrc
    assign ALUSrc =
            (Op == 7'b0000011 |    // lw
             Op == 7'b0100011 |    // sw
             Op == 7'b0010011 |    // addi
             Op == 7'b1100111)     // jalr
             ? 1'b1 : 1'b0;

    // MemWrite
    assign MemWrite =
            (Op == 7'b0100011) ? 1'b1 :
                                 1'b0;

    // ResultSrc
    // 00 -> ALU Result
    // 01 -> Memory Read Data
    // 10 -> PC + 4

    assign ResultSrc =
            (Op == 7'b0000011) ? 2'b01 :   // lw
            (Op == 7'b1101111 ||
             Op == 7'b1100111) ? 2'b10 :   // jal/jalr
                                2'b00;

    // Branch
    assign Branch =
            (Op == 7'b1100011) ? 1'b1 :
                                 1'b0;

    // Jump
    assign Jump =
            (Op == 7'b1101111 ||
             Op == 7'b1100111) ? 1'b1 :
                                 1'b0;

    // Jalr
    assign Jalr =
            (Op == 7'b1100111) ? 1'b1 :
                                 1'b0;

    // ALUOp
    assign ALUOp =
            (Op == 7'b0110011 ||
             Op == 7'b0010011) ? 2'b10 :
            (Op == 7'b1100011) ? 2'b01 :
                                 2'b00;

endmodule

module Instruction_Memory(rst,A,RD);

  input rst;
  input [31:0]A;
  output [31:0]RD;

  reg [31:0] mem [1023:0];
  
  assign RD = (rst == 1'b0) ? {32{1'b0}} : mem[A[31:2]];

  initial begin
    
    mem[0]  = 32'h00500093;  // addi x1, x0, 5
    mem[1]  = 32'h00A00113;  // addi x2, x0, 10
    mem[2]  = 32'h002081B3;  // add x3, x1, x2
    /*
    mem[3]  = 32'h00302023;  // sw x3, 0(x0)
    mem[4]  = 32'h00002203;  // lw x4, 0(x0)
    mem[5]  = 32'h001202B3;  // add x5, x4, x1
    mem[6]  = 32'h00528463;  // beq x5, x5, TARGET
    mem[7]  = 32'h06300313;  // addi x6, x0, 99  should flush
    mem[8]  = 32'h00700393;  // TARGET: addi x7, x0, 7
    mem[9]  = 32'h0080046F;  // jal x8, JUMPDEST
    mem[10] = 32'h06300493;  // addi x9, x0, 99  should flush
    mem[11] = 32'h04000513;  // JUMPDEST: addi x10, x0, 64
    mem[12] = 32'h000505E7;  // jalr x11, 0(x10)

    mem[16] = 32'h00C00613;  // address 64: addi x12, x0, 12
    */
    //$readmemh("memfile.hex",mem);
  end


/*
  initial begin
    //mem[0] = 32'hFFC4A303;
    //mem[1] = 32'h00832383;
    // mem[0] = 32'h0064A423;
    // mem[1] = 32'h00B62423;
    mem[0] = 32'h0062E233;
    // mem[1] = 32'h00B62423;

  end
*/
endmodule
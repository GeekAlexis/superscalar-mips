`timescale 1ns / 1ps

module ALU_tb;
  
  reg [31:0] in1, in2;
  reg [3:0] func;
  wire [31:0] aluout;
  
  ALU u1(in1, in2, func, aluout);
  
  initial begin
    
    in1 = 32'hffff_0000;
    in2 = 32'hff00_ff00;
    
    func = 4'b0000; #10 //and, return FF00_0000
    func = 4'b0001; #10 //or, return FFFF_FF00
    func = 4'b0010; #10 //xor, return 00FF_FF00
    func = 4'b0011; #10 //xnor, return FF00_00FF
    
    in1 = 78375;
    in2 = 42596;
    func = 4'b0100; #10 //add, addu, 78375 + 42596 = 120971 = 0x1D88B
    func = 4'b1100; #10 //sub, subu, 78375 - 42596 = 35779 = 0x8BC3

    in1 = 32'hffff_ffff; //-1
    in2 = 32'h0000_000f; //15
    func = 4'b1101; #10 //slt, -1 < 15, return 1
    func = 4'b0110; #10 //sltu, 2^32 - 1 > 15, return 0
    $stop;
  
  end
 
endmodule 

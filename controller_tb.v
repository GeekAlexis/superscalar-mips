`timescale 1ns / 1ps

module controller_tb;
  reg [5:0] op, func;
  reg equal;
  wire memwrite, regwrite, memtoreg, regdst, alusrc, se_ze, branch, start_mult, mult_sign;
  wire [3:0] alu_op;
  wire [1:0] out_sel, pcsrc;
  
  controller dut (op, func,
                  equal,
                  memwrite, regwrite, memtoreg, regdst, alusrc, se_ze, branch, start_mult, mult_sign,
                  alu_op,
                  out_sel, pcsrc);
  initial begin 
    
    //signal order: memwrite, regwrite, memtoreg, regdst, alusrc, se_ze, branch, start_mult, mult_sign, alu_op, out_sel, pcsrc
    
    op = 6'h0; //R-type instructions
    func = 0'h20; #10; //add   010100000_0100_00_00
    func = 0'h21; #10; //addu  010100000_0100_00_00
    func = 0'h22; #10; //sub   010100000_1100_00_00
    func = 0'h23; #10; //subu  010100000_1100_00_00
    func = 0'h24; #10; //and   010100000_0000_00_00
    func = 0'h25; #10; //or    010100000_0001_00_00
    func = 0'h26; #10; //xor   010100000_0010_00_00
    func = 0'h27; #10; //xnor  010100000_0011_00_00
    func = 6'h2a; #10; //slt   010100000_1101_00_00
    func = 6'h2b; #10; //sltu  010100000_0110_00_00
    func = 6'h18; #10; //mult  000000011_0000_00_00
    func = 6'h19; #10; //multu 000000010_0000_00_00
    func = 6'h10; #10; //mfhi  010100000_0000_11_00
    func = 6'h12; #10; //mflo  010100000_0000_10_00
    
    //I-type instructions    
    func = 6'bxxxxxx;
    op = 6'h23; #10; //lw 011011000_0100_00_00
    op = 6'h2b; #10; //sw 100011000_0100_00_00
    op = 6'h4; //beq
    equal = 0; #10; //    000001100_0000_00_00
    equal = 1; #10; //    000001100_0000_00_01
    op = 6'h5; //bne
    equal = 0; #10; //    000001100_0000_00_01
    equal = 1; #10; //    000001100_0000_00_01
    
    equal = 1'bx;
    op = 6'h8; #10; //addi  010011000_0100_00_00
    op = 6'h9; #10; //addiu 010011000_0100_00_00
    op = 6'hc; #10; //andi  010010000_0000_00_00
    op = 6'hd; #10; //ori   010010000_0001_00_00
    op = 6'he; #10; //xori  010010000_0010_00_00
    op = 6'ha; #10; //slti  010011000_1101_00_00
    op = 6'hb; #10; //sltiu 010011000_0110_00_00
    op = 6'hf; #10; //lui   010000000_0000_01_00
    op = 6'h2; #10; //j     000000000_0000_00_10
    $stop;

  end
  
endmodule 

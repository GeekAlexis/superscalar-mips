`timescale 1ns / 1ps

module multiplier_tb;
  reg [31:0] a = 0;
  reg [31:0] b = 0;
  reg clk = 0, start = 0;
  reg is_signed = 0;
  wire busy;
  wire[63:0] s;
  integer i = 0;
  reg [63:0] k;
  
  multiplier dut (clk, start, is_signed, a, b, busy, s);
  
  task display; //task to make the clock tick
    begin
      #1; clk = ~clk;
      #1; clk = ~clk;
    end
  endtask
  
  initial begin 
       
    //87359729 * 23422 signed
    a = 87359729; b = 23422; is_signed = 1;
    
    start = 1; display; start = 0;
    for (i = 1; i < 65; i = i + 1) display;

    k = 87359729 * 23422; //directly multiply to check the result
    
    //-77 * 999 signed
    a = -77; b = 999; is_signed = 1;
    
    start = 1; display; start = 0;
    for (i = 1; i < 65; i = i + 1) display;

    k = -77 * 999; //directly multiply to check the result
    
    //809843053 * -328932 signed
    a = 809843053; b = -328932; is_signed = 1;
    
    start = 1; display; start = 0;
    for (i = 1; i < 65; i = i + 1) display;

    k = 809843053 * -328932; //directly multiply to check the result
    
    //-2147483648 * -2147483648 signed
    a = -2147483648; b = -2147483648; is_signed = 1;
    
    start = 1; display; start = 0;
    for (i = 1; i < 65; i = i + 1) display;

    k = -2147483648 * -2147483648; //directly multiply to check the result
    
    //33329255 * 45825983 unsigned
    a = 33329255; b = 45825983; is_signed = 0;
    
    start = 1; display; start = 0;
    for (i = 1; i < 65; i = i + 1) display;
    k = 33329255 * 45825983; //directly multiply to check the result
    
    //0xF398_F1AB * 0xFFFF_FFFF unsigned
    a = 32'hf398_f1ab; b = 32'hffff_ffff; is_signed = 0;
    
    start = 1; display; start = 0;
    for (i = 1; i < 65; i = i + 1) display;

    k = 32'hf398_f1ab * 32'hffff_ffff; //directly multiply to check the result
    
    start = 0; display; start = 0;
    for (i = 1; i < 65; i = i + 1) display;
    $stop;

  end
  
endmodule 

`timescale 1ns / 1ps

module multiplier_tb;
  reg clk = 0, multE, is_signedE;
  reg [31:0] a, b;
  wire mult_stall;
  wire[63:0] s;
  integer i;
  reg [63:0] k;
  
  multiplier dut (clk, multE, is_signedE,
                  a, b, 
                  mult_stall, s);
  
  task display;
    begin
      #1; clk = ~clk;
      #1; clk = ~clk;
    end
  endtask
  
  initial begin 
    
    //87359729 * 23422 signed
    multE = 1; is_signedE = 1; a = 87359729; b = 23422; 
  
    for (i = 0; i < 65; i = i + 1) display;
    k = 87359729 * 23422; 
    
    //-77 * 999 signed
    multE = 1; is_signedE = 1; a = -77; b = 999;
    
    for (i = 0; i < 65; i = i + 1) display;
    k = -77 * 999; 
    
    //809843053 * -328932 signed
    multE = 1; is_signedE = 1; a = 809843053; b = -328932;

    for (i = 0; i < 65; i = i + 1) display;
    k = 809843053 * -328932; 
    
    //-2147483648 * -2147483648 signed
    multE = 1; is_signedE = 1; a = -2147483648; b = -2147483648;
    
    for (i = 0; i < 65; i = i + 1) display;
    k = -2147483648 * -2147483648;
    
    //33329255 * 45825983 unsigned
    multE = 1; is_signedE = 0; a = 33329255; b = 45825983;
    
    for (i = 0; i < 65; i = i + 1) display;
    k = 33329255 * 45825983;
    
    //0xF398_F1AB * 0xFFFF_FFFF unsigned
    multE = 1; is_signedE = 0; a = 32'hf398_f1ab; b = 32'hffff_ffff;

    for (i = 0; i < 65; i = i + 1) display;
    k = 32'hf398_f1ab * 32'hffff_ffff;
    
    for (i = 0; i < 65; i = i + 1) display;
    $stop;
  end
  
endmodule

`timescale 1ns / 1ps

module multiplier_tb;
  reg [31:0] a = 0;
  reg [31:0] b = 0;
  reg clk = 0, start = 0;
  reg is_signed = 0;
  wire[63:0] s;
  
  integer i = 0;
  reg [63:0] k = 0;
  
  multiplier mult_32b (clk, start, is_signed, a, b, s);
  
  task display;
    begin
      #1;
      clk = ~clk;
      #1;
      clk = ~clk;
    end
  endtask
  
  initial begin 
    $dumpfile("dump.vcd");
  	$dumpvars(1);
       
    //87359729 * 23422 signed
    a = 87359729;
    b = 23422;
    is_signed = 1;
    
    start = 1;
    display;
    start = 0;
    
    for (i = 1; i < 65; i = i + 1) begin
      display;
    end
    k = 87359729 * 23422;
    
    //-77 * 999 signed
    a = -77;
    b = 999;
    is_signed = 1;
    
    start = 1;
    display;
    start = 0;
    
    for (i = 1; i < 65; i = i + 1) begin
      display;
    end
    k = -77 * 999;
    
    //809843053 * -328932 signed
    a = 809843053;
    b = -328932;
    is_signed = 1;
    
    start = 1;
    display;
    start = 0;
    
    for (i = 1; i < 65; i = i + 1) begin
      display;
    end
    k = 809843053 * -328932;
    
    //-2147483648 * -2147483648 signed
    a = -2147483648;
    b = -2147483648;
    is_signed = 1;
    
    start = 1;
    display;
    start = 0;
    
    for (i = 1; i < 65; i = i + 1) begin
      display;
    end
    k = -2147483648 * -2147483648;
    
    //33329255 * 45825983 unsigned
    a = 33329255;
    b = 45825983;
    is_signed = 0;
    
    start = 1;
    display;
    start = 0;
    
    for (i = 1; i < 65; i = i + 1) begin
      display;
    end
    k = 33329255 * 45825983;
    
    //4294967295 * 4294967295 unsigned
    a = 4294967295;
    b = 4294967295;
    is_signed = 0;
    
    start = 1;
    display;
    start = 0;
    
    for (i = 1; i < 65; i = i + 1) begin
      display;
    end
    k = 4294967295 * 4294967295;
    
    start = 0;
    display;
    start = 0;
    
    for (i = 1; i < 65; i = i + 1) begin
      display;
    end
 
  end
  
endmodule


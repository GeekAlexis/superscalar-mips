`timescale 1ns / 1ps

module reg_file_tb;
	
  reg clk = 1, reset = 1, write; //reset is high at the begining
  reg [4:0] pr1 = 1, pr2 = 2; //set register file to read #1 and #2 register at start
  reg [4:0] wr;
  reg [31:0] wd;
  wire [31:0] rd1, rd2;
	
  reg_file dut (clk, reset, write, 
		pr1, pr2,
		wr,
		wd,
		rd1, rd2);
  
  task display; //task to make the clock tick
    begin
      #5; clk = ~clk;
      #5; clk = ~clk;
    end
  endtask
  
  initial begin 
    
    display; //reset the register file
    reset = 0;
    write = 1;
		
    wr = 1;
    wd = 32'hffff_ffff;
    reset = 0;
    display; //write 0xFFFF_FFFF to register #1
		
    wr = 2;
    wd = 32'h0fff_ffff;
    display; //write 0x0FFF_FFFF to register #2
		
    wr = 3;
    wd = 32'h00ff_ffff;
    pr1 = 3; //read from register #3
    pr2 = 4; //read from register #4
    display; //write 0x00FF_FFFF to register #3
	
    wr = 4;
    wd = 32'h000f_ffff;
    display; //write 0x000F_FFFF to register #4
    
    write = 0;
    wd = 32'h0000_ffff;
    display; //try to write 0x0000_FFFF to register #4 when write is low
    $stop;
  
  end
  
endmodule 

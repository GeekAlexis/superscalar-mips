`timescale 1ns / 1ps

module inst_memory_tb;
  
  reg [31:0] address = 0;
  wire [31:0] read_data;
  integer i;
	
  inst_memory dut (address, read_data);
  
  initial begin 
    
    i = 1; #10 //read in total 15 lines of machine code, i indicates the line number
    
    for(i = 2; i <= 15 ; i = i + 1) begin
      address = address + 4; #10;
    end
    $stop;

  end
  
endmodule

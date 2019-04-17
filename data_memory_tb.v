`timescale 1ns / 1ps

module data_memory_tb;

  reg clk = 0;
  reg write = 1; //initially write to memory
  reg [31:0] address;
  reg [31:0] write_data;
  wire [31:0] read_data;
	
  data_memory dut (clk, write,
                   address, 
                   write_data,
                   read_data);

  task display; //task to make the clock tick
    begin
      #1; clk = ~clk;
      #1; clk = ~clk;
    end
  endtask
  
  initial begin 

    address = 0;
    write_data = 32'hffff_ffff;
    display; //write 0xFFFF_FFFF to address 0
		
    address = 4;
    write_data = 32'h0fff_ffff;
    display; //write 0x0FFF_FFFF to address 4
		
    address = 8;
    write_data = 32'h00ff_ffff;
    display; //write 0x00FF_FFFF to address 8
	
    address = 12;
    write_data = 32'h000f_ffff;
    display; //write 0x000F_FFFF to address 12

    write = 0;
    address = 12;
    write_data = 32'h0000_ffff;
    display; //try to write 0x0000_FFFF to address 12 when write = 0
		
    address = 0;
    display; //read from address 0
    
    address = 4;
    display; //read from address 4
    
    address = 8;
    display; //read from address 8
    
    address = 12;
    display; //read from address 12
    $stop;

  end
  
endmodule 

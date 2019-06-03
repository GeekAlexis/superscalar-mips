`timescale 1ns / 1ps

module data_path_tb;
  
  reg clk;
  reg reset = 1;

  data_path dut(clk, reset);
    
  initial begin // initialize test
    #10; reset = 0;
  end
    
  always begin // generate clock to sequence tests
    clk = 0; #5;
    clk = 1; #5;
  end

endmodule

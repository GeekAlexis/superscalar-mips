`timescale 1ns / 1ps
module data_memory(input clk, read, write,
                   input [31:0] addr,
                   input [127:0] data_to_mem,
                   output reg ready = 0,
                   output reg [127:0] data_from_mem);

  reg [127:0] ram [0:4095];
  wire [27:0] i; assign i = addr[31:4];

  always @(posedge clk) begin
    if(ready) ready <= 0;
    if(read) begin
      ready <= #190 1;
      data_from_mem <= #190 ram[i];
    end
    else if(write) begin
      ready <= #190 1;
      ram[i] <= #190 data_to_mem;
    end

  end
    
endmodule 

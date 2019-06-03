/*
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
      ready <= #190 1; //delay by 190ns, 10ns per cycle, data available at 20th cycle
      data_from_mem <= #190 ram[i];
    end
    else if(write) begin
      ready <= #190 1; //delay by 190ns, 10ns per cycle, data written at 20th cycle
      ram[i] <= #190 data_to_mem;
    end

  end
    
endmodule*/ 

module data_memory(input clk, write1, write2,
                   input [31:0] addr1, addr2,
                   input [31:0] write_data1, write_data2,
                   output [31:0] read_data1, read_data2);

  reg [31:0] ram [0:63]; //64 words memory
    
  always @(negedge clk) begin
    if((addr1 == addr2) & write1 & write2) ram[addr2[31:2]] <= write_data2;
    else begin
      if(write1) ram[addr1[31:2]] <= write_data1;
      if(write2) ram[addr2[31:2]] <= write_data2;
    end
  end
  
  assign read_data1 = ram[addr1[31:2]];
  assign read_data2 = ram[addr2[31:2]];

endmodule

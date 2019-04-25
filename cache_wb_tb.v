`timescale 1ns / 1ps

module cache_wb_tb;

  reg clk = 0, reset = 1;
  reg read = 0, write = 0;
  reg [31:0] addr_cpu, data_cpu;
  wire mem_ready;
  wire [127:0] data_from_mem;

  wire hit, mem_read, mem_write, cache_stall;
  wire [31:0] mem_addr, data_out;
  wire [127:0] data_to_mem;
 
  integer i = 0;

  cache_wb cache(clk, reset, mem_ready, 
               read, write,
               addr_cpu, data_cpu,
               data_from_mem,
               hit, mem_read, mem_write, cache_stall,
               mem_addr, 
               data_out,
               data_to_mem);
	
  data_memory mem(clk, mem_read, mem_write,
                  mem_addr,
                  data_to_mem,
                  mem_ready,
                  data_from_mem);

  initial begin // initialize test
    #10;
    reset = 0;
  end
    
  always begin // generate clock to sequence tests
    clk = 0; #5;
    clk = 1; #5;
  end
  
  always @(*) begin
    case(i)
      1:  begin read = 0; write = 1; addr_cpu = 32'b000000000000000000_0000000000_00_00; data_cpu = 32'ha000_000b; end //way0, set0
      2:  begin read = 0; write = 1; addr_cpu = 32'b000000000000000000_0000000000_11_00; data_cpu = 32'ha000_001b; end //way0, set0
      3:  begin read = 0; write = 1; addr_cpu = 32'b000000000000000000_0000000001_00_00; data_cpu = 32'ha000_002b; end //way0, set1
      4:  begin read = 0; write = 1; addr_cpu = 32'b000000000000000000_0000000001_11_00; data_cpu = 32'ha000_003b; end //way0, set1
      
      5:  begin read = 1; write = 0; addr_cpu = 32'b000000000000000000_0000000000_00_00; data_cpu = 32'hx; end
      6:  begin read = 1; write = 0; addr_cpu = 32'b000000000000000000_0000000000_11_00; data_cpu = 32'hx; end
      7:  begin read = 1; write = 0; addr_cpu = 32'b000000000000000000_0000000001_00_00; data_cpu = 32'hx; end
      8:  begin read = 1; write = 0; addr_cpu = 32'b000000000000000000_0000000001_11_00; data_cpu = 32'hx; end
      
      9:  begin read = 0; write = 1; addr_cpu = 32'b000000000000000001_0000000000_00_00; data_cpu = 32'ha000_004b; end //way1, set0
      10: begin read = 0; write = 1; addr_cpu = 32'b000000000000000001_0000000000_11_00; data_cpu = 32'ha000_005b; end //way1, set0
      11: begin read = 0; write = 1; addr_cpu = 32'b000000000000000010_0000000000_00_00; data_cpu = 32'ha000_006b; end //way0, set0
      12: begin read = 0; write = 1; addr_cpu = 32'b000000000000000010_0000000000_11_00; data_cpu = 32'ha000_007b; end //way0, set0
      
      13: begin read = 1; write = 0; addr_cpu = 32'b000000000000000000_0000000000_00_00; data_cpu = 32'hx; end //read 0
      14: begin read = 1; write = 0; addr_cpu = 32'b000000000000000000_0000000000_11_00; data_cpu = 32'hx; end //read 1
      15: begin read = 1; write = 0; addr_cpu = 32'b000000000000000001_0000000000_00_00; data_cpu = 32'hx; end //read 4
      16: begin read = 1; write = 0; addr_cpu = 32'b000000000000000001_0000000000_11_00; data_cpu = 32'hx; end //read 5
      
      17: begin read = 1; write = 0; addr_cpu = 32'b000000000000000010_0000000000_00_00; data_cpu = 32'hx; end //read 6
      18: begin read = 1; write = 0; addr_cpu = 32'b000000000000000010_0000000000_11_00; data_cpu = 32'hx; end //read 7
     
    endcase
  end

  always @(posedge clk) begin
    if(~cache_stall) begin
      i = i + 1;
      if(i == 19) $stop;
    end
  end
  
endmodule 

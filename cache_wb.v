module cache_wb(input clk, reset, mem_ready, 
                input read0, write0,
                input [31:0] addr_cpu0, data_cpu0,
                input [127:0] data_from_mem,
                output hit, mem_read, mem_write, cache_stall,
                output reg [31:0] mem_addr, 
                output [31:0] data_out,
                output reg [127:0] data_to_mem);
  
  reg read1, write1, delay_cache_stall;
  reg [31:0] addr_cpu1, data_cpu1;
  always @(posedge clk) begin
    delay_cache_stall <= cache_stall;
    if(~delay_cache_stall) begin
      read1 <= read0;
      write1 <= write0;
      addr_cpu1 <= addr_cpu0;
      data_cpu1 <= data_cpu0;
    end
  end
  wire read; assign read = (delay_cache_stall) ? read1 : read0;
  wire write; assign write = (delay_cache_stall) ? write1 : write0;
  wire [31:0] addr_cpu; assign addr_cpu = (delay_cache_stall) ? addr_cpu1 : addr_cpu0;
  wire [31:0] data_cpu; assign data_cpu = (delay_cache_stall) ? data_cpu1 : data_cpu0;

  wire cpu_write0;
  wire cpu_write1;
  reg cw_mem0, mem_wc0, cw_mem1, mem_wc1; 
  wire hit0, hit1, valid0, valid1, dirty0, dirty1;
  wire [31:0] addr_out0, addr_out1, word_out0, word_out1; 
  wire [127:0] block_out0, block_out1;
  assign cpu_write0 = (write & hit0) ? 1 : 0;
  assign cpu_write1 = (write & hit1) ? 1 : 0;
  
  reg [3:0] state;
  way way0(clk, reset, cpu_write0, cw_mem0, mem_wc0, mem_ready, 1'b0,
           state,
           addr_cpu, data_cpu,
           data_from_mem,
           hit0, valid0, dirty0,
           addr_out0, word_out0,
           block_out0);

  way way1(clk, reset, cpu_write1, cw_mem1, mem_wc1, mem_ready, 1'b1,
           state,
           addr_cpu, data_cpu,
           data_from_mem,
           hit1, valid1, dirty1,
           addr_out1, word_out1,
           block_out1);
  

  assign hit = hit0 | hit1;
  assign mem_read = (state == 0 & (mem_wc0 | mem_wc1)) | ((mem_wc0 | mem_wc1) & (state == 4'b1000 | state == 4'b0010) & mem_ready);
  assign mem_write = (state == 0 & (cw_mem0 | cw_mem1)) | ((cw_mem0 | cw_mem1) & (state == 4'b1000 | state == 4'b0010) & mem_ready); 
  assign cache_stall = (read | write) & ~hit ;
  assign data_out = (hit0) ? word_out0[31:0] : 
	            (hit1) ? word_out1[31:0] : 32'bx;
  
  reg lru [0:1023];
  reg p_lru;
  wire[9:0] index; assign index = addr_cpu[13:4];
  integer i;

  always @(posedge clk) begin
    
    if(reset) begin
      state <= 0;
      delay_cache_stall <= 0;
      for(i = 0; i < 1024; i = i + 1) lru[i] <= 0;
    end
    else if(read | write) begin 
      if(hit) begin
        state <= 0;
        lru[index] <= (hit0) ? 1 : 0;
      end  
      else if (~valid0 | (mem_ready & state == 4'b1000) | ~p_lru & ~dirty0)
        state = 4'b0100;
      else if (~valid1 | (mem_ready & state == 4'b0010) | p_lru & ~dirty1)
        state = 4'b0001;
      else if (~p_lru & dirty0)
        state = 4'b1000;
      else if (p_lru & dirty1)
       state = 4'b0010;
    end
 
  end  
  
  always @(*) begin
    
    if(read | write) begin   
      if(hit) begin
        cw_mem0 <= 0; mem_wc0 <= 0; cw_mem1 <= 0; mem_wc1 <= 0;
        p_lru <= (hit0) ? 1 : 0;
      end
      else if (~valid0 | (mem_ready & state == 4'b1000) | ~p_lru & ~dirty0) begin
        cw_mem0 <= 0; mem_wc0 <= 1; cw_mem1 <= 0; mem_wc1 <= 0;
        mem_addr <= addr_cpu;
        p_lru <= lru[index];
      end
      else if (~valid1 | (mem_ready & state == 4'b0010) | p_lru & ~dirty1) begin
        cw_mem0 <= 0; mem_wc0 <= 0; cw_mem1 <= 0; mem_wc1 <= 1;
        mem_addr <= addr_cpu;
        p_lru <= lru[index];   
      end
      else if (~p_lru & dirty0) begin
        cw_mem0 <= 1; mem_wc0 <= 0; cw_mem1 <= 0; mem_wc1 <= 0;
        mem_addr <= addr_out0;
        data_to_mem <= block_out0;
        p_lru <= lru[index];
      end
      else if (p_lru & dirty1) begin
        cw_mem0 <= 0; mem_wc0 <= 0; cw_mem1 <= 1; mem_wc1 <= 0;
        mem_addr <= addr_out1;
        data_to_mem <= block_out1;
        p_lru <= lru[index];
      end
    end

  end
  
endmodule

module way(input clk, reset, cpu_write, cw_mem, mem_wc, mem_ready, a,
           input [3:0] state,
           input [31:0] addr_in, word_in,
           input [127:0] block_in,
           output hit, valid, dirty,
           output [31:0] addr_out, word_out,
           output [127:0] block_out);
  
  wire [17:0] tag; assign tag = addr_in[31:14];  
  wire [9:0] index; assign index = addr_in[13:4];
  wire [1:0] offset; assign offset = addr_in[3:2];
  reg [147:0] sets [0:1023];
  
  assign hit = ((tag == sets[index][145:128]) & sets[index][147]);
  assign valid = sets[index][147];
  assign dirty = sets[index][146];
  assign addr_out = {sets[index][145:128], index, offset, 2'b00};
  mux4#(32) mux (sets[index][31:0], sets[index][63:32], sets[index][95:64], sets[index][127:96], offset, word_out);
  assign block_out = sets[index][127:0];
  integer i;

  always @(posedge clk) begin
    
    if(reset) begin
      for(i = 0; i < 1024; i = i + 1) sets[i] <= 0;
    end
    
    else if(cpu_write & hit) begin
      sets[index][146] <= 1; //dirty bit
      sets[index][145:128] <= tag;
      case(offset)
         2'b00: sets[index][31:0] = word_in;
         2'b01: sets[index][63:32] = word_in;
         2'b10: sets[index][95:64] = word_in;
         2'b11: sets[index][127:96] = word_in;
      endcase
    end       
    
    else if( ((~a & state == 4'b1000) | (a & state == 4'b0010)) & mem_ready) begin
      sets[index][147] <= 0; //valid bit      
    end

    else if( ((~a & state == 4'b0100) | (a & state == 4'b0001)) & mem_ready) begin
      sets[index][147] <= 1; //valid bit
      sets[index][146] <= 0; //dirty bit
      sets[index][145:128] <= tag;
      sets[index][127:0] <= block_in;
    end

  end

endmodule 

module mux4#(parameter width = 1)
	   (input [width - 1:0] d0, d1, d2, d3,
	    input [1:0] sel,
	    output [width - 1:0] y);

	assign y = (sel == 2'd0) ? d0 : 
	           (sel == 2'd1) ? d1 :
	           (sel == 2'd2) ? d2 : 
	           (sel == 2'd3) ? d3 : {width{1'bx}};
	
endmodule

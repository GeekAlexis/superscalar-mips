module cache_wb(input clk, reset, mem_ready, //mem_ready become 1 after 20 cycles of memory delay
                input read0, write0, //read, write is connected to the controls memreadM and memwriteM
                input [31:0] addr_cpu0, data_cpu0, //addr_cpu is connected to OutM, data_cpuis connected to writedataM
                input [127:0] data_from_mem, //the block of data read from memeory
                output hit, mem_read, mem_write, cache_stall, //cache_stall stall the entire pipeline when memory access needed
                output reg [31:0] mem_addr, //address of memory location cache wants access
                output [31:0] data_out, //connected to readdataM
                output reg [127:0] data_to_mem); //block of data to write to memory from cache
  
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
  assign cpu_write0 = (write & hit0) ? 1 : 0; //if way 0 is hitted in the first cycle, write to cache directly
  assign cpu_write1 = (write & hit1) ? 1 : 0; //if way 1 is hitted in the first cycle, write to cache directly
  
  reg [3:0] state; //state can take number 8, 4, 2, 1, 0
  //the two ways of the cache
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
  

  assign hit = hit0 | hit1; //hit is 1 when one of the ways get a hit
  //the following logic makes sure mem_read only stay high for one cycle
  assign mem_read = (state == 0 & (mem_wc0 | mem_wc1)) | ((mem_wc0 | mem_wc1) & (state == 4'b1000 | state == 4'b0010) & mem_ready);
  //the following logic makes sure mem_write only stay high for one cyle
  assign mem_write = (state == 0 & (cw_mem0 | cw_mem1)) | ((cw_mem0 | cw_mem1) & (state == 4'b1000 | state == 4'b0010) & mem_ready); 
  assign cache_stall = (read | write) & ~hit ; //stall cache when we need to read or write but we did not hit
  assign data_out = (hit0) ? word_out0[31:0] : 
	            (hit1) ? word_out1[31:0] : 32'bx;
  
  reg lru [0:1023]; //lru register
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
        state <= 0; //if hit, state stays 0 
        lru[index] <= (hit0) ? 1 : 0;
      end  
      else if (~valid0 | (mem_ready & state == 4'b1000) | ~p_lru & ~dirty0)
        state = 4'b0100; //state 4, memory writes the requested block to way0
      else if (~valid1 | (mem_ready & state == 4'b0010) | p_lru & ~dirty1)
        state = 4'b0001; //state 1, memory writes the requested block to way1
      else if (~p_lru & dirty0)
        state = 4'b1000; //state 8, way0 writes a block to memory
      else if (p_lru & dirty1)
       state = 4'b0010; //state 2, way1 writes a block to memory
    end
 
  end  
  
  always @(*) begin
    
    if(read | write) begin   
      if(hit) begin
        cw_mem0 <= 0; mem_wc0 <= 0; cw_mem1 <= 0; mem_wc1 <= 0;
        p_lru <= (hit0) ? 1 : 0;
      end
      else if (~valid0 | (mem_ready & state == 4'b1000) | ~p_lru & ~dirty0) begin
        cw_mem0 <= 0; mem_wc0 <= 1; cw_mem1 <= 0; mem_wc1 <= 0; //control signals to make memory write to way0
        mem_addr <= addr_cpu;
        p_lru <= lru[index];
      end
      else if (~valid1 | (mem_ready & state == 4'b0010) | p_lru & ~dirty1) begin
        cw_mem0 <= 0; mem_wc0 <= 0; cw_mem1 <= 0; mem_wc1 <= 1; //control signals to make memory write to way1
        mem_addr <= addr_cpu;
        p_lru <= lru[index];   
      end
      else if (~p_lru & dirty0) begin
        cw_mem0 <= 1; mem_wc0 <= 0; cw_mem1 <= 0; mem_wc1 <= 0; //control signals to make way0 write to memory
        mem_addr <= addr_out0;
        data_to_mem <= block_out0;
        p_lru <= lru[index];
      end
      else if (p_lru & dirty1) begin
        cw_mem0 <= 0; mem_wc0 <= 0; cw_mem1 <= 1; mem_wc1 <= 0; //control signals to make way1 write to memory
        mem_addr <= addr_out1;
        data_to_mem <= block_out1;
        p_lru <= lru[index];
      end
    end

  end
  
endmodule

module way(input clk, reset, cpu_write, cw_mem, mem_wc, mem_ready, a, //a = 0 creats way0 module, a = 1 creats way1 module
           input [3:0] state,
           input [31:0] addr_in, word_in, //word_in is the word from the pipeline
           input [127:0] block_in, //block_in is the block from memory
           output hit, valid, dirty, //hit, valid bit and dirty bit output
           output [31:0] addr_out, word_out, //addr_out is address for memory, word_out is the word output to the pipeline
           output [127:0] block_out);//block_out is the block written to memory
  
  wire [17:0] tag; assign tag = addr_in[31:14]; //18 tag bits
  wire [9:0] index; assign index = addr_in[13:4]; //10 index bits
  wire [1:0] offset; assign offset = addr_in[3:2]; //2 offset bits
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
    
    else if(cpu_write & hit) begin //write the word directly if we get a hit
      sets[index][146] <= 1; //dirty bit
      sets[index][145:128] <= tag;
      case(offset)
         2'b00: sets[index][31:0] = word_in;
         2'b01: sets[index][63:32] = word_in;
         2'b10: sets[index][95:64] = word_in;
         2'b11: sets[index][127:96] = word_in;
      endcase
    end       
    
    else if( ((~a & state == 4'b1000) | (a & state == 4'b0010)) & mem_ready) begin //write a block back to memory
      sets[index][147] <= 0; //valid bit      
    end

    else if( ((~a & state == 4'b0100) | (a & state == 4'b0001)) & mem_ready) begin //write a block from memory to cache
      sets[index][147] <= 1; //valid bit
      sets[index][146] <= 0; //dirty bit
      sets[index][145:128] <= tag;
      sets[index][127:0] <= block_in;
    end

  end

endmodule 

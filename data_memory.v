module data_memory(input clk, write,
                   input [31:0] address,
                   input [31:0] write_data,
                   output reg [31:0] read_data);

  reg [31:0] ram [0:63]; //64 words memory
    
  always @(posedge clk) begin
    if(write)
      ram[address[31:2]] <= write_data; //write data
    else
      read_data <= ram[address[31:2]]; //write data
  end
    
endmodule 

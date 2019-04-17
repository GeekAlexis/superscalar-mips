module inst_memory(input [31:0] address,
                   output [31:0] read_data);

  reg [31:0] ram [0:127]; //memory with 128 32-bits words 

  initial
    $readmemh("dotProduct.mem", ram); //load machine code
  
  assign read_data = ram[address[31:2]]; //read from memory
 
endmodule 

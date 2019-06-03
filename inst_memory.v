module inst_memory(input [31:0] pcF1, pcF2,
                   output [31:0] instrF1, instrF2);

  reg [31:0] ram [0:127]; //memory with 128 32-bits words 

  initial
    $readmemh("program.mem", ram); //load machine code
  
  assign instrF1 = ram[pcF1[31:2]]; //read from memory
  assign instrF2 = ram[pcF2[31:2]];
 
endmodule 

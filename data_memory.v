module data_memory(input clk, write,
                   input [31:0] address,
                   input [31:0] write_data,
                   output [31:0] read_data);

    reg [31:0] ram [0:63];
    always @(posedge clk) begin
        if(write)
            ram[address[31:2]] <= write_data;
    end
    assign read_data = ram[address[31:2]];
    
endmodule
                   

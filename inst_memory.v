module inst_memory(input [31:0] address,
                   output [31:0] read_data);

    reg [31:0] ram [0:63];
    initial begin
	$readmemh("dotProduct.mem", ram);
    end
    assign read_data = ram[address[31:2]];
 
endmodule


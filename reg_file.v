module reg_file(input clk, reset, write,
                input [4:0] pr1, pr2,
                input [4:0] wr,
                input [31:0] wd,
                output [31:0] rd1, rd2);
                
    reg [31:0] rf [0:31];
    integer i;
    always @(negedge clk) begin
        if(reset) begin
            for(i = 0; i < 32; i = i + 1)
                rf[i] <= 32'd0;
        end
        else if(write)
            rf[wr] <= wd;
    end
    assign rd1 = (pr1 != 0) ? rf[pr1] : 32'd0;
    assign rd2 = (pr2 != 0) ? rf[pr2] : 32'd0;
    
endmodule
            

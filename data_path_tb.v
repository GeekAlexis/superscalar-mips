`timescale 1ns / 1ps

module data_path_tb;

    reg clk;
    reg reset;
    wire [31:0] pcF, instrD, outM, writedataM;
    wire memwriteM;
    wire [31:0] readdataM;
    
    data_path dut(clk, reset, pcF, instrD, outM, writedataM, readdataM, memwriteM);
    
    // initialize test
    initial begin
        reset = 1; 
        #10;
        reset = 0;
    end
    
    // generate clock to sequence tests
    always begin
        clk = 0;
        #5;
        clk = 1;
        #5;
    end
    
    // dot product result 4985
    // check results
    always @(negedge clk) begin
        if(memwriteM) begin
            if(outM === 0 & writedataM === 4985) begin
                $display("Simulation succeeded");
                #5;
                $stop;
            end
            else begin
                $display("Simulation failed");
                #5;
                $stop;
            end
        end
    end

endmodule


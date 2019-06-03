module reg_file(input clk, reset, write1, write2,
                input [4:0] addr1D1, addr2D1, addr1D2, addr2D2,
                input [4:0] wr1, wr2,
                input [31:0] wd1, wd2,
                output [31:0] rf_out1D1, rf_out2D1, rf_out1D2, rf_out2D2);
            
  reg [31:0] rf [0:31]; //32 registers
  integer i;
  
  always @(negedge clk) begin
    if(reset) begin
      for(i = 0; i < 32; i = i + 1) //reset all 32 registers
        rf[i] <= 32'd0;
      end
    else begin
      if((wr1 == wr2) & write1 & write2) rf[wr2] <= wd2;
      else begin
        if(write1) rf[wr1] <= wd1;
        if(write2) rf[wr2] <= wd2;
      end
    end
  end
  
  assign rf_out1D1 = (addr1D1 != 0) ? rf[addr1D1] : 32'd0; 
  assign rf_out2D1 = (addr2D1 != 0) ? rf[addr2D1] : 32'd0; 
  assign rf_out1D2 = (addr1D2 != 0) ? rf[addr1D2] : 32'd0; 
  assign rf_out2D2 = (addr2D2 != 0) ? rf[addr2D2] : 32'd0; 

endmodule 

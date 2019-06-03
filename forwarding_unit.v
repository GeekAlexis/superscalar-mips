module forwarding_unit(input [4:0] rsD1, rtD1, rsD2, rtD2, 
                       input [4:0] rsE1, rtE1, rsE2, rtE2,
                       input regwriteM1, regwriteM2, input [4:0] writeregM1, writeregM2,
                       input regwriteW1, regwriteW2, input [4:0] writeregW1, writeregW2,
                       output reg [1:0] forwardaD1, forwardbD1, forwardaD2, forwardbD2,
                       output reg [2:0] forwardaE1, forwardbE1, forwardaE2, forwardbE2);

  always @(*) begin
    
    //forward to decode stage
    if(rsD1 != 0) begin //outM1, outM2,
      if     (rsD1 == writeregM2 & regwriteM2) forwardaD1 = 2'd2;
      else if(rsD1 == writeregM1 & regwriteM1) forwardaD1 = 2'd1;
      else forwardaD1 = 2'd0;
    end
    else forwardaD1 = 2'd0;
    if(rtD1 != 0) begin
      if     (rtD1 == writeregM2 & regwriteM2) forwardbD1 = 2'd2;
      else if(rtD1 == writeregM1 & regwriteM1) forwardbD1 = 2'd1;
      else forwardbD1 = 2'd0;
    end
    else forwardbD1 = 2'd0; 
    if(rsD2 != 0) begin //outM1, outM2,
      if     (rsD2 == writeregM2 & regwriteM2) forwardaD2 = 2'd2;
      else if(rsD2 == writeregM1 & regwriteM1) forwardaD2 = 2'd1;
      else forwardaD2 = 2'd0;
    end
    else forwardaD2 = 2'd0;
    if(rtD2 != 0) begin
      if     (rtD2 == writeregM2 & regwriteM2) forwardbD2 = 2'd2;
      else if(rtD2 == writeregM1 & regwriteM1) forwardbD2 = 2'd1;
      else forwardbD2 = 2'd0;
    end 
    else forwardbD2 = 2'd0;

    //forward to execution stage
    if(rsE1 != 0) begin //outM1, resultW1, outM2, resultW2,
      if     (rsE1 == writeregM2 & regwriteM2) forwardaE1 = 3'd3;
      else if(rsE1 == writeregM1 & regwriteM1) forwardaE1 = 3'd1;
      else if(rsE1 == writeregW2 & regwriteW2) forwardaE1 = 3'd4;
      else if(rsE1 == writeregW1 & regwriteW1) forwardaE1 = 3'd2;
      else forwardaE1 = 3'd0;
    end
    else forwardaE1 = 2'd0;
    if(rtE1 != 0) begin
      if     (rtE1 == writeregM2 & regwriteM2) forwardbE1 = 3'd3;
      else if(rtE1 == writeregM1 & regwriteM1) forwardbE1 = 3'd1;
      else if(rtE1 == writeregW2 & regwriteW2) forwardbE1 = 3'd4;
      else if(rtE1 == writeregW1 & regwriteW1) forwardbE1 = 3'd2;
      else forwardbE1 = 3'd0;
    end
    else forwardbE1 = 3'd0;
    if(rsE2 != 0) begin //outM1, resultW1, outM2, resultW2,
      if     (rsE2 == writeregM2 & regwriteM2) forwardaE2 = 3'd3;
      else if(rsE2 == writeregM1 & regwriteM1) forwardaE2 = 3'd1;
      else if(rsE2 == writeregW2 & regwriteW2) forwardaE2 = 3'd4;
      else if(rsE2 == writeregW1 & regwriteW1) forwardaE2 = 3'd2;
      else forwardaE2 = 3'd0;
    end
    else forwardaE2 = 3'd0;
    if(rtE2 != 0) begin
      if     (rtE2 == writeregM2 & regwriteM2) forwardbE2 = 3'd3;
      else if(rtE2 == writeregM1 & regwriteM1) forwardbE2 = 3'd1;
      else if(rtE2 == writeregW2 & regwriteW2) forwardbE2 = 3'd4;
      else if(rtE2 == writeregW1 & regwriteW1) forwardbE2 = 3'd2;
      else forwardbE2 = 3'd0;
    end
    else forwardbE2 = 3'd0;
  end

endmodule 

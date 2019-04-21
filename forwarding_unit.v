module forwarding_unit(input regwriteM,
		       input regwriteW,
		       input [4:0] rsD, rtD, rsE, rtE,
		       input [4:0] writeregM, writeregW,
		       output forwardaD, forwardbD,
		       output reg [1:0] forwardaE, forwardbE);

  assign forwardaD = (rsD != 0) & (rsD == writeregM) & regwriteM;
  assign forwardbD = (rtD != 0) & (rtD == writeregM) & regwriteM;

  always @(*) begin
    if(rsE != 0 && rsE == writeregM && regwriteM)
      forwardaE = 2'b10; // forward from memory stage
    else if(rsE != 0 && rsE == writeregW && regwriteW)
      forwardaE = 2'b01; // forward from write-back stage
    else
      forwardaE = 2'b00; // no forwarding

    if(rtE != 0 && rtE == writeregM && regwriteM)
      forwardbE = 2'b10;
    else if(rtE != 0 && rtE == writeregW && regwriteW)
      forwardbE = 2'b01;
    else
      forwardbE = 2'b00;
  end

endmodule 

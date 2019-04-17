module hazard_detector(//input clk, reset,
		       input branchD,
		       input memtoregE, regwriteE,
		       input memtoregM, regwriteM,
		       input regwriteW,
		       input start_multE, busy_multE,
		       input [4:0] rsD, rtD, rsE, rtE,
		       input [4:0] writeregE, writeregM, writeregW,
		       output stallF, stallD,
		       output forwardaD, forwardbD,
		       output flushE,
		       output reg [1:0] forwardaE, forwardbE);

  wire lwstall; 
  wire branchstall, bsc1, bsc2; 
  //wire done;
  //reg [5:0] counter; // mult stall counter
  //reg multstall;
  wire multstall;
  assign multstall = start_multE | busy_multE;
  //assign done = counter == 6'd63; // signal for counter control
  assign lwstall = ((rsD == rtE) | (rtD == rtE)) & memtoregE;

  assign bsc1 = ((writeregE == rsD) | (writeregE == rtD)) & regwriteE;
  assign bsc2 = ((writeregM == rsD) | (writeregM == rtD)) & memtoregM;
  assign branchstall = branchD & (bsc1 | bsc2);
  
  assign forwardaD = (rsD != 0) & (rsD == writeregM) & regwriteM;
  assign forwardbD = (rtD != 0) & (rtD == writeregM) & regwriteM;
  // decode stage stall signals
  assign flushE = lwstall | branchstall | multstall;
  assign stallD = flushE;
  assign stallF = stallD;

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

    /*
    // count to 64 cycles
    always @(posedge clk) begin
	if(start_multE) counter <= 0;
	else if(~done) counter <= counter + 1;
    end

   // set multstall high for 64 cycles
   always @(start_multE or done or reset) begin
	if(start_multE) multstall = 1;
	else if(done | reset) multstall = 0;
   end
   */

endmodule

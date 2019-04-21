module hazard_detector(input branchD,
		       input memtoregE, regwriteE,
		       input memtoregM,
		       input regwriteW,
		       input start_multE, busy_multE, //let hazard unit know when mult is done
		       input [4:0] rsD, rtD, rsE, rtE,
		       input [4:0] writeregE, writeregM,
		       output stallF, stallD,
		       output flushE);

  wire lwstall; 
  wire branchstall, bsc1, bsc2;
  wire multstall;
  
  assign multstall = start_multE | busy_multE;
  assign lwstall = ((rsD == rtE) | (rtD == rtE)) & memtoregE;

  assign bsc1 = ((writeregE == rsD) | (writeregE == rtD)) & regwriteE;
  assign bsc2 = ((writeregM == rsD) | (writeregM == rtD)) & memtoregM;
  assign branchstall = branchD & (bsc1 | bsc2);
  
  // decode stage stall signals
  assign flushE = lwstall | branchstall | multstall;
  assign stallD = flushE;
  assign stallF = stallD;

endmodule

`timescale 1ns / 1ps

module hazard_detector_tb;
  
  reg branchD;
  reg memtoregE, regwriteE;
  reg memtoregM;
  reg regwriteW;
  reg start_multE, busy_multE;
  reg [4:0] rsD, rtD, rsE, rtE;
  reg [4:0] writeregE, writeregM;
  wire stallF, stallD;
  wire flushE;
 
  hazard_detector dut (branchD,
		       memtoregE, regwriteE,
		       memtoregM,
		       regwriteW,
		       start_multE, busy_multE,
		       rsD, rtD, rsE, rtE,
		       writeregE, writeregM,
		       stallF, stallD,
		       flushE);
  initial begin
    //mult stall
    start_multE = 0; busy_multE = 0; #10; //stallF = stallD = flushE = x
    start_multE = 0; busy_multE = 1; #10; //stallF = stallD = flushE = 1
    start_multE = 1; busy_multE = 0; #10; //stallF = stallD = flushE = 1
    start_multE = 1'bx; busy_multE = 1'bx;
    //lw stall
    rsD = 12; rtD = 11; rtE = 10; memtoregE = 1; #10; //stallF = stallD = flushE = x
    rsD = 10; rtD = 11; rtE = 10; memtoregE = 1; #10; //stallF = stallD = flushE = 1
    rsD = 11; rtD = 10; rtE = 10; memtoregE = 1; #10; //stallF = stallD = flushE = 1
    rsD = 10; rtD = 10; rtE = 10; memtoregE = 1; #10; //stallF = stallD = flushE = 1
    rsD = 10; rtD = 10; rtE = 10; memtoregE = 0; #10; //stallF = stallD = flushE = x
    rsD = 5'bx; rtD = 5'bx; rtE = 5'bx; memtoregE = 1'bx;
    //branch stall
    branchD = 1; rsD = 5; rtD = 6; writeregE = 7; regwriteE = 1; writeregM = 8; memtoregM = 1; #10; //stallF = stallD = flushE = x
    branchD = 1; rsD = 5; rtD = 6; writeregE = 5; regwriteE = 1; writeregM = 7; memtoregM = 1; #10; //stallF = stallD = flushE = 1
    branchD = 1; rsD = 5; rtD = 6; writeregE = 7; regwriteE = 1; writeregM = 6; memtoregM = 1; #10; //stallF = stallD = flushE = 1
    branchD = 1; rsD = 5; rtD = 6; writeregE = 7; regwriteE = 1; writeregM = 6; memtoregM = 0; #10; //stallF = stallD = flushE = x
    rsD = 5'bx; rtD = 5'bx; writeregE = 5'bx; regwriteE = 1'bx; writeregM = 5'bx; memtoregM = 1'bx;
    $stop;

  end

endmodule

`timescale 1ns / 1ps

module hazard_detector_tb;
  
  //reg clk = 0, reset = 0;
  reg branchD; 
  reg memtoregE, regwriteE;
  reg memtoregM, regwriteM;
  reg regwriteW;
  reg start_multE, busy_multE;
  reg [4:0] rsD, rtD, rsE, rtE;
  reg [4:0] writeregE, writeregM, writeregW;
  wire stallF, stallD;
  wire forwardaD, forwardbD;
  wire flushE;
  wire [1:0] forwardaE, forwardbE;
 
  hazard_detector dut (//clk, reset,
                       branchD, 
                       memtoregE, regwriteE,
                       memtoregM, regwriteM,
                       regwriteW,
                       start_multE, busy_multE,
                       rsD, rtD, rsE, rtE,
                       writeregE, writeregM, writeregW,
                       stallF, stallD,
                       forwardaD, forwardbD,
                       flushE,
                       forwardaE, forwardbE);
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
    //forwardA decode stage
    rsD = 0; writeregM = 0; regwriteM = 1; #10; //forwardaD = 0
    rsD = 5; writeregM = 2; regwriteM = 1; #10; //forwardaD = 0
    rsD = 5; writeregM = 5; regwriteM = 1; #10; //forwardaD = 1
    rsD = 5; writeregM = 5; regwriteM = 0; #10; //forwardaD = 0 
    rsD = 5'bx; writeregM = 5'bx; regwriteM = 1'bx;
    //forwardB decode stage
    rtD = 0; writeregM = 0; regwriteM = 1; #10; //forwardbD = 0
    rtD = 5; writeregM = 2; regwriteM = 1; #10; //forwardbD = 0
    rtD = 5; writeregM = 5; regwriteM = 1; #10; //forwardbD = 1
    rtD = 5; writeregM = 5; regwriteM = 0; #10; //forwardbD = 0
    rtD = 5'bx; writeregM = 5'bx; regwriteM = 1'bx;
    //forwardA execution stage
    rsE = 0; writeregM = 5; regwriteM = 1; writeregW = 5; regwriteW = 1; #10; //forwardaE = 2'b00
    rsE = 4; writeregM = 5; regwriteM = 1; writeregW = 6; regwriteW = 1; #10; //forwardaE = 2'b00
    rsE = 5; writeregM = 5; regwriteM = 1; writeregW = 5; regwriteW = 1; #10; //forwardaE = 2'b10
    rsE = 5; writeregM = 4; regwriteM = 1; writeregW = 5; regwriteW = 1; #10; //forwardaE = 2'b01
    rsE = 5'bx; writeregM = 5'bx; regwriteM = 1'bx; writeregW = 5'bx; regwriteW = 1'bx;
    //forwardB execution stage
    rtE = 0; writeregM = 5; regwriteM = 1; writeregW = 5; regwriteW = 1; #10; //forwardbE = 2'b00
    rtE = 4; writeregM = 5; regwriteM = 1; writeregW = 6; regwriteW = 1; #10; //forwardbE = 2'b00
    rtE = 5; writeregM = 5; regwriteM = 1; writeregW = 5; regwriteW = 1; #10; //forwardbE = 2'b10
    rtE = 5; writeregM = 4; regwriteM = 1; writeregW = 5; regwriteW = 1; #10; //forwardbE = 2'b01
    rtE = 5'bx; writeregM = 5'bx; regwriteM = 1'bx; writeregW = 5'bx; regwriteW = 1'bx;
    $stop;

  end

endmodule 

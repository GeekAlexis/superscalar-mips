`timescale 1ns / 1ps

module forwarding_unit_tb;
  
  reg regwriteM;
  reg regwriteW;
  reg [4:0] rsD, rtD, rsE, rtE;
  reg [4:0] writeregM, writeregW;
  wire forwardaD, forwardbD;
  wire [1:0] forwardaE, forwardbE;
 
  forwarding_unit dut (regwriteM,
		       regwriteW,
		       rsD, rtD, rsE, rtE,
		       writeregM, writeregW,
		       forwardaD, forwardbD,
		       forwardaE, forwardbE);
  initial begin
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
    rsE = 5; writeregM = 5; regwriteM = 1; writeregW = 5; regwriteW = 1; #10; //forwardaE = 2'b10
    rsE = 0; writeregM = 5; regwriteM = 1; writeregW = 5; regwriteW = 1; #10; //forwardaE = 2'b00
    rsE = 4; writeregM = 5; regwriteM = 1; writeregW = 6; regwriteW = 1; #10; //forwardaE = 2'b00
    rsE = 5; writeregM = 4; regwriteM = 1; writeregW = 5; regwriteW = 1; #10; //forwardaE = 2'b01
    rsE = 5'bx; writeregM = 5'bx; regwriteM = 1'bx; writeregW = 5'bx; regwriteW = 1'bx;
    //forwardB execution stage
    rtE = 5; writeregM = 5; regwriteM = 1; writeregW = 5; regwriteW = 1; #10; //forwardbE = 2'b10
    rtE = 0; writeregM = 5; regwriteM = 1; writeregW = 5; regwriteW = 1; #10; //forwardbE = 2'b00
    rtE = 4; writeregM = 5; regwriteM = 1; writeregW = 6; regwriteW = 1; #10; //forwardbE = 2'b00
    rtE = 5; writeregM = 4; regwriteM = 1; writeregW = 5; regwriteW = 1; #10; //forwardbE = 2'b01
    rtE = 5'bx; writeregM = 5'bx; regwriteM = 1'bx; writeregW = 5'bx; regwriteW = 1'bx;
    $stop;

  end

endmodule

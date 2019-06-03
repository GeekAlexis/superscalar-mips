module hazard_detector(input multD1, multD2, 
                       input [1:0] out_selD1, out_selD2,
                       input is_bjD1, real_bjD1, 
                       input branchD1, branchD2, memtoregD1, memtoregD2, regwriteD1, regwriteD2,
                       input [4:0] rsD1, rtD1, writeregD1, rsD2, rtD2, writeregD2,
                       input memtoregE1, regwriteE1, mult_stallE1, 
                       input memtoregE2, regwriteE2, mult_stallE2, 
                       input [4:0] rsE1, rtE1, writeregE1, rsE2, rtE2, writeregE2,
                       input memtoregM1, memtoregM2,
                       input [4:0] writeregM1, writeregM2,
                       output stall_f, 
                       output stall_d1, stall_e1, stall_m1, stall_w1,
                       output stall_d2, stall_e2, stall_m2, stall_w2,
                       output flush_d1, flush_e1, flush_m1, flush_w1,
                       output flush_d2, flush_e2, flush_m2, flush_w2);
  //lw stall
  wire lw_stall1; assign lw_stall1 = ( (((rsD1 == writeregE1) | (rtD1 == writeregE1)) & memtoregE1) |
                                       (((rsD1 == writeregE2) | (rtD1 == writeregE2)) & memtoregE2) );
                                                                                   
  wire lw_stall2; assign lw_stall2 = ( (((rsD2 == writeregD1) | (rtD2 == writeregD1)) & memtoregD1) |
                                       (((rsD2 == writeregE1) | (rtD2 == writeregE1)) & memtoregE1) |
                                       (((rsD2 == writeregE2) | (rtD2 == writeregE2)) & memtoregE2) );

  //branch stall
  wire bscE1; assign bscE1 = ( (((rsD1 == writeregE1) | (rtD1 == writeregE1)) & regwriteE1) |
                               (((rsD1 == writeregE2) | (rtD1 == writeregE2)) & regwriteE2) );
  wire bscM1; assign bscM1 = ( (((rsD1 == writeregM1) | (rtD1 == writeregM1)) & memtoregM1) |
                               (((rsD1 == writeregM2) | (rtD1 == writeregM2)) & memtoregM2) );
  wire branch_stall1; assign branch_stall1 = branchD1 & (bscE1 | bscM1);

  wire bscD2; assign bscD2 = ((rsD2 == writeregD1) | (rtD2 == writeregD1)) & regwriteD1; 
  wire bscE2; assign bscE2 = ( (((rsD2 == writeregE1) | (rtD2 == writeregE1)) & regwriteE1) |
                               (((rsD2 == writeregE2) | (rtD2 == writeregE2)) & regwriteE2) );
  wire bscM2; assign bscM2 = ( (((rsD2 == writeregM1) | (rtD2 == writeregM1)) & memtoregM1) |
                               (((rsD2 == writeregM2) | (rtD2 == writeregM2)) & memtoregM2) );
  wire branch_stall2; assign branch_stall2 = branchD2 & (bscD2 | bscE2 | bscM2);

  //execution stall
  wire exe_stall2; assign exe_stall2 = ((rsE2 == writeregE1) | (rtE2 == writeregE1)) & regwriteE1; 

  //stalls
  assign stall_w1 = 0;
  assign stall_w2 = 0;
  assign stall_m1 = 0;
  assign stall_m2 = 0;
  assign stall_e1 = mult_stallE1;
  assign stall_e2 = stall_e1 | exe_stall2 | mult_stallE2;
  assign stall_d1 = stall_e2 | lw_stall1 | branch_stall1;
  assign stall_d2 = stall_d1 | ((lw_stall2 | branch_stall2) & ~(is_bjD1 & real_bjD1)) 
                             | (multD1 & (out_selD2 == 2'b10)|(out_selD2 == 2'b11));
  assign stall_f = stall_d2;
  
  //flushes  
  assign flush_w1 = 0;
  assign flush_w2 = 0;
  assign flush_m1 = stall_e1;
  assign flush_m2 = stall_e1 | stall_e2;
  assign flush_e1 = stall_d1 | stall_e2;
  assign flush_e2 = stall_d1 | stall_d2 | (is_bjD1 & real_bjD1);
  assign flush_d1 = stall_d2;
  assign flush_d2 = 0;


endmodule

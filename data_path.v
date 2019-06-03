module data_path(input clk, reset);
  
  //fetch stage
  wire stall_f, flush_f;

  wire flush_d1F, hitD1, is_bjD1, pred_bjD1, real_bjD1;
  wire [31:0] pcD1, target_pcD1;
  wire [65:0] dD1;
  wire flush_d2F, hitD2, is_bjD2, pred_bjD2, real_bjD2;
  wire [31:0] pcD2, target_pcD2;
  wire [65:0] dD2;
  f_stage f1f2(clk, reset, stall_f, flush_f,
               hitD1, pred_bjD1, is_bjD1, real_bjD1,
               hitD2, pred_bjD2, is_bjD2, real_bjD2,
               pcD1, target_pcD1,
               pcD2, target_pcD2,
               flush_d1F, flush_d2F,
               dD1, dD2);
  
  //decode stage
  wire [31:0] outM1, outM2;
  wire [4:0] addr1D1, addr2D1, addr1D2, addr2D2;
  wire [31:0] rf_out1D1, rf_out2D1, rf_out1D2, rf_out2D2;

  wire stall_d1, flush_d1, branchD1, memtoregD1, regwriteD1, multD1;
  wire [1:0] forwardaD1, forwardbD1, out_selD1;
  wire [4:0] rsD1, rtD1, writeregD1;
  wire [188:0] dE1;
  d_stage d1(clk, reset, stall_d1, flush_d1|flush_d1F, 
             forwardaD1, forwardbD1,
             rf_out1D1, rf_out2D1, outM1, outM2,
             dD1,
             branchD1, memtoregD1, regwriteD1,
             hitD1, pred_bjD1, is_bjD1, real_bjD1,
             multD1,
             out_selD1,
             rsD1, rtD1, writeregD1,
             addr1D1, addr2D1,
             pcD1, target_pcD1,
             dE1);

  wire regwriteW1, regwriteW2;
  wire [4:0] writeregW1, writeregW2;
  wire [31:0] resultW1, resultW2;
  reg_file rf(clk, reset, regwriteW1, regwriteW2,
              addr1D1, addr2D1, addr1D2, addr2D2, 
              writeregW1, writeregW2,
              resultW1, resultW2,
              rf_out1D1, rf_out2D1, rf_out1D2, rf_out2D2);

  wire stall_d2, flush_d2, branchD2, memtoregD2, regwriteD2, multD2;
  wire [1:0] forwardaD2, forwardbD2, out_selD2;
  wire [4:0] rsD2, rtD2, writeregD2;
  wire [188:0] dE2;
  d_stage d2(clk, reset, stall_d2, flush_d2|flush_d2F, 
             forwardaD2, forwardbD2,
             rf_out1D2, rf_out2D2, outM1, outM2,
             dD2,
             branchD2, memtoregD2, regwriteD2,
             hitD2, pred_bjD2, is_bjD2, real_bjD2,
             multD2,
             out_selD2,
             rsD2, rtD2, writeregD2,
             addr1D2, addr2D2,
             pcD2, target_pcD2,
             dE2);
  
  //execution stage
  wire stall_e1, flush_e1, mult_stallE1, regwriteE1, memtoregE1;
  wire [2:0] forwardaE1, forwardbE1;
  wire [4:0] rsE1, rtE1, writeregE1;
  wire [31:0] loE_t, hiE_t, loE1, hiE1, loE2, hiE2;
  wire [104:0] dM1;
  e_stage e1(clk, reset, stall_e1, flush_e1,
             forwardaE1, forwardbE1,
             outM1, resultW1, outM2, resultW2, loE_t, hiE_t,
             dE1,
             mult_stallE1, regwriteE1, memtoregE1,
             rsE1, rtE1, writeregE1,
             loE1, hiE1, 
             dM1);

  wire stall_e2, flush_e2, mult_stallE2, regwriteE2, memtoregE2;
  wire [2:0] forwardaE2, forwardbE2;
  wire [4:0] rsE2, rtE2, writeregE2;
  wire [104:0] dM2;  
  e_stage e2(clk, reset, stall_e2, flush_e2,
             forwardaE2, forwardbE2,
             outM1, resultW1, outM2, resultW2, loE_t, hiE_t,
             dE2,
             mult_stallE2, regwriteE2, memtoregE2,
             rsE2, rtE2, writeregE2,
             loE2, hiE2, 
             dM2); 
  
  wire ms1_d, ms2_d;
  wire [31:0] lo_out, hi_out;
  register#(1) mult_stallE1_delay(clk, reset, 0, 0, mult_stallE1, ms1_d);
  register#(1) mult_stallE2_delay(clk, reset, 0, 0, mult_stallE2, ms2_d);
  wire m1_done; assign m1_done = {mult_stallE1, ms1_d} == 2'b01;
  wire m2_done; assign m2_done = {mult_stallE2, ms2_d} == 2'b01;
  wire p_sel; assign p_sel = m2_done;  
  mux2#(32) lo_mux(loE1, loE2, p_sel, lo_out);
  mux2#(32) hi_mux(hiE1, hiE2, p_sel, hi_out);
  register#(32) lo_t(clk, reset, ~(m1_done|m2_done), 0, lo_out, loE_t);
  register#(32) hi_t(clk, reset, ~(m1_done|m2_done), 0, hi_out, hiE_t);

  //memory stage  
  wire memwriteM1, memtoregM1, memwriteM2, memtoregM2, regwriteM1, regwriteM2;
  wire [31:0] writedataM1, writedataM2, readdataM1, readdataM2;

  wire stall_m1, flush_m1;
  wire [4:0] writeregM1;
  wire [102:0] dW1;
  m_stage m1(clk, reset, stall_m1, flush_m1,
             readdataM1,
             dM1,
             memwriteM1, memtoregM1, regwriteM1,
             writeregM1,
             outM1, writedataM1,
             dW1); 

  data_memory mem(clk, memwriteM1, memwriteM2,
                  outM1, outM2,
                  writedataM1, writedataM2,
                  readdataM1, readdataM2);
  
  wire stall_m2, flush_m2;
  wire [4:0] writeregM2;
  wire [102:0] dW2;
  m_stage m2(clk, reset, stall_m2, flush_m2,
             readdataM2,
             dM2,
             memwriteM2, memtoregM2, regwriteM2,
             writeregM2,
             outM2, writedataM2,
             dW2); 
  
  //write-back stage
  wire stall_w1, flush_w1;
  w_stage w1(clk, reset, stall_w1, flush_w1,
             dW1, 
             regwriteW1,
             writeregW1,
             resultW1);

  wire stall_w2, flush_w2;
  w_stage w2(clk, reset, stall_w2, flush_w2,
             dW2, 
             regwriteW2,
             writeregW2,
             resultW2);
    
  hazard_detector hd(multD1, multD2, 
                     out_selD1, out_selD2,
                     is_bjD1, real_bjD1, 
                     branchD1, branchD2, memtoregD1, memtoregD2, regwriteD1, regwriteD2,
                     rsD1, rtD1, writeregD1, rsD2, rtD2, writeregD2,
                     memtoregE1, regwriteE1, mult_stallE1, 
                     memtoregE2, regwriteE2, mult_stallE2, 
                     rsE1, rtE1, writeregE1, rsE2, rtE2, writeregE2,
                     memtoregM1, memtoregM2,
                     writeregM1, writeregM2,
                     stall_f, 
                     stall_d1, stall_e1, stall_m1, stall_w1,
                     stall_d2, stall_e2, stall_m2, stall_w2,
                     flush_d1, flush_e1, flush_m1, flush_w1,
                     flush_d2, flush_e2, flush_m2, flush_w2);
    
  forwarding_unit fu(rsD1, rtD1, rsD2, rtD2, 
                     rsE1, rtE1, rsE2, rtE2,
                     regwriteM1, regwriteM2, writeregM1, writeregM2,
                     regwriteW1, regwriteW2, writeregW1, writeregW2,
                     forwardaD1, forwardbD1, forwardaD2, forwardbD2,
                     forwardaE1, forwardbE1, forwardaE2, forwardbE2);

endmodule

module f_stage(input clk, reset, stall_f, flush_f, 
               input hitD1, pred_bjD1, is_bjD1, real_bjD1, 
               input hitD2, pred_bjD2, is_bjD2, real_bjD2,
               input [31:0] pcD1, target_pcD1,
               input [31:0] pcD2, target_pcD2,
               output flush_d1F, flush_d2F,
               output [65:0] dD1, dD2);

  wire hitF1, pred_bjF1;
  wire hitF2, pred_bjF2;
  wire [31:0] pc_next1, pcF1, pcF2, instrF1, instrF2;
  assign pcF2 = pcF1 + 4;
    
  register#(32) pc_reg(clk, reset, stall_f, flush_f, pc_next1, pcF1);
  inst_memory imem(pcF1, pcF2, instrF1, instrF2);
    
  branch_pred bp(clk, reset, stall_f,
                 hitD1, pred_bjD1, is_bjD1, real_bjD1,
                 hitD2, pred_bjD2, is_bjD2, real_bjD2,
                 pcF1, pcD1, target_pcD1,
                 pcF2, pcD2, target_pcD2,
                 hitF1, pred_bjF1, flush_d1F,
                 hitF2, pred_bjF2, flush_d2F,
                 pc_next1);
    
  assign dD1 = {hitF1, pred_bjF1, pcF1, instrF1};
  assign dD2 = {hitF2, pred_bjF2, pcF2, instrF2};

endmodule


module d_stage(input clk, reset, stall_d, flush_dF, 
               input [1:0] forwardaD, forwardbD,
               input [31:0] rf_out1D, rf_out2D, outM1, outM2,
               input [65:0] dD,
               output branchD, regwriteD, memtoregD,
               output hitD, pred_bjD, is_bjD, real_bjD,
               output multD,
               output [1:0] out_selD,
               output [4:0] rsD, rtD, writeregD, 
               output [4:0] addr1D, addr2D,
               output [31:0] pcD, target_pcD,
               output [188:0] dE);
 
  wire [65:0] qD;
  wire [31:0] instrD;
  assign {hitD, pred_bjD, pcD, instrD} = qD;
  assign addr1D = instrD[25:21];
  assign addr2D = instrD[20:16];
  register#(66) pipeline_regD(clk, reset, stall_d, flush_dF, dD, qD);
  
  wire se_zeD, eq_neD, jumpD;
  wire memreadD, memwriteD, regdstD;
  wire alusrcD, mult_signD;
  wire [3:0] alu_opD;
  controller control(instrD[31:26], instrD[5:0],
                     se_zeD, eq_neD, branchD, jumpD,
                     memreadD, memwriteD, regwriteD, memtoregD, regdstD, 
                     alusrcD, multD, mult_signD, 
                     out_selD,
                     alu_opD);

  branch_jump bj(eq_neD, branchD, jumpD, 
                 forwardaD, forwardbD,
                 rf_out1D, rf_out2D, outM1, outM2, pcD, instrD,
                 is_bjD, real_bjD,
                 target_pcD);
  
  wire [31:0] sh_immD, se_immD, ze_immD, ext_immD;
  ls16 lui_sh(instrD[15:0], sh_immD);
  signext se(instrD[15:0], se_immD);
  zeroext ze(instrD[15:0], ze_immD);
  mux2#(32) ext_muxD(ze_immD, se_immD, se_zeD, ext_immD);


  wire [4:0] rdD;
  assign rsD = instrD[25:21];
  assign rtD = instrD[20:16];
  assign rdD = instrD[15:11];
  mux2#(5) regdst_mux(rtD, rdD, regdstD, writeregD);

  assign dE = {memreadD, memwriteD, regwriteD, memtoregD, regdstD, 
               alusrcD, alu_opD, out_selD, multD, mult_signD, 
               rf_out1D, rf_out2D, rsD, rtD, rdD, sh_immD, ext_immD, instrD};

endmodule

module branch_jump(input eq_neD, branchD, jumpD, 
                   input [1:0] forwardaD, forwardbD,
                   input [31:0] rf_out1D, rf_out2D, outM1, outM2, pcD, instrD,
                   output is_bjD, real_bjD,
                   output [31:0] target_pcD);
  
  wire equal, branch_cond;
  wire [31:0] muxa_out, muxb_out;
  wire [31:0] pcplus4D; assign pcplus4D = pcD + 4;
  
  mux3#(32) forward_muxaD(rf_out1D, outM1, outM2, forwardaD, muxa_out);
  mux3#(32) forward_muxbD(rf_out2D, outM1, outM2, forwardbD, muxb_out);
  
  assign equal = (muxa_out == muxb_out);
  assign branch_cond = (eq_neD) ? equal : ~equal; // branch condition determined by beq or bne
  assign is_bjD = branchD | jumpD;
  assign real_bjD = (branchD & branch_cond) | jumpD;

  wire [31:0] se_imm, ls2_out;
  signext se(instrD[15:0], se_imm);
  ls2 branch_sh(se_imm, ls2_out);
  
  wire [31:0] branch_pc; assign branch_pc = ls2_out + pcplus4D;
  wire [31:0] jump_pc; assign jump_pc = {pcplus4D[31:28], instrD[25:0], 2'b0};
  assign target_pcD = (branchD) ? branch_pc :
                      (jumpD)   ? jump_pc   : 32'b0;

endmodule


module e_stage(input clk, reset, stall_e, flush_e,
               input[2:0] forwardaE, forwardbE,
               input[31:0] outM1, resultW1, outM2, resultW2, loE_t, hiE_t,
               input[188:0] dE,
               output mult_stallE, regwriteE, memtoregE,
               output[4:0] rsE, rtE, writeregE,
               output [31:0] loE, hiE,
               output[104:0] dM);
  
  wire memreadE, memwriteE, regdstE; 
  wire alusrcE; wire [3:0] alu_opE; wire [1:0] out_selE; wire multE, mult_signE;
  wire [31:0] rd1E, rd2E; wire [4:0] rdE; wire [31:0] sh_immE, ext_immE;
  wire [31:0] srcaE, srcbE, aluoutE, writedataE, outE;
  wire [188:0] qE;
  wire [31:0] instrE;

  assign {memreadE, memwriteE, regwriteE, memtoregE, regdstE, 
          alusrcE, alu_opE, out_selE, multE, mult_signE, 
          rd1E, rd2E, rsE, rtE, rdE, sh_immE, ext_immE, instrE} = qE;
  
  register#(189) pipeline_regE(clk, reset, stall_e, flush_e, dE, qE);
  
  mux5#(32) forward_muxaE(rd1E, outM1, resultW1, outM2, resultW2, forwardaE, srcaE);
  mux5#(32) forward_muxbE(rd2E, outM1, resultW1, outM2, resultW2, forwardbE, writedataE);

  mux2#(5) regdst_mux(rtE, rdE, regdstE, writeregE);
  mux2#(32) alusrc_mux(writedataE, ext_immE, alusrcE, srcbE);

  ALU alu(srcaE, srcbE, alu_opE, aluoutE);

  multiplier mul(clk, multE, mult_signE,
                 srcaE, srcbE,
                 mult_stallE,
                 {hiE, loE});

  mux4#(32) out_muxE(aluoutE, sh_immE, loE_t, hiE_t, out_selE, outE);
  assign dM = {memreadE, memwriteE, regwriteE, memtoregE, outE, writedataE, writeregE, instrE};

endmodule

module m_stage(input clk, reset, stall_m, flush_m,
               input [31:0] readdataM,
               input [104:0] dM,
               output memwriteM, memtoregM, regwriteM,
               output [4:0] writeregM,
               output [31:0] outM, writedataM,
               output [102:0] dW);

  wire [104:0] qM;
  wire  memreadM;
  wire [31:0] instrM;
  /*
  wire mem_ready;
  wire [127:0] data_from_mem;
  wire hit, mem_read, mem_write, cache_stall;
  wire [31:0] mem_addr;
  wire [127:0] data_to_mem;*/
  assign {memreadM, memwriteM, regwriteM, memtoregM, outM, writedataM, writeregM, instrM} = qM;
  register#(105) pipeline_regM(clk, reset, stall_m, flush_m, dM, qM);

  /*
  cache_wb cache(clk, reset, mem_ready, 
                 memreadM, memwriteM,
                 outM, writedataM,
                 data_from_mem,
                 hit, mem_read, mem_write, cache_stall,
                 mem_addr, 
                 readdataM,
                 data_to_mem);
	
  data_memory mem(clk, mem_read, mem_write,
                  mem_addr,
                  data_to_mem,
                  mem_ready,
                  data_from_mem);*/

  assign dW = {regwriteM, memtoregM, readdataM, outM, writeregM, instrM};

endmodule

module w_stage(input clk, reset, stall_w, flush_w,
               input [102:0] dW, 
               output regwriteW,
               output [4:0] writeregW,
               output [31:0] resultW);

  wire memtoregW;
  wire [31:0] outW, readdataW;
  wire [31:0] instrW;
 
  wire [102:0] qW;
  assign {regwriteW, memtoregW, readdataW, outW, writeregW, instrW} = qW;
  register#(103) pipeline_regW(clk, reset, stall_w, flush_w, dW, qW);
  
  mux2#(32) memtoreg_muxW(outW, readdataW, memtoregW, resultW);

endmodule

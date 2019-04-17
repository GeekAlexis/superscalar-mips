// top level module
module data_path(input clk, reset);
    
    // fetch stage signals
    wire [31:0] pcplus4F, pc_next, pcF;
    wire [31:0] instrF;
    wire stallF;
    
    // decode stage signals
    wire [31:0] instrD;
    wire equalD;
    wire [4:0] rsD, rtD, rdD;
    wire memwriteD, regwriteD, memtoregD, regdstD, alusrcD, se_zeD, branchD, start_multD, mult_signD;
    wire [3:0] alu_opD;
    wire [1:0] out_selD, pcsrcD;
    wire [31:0] readdata1D, readdata2D, muxa_outD, muxb_outD, sh_immD, se_immD, ze_immD, ext_immD, sl2_outD, pcplus4D, pcbranchD, pcjumpD;
    wire stallD, forwardaD, forwardbD;
    
    // execute stage signals
    wire memwriteE, regwriteE, memtoregE, regdstE, alusrcE, start_multE, mult_signE;
    wire [1:0] out_selE;
    wire [3:0] alu_opE;
    wire [4:0] rsE, rtE, rdE;
    wire [4:0] writeregE;
    wire [31:0] srcaE, srcbE, aluoutE, readdata1E, readdata2E, writedataE, outE, ext_immE, sh_immE, loE, hiE;
    wire flushE;
    wire [1:0] forwardaE, forwardbE;
	
    // memory stage signals
    wire regwriteM, memtoregM, memwriteM;
    wire [4:0] writeregM;
    wire [31:0] writedataM, readdataM, outM;
    
    // write-back stage signals
    wire regwriteW, memtoregW;
    wire [4:0] writeregW;
    wire [31:0] outW, readdataW, resultW;
    
    // fetch stage logic
    mux3#(32) pc_mux(pcplus4F, pcbranchD, pcjumpD, pcsrcD, pc_next);
    register#(32) pc_reg(clk, reset, stallF, pc_next, pcF);
    inst_memory imem(pcF, instrF);
    assign pcplus4F = pcF + 4;
    
    // decode stage logic
    register#(64) pipeline_regD(clk, reset | pcsrcD[0] | pcsrcD[1], stallD, {instrF, pcplus4F}, {instrD, pcplus4D});
    controller control(instrD[31:26], instrD[5:0], equalD, memwriteD, regwriteD, memtoregD, regdstD, alusrcD, se_zeD, branchD, start_multD, mult_signD, alu_opD, out_selD, pcsrcD);
    reg_file rf(clk, reset, regwriteW, instrD[25:21], instrD[21:16], writeregW, resultW, readdata1D, readdata2D);
    assign rsD = instrD[25:21];
    assign rtD = instrD[20:16];
    assign rdD = instrD[15:11];
    mux2#(32) forward_muxaD(readdata1D, outM, forwardaD, muxa_outD);
    mux2#(32) forward_muxbD(readdata2D, outM, forwardbD, muxb_outD);
    assign equalD = muxa_outD == muxb_outD;
    sl16 lui_sh(instrD[15:0], sh_immD);
    signext se(instrD[15:0], se_immD);
    zeroext ze(instrD[15:0], ze_immD);
    mux2#(32) ext_muxD(ze_immD, se_immD, se_zeD, ext_immD);
    sl2 jump_sh(se_immD, sl2_outD);
    assign pcbranchD = sl2_outD + pcplus4D;
    assign pcjumpD = {pcplus4D[31:28], instrD[25:0], 2'b0};
    
    // execute stage logic
    wire [155:0] dE, qE;
    assign dE = {memwriteD, regwriteD, memtoregD, regdstD, alusrcD, alu_opD, out_selD, start_multD, mult_signD, readdata1D, readdata2D, rsD, rtD, rdD, sh_immD, ext_immD};
    assign {memwriteE, regwriteE, memtoregE, regdstE, alusrcE, alu_opE, out_selE, start_multE, mult_signE, readdata1E, readdata2E, rsE, rtE, rdE, sh_immE, ext_immE} = qE;
    register#(156) pipeline_regE(clk, reset | flushE, 0, dE, qE);
    mux2#(5) regdst_mux(rtE, rdE, regdstE, writeregE);
    mux3#(32) forward_muxaE(readdata1E, resultW, outM, forwardaE, srcaE);
    mux3#(32) forward_muxbE(readdata2E, resultW, outM, forwardbE, writedataE);
    mux2#(32) alusrc_mux(writedataE, ext_immE, alusrcE, srcbE);
    ALU alu(srcaE, srcbE, alu_opE, aluoutE);
    wire busy_multE;
    multiplier mult(clk, start_multE, mult_signE, srcaE, srcbE, busy_multE, {hiE, loE});
    mux4#(32) out_muxE(aluoutE, sh_immE, loE, hiE, out_selE, outE);
    
    // memory stage logic
    wire [71:0] dM, qM;
    assign dM = {memwriteE, regwriteE, memtoregE, outE, writedataE, writeregE};
    assign {memwriteM, regwriteM, memtoregM, outM, writedataM, writeregM} = qM;
    register#(72) pipeline_regM(clk, reset, 0, dM, qM);
    data_memory dmem(clk, memwriteM, outM, writedataM, readdataM);
    
    // write-back stage logic
    wire [70:0] dW, qW;
    assign dW = {regwriteM, memtoregM, readdataM, outM, writeregM};
    assign {regwriteW, memtoregW, readdataW, outW, writeregW} = qW;
    register#(71) pipeline_regW(clk, reset, 0, dW, qW);
    mux2#(32) memtoreg_muxW(outW, readdataW, memtoregW, resultW);
    
    // hazard unit
    hazard_detector hd(//clk, reset,
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

endmodule

// basic building blocks
module register#(parameter width = 1)
                (input clk, reset, en,
                 input [width - 1:0] d,
                 output reg [width - 1:0] q);
                     
    always @(posedge clk) begin
        if(reset)
            q <= 0;
        else if(~en)
            q <= d;
    end
    
endmodule

module mux2#(parameter width = 1)
	   (input [width - 1:0] d0, d1,
	    input sel,
	    output [width - 1:0] y);

	assign y = sel ? d1 : d0;
	
endmodule

module mux3#(parameter width = 1)
	   (input [width - 1:0] d0, d1, d2,
	    input [1:0] sel,
	    output [width - 1:0] y);

	assign y = (sel == 2'd0) ? d0 : 
	           (sel == 2'd1) ? d1 :
	           (sel == 2'd2) ? d2 : {width{1'bx}};
	
endmodule

module mux4#(parameter width = 1)
	   (input [width - 1:0] d0, d1, d2, d3,
	    input [1:0] sel,
	    output [width - 1:0] y);

	assign y = (sel == 2'd0) ? d0 : 
	           (sel == 2'd1) ? d1 :
	           (sel == 2'd2) ? d2 : 
	           (sel == 2'd3) ? d3 : {width{1'bx}};
	
endmodule

module signext(input [15:0] a, output [31:0] y);
  assign y = {{16{a[15]}}, a};	
endmodule

module zeroext(input [15:0] a, output [31:0] y);	       
  assign y = {16'b0, a};
endmodule

module sl2(input [31:0] a, output [31:0] y); // shift left by 2
  assign y = {a[29:0], 2'b0};
endmodule

module sl16(input [15:0] a, output [31:0] y); // shift left by 16
  assign y = {a, 16'b0};
endmodule 

module controller(input [5:0] op, func,
                  input equal,
                  output memwrite,
                  output regwrite,
                  output memtoreg,
                  output regdst,
                  output alusrc,
                  output se_ze,
                  output branch,
		  output start_mult,
		  output mult_sign,
                  output [3:0] alu_op,
                  output [1:0] out_sel,
                  output [1:0] pcsrc);
    
	wire eq_ne, jump, branch_cond;
	reg [16:0] controls;
	assign {memwrite, regwrite, memtoreg, regdst, alusrc, se_ze, eq_ne, branch, jump, start_mult, mult_sign, out_sel, alu_op} = controls;
	assign branch_cond = (eq_ne) ? equal : ~equal;
	module controller(input [5:0] op, func,
                  input equal,
                  output memwrite,
                  output regwrite,
                  output memtoreg,
                  output regdst,
                  output alusrc,
                  output se_ze,
                  output branch,
		  output start_mult,
		  output mult_sign,
                  output [3:0] alu_op,
                  output [1:0] out_sel,
                  output [1:0] pcsrc);
    
	wire eq_ne, jump, branch_cond;
	reg [16:0] controls;
	assign {memwrite, regwrite, memtoreg, regdst, alusrc, se_ze, eq_ne, branch, jump, start_mult, mult_sign, out_sel, alu_op} = controls;
	assign branch_cond = (eq_ne) ? equal : ~equal;
	assign pcsrc = (branch_cond & branch) ? 2'b01 : (jump) ? 2'b10 : 2'b00;
	               
  	always@(*) begin
            case(op)
      		6'h0: 
      		    case(func)
      		        6'h20, 6'h21: controls = 17'b01010000000000100; // add / addu
      		        6'h22, 6'h23: controls = 17'b01010000000001100; // sub / subu
      		        6'h24:        controls = 17'b01010000000000000; // and
      		        6'h25:        controls = 17'b01010000000000001; // or
      		        6'h26:        controls = 17'b01010000000000010; // xor
      		        6'h27:        controls = 17'b01010000000000011; // xnor
      		        6'h2a:        controls = 17'b01010000000001101; // slt
      		        6'h2b:        controls = 17'b01010000000000110; // sltu
      		        6'h18:        controls = 17'b00000000011000000; // mult
      		        6'h19:        controls = 17'b00000000010000000; // multu
      		        6'h10:        controls = 17'b01010000000110000; // mfhi
      		        6'h12:        controls = 17'b01010000000100000; // mflo
      		        default:      controls = 17'b0;
                    endcase
      		6'h23:      controls = 17'b01101100000000100; // lw
      		6'h2b:      controls = 17'b10001100000000100; // sw
      		6'h4:       controls = 17'b00000111000000000; // beq
      		6'h5:       controls = 17'b00000101000000000; // bne
      		6'h8, 6'h9: controls = 17'b01001100000000100; // addi / addiu
                6'hc:       controls = 17'b01001000000000000; // andi
                6'hd:       controls = 17'b01001000000000001; // ori
                6'he:       controls = 17'b01001000000000010; // xori
                6'ha:       controls = 17'b01001100000001101; // slti
                6'hb:       controls = 17'b01001100000000110; // sltiu
                6'hf:       controls = 17'b01000000000010000; // lui
                6'h2:       controls = 17'b00000000100000000; // j
                default:    controls = 17'b0;
	    endcase
  	end
    
endmodule

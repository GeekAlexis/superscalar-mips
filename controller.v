module controller(input [5:0] op, func,
                  output se_ze, eq_ne, branch, jump,
                  output memread, memwrite, regwrite, memtoreg, regdst, 
                  output alusrc, start_mult, mult_sign,
                  output [1:0] out_sel,
                  output [3:0] alu_op);
    
  reg [17:0] controls;
  assign {memread, memwrite, regwrite, memtoreg, regdst, 
          alusrc, se_ze, eq_ne, branch, jump, start_mult, mult_sign, 
          out_sel, 
          alu_op} = controls;

  always@(*) begin
    
    case(op)
      6'h0: 
        case(func)
          6'h20, 6'h21: controls = 18'b001010000000_00_0100; // add / addu
          6'h22, 6'h23: controls = 18'b001010000000_00_1100; // sub / subu
          6'h24:        controls = 18'b001010000000_00_0000; // and
          6'h25:        controls = 18'b001010000000_00_0001; // or
          6'h26:        controls = 18'b001010000000_00_0010; // xor
          6'h27:        controls = 18'b001010000000_00_0011; // xnor
          6'h2a:        controls = 18'b001010000000_00_1101; // slt
          6'h2b:        controls = 18'b001010000000_00_0110; // sltu
          6'h18:        controls = 18'b000000000011_00_0000; // mult
          6'h19:        controls = 18'b000000000010_00_0000; // multu
          6'h10:        controls = 18'b001010000000_11_0000; // mfhi
          6'h12:        controls = 18'b001010000000_10_0000; // mflo
          default:      controls = 18'b0;
        endcase
      6'h23:      controls = 18'b101101100000_00_0100; // lw
      6'h2b:      controls = 18'b010001100000_00_0100; // sw
      6'h4:       controls = 18'b000000111000_00_0000; // beq
      6'h5:       controls = 18'b000000101000_00_0000; // bne
      6'h8, 6'h9: controls = 18'b001001100000_00_0100; // addi / addiu
      6'hc:       controls = 18'b001001000000_00_0000; // andi
      6'hd:       controls = 18'b001001000000_00_0001; // ori
      6'he:       controls = 18'b001001000000_00_0010; // xori
      6'ha:       controls = 18'b001001100000_00_1101; // slti
      6'hb:       controls = 18'b001001100000_00_0110; // sltiu
      6'hf:       controls = 18'b001000000000_01_0000; // lui
      6'h2:       controls = 18'b000000000100_00_0000; // j
      default:    controls = 18'b0;
    endcase

  end
    
endmodule
	              

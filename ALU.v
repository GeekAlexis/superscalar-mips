module ALU (input [31:0] in1, in2, 
            input [3:0] func, 
            output reg [31:0] aluout);
  
  wire [31:0] in2_muxout;
  wire [31:0] sum;
  wire cout;
  wire sltu;
  
  assign in2_muxout = (func[3]) ? ~in2 : in2; //invert in2
  assign {cout, sum} = func[3] + in1 + in2_muxout; //adder
  assign sltu = (in1 < in2_muxout) ? 1'b1 : 1'b0; //sltu
  
  always @(*) begin
    case(func[2:0])
      3'b000 : aluout = in1 & in2_muxout; //and
      3'b001 : aluout = in1 | in2_muxout; //or
      3'b010 : aluout = in1 ^ in2_muxout; //xor
      3'b011 : aluout = in1 ~^ in2_muxout; //xnor
      3'b100 : aluout = sum; //add, addu, sub, subu
      3'b101 : aluout = {31'b0, sum[31]}; //slt
      3'b110 : aluout = {31'b0, sltu}; //sltu
      default : aluout = 32'hxxxxxxxx;
    endcase
  end
 
endmodule 

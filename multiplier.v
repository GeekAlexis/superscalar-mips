module multiplier(
  input clk, start, is_signed,
  input [31:0] a, b,
  output [63:0] s);
  
  reg [63:0] a_t;
  reg [128:0] s_t;
  reg [6:0] i = 64;
  assign s =  s_t[63:0]; 
  
  always @(posedge clk) begin
    
    if(start) begin
      i <= 0;
      s_t[128:64] <= 65'b0;
      if(is_signed) begin
        a_t[63:0] <= { {32{a[31]}}, a[31:0] };
        s_t[63:0] <= { {32{b[31]}}, b[31:0] };
      end
      else begin
        a_t[63:0] <= { 32'b0, a[31:0] };
        s_t[63:0] <= { 32'b0, b[31:0] };
      end
    end
    else if(i < 64) begin
      if(s_t[0]) s_t[128:64] = s_t[128:64] + a_t[63:0];
      s_t = s_t >> 1;
      i = i + 1;
    end
  
  end

endmodule

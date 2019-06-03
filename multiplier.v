module multiplier(input clk, multE, is_signed,
                  input [31:0] a, b,
                  output mult_stall,
                  output reg [63:0] s);
  
  wire start;
  reg busy = 0, stall = 0;
  reg [63:0] a_temp;
  reg [128:0] s_temp; //129 bits shift register to store product
  reg [6:0] i;
  
  assign start = multE & ~busy;
  assign mult_stall = start | stall;

  always @(posedge clk) begin
    
    if(start) begin
      i <= 0; busy <= 1; stall <= 1; 
      s_temp[128:64] <= 65'b0; //reset the upper 65 bits to 0
      if(is_signed) begin
        a_temp[63:0] <= { {32{a[31]}}, a[31:0] }; //sign extend a to 64 bits, store to a_temp
        s_temp[63:0] <= { {32{b[31]}}, b[31:0] }; //sign extend b to 64 bits, store to s_temp's lower 64 bits
      end
      else begin
        a_temp[63:0] <= { 32'b0, a[31:0] }; //zero extend a to 64 bits, store to a_temp
        s_temp[63:0] <= { 32'b0, b[31:0] }; //zero extend b to 64 bits, store to s_temp's lower 64 bits
      end
    end
    else if(i < 64) begin
      i = i + 1; 
      if(s_temp[0]) s_temp[128:64] = s_temp[128:64] + a_temp[63:0];
      s_temp = s_temp >> 1;
      if(i == 64) begin stall <= 0; s <= s_temp[63:0]; end
    end
    else begin
      busy <= 0;
    end

  end

endmodule

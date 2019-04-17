module multiplier(input clk, start, is_signed,
                  input [31:0] a, b,
                  output reg busy = 0,
                  output reg [63:0] s);
  
  reg [63:0] a_temp;
  reg [128:0] s_temp; //129 bits shift register to store product
  reg [6:0] i = 64; //edge cycle count
  
  always @(posedge clk) begin
    
    if(start) begin
      i <= 0;
      busy <= 1;
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
      if(s_temp[0]) //add a_temp to upper 65 bits of s_temp if last digit of s_temp is 1
        s_temp[128:64] = s_temp[128:64] + a_temp[63:0];
      s_temp = s_temp >> 1; //left shit s_temp by 1
      i = i + 1; //cycle count + 1
      if(i == 64) begin
        s <= s_temp[63:0]; //actual product is the lower 64 bits of s_temp
        busy <= 0;
      end
    end

  end

endmodule 

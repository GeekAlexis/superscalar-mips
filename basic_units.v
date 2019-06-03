module register#(parameter width = 1)(input clk, reset, stall, flush,
                                      input [width - 1:0] d,
                                      output reg [width - 1:0] q);
                     
    always @(posedge clk) begin
      if(reset) q <= 0;
      else if(~stall & flush) q <= 0;
      else if(~stall) q <= d;
    end
    
endmodule

module mux2#(parameter width = 1)(input [width - 1:0] d0, d1,
	                          input sel,
	                          output [width - 1:0] y);

	assign y = sel ? d1 : d0;
	
endmodule

module mux3#(parameter width = 1)(input [width - 1:0] d0, d1, d2,
	                          input [1:0] sel,
	                          output [width - 1:0] y);

	assign y = (sel == 2'd0) ? d0 : 
	           (sel == 2'd1) ? d1 :
	           (sel == 2'd2) ? d2 : {width{1'bx}};
	
endmodule

module mux4#(parameter width = 1)(input [width - 1:0] d0, d1, d2, d3,
	                          input [1:0] sel,
	                          output [width - 1:0] y);

	assign y = (sel == 2'd0) ? d0 : 
	           (sel == 2'd1) ? d1 :
	           (sel == 2'd2) ? d2 : 
	           (sel == 2'd3) ? d3 : {width{1'bx}};
	
endmodule
module mux5#(parameter width = 1)(input [width - 1:0] d0, d1, d2, d3, d4,
	                          input [2:0] sel,
	                          output [width - 1:0] y);

	assign y = (sel == 3'd0) ? d0 : 
	           (sel == 3'd1) ? d1 :
	           (sel == 3'd2) ? d2 : 
	           (sel == 3'd3) ? d3 : 
                   (sel == 3'd4) ? d4 : {width{1'bx}};
	
endmodule

module signext(input [15:0] a, output [31:0] y);
  assign y = {{16{a[15]}}, a};	
endmodule

module zeroext(input [15:0] a, output [31:0] y);	       
  assign y = {16'b0, a};
endmodule

module ls2(input [31:0] a, output [31:0] y); // left shift by 2
  assign y = {a[29:0], 2'b0};
endmodule

module ls16(input [15:0] a, output [31:0] y); // left shift by 16
  assign y = {a, 16'b0};
endmodule 

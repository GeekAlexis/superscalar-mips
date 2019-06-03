module branch_pred(input clk, reset, stall_f,
                   input hitD1, pred_bjD1, is_bjD1, real_bjD1,
                   input hitD2, pred_bjD2, is_bjD2, real_bjD2,
                   input [31:0] pcF1, pcD1, target_pcD1,
                   input [31:0] pcF2, pcD2, target_pcD2,
                   output hitF1, pred_bjF1, output reg flush_d1F,
                   output hitF2, pred_bjF2, output reg flush_d2F,
                   output reg [31:0] pc_next1);
  
  wire [31:0] target_pcF1; // target_pcF is the target pc stored in branch target buffer 
  wire [31:0] target_pcF2;

  branch_target_buffer btb(clk, reset, stall_f,
                           hitD1, is_bjD1, real_bjD1,
                           hitD2, is_bjD2, real_bjD2,
                           pcF1, pcD1, target_pcD1,
                           pcF2, pcD2, target_pcD2,
                           hitF1, hitF2,
                           target_pcF1,
                           target_pcF2);
  
  global_history_predictor ghp(clk, reset, stall_f,
                               is_bjD1, real_bjD1,
                               is_bjD2, real_bjD2,
                               pcF1, pcD1,
                               pcF2, pcD2,
                               pred_bjF1,
                               pred_bjF2);
  
  always @(*) begin
    if(~is_bjD1 & ~is_bjD2) begin //if both instrutions in decode stage are not branch
      if     (hitF1 & pred_bjF1) begin pc_next1 <= target_pcF1; flush_d1F <= 0; flush_d2F <= 0; end
      else if(hitF2 & pred_bjF2) begin pc_next1 <= target_pcF2; flush_d1F <= 0; flush_d2F <= 0; end
      else                       begin pc_next1 <= pcF1 + 8;    flush_d1F <= 0; flush_d2F <= 0; end
    end

    else begin
      if(hitD1 & pred_bjD1) begin //if predicted d1 branch takes
        if     (real_bjD1) begin //if d1 actually takes
          if     (hitF1 & pred_bjF1) begin pc_next1 <= target_pcF1; flush_d1F <= 0; flush_d2F <= 0; end
          else if(hitF2 & pred_bjF2) begin pc_next1 <= target_pcF2; flush_d1F <= 0; flush_d2F <= 0; end
          else                       begin pc_next1 <= pcF1 + 8;    flush_d1F <= 0; flush_d2F <= 0; end 
        end
        else if(real_bjD2) begin pc_next1 <= target_pcD2; flush_d1F <= 1; flush_d2F <= 1; end //if d2 actually takes
        else               begin pc_next1 <= pcD1 + 8;    flush_d1F <= 1; flush_d2F <= 1; end //none of them takes
      end
      else if(hitD2 & pred_bjD2) begin //if predicted d2 branch takes
        if     (real_bjD1) begin pc_next1 <= target_pcD1; flush_d1F <= 1; flush_d2F <= 1; end //if d1 actually takes
        else if(real_bjD2) begin //if d2 actually takes
          if     (hitF1 & pred_bjF1) begin pc_next1 <= target_pcF1; flush_d1F <= 0; flush_d2F <= 0; end
          else if(hitF2 & pred_bjF2) begin pc_next1 <= target_pcF2; flush_d1F <= 0; flush_d2F <= 0; end
          else                       begin pc_next1 <= pcF1 + 8;    flush_d1F <= 0; flush_d2F <= 0; end 
        end
        else               begin pc_next1 <= pcD1 + 8;    flush_d1F <= 1; flush_d2F <= 1; end //none of them takes
      end
      else begin //predicted none of them takes
        if     (real_bjD1) begin pc_next1 <= target_pcD1; flush_d1F <= 1; flush_d2F <= 1; end //if d1 actually takes
        else if(real_bjD2) begin pc_next1 <= target_pcD2; flush_d1F <= 1; flush_d2F <= 1; end //if d2 actually takes
        else begin //none of them takes
          if     (hitF1 & pred_bjF1) begin pc_next1 <= target_pcF1; flush_d1F <= 0; flush_d2F <= 0; end
          else if(hitF2 & pred_bjF2) begin pc_next1 <= target_pcF2; flush_d1F <= 0; flush_d2F <= 0; end
          else                       begin pc_next1 <= pcF1 + 8;    flush_d1F <= 0; flush_d2F <= 0; end 
        end        
      end
    end

  end

endmodule

module branch_target_buffer(input clk, reset, stall_f,
                            input hitD1, is_bjD1, real_bjD1,
                            input hitD2, is_bjD2, real_bjD2,
                            input [31:0] pcF1, pcD1, target_pcD1,
                            input [31:0] pcF2, pcD2, target_pcD2,
                            output hitF1, hitF2,
                            output [31:0] target_pcF1,
                            output [31:0] target_pcF2);

  //integer a = 0;
  
  wire [31:3] tagF1; assign tagF1 = pcF1[31:3];
  wire [2:0] indexF1; assign indexF1 = pcF1[2:0];
  wire [31:3] tagD1; assign tagD1 = pcD1[31:3];
  wire [2:0] indexD1; assign indexD1 = pcD1[2:0];
  
  wire [31:3] tagF2; assign tagF2 = pcF2[31:3];
  wire [2:0] indexF2; assign indexF2 = pcF2[2:0];
  wire [31:3] tagD2; assign tagD2 = pcD2[31:3];
  wire [2:0] indexD2; assign indexD2 = pcD2[2:0];
  
  reg v [0:7]; reg [31:0] b_pc_tag [0:7]; reg [31:0] t_pc [0:7]; // branch pc tag and target pc
  integer i;

  assign hitF1 = v[indexF1] & (tagF1 == b_pc_tag[indexF1]);
  assign hitF2 = v[indexF2] & (tagF2 == b_pc_tag[indexF2]);
  //assign hitF = v[indexF] & (pcF == b_pc[indexF]);
  assign target_pcF1 = t_pc[indexF1];
  assign target_pcF2 = t_pc[indexF2];
  
  always @(posedge clk) begin
    if(reset) begin
      for(i = 0; i < 8; i = i + 1) begin
        v[i] = 0; b_pc_tag[i] = 0; t_pc[i] = 0;
      end
    end
    else if(~stall_f) begin //store pc and target if not hit but branch
      if(is_bjD1 & real_bjD1 & ~hitD1) begin
        v[indexD1] <= 1;
        b_pc_tag[indexD1] <= pcD1[31:3];
        t_pc[indexD1] <= target_pcD1;
        //a = a+1;
      end
      if(is_bjD2 & real_bjD2 & ~hitD2 & (~is_bjD1|(is_bjD1 & ~real_bjD1))) begin
        v[indexD2] <= 1;
        b_pc_tag[indexD2] <= pcD2[31:3];
        t_pc[indexD2] <= target_pcD2;
        //a = a+1;
      end
    end
  end

endmodule

module global_history_predictor(input clk, reset, stall_f,
                                input is_bjD1, real_bjD1,
                                input is_bjD2, real_bjD2,
                                input [31:0] pcF1, pcD1,
                                input [31:0] pcF2, pcD2,
                                output pred_bjF1,
                                output pred_bjF2);

  wire [9:0] pc_lowerF1; assign pc_lowerF1 = pcF1[9:0];
  wire [9:0] pc_lowerD1; assign pc_lowerD1 = pcD1[9:0];

  wire [9:0] pc_lowerF2; assign pc_lowerF2 = pcF2[9:0];
  wire [9:0] pc_lowerD2; assign pc_lowerD2 = pcD2[9:0];

  reg [1:0] bhr; //branch history registor
  reg [1:0] pht [0:4095]; //pattern history table

  wire [11:0] pht_addrF1; assign pht_addrF1 = { pc_lowerF1[9:0], bhr[1:0] }; //combining 10 bits from pc and 2 bits of bhr
  wire [11:0] pht_addrD1; assign pht_addrD1 = { pc_lowerD1[9:0], bhr[1:0] };

  wire [11:0] pht_addrF2; assign pht_addrF2 = { pc_lowerF2[9:0], bhr[1:0] }; //combining 10 bits from pc and 2 bits of bhr
  wire [11:0] pht_addrD2; assign pht_addrD2 = { pc_lowerD2[9:0], bhr[1:0] };

  integer i;
  
  assign pred_bjF1 = pht[pht_addrF1][1];
  assign pred_bjF2 = pht[pht_addrF2][1];
  //wire[1:0] state; assign state = pht[pht_addrF];

  always @(posedge clk) begin
    if(reset) begin
      bhr <= 0;
      for(i = 0; i < 4096; i = i + 1) pht[i] <= 0;
    end
    else if(~stall_f)begin

      if(is_bjD1) begin // if is a branch and branched in reality, increment pht
        if(real_bjD1) begin
          if(pht[pht_addrD1] != 3) pht[pht_addrD1] = pht[pht_addrD1] + 1;
          bhr = bhr << 1;
          bhr[0] = real_bjD1;
        end
        else begin
          if(pht[pht_addrD1] != 0) pht[pht_addrD1] = pht[pht_addrD1] - 1;
          bhr = bhr << 1;
          bhr[0] = real_bjD1;
        end
      end
      if(is_bjD2) begin // if is a branch and branched in reality, increment pht
        if(real_bjD2 & (~is_bjD1|(is_bjD1 & ~real_bjD1)))begin
          if(pht[pht_addrD2] != 3) pht[pht_addrD2] = pht[pht_addrD2] + 1;
          bhr = bhr << 1;
          bhr[0] = real_bjD2;
        end
        else if(~real_bjD2 & (~is_bjD1|(is_bjD1 & ~real_bjD1)))begin
          if(pht[pht_addrD2] != 0) pht[pht_addrD2] = pht[pht_addrD2] - 1;
          bhr = bhr << 1;
          bhr[0] = real_bjD2;
        end
      end
    
    end
  end

endmodule

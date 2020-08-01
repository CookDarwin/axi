/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________descript:
author : Cook.Darwin
Version: VERA.0.0
    build from axi_streams_scaler
Version: VERA.0.1
    use data combin VERA.1.0
Version: VERA.1.0
    use data_c_scaler_A1
creaded: 2016/12/9 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axi_streams_combin_A1 #(
    parameter   MODE = "BOTH",      //HEAD END
    parameter   CUT_OR_COMBIN_BODY  = "ON" //ON OFF
)(
    input [15:0]               new_body_len,
    input                      trigger_signal,
    axi_stream_inf.slaver      head_inf,
    (* up_stream = "true" *)
    axi_stream_inf.slaver      body_inf,
    axi_stream_inf.slaver      end_inf,
    (* down_stream = "true" *)
    axi_stream_inf.master      m00
);


import DataInterfacePkg::*;

wire        clock,rst_n,clk_en;
assign      clock   = head_inf.aclk;
assign      rst_n   = head_inf.aresetn;
assign      clk_en  = head_inf.aclken;

// localparam  KSIZE   = (m00.DSIZE/8 > 0)? m00.DSIZE/8 : 1;

data_inf_c #(.DSIZE(m00.DSIZE+1+1+m00.KSIZE) ) s00_data_inf (clock,rst_n);
data_inf_c #(.DSIZE(m00.DSIZE+1+1+m00.KSIZE) ) s01_data_inf (clock,rst_n);
data_inf_c #(.DSIZE(m00.DSIZE+1+1+m00.KSIZE) ) s02_data_inf (clock,rst_n);
data_inf_c #(.DSIZE(m00.DSIZE+1+1+m00.KSIZE) ) m00_data_inf (clock,rst_n);

logic       body_new_last;
logic       body_mix_last;
logic       body_pass_last;
logic       body_ctrl_last;

assign body_mix_last    = (CUT_OR_COMBIN_BODY=="OFF" || (MODE=="HEAD")) ? body_inf.axis_tlast : body_new_last;

always@(*)
    if(MODE=="HEAD")begin
        if(CUT_OR_COMBIN_BODY == "OFF")
                body_pass_last  = body_inf.axis_tlast;
        else    body_pass_last  = body_new_last;
    end else    body_pass_last  = 1'b0;

always@(*)
    if(MODE=="HEAD")begin
        if(CUT_OR_COMBIN_BODY=="OFF")
                body_ctrl_last  = body_inf.axis_tlast;
        else    body_ctrl_last  = body_new_last;
    end else begin
        if(CUT_OR_COMBIN_BODY=="OFF")
                body_ctrl_last  = body_inf.axis_tlast;
        else    body_ctrl_last  = body_new_last;
    end

assign s00_data_inf.valid                       = head_inf.axis_tvalid && clk_en;
// assign s00_data_inf.data[m00.DSIZE-1:0]             = head_inf.axis_tdata;
// assign s00_data_inf.data[m00.DSIZE]                 = 1'b0;
// assign s00_data_inf.data[m00.DSIZE+1]               = head_inf.axis_tuser;
// assign s00_data_inf.data[m00.DSIZE+m00.KSIZE+1-:m00.KSIZE]  = head_inf.axis_tkeep;
always_comb begin
    s00_data_inf.data[m00.DSIZE-1:0]             = head_inf.axis_tdata;
    s00_data_inf.data[m00.DSIZE]                 = 1'b0;
    s00_data_inf.data[m00.DSIZE+1]               = head_inf.axis_tuser;
    s00_data_inf.data[m00.DSIZE+m00.KSIZE+1-:m00.KSIZE]  = head_inf.axis_tkeep;
end
assign head_inf.axis_tready                     = s00_data_inf.ready && clk_en;


assign s01_data_inf.valid                       = body_inf.axis_tvalid && clk_en;
// assign s01_data_inf.data[m00.DSIZE-1:0]             = body_inf.axis_tdata;
// assign s01_data_inf.data[m00.DSIZE]                 = body_pass_last;
// assign s01_data_inf.data[m00.DSIZE+1]               = body_inf.axis_tuser;
// assign s01_data_inf.data[m00.DSIZE+m00.KSIZE+1-:m00.KSIZE]  = body_inf.axis_tkeep;
always_comb begin
    s01_data_inf.data[m00.DSIZE-1:0]             = body_inf.axis_tdata;
    s01_data_inf.data[m00.DSIZE]                 = body_pass_last;
    s01_data_inf.data[m00.DSIZE+1]               = body_inf.axis_tuser;
    s01_data_inf.data[m00.DSIZE+m00.KSIZE+1-:m00.KSIZE]  = body_inf.axis_tkeep;
end
assign body_inf.axis_tready                     = s01_data_inf.ready && clk_en;

assign s02_data_inf.valid                       = end_inf.axis_tvalid && clk_en;
// assign s02_data_inf.data[m00.DSIZE-1:0]             = end_inf.axis_tdata;
// assign s02_data_inf.data[m00.DSIZE]                 = end_inf.axis_tlast;
// assign s02_data_inf.data[m00.DSIZE+1]               = end_inf.axis_tuser;
// assign s02_data_inf.data[m00.DSIZE+m00.KSIZE+1-:m00.KSIZE]  = end_inf.axis_tkeep;
always_comb begin
    s02_data_inf.data[m00.DSIZE-1:0]             = end_inf.axis_tdata;
    s02_data_inf.data[m00.DSIZE]                 = end_inf.axis_tlast;
    s02_data_inf.data[m00.DSIZE+1]               = end_inf.axis_tuser;
    s02_data_inf.data[m00.DSIZE+m00.KSIZE+1-:m00.KSIZE]  = end_inf.axis_tkeep;
end
assign end_inf.axis_tready                      = s02_data_inf.ready && clk_en;

logic[15:0]     bcnt;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  bcnt    <= 16'd0;
    else begin
        if(CUT_OR_COMBIN_BODY=="ON")begin
            if(body_inf.axis_tready && body_inf.axis_tvalid && body_inf.aclken)
                if(bcnt == (new_body_len-1))
                        bcnt    <= 16'd0;
                else    bcnt    <= bcnt+1'b1;
            else
                bcnt   <= bcnt;
        end else begin
            bcnt <= 16'd0;
        end
    end

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  body_new_last   <= 1'b0;
    else begin
        // if((bcnt==(new_body_len-2) && body_inf.axis_tvalid && body_inf.axis_tready))
        //         body_new_last   <= 1'b1;
        // else    body_new_last   <= 1'b0;
        if(new_body_len < 2)
                body_new_last   <= 1'b1;
        else    body_new_last   <= pipe_last_func(body_inf.axis_tvalid,body_inf.axis_tready,body_new_last,(bcnt==(new_body_len-2)));
    end


//
// data_streams_combin #(
// data_streams_combin_A1 #(
//     .MODE       (MODE   ),       //HEAD END BOTH
//     .DSIZE      (m00.DSIZE+1+1+m00.KSIZE  )
// )data_streams_combin_inst(
// /*    input           */    .clock          (clock                  ),
// /*    input           */    .rst_n          (rst_n                  ),
// /*    input           */    .clk_en         (clk_en                 ),
// /*    input           */    .trigger_signal (trigger_signal         ),
// /*    input           */    .head_last      (head_inf.axis_tlast    ),
// /*    input           */    .body_last      (body_ctrl_last         ),
// /*    input           */    .end_last       (end_inf.axis_tlast     ),
// /*    data_inf.slaver */    .head_inf       (s00_data_inf           ),
// /*    data_inf.slaver */    .body_inf       (s01_data_inf           ),
// /*    data_inf.slaver */    .end_inf        (s02_data_inf           ),
// /*    data_inf.master */    .m00            (m00_data_inf           )
// );

data_c_scaler_A1 #(
    .MODE       (MODE   )
)data_c_scaler_A1_inst(
/*  input               */    .trigger      (trigger_signal         ),
/*  input               */    .head_last    (head_inf.axis_tlast    ),
/*  input               */    .body_last    (body_ctrl_last         ),
/*  input               */    .end_last     (end_inf.axis_tlast     ),
/*  data_inf_c.slaver   */    .head_inf     (s00_data_inf           ),
/*  data_inf_c.slaver   */    .body_inf     (s01_data_inf           ),
/*  data_inf_c.slaver   */    .end_inf      (s02_data_inf           ),
/*  data_inf_c.master   */    .m00          (m00_data_inf           )
);

assign m00.axis_tdata            = m00_data_inf.data[m00.DSIZE-1:0];
assign m00.axis_tvalid           = m00_data_inf.valid && clk_en;
assign m00.axis_tlast            = m00_data_inf.data[m00.DSIZE];
assign m00.axis_tuser            = m00_data_inf.data[m00.DSIZE+1];
assign m00_data_inf.ready        = m00.axis_tready && clk_en;
assign m00.axis_tkeep            = m00_data_inf.data[m00.DSIZE+m00.KSIZE+1-:m00.KSIZE];

endmodule

/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/1/3 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axi_stream_interconnect_M2S  #(
    parameter   NUM   = 8,
    parameter   NSIZE =  NUM <= 2? 1 :
                         NUM <= 4? 2 :
                         NUM <= 8? 3 :
                         NUM <= 16?4 : 5
)(
    input [NSIZE-1:0]      addr,
    axi_stream_inf.slaver  s00 [NUM-1:0],
    axi_stream_inf.master  m00
);

// initial begin
//     $error("axi_stream_interconnect_M2S has be abandon,pleace use axi_stream_interconnect_M2S_with_addr");
//     $stop;
// end

// localparam  DSIZE   = m00.DSIZE;
// localparam  KSIZE   = (m00.DSIZE/8 > 0)? m00.DSIZE/8 : 1;

data_inf #(.DSIZE(m00.DSIZE+1+1+m00.KSIZE) ) s00_data_inf [NUM-1:0] ();
data_inf #(.DSIZE(m00.DSIZE+1+1+m00.KSIZE) ) m00_data_inf ();

genvar KK;
generate
for(KK=0;KK<NUM;KK++)begin
assign s00_data_inf[KK].valid                                   = s00[KK].axis_tvalid;
assign s00_data_inf[KK].data                                    = {s00[KK].axis_tkeep,s00[KK].axis_tuser,s00[KK].axis_tlast,s00[KK].axis_tdata};
// assign s00_data_inf[KK].data[m00.DSIZE-1:0]                     = s00[KK].axis_tdata;
// assign s00_data_inf[KK].data[m00.DSIZE]                         = s00[KK].axis_tlast;
// assign s00_data_inf[KK].data[m00.DSIZE+1]                       = s00[KK].axis_tuser;
// assign s00_data_inf[KK].data[m00.DSIZE+m00.KSIZE+1-:m00.KSIZE]  = s00[KK].axis_tkeep;
assign s00[KK].axis_tready                                      = s00_data_inf[KK].ready;
end
endgenerate
`include "define_macro.sv"
`ifdef VIVADO_ENV
localparam DSIZE = m00.DSIZE+m00.KSIZE+1+1;
`endif

data_pipe_interconnect_M2S_verb #(
`ifdef VIVADO_ENV
    .DSIZE      (DSIZE     ),
`else
    .DSIZE      (m00.DSIZE+m00.KSIZE+1+1     ),
`endif
    .NUM        (NUM       )
)data_pipe_interconnect_M2S_verb_inst(
/*    input                 */    .clock            (m00.aclk       ),
/*    input                 */    .rst_n            (m00.aresetn    ),
/*    input                 */    .clk_en           (m00.aclken     ),
/*    input [NSIZE-1:0]     */    .addr             (addr           ),
/*    data_inf.slaver       */    .s00              (s00_data_inf   ),
/*    data_inf.master       */    .m00              (m00_data_inf   )
);

assign m00.axis_tdata            = m00_data_inf.data[m00.DSIZE-1:0];
assign m00.axis_tvalid           = m00_data_inf.valid;
assign m00.axis_tlast            = m00_data_inf.data[m00.DSIZE];
assign m00.axis_tuser            = m00_data_inf.data[m00.DSIZE+1];
assign m00_data_inf.ready        = m00.axis_tready;
assign m00.axis_tkeep            = m00_data_inf.data[m00.DSIZE+m00.KSIZE+1-:m00.KSIZE];

endmodule

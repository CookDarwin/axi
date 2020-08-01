/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
    build from axi_stream_interconnect_M2S
Version: VERA.0.1
    when valid set high one clock,after that,set low,signal will be locked uncorrect
Version: VERA.1.0
    use data_inf_c m2s
Version: VERA.2.0 ###### Wed Jun 17 14:28:42 CST 2020
     兼容vcs ,vcs有时无法通过 interface.Parameter 传入参数
creaded: 2017/1/3 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axi_stream_interconnect_M2S_A2 #(
    parameter   NUM   = 8,
    parameter   DSIZE = 8,
    parameter   KSIZE = (DSIZE/8 > 0)? DSIZE/8 : 1, // (* show = "false" *)
    parameter   NSIZE =  NUM <= 2? 1 :
                         NUM <= 4? 2 :
                         NUM <= 8? 3 :
                         NUM <= 16?4 : 5
)(
    (* up_stream = "true" *)
    axi_stream_inf.slaver  s00 [NUM-1:0],
    (* down_stream = "true" *)
    axi_stream_inf.master  m00
);


//localparam  DSIZE   = m00.DSIZE;
// localparam  KSIZE   = (DSIZE/8 > 0)? DSIZE/8 : 1;

data_inf_c #(.DSIZE(DSIZE+1+1+KSIZE) ) s00_data_inf [NUM-1:0] (m00.aclk,m00.aresetn);
data_inf_c #(.DSIZE(DSIZE+1+1+KSIZE) ) m00_data_inf (m00.aclk,m00.aresetn);

logic [NUM-1:0] last;

genvar KK;
generate
for(KK=0;KK<NUM;KK++)
    assign last[KK] = s00[KK].axis_tlast;
endgenerate

generate
for(KK=0;KK<NUM;KK++)begin
assign s00_data_inf[KK].data    = {s00[KK].axis_tkeep,s00[KK].axis_tuser,s00[KK].axis_tlast,s00[KK].axis_tdata};
assign s00_data_inf[KK].valid   = s00[KK].axis_tvalid;
assign s00[KK].axis_tready      = s00_data_inf[KK].ready;
end
endgenerate

data_c_pipe_intc_M2S_verc #(
    .PRIO   ("BEST_LAST"    ),   //BEST_ROBIN BEST_LAST ROBIN LAST WAIT_IDLE FORCE_ROBIN
    .NUM    (NUM            )
)data_c_pipe_intc_M2S_verc_inst(
/*  input [NUM-1:0]      */       .last         (last           ),             //ctrl prio
/*  data_inf_c.slaver    */       .s00          (s00_data_inf   ),//[NUM-1:0],
/*  data_inf_c.master    */       .m00          (m00_data_inf   )
);

assign {m00.axis_tkeep,m00.axis_tuser,m00.axis_tlast,m00.axis_tdata} = m00_data_inf.data;
assign m00.axis_tvalid      = m00_data_inf.valid;
assign m00_data_inf.ready   = m00.axis_tready;

endmodule

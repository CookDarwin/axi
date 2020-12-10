/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2020/11/30 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axi_stream_interconnect_S2M_with_info #(
    parameter   NUM   = 8,
    parameter   ISIZE = 32,
    parameter   NSIZE = $clog2(NUM)
)(
    input [NSIZE-1:0]       addr,               //sync s00
    input [ISIZE-1:0]       in_info,            //sync s00
    output[ISIZE-1:0]       out_info [NUM-1:0], //sync m00
    axi_stream_inf.slaver   s00,                
    axi_stream_inf.master   m00  [NUM-1:0]
);

//localparam  DSIZE   = s00.DSIZE;
// localparam  KSIZE   = (DSIZE/8 > 0)? DSIZE/8 : 1;

data_inf #(.DSIZE(s00.DSIZE+1+s00.USIZE+ISIZE+s00.KSIZE) ) s00_data_inf ();
data_inf #(.DSIZE(s00.DSIZE+1+s00.USIZE+ISIZE+s00.KSIZE) ) m00_data_inf [NUM-1:0] ();

genvar KK;
generate
for(KK=0;KK<NUM;KK++)begin
assign m00[KK].axis_tvalid      =  m00_data_inf[KK].valid                          ;
assign m00[KK].axis_tdata       =  m00_data_inf[KK].data[s00.DSIZE-1:0]            ;
assign m00[KK].axis_tlast       =  m00_data_inf[KK].data[s00.DSIZE]                ;
assign m00[KK].axis_tuser       =  m00_data_inf[KK].data[s00.DSIZE+1 +: s00.USIZE] ;
assign m00[KK].axis_tkeep       =  m00_data_inf[KK].data[s00.DSIZE+s00.KSIZE+s00.USIZE-:s00.KSIZE] ;
assign out_info[KK]             =  m00_data_inf[KK].data[s00.DSIZE+1+s00.USIZE+ISIZE+s00.KSIZE-1-:ISIZE];
assign m00_data_inf[KK].ready   =  m00[KK].axis_tready                         ;
end
endgenerate

data_pipe_interconnect_S2M_verb #(
    .NUM        (NUM       )
)data_pipe_interconnect_S2M_inst(
/*    input                 */    .clock            (s00.aclk       ),
/*    input                 */    .rst_n            (s00.aresetn    ),
/*    input                 */    .clk_en           (s00.aclken     ),
/*    input [NSIZE-1:0]     */    .addr             (addr           ),
    // output logic[2:0]   curr_path,

/*    data_inf.master       */    .m00              (m00_data_inf   ),  //[NUM-1:0],
/*    data_inf.slaver       */    .s00              (s00_data_inf   )
);

assign  s00_data_inf.data             = {in_info,s00.axis_tkeep,s00.axis_tuser,s00.axis_tlast,s00.axis_tdata}     ;
assign  s00_data_inf.valid                            = s00.axis_tvalid    ;
// assign  s00_data_inf.data[s00.DSIZE]                  = s00.axis_tlast     ;
// assign  s00_data_inf.data[s00.DSIZE+1]                = s00.axis_tuser     ;
assign  s00.axis_tready                               = s00_data_inf.ready ;
// assign  s00_data_inf.data[s00.DSIZE+1+1+:s00.KSIZE]   = s00.axis_tkeep     ;

endmodule

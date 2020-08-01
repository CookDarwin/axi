/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
    build from axi_stream_interconnect_M2S_noaddr
creaded: 2017/8/11 
madified:
***********************************************/
`timescale 1ns/1ps
module data_inf_intc_M2S_force_addr_with_id #(
    parameter   NUM   = 8,
    parameter   IDSIZE= 4,
    parameter   NSIZE =  $clog2(NUM)
)(
    input                clock,
    input                rst_n,
    input [NSIZE-1:0]    addr,
    input                addr_vld,
    output  [NSIZE-1:0]  curr_addr,
    input [IDSIZE-1:0]   sid [NUM-1:0],
    output[IDSIZE-1:0]   mid,
    data_inf.slaver      s00 [NUM-1:0],
    data_inf.master      m00
);

data_inf #(.DSIZE(m00.DSIZE+IDSIZE) ) s00_data_inf [NUM-1:0] ();
data_inf #(.DSIZE(m00.DSIZE+IDSIZE) ) m00_data_inf ();

genvar KK;
generate
for(KK=0;KK<NUM;KK++)begin
assign s00_data_inf[KK].valid                           = s00[KK].valid;
assign s00_data_inf[KK].data/*[m00.DSIZE-1:0]*/         = {sid[KK],s00[KK].data};
assign s00[KK].ready                                    = s00_data_inf[KK].ready;
end
endgenerate


data_pipe_interconnect_M2S #(
    // .DSIZE      (m00.DSIZE+IDSIZE     ),
    .NUM        (NUM       )
)data_pipe_interconnect_M2S_inst(
/*    input                 */    .clock            (clock          ),
/*    input                 */    .rst_n            (rst_n          ),
/*    input                 */    .clk_en           (1'b1           ),
/*    input                  */   .vld_sw           (addr_vld       ),
/*    input [NSIZE-1:0]      */   .sw               (addr           ),
/*    output logic[NSIZE-1:0]*/   .curr_path        (curr_addr      ),
/*    data_inf.slaver       */    .s00              (s00_data_inf   ),
/*    data_inf.master       */    .m00              (m00_data_inf   )
);

assign {mid,m00.data}            = m00_data_inf.data[m00.DSIZE-1:0];
assign m00.valid                 = m00_data_inf.valid;
assign m00_data_inf.ready        = m00.ready;

//--->> ADDR STATUS <<---------------------
//---<< ADDR STATUS >>---------------------
endmodule

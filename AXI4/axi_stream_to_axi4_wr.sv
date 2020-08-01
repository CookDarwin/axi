/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/3/1 
madified:
***********************************************/
`timescale 1ns/1ps
module axi_stream_to_axi4_wr (
    axi_stream_inf.slaver       axis_in,
    axi_inf.master_wr           axi_wr_inf
);

localparam FIELD_LEN    = 64/axis_in.DSIZE + (64%axis_in.DSIZE != 0);

axi_stream_inf #(.DSIZE(axis_in.DSIZE)) ps_inf              (.aclk(axis_in.aclk),.aresetn(axis_in.aresetn),.aclken(axis_in.aclken));
axi_stream_inf #(.DSIZE(axi_wr_inf.IDSIZE+axi_wr_inf.ASIZE+axi_wr_inf.LSIZE))
id_add_len_inf      (.aclk(axis_in.aclk),.aresetn(axis_in.aresetn),.aclken(axis_in.aclken));

logic[axis_in.DSIZE*FIELD_LEN-1:0]  value;

logic [31:0]                addr;
logic [31:0]                length;
logic                       addr_len_vld;

assign {addr,length}    = value[63:0];

parse_big_field_table #(
    .DSIZE          (axis_in.DSIZE      ),
    .FIELD_LEN      (FIELD_LEN          ),     //MAX 16*8
    .FIELD_NAME     ("Big Filed"        ),
    .TRY_PARSE      ("OFF"              )
)parse_big_field_table_inst(
/*    input                               */    .enable     (1'b1           ),
/*    input [DSIZE*FIELD_LEN-1:0]         */    .value      (value          ),
/*    output logic                        */    .out_valid  (addr_len_vld   ),
/*    axi_stream_inf.slaver               */    .cm_tb_s    (axis_in        ),
/*    axi_stream_inf.master               */    .cm_tb_m    (ps_inf         ),
/*    axi_stream_inf.mirror               */    .cm_mirror  (axis_in        )
);

assign ps_inf.axis_tready   = axi_wr_inf.axi_awready || axi_wr_inf.axi_wready;

assign id_add_len_inf.axis_tvalid   = addr_len_vld;
assign id_add_len_inf.axis_tdata    = {{axi_wr_inf.IDSIZE{1'b0}},addr[axi_wr_inf.ASIZE-1:0],length[axi_wr_inf.LSIZE-1:0]};

axi4_wr_auxiliary_gen axi4_wr_auxiliary_gen_inst(
/*    axi_stream_inf.slaver    */   .id_add_len_in  (id_add_len_inf         ),      //tlast is not necessary
/*    axi_inf.master_wr_aux    */   .axi_wr_aux     (axi_wr_inf             )
);

assign axi_wr_inf.axi_wdata     = ps_inf.axis_tdata;
assign axi_wr_inf.axi_wvalid    = ps_inf.axis_tvalid;
assign axi_wr_inf.axi_wlast     = ps_inf.axis_tlast;

assign axi_wr_inf.axi_wstrb     = '1;

endmodule

/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/2/16 
madified:
***********************************************/
`timescale 1ns/1ps
import AxiBfmPkg::*;
module data_convert_2_16_tb;

clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(5			),
	.FreqM			(148.5     	)
)clock_rst_pixel(
	.clock			(pclk   	),
	.rst_x			(prst_n  	)
);


axi_stream_inf #(8)axis_combin(pclk,prst_n,1'b1);
axi_stream_inf #(30)axis_combin_bfm(pclk,prst_n,1'b1);

logic   enable = 0;
logic   ready;
int     length = 0;
int     frames = 20;

initial begin
    length = 8;
    repeat(frames)begin
        wait(ready);
        enable  = 1;
        wait(!ready);
        enable  = 0;
        @(negedge axis_combin_bfm.axis_tlast);
        length ++;
    end
end

gen_origin_axis #(
    .MODE       ("RANGE")
)gen_origin_axis_combin(
/*    input                */ .enable       (enable),
/*    output logic         */ .ready        (ready),
/*    input [15:0]         */ .length       (length),
/*    axi_stream_inf.master*/ .axis_out     (axis_combin)
);


data_combin_0 #(
    .IDSIZE         (axis_combin.DSIZE   ),
    .ODSIZE         (axis_combin_bfm.DSIZE                 )
)data_combin_0_inst(
/*    input                     */  .clock          (axis_combin.aclk       ),
/*    input                     */  .rst_n          (axis_combin.aresetn    ),
/*    input [31:0]              */  .cut_old_len    ('1),
/*    input [IDSIZE-1:0]        */  .indata         (axis_combin.axis_tdata),
/*    input                     */  .invalid        (axis_combin.axis_tvalid),
/*    output                    */  .inready        (axis_combin.axis_tready),
/*    input                     */  .inlast         (axis_combin.axis_tlast ),
/*    output logic[ODSIZE-1:0]  */  .outdata        (axis_combin_bfm.axis_tdata),
/*    output logic              */  .outvalid       (axis_combin_bfm.axis_tvalid),
/*    input                     */  .outready       (axis_combin_bfm.axis_tready),
/*    output logic              */  .outlast        (axis_combin_bfm.axis_tlast )
);

AxiStreamSlaverBfm_c #(axis_combin_bfm.DSIZE) slaver_bfm;

initial begin
    slaver_bfm = new(axis_combin_bfm);
    repeat(frames)
        slaver_bfm.get_data(30,0);
end

//---->> DESTRUCT <<------------------------------------------
axi_stream_inf #(16)axis_destruct(pclk,prst_n,1'b1);
axi_stream_inf #(4)axis_destruct_bfm(pclk,prst_n,1'b1);

logic   ds_enable = 0;
logic   ds_ready;
int     ds_length = 0;
int     ds_frames = 20;

logic [axis_destruct.DSIZE-1:0] ds_data [$];

initial begin
    ds_length = 8;
    repeat(ds_frames)begin
        wait(ds_ready);
        ds_enable  = 1;
        wait(!ds_ready);
        ds_enable  = 0;
        @(negedge axis_destruct_bfm.axis_tlast);
        ds_length ++;
    end
end


// gen_origin_axis #(
//     .MODE       ("RANGE")
// )gen_origin_axis_destruct(
// /*    input                */ .enable       (ds_enable),
// /*    output logic         */ .ready        (ds_ready),
// /*    input [15:0]         */ .length       (ds_length),
// /*    axi_stream_inf.master*/ .axis_out     (axis_destruct)
// );
AxiStreamMasterBfm_c #(axis_destruct.DSIZE) axis_master_bfm;

initial begin
    axis_master_bfm = new(axis_destruct);
    repeat(ds_frames)begin
        repeat($urandom_range(100,0))begin
            ds_data = {ds_data,$urandom_range(100,0)};
        end
        axis_master_bfm.gen_axi_stream(ds_data.size(),$urandom_range(100,0),ds_data);
    end
end

data_destruct #(
    .IDSIZE         (axis_destruct.DSIZE   ),
    .ODSIZE         (axis_destruct_bfm.DSIZE                 )
)data_destruct_inst(
/*    input                    */   .clock           (axis_destruct.aclk       ),
/*    input                    */   .rst_n           (axis_destruct.aresetn    ),
/*    input [IDSIZE-1:0]       */   .indata          (axis_destruct.axis_tdata ),
/*    input                    */   .invalid         (axis_destruct.axis_tvalid),
/*    output logic             */   .inready         (axis_destruct.axis_tready),
/*    input                    */   .inlast          (axis_destruct.axis_tlast ),
/*    output logic[ODSIZE-1:0] */   .outdata         (axis_destruct_bfm.axis_tdata),
/*    output logic             */   .outvalid        (axis_destruct_bfm.axis_tvalid),
/*    input                    */   .outready        (axis_destruct_bfm.axis_tready),
/*    output logic             */   .outlast         (axis_destruct_bfm.axis_tlast )
);

AxiStreamSlaverBfm_c #(axis_destruct_bfm.DSIZE) ds_slaver_bfm;

initial begin
    ds_slaver_bfm = new(axis_destruct_bfm);
    repeat(ds_frames)
        ds_slaver_bfm.get_data(50,0);
end

feed_check #(
    .ASIZE      (axis_destruct.DSIZE    ),
    .BSIZE      (axis_destruct_bfm.DSIZE    ),
    .LIST       ("ON")
)feed_check_inst(
/*  input             */  .aclock   (axis_destruct.aclk             ),
/*  input [ASIZE-1:0] */  .adata    (axis_destruct.axis_tdata       ),
/*  input             */  .avld     (axis_destruct.axis_tvalid && axis_destruct.axis_tready),
/*  input             */  .bclock   (axis_destruct_bfm.aclk         ),
/*  input [BSIZE-1:0] */  .bdata    (axis_destruct_bfm.axis_tdata   ),
/*  input             */  .bvld     (axis_destruct_bfm.axis_tvalid && axis_destruct_bfm.axis_tready)
);

endmodule

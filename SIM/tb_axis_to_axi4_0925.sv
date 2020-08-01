/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/9/25 
madified:
***********************************************/
`timescale 1ns/1ps
module tb_axis_to_axi4_0925;
import AxiBfmPkg::*;

logic   aclk;
logic   aresetn;

logic   axi_aclk;
logic   axi_aresetn;

clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(5			),
	.FreqM			(140     	)
)clock_rst_master(
	.clock			(aclk	    ),
	.rst_x			(aresetn 	)
);

clock_rst_verb #(
	.ACTIVE			(0			),
	.PERIOD_CNT		(0			),
	.RST_HOLD		(5			),
	.FreqM			(50     	)
)clock_rst_slaver(
	.clock			(axi_aclk     ),
	.rst_x			(axi_aresetn     )
);

localparam DSIZE    = 32;

axi_stream_inf #(DSIZE) axis_in (aclk,aresetn,1'b1);

AxiStreamMasterBfm_c #(DSIZE,"OFF") MasterBfm = new(axis_in);

axi_inf #(
    .IDSIZE    (1           ),
    .ASIZE     (19          ),
    .LSIZE     (17          ),
    .DSIZE     (DSIZE       )
)axi_wr(
    .axi_aclk      (axi_aclk),
    .axi_aresetn    (axi_aresetn)
);

Axi4SlaverBfm_c #(
    .IDSIZE    (axi_wr.IDSIZE   ),
    .ASIZE     (axi_wr.ASIZE    ),
    .DSIZE     (axi_wr.DSIZE    ),
    .LSIZE     (axi_wr.LSIZE    ),
    .MSG       ("ON"                    )
) Axi4SlaverBfm = new(axi_wr);

axis_to_axi4_wr#(
    .ADDR_STEP      (1)
)axis_to_axi4_wr_inst(
/*  input[31:0]           */    .addr       (0),
/*  axi_stream_inf.slaver */    .axis_in    (axis_in    ),
/*  axi_inf.master_wr     */    .axi_wr     (axi_wr     )
);

initial begin
    wait(axi_wr.axi_aresetn);
    repeat(10)  @(posedge axi_wr.axi_aclk);
    Axi4SlaverBfm.run(50,50);
end

logic [DSIZE-1:0]   data [$];
int CC;
initial begin
    wait(axis_in.aresetn);
    // repeat(10)  @(posedge axis_in.aclk);
    repeat(10)  @(posedge axi_wr.axi_aclk);
    repeat(10)  @(posedge axis_in.aclk);
    data   = {>>{8'd1,8'd2,8'd3,8'd4}};
    for(CC=0;CC<1024;CC++)
        data[CC] = $urandom_range(2**16);
    repeat(2)
        MasterBfm.gen_axi_stream(512*4+1,50,data);
end

mailbox mdata = new();

always@(negedge axis_in.aclk)
    if(axis_in.axis_tvalid && axis_in.axis_tready)
            mdata.put(axis_in.axis_tdata);

always@(negedge axi_wr.axi_aclk)begin
logic [axi_wr.DSIZE-1:0]    gdata;
    if(axi_wr.axi_wvalid && axi_wr.axi_wready)begin
        mdata.get(gdata);
        assert(gdata == axi_wr.axi_wdata)
        else $error("\nDATA ERROR: EXPECT[%h],BUT [%h]\n",gdata,axi_wr.axi_wdata);
    end
end
endmodule

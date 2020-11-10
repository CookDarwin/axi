/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
created: xxxx.xx.xx
madified:
***********************************************/
`timescale 1ns/1ps

module axi4_partition_rd_verb #(
    parameter  PSIZE = 128
)(
    axi_inf.slaver_rd   long_inf,
    axi_inf.master_rd   short_inf
);

//==========================================================================
//-------- define ----------------------------------------------------------
logic  clock;
logic  rst_n;
(* MARK_DEBUG="true" *)(* dont_touch="true" *)logic fifo_empty;
(* MARK_DEBUG="true" *)(* dont_touch="true" *)logic fifo_full;
data_inf_c #(.DSIZE(long_inf.IDSIZE+long_inf.LSIZE+long_inf.ASIZE)) pre_partition_data_inf (.clock(clock),.rst_n(rst_n)) ;
data_inf_c #(.DSIZE(short_inf.IDSIZE+long_inf.LSIZE+long_inf.ASIZE)) post_partition_data_inf (.clock(clock),.rst_n(rst_n)) ;
data_inf_c #(.DSIZE(1)) partition_pulse_inf (.clock(clock),.rst_n(rst_n)) ;
data_inf_c #(.DSIZE(1)) wait_last_inf (.clock(clock),.rst_n(rst_n)) ;
//==========================================================================
//-------- instance --------------------------------------------------------
data_inf_partition #(
    .PLEN      (PSIZE              ),
    .LSIZE     (long_inf.LSIZE     ),
    .IDSIZE    (long_inf.IDSIZE    ),
    .ADDR_STEP (long_inf.ADDR_STEP )
)data_inf_partition_inst(
/* data_inf_c.slaver */.data_in             (pre_partition_data_inf  ),
/* data_inf_c.master */.data_out            (post_partition_data_inf ),
/* data_inf_c.master */.partition_pulse_inf (partition_pulse_inf     ),
/* data_inf_c.master */.wait_last_inf       (wait_last_inf           )
);
common_fifo #(
    .DEPTH (6 ),
    .DSIZE (1 )
)common_fifo_inst(
/* input  */.clock (clock                                                              ),
/* input  */.rst_n (rst_n                                                              ),
/* input  */.wdata (partition_pulse_inf.data                                           ),
/* input  */.wr_en (partition_pulse_inf.valid && partition_pulse_inf.ready             ),
/* output */.rdata (                                                                   ),
/* input  */.rd_en ( (short_inf.axi_rvalid & short_inf.axi_rready)&short_inf.axi_rlast ),
/* output */.count (/*unused */                                                        ),
/* output */.empty (fifo_empty                                                         ),
/* output */.full  (fifo_full                                                          )
);
//==========================================================================
//-------- expression ------------------------------------------------------
assign  clock = long_inf.axi_aclk;
assign  rst_n = long_inf.axi_aresetn;

assign  pre_partition_data_inf.data = {long_inf.axi_arid,long_inf.axi_araddr,long_inf.axi_arlen};
assign  pre_partition_data_inf.valid = long_inf.axi_arvalid;
assign  long_inf.axi_arready = pre_partition_data_inf.ready;
assign  {short_inf.axi_arid,short_inf.axi_araddr,short_inf.axi_arlen} = post_partition_data_inf.data;
assign  short_inf.axi_arvalid = post_partition_data_inf.valid;
assign  post_partition_data_inf.ready = short_inf.axi_arready;

assign  partition_pulse_inf.ready = ~fifo_full;

assign  short_inf.axi_arsize = long_inf.axi_arsize;
assign  short_inf.axi_arburst = long_inf.axi_arburst;
assign  short_inf.axi_arlock = long_inf.axi_arlock;
assign  short_inf.axi_arcache = long_inf.axi_arcache;
assign  short_inf.axi_arprot = long_inf.axi_arprot;
assign  short_inf.axi_arqos = long_inf.axi_arqos;
assign  long_inf.axi_rid = short_inf.axi_rid[ long_inf.IDSIZE-1:0];
assign  long_inf.axi_rdata = short_inf.axi_rdata;
assign  long_inf.axi_rresp = short_inf.axi_rresp;
assign  long_inf.axi_rlast = ( short_inf.axi_rlast&fifo_empty);
assign  long_inf.axi_rvalid = short_inf.axi_rvalid;
assign  short_inf.axi_rready = long_inf.axi_rready;

always_ff@(posedge clock,negedge rst_n) begin 
    if(~rst_n)begin
         wait_last_inf.ready <= 1'b0;
    end
    else begin
         wait_last_inf.ready <= ( long_inf.axi_rvalid&long_inf.axi_rready& long_inf.axi_rlast);
    end
end

endmodule

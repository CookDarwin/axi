/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/4/5 
madified:
***********************************************/
`timescale 1ns/1ps
module axi4_wr_aux_bind_data (
    axi_inf.slaver_wr           caxi4_inf,
    axi_stream_inf.master       axis_inf
);

initial begin
    assert(caxi4_inf.ASIZE+caxi4_inf.DSIZE == axis_inf.DSIZE)
    else begin
        $error("AXI4.DSIZE#%0d + AXI4.ASIZE#%0d != AXIS.DSIZE#%0d",caxi4_inf.DSIZE,caxi4_inf.ASIZE,axis_inf.DSIZE);
        $stop;
    end
end

logic   clock,rst_n;
assign  clock   = caxi4_inf.axi_aclk;
assign  rst_n   = caxi4_inf.axi_aresetn;

logic       fifo_wr_en,fifo_rd_en;
logic       fifo_empty,fifo_full;
logic[caxi4_inf.ASIZE-1:0]   fifo_rdata;

common_fifo #(
    .DEPTH      (4      ),
    .DSIZE      (caxi4_inf.ASIZE      )
)common_fifo_inst(
/*  input                    */   .clock        (clock      ),
/*  input                    */   .rst_n        (rst_n      ),
/*  input [DSIZE-1:0]        */   .wdata        (caxi4_inf.axi_awaddr    ),
/*  input                    */   .wr_en        (fifo_wr_en ),
/*  output logic[DSIZE-1:0]  */   .rdata        (fifo_rdata ),
/*  input                    */   .rd_en        (fifo_rd_en ),
/*  output logic[CSIZE-1:0]  */   .count        (),
/*  output logic             */   .empty        (fifo_empty ),
/*  output logic             */   .full         (fifo_full  )
);

assign  fifo_wr_en  = caxi4_inf.axi_awvalid && caxi4_inf.axi_awready;
assign  caxi4_inf.axi_awready    = !fifo_full;


//--->> AXI4 datd to AXIs <<---------------------------
axi_stream_inf #(caxi4_inf.DSIZE)    axi4_data_inf (clock,rst_n,1'b1);
axi_stream_inf #(caxi4_inf.DSIZE)    axi4_data_inf_valve (clock,rst_n,1'b1);

assign  axi4_data_inf.axis_tdata    = caxi4_inf.axi_wdata;
assign  axi4_data_inf.axis_tvalid   = caxi4_inf.axi_wvalid;
assign  axi4_data_inf.axis_tlast    = caxi4_inf.axi_wlast;
assign  caxi4_inf.axi_wready         = axi4_data_inf.axis_tready;
assign  axi4_data_inf.axis_tkeep    = '1;
assign  axi4_data_inf.axis_tuser    = '0;

axis_valve axis_valve_inst(
/*  input                  */   .button     (!fifo_empty            ),          //[1] OPEN ; [0] CLOSE
/*  axi_stream_inf.slaver  */   .axis_in    (axi4_data_inf          ),
/*  axi_stream_inf.master  */   .axis_out   (axi4_data_inf_valve    )
);

// always_ff@(posedge clock,negedge rst_n)
//     if(~rst_n)  fifo_rd_en  <= 1'b0;
//     else begin
//         if(axi4_data_inf_valve.axis_tvalid && axi4_data_inf_valve.axis_tready && axi4_data_inf_valve.axis_tlast)
//                 fifo_rd_en  <= 1'b1;
//         else    fifo_rd_en  <= 1'b0;
//     end

assign  fifo_rd_en  = axi4_data_inf_valve.axis_tvalid && axi4_data_inf_valve.axis_tready && axi4_data_inf_valve.axis_tlast;

logic[caxi4_inf.ASIZE-1:0]   info_addr,info_out;

assign  info_addr   = fifo_rdata + axi4_data_inf_valve.axis_tcnt * (caxi4_inf.ADDR_STEP)/1024;

axi_stream_inf #(caxi4_inf.DSIZE)    axis_inf_just_data (clock,rst_n,1'b1);

axis_connect_pipe_with_info #(
    .IFSIZE      (caxi4_inf.ASIZE)
)axis_connect_pipe_with_info_inst(
/*  input [IFSIZE-1:0]        */ .info_in       (info_addr              ),
/*  output logic[IFSIZE-1:0]  */ .info_out      (info_out               ),
/*  axi_stream_inf.slaver     */ .axis_in       (axi4_data_inf_valve    ),
/*  axi_stream_inf.master     */ .axis_out      (axis_inf_just_data     )
);

assign  axis_inf.axis_tdata     = {info_out,axis_inf_just_data.axis_tdata};
assign  axis_inf.axis_tvalid    = axis_inf_just_data.axis_tvalid;
assign  axis_inf.axis_tlast     = axis_inf_just_data.axis_tlast;
assign  axis_inf_just_data.axis_tready  = axis_inf.axis_tready;
assign  axis_inf.axis_tkeep     = '1;
assign  axis_inf.axis_tuser     = '0;

//--->> BRESP <<----------------
logic       bfifo_empty,bfifo_full;
common_fifo #(
    .DEPTH      (4      ),
    .DSIZE      (caxi4_inf.IDSIZE     )
)common_fifo_inst_bresp(
/*  input                    */   .clock        (clock      ),
/*  input                    */   .rst_n        (rst_n      ),
/*  input [DSIZE-1:0]        */   .wdata        (caxi4_inf.axi_awid  ),
/*  input                    */   .wr_en        (caxi4_inf.axi_awvalid && caxi4_inf.axi_awready ),
/*  output logic[DSIZE-1:0]  */   .rdata        (caxi4_inf.axi_bid ),
/*  input                    */   .rd_en        (caxi4_inf.axi_bvalid && caxi4_inf.axi_bready),
/*  output logic[CSIZE-1:0]  */   .count        (),
/*  output logic             */   .empty        (bfifo_empty ),
/*  output logic             */   .full         (bfifo_full  )
);

assign  caxi4_inf.axi_bvalid = !bfifo_empty;
assign  caxi4_inf.axi_bresp  = 2'b00;
//---<< BRESP >>----------------
endmodule

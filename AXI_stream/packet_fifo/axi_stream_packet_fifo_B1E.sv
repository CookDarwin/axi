/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERB.0.0 :
    add custom signalssync to last
Version: VERB.1.0 :2017/3/15 
    add empty size
Version: VERB.1.1 :2017/11/3 
    user xilinx_fifo_verb
creaded:
madified:
***********************************************/
`timescale 1ns/1ps
module axi_stream_packet_fifo_B1E #(
    parameter DEPTH   = 2,   //2-4
    parameter CSIZE   = 1,
    parameter DSIZE   = 24,
    parameter KSIZE   = DSIZE/8
)(
    // input                    slaver_aclk,
    // input                    slaver_aresetn,
    // input                    master_aclk,
    // input                    master_aresetn,
    input [CSIZE-1:0]        in_cdata,
    output[CSIZE-1:0]        out_cdata,
    output logic[15:0]       empty_size,
    // input[DSIZE-1:0]         slaver_axis_tdata    ,
    // input                    slaver_axis_tvalid   ,
    // output                   slaver_axis_tready   ,
    // input                    slaver_axis_tuser    ,
    // input                    slaver_axis_tlast    ,
    // input[KSIZE-1:0]         slaver_axis_tkeep    ,
    axi_stream_inf.slaver    slaver,
    // output[DSIZE-1:0]        master_axis_tdata    ,
    // output                   master_axis_tvalid   ,
    // input                    master_axis_tready   ,
    // output                   master_axis_tuser    ,
    // output                   master_axis_tlast    ,
    // output[KSIZE-1:0]        master_axis_tkeep
    axi_stream_inf.master    master
);

// axi_stream_inf #(
//    .DSIZE(DSIZE)
// )slaver(
//    .aclk        (slaver_aclk    ),
//    .aresetn     (slaver_aresetn  ),
//    .aclken      (1'b1    )
// );
//
// axi_stream_inf #(
//    .DSIZE(DSIZE)
// )master(
//    .aclk        (master_aclk    ),
//    .aresetn     (master_aresetn  ),
//    .aclken      (1'b1    )
// );
//
// assign      slaver.axis_tdata    = slaver_axis_tdata ;
// assign      slaver.axis_tvalid   = slaver_axis_tvalid;
// assign      slaver_axis_tready   = slaver.axis_tready;
// assign      slaver.axis_tuser    = slaver_axis_tuser ;
// assign      slaver.axis_tlast    = slaver_axis_tlast ;
// assign      slaver.axis_tkeep    = slaver_axis_tkeep ;
// // assign      slaver.axis_tcnt     = slaver_axis_tcnt  ;
//
// assign      master_axis_tdata    = master.axis_tdata ;
// assign      master_axis_tvalid   = master.axis_tvalid;
// assign      master.axis_tready   = master_axis_tready;
// assign      master_axis_tuser    = master.axis_tuser ;
// assign      master_axis_tlast    = master.axis_tlast ;
// assign      master_axis_tkeep    = master.axis_tkeep ;
// // assign      master_axis_tcnt     = master.axis_tcnt  ;

//--->> NATIVE FIFO IP <<------------------------------

// parameter LSIZE =
// (DSIZE>= 37             )?  9 :         //
// (DSIZE>= 19 && DSIZE<=36)?  9 :         //
// (DSIZE>= 10 && DSIZE<=18)? 10 :         //
// (DSIZE>=  5 && DSIZE<=9 )? 11 :         //
// (DSIZE>=  1 && DSIZE<=4 )? 12 :  1;       //

parameter LSIZE = $clog2(1024+1);

logic[LSIZE-1:0]   wcount;
logic[LSIZE-1:0]   rcount;

logic   data_fifo_full;
logic   data_fifo_empty;

// xilinx_fifo_A1 #(
xilinx_fifo_verb #(
    .DSIZE      (DSIZE  )
)stream_packet_fifo_inst (
/*  input          */ .wr_clk       (slaver.aclk        ),
/*  input          */ .wr_rst       (!slaver.aresetn    ),
/*  input          */ .rd_clk       (master.aclk       ),
/*  input          */ .rd_rst       (!master.aresetn   ),
/*  input [255:0]  */ .din          (slaver.axis_tdata  ),
/*  input          */ .wr_en        ((slaver.axis_tvalid && slaver.axis_tready)      ),
/*  input          */ .rd_en        ((master.axis_tvalid && master.axis_tready)    ),
/*  output [255:0] */ .dout         (master.axis_tdata ),
/*  output         */ .full         (data_fifo_full      ),
/*  output         */ .empty        (data_fifo_empty     ),
/* output logic[LSIZE-1:0] */  .wrcount  (wcount          ),
/* output logic[LSIZE-1:0] */  .rdcount  (rcount          )
);

always@(posedge slaver.aclk,negedge slaver.aresetn)
    if(~slaver.aresetn)  empty_size    <= '0;
    else begin
        if(data_fifo_full)
                empty_size    <= '0;
        else begin
            empty_size  <= (2**LSIZE)-wcount;
        end
    end
//---<< NATIVE FIFO IP >>------------------------------

//--->> PACKET <<--------------------------------------
logic   packet_fifo_full;
logic   packet_fifo_empty;
logic [15:0]      w_bytes_total;
logic [15:0]      r_bytes_total;
logic             w_total_eq_1;
logic             r_total_eq_1;

// assign w_total_eq_1 = w_bytes_total=='0;
assign w_total_eq_1 = slaver.axis_tcnt =='0;

localparam IDEPTH   = (DEPTH<4)? 4 : DEPTH;

independent_clock_fifo #(
    .DEPTH      (IDEPTH     ),
    .DSIZE      (16+1+CSIZE      )
)common_independent_clock_fifo_inst(
/*    input                     */  .wr_clk     (slaver.aclk        ),
/*    input                     */  .wr_rst_n   (slaver.aresetn     ),
/*    input                     */  .rd_clk     (master.aclk       ),
/*    input                     */  .rd_rst_n   (master.aresetn    ),
/*    input [DSIZE-1:0]         */  .wdata      ({w_total_eq_1,w_bytes_total,in_cdata}      ),
/*    input                     */  .wr_en      ((slaver.axis_tvalid && slaver.axis_tlast && slaver.axis_tready)      ),
/*    output logic[DSIZE-1:0]   */  .rdata      ({r_total_eq_1,r_bytes_total,out_cdata}      ),
/*    input                     */  .rd_en      ((master.axis_tvalid && master.axis_tlast && master.axis_tready)    ),
/*    output logic              */  .empty      (packet_fifo_empty   ),
/*    output logic              */  .full       (packet_fifo_full    )
);

assign slaver.axis_tready  = !packet_fifo_full && !data_fifo_full;
assign master.axis_tvalid = !packet_fifo_empty && !data_fifo_empty;
//---<< PACKET >>--------------------------------------
//--->> bytes counter <<-------------------------------
logic reset_w_bytes;
assign #1 reset_w_bytes = slaver.axis_tvalid && slaver.axis_tlast && slaver.axis_tready;

always@(posedge slaver.aclk,negedge slaver.aresetn)
    if(~slaver.aresetn)    w_bytes_total   <= '0;
    else begin
        // if(slaver.axis_tvalid && slaver.axis_tlast && slaver.axis_tready)
        if(reset_w_bytes)
                w_bytes_total   <= '0;
        else if(slaver.axis_tvalid && slaver.axis_tready)
                w_bytes_total   <= w_bytes_total + 1'b1;
        else    w_bytes_total   <= w_bytes_total;
    end

logic [15:0]    out_cnt;

always@(posedge master.aclk,negedge master.aresetn)
    if(~master.aresetn)   out_cnt <= '0;
    else begin
        if(master.axis_tvalid && master.axis_tlast && master.axis_tready)
                out_cnt   <= '0;
        else if(master.axis_tvalid && master.axis_tready)
                out_cnt   <= out_cnt + 1'b1;
        else    out_cnt   <= out_cnt;
    end
//---<< bytes counter >>-------------------------------
//--->> READ LAST <<-----------------------------------
logic   native_last;

always@(posedge master.aclk,negedge master.aresetn)
    if(~master.aresetn) native_last   <= 1'b0;
    else begin
        if(master.axis_tvalid && native_last && master.axis_tready)
                native_last <= 1'b0;
        else if(out_cnt == (r_bytes_total-1) && master.axis_tvalid  && master.axis_tready)
                native_last <= 1'b1;
        else    native_last <= native_last;
    end

assign master.axis_tlast  = native_last || r_total_eq_1;
//---<< READ LAST >>-----------------------------------
endmodule

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
creaded:
madified:
***********************************************/
`timescale 1ns/1ps
module axi_stream_packet_fifo_B1 #(
    parameter DEPTH   = 2,   //2-4
    parameter CSIZE   = 1
)(
    input [CSIZE-1:0]          in_cdata,
    output[CSIZE-1:0]          out_cdata,
    output logic[15:0]         empty_size,
    axi_stream_inf.slaver      axis_in,
    axi_stream_inf.master      axis_out
);

//--->> NATIVE FIFO IP <<------------------------------

parameter LSIZE =
(axis_in.DSIZE>= 37                     )?  9 :         //
(axis_in.DSIZE>= 19 && axis_in.DSIZE<=36)?  9 :         //
(axis_in.DSIZE>= 10 && axis_in.DSIZE<=18)? 10 :         //
(axis_in.DSIZE>=  5 && axis_in.DSIZE<=9 )? 11 :         //
(axis_in.DSIZE>=  1 && axis_in.DSIZE<=4 )? 12 :  1;       //

logic[LSIZE-1:0]   wcount;
logic[LSIZE-1:0]   rcount;

logic   data_fifo_full;
logic   data_fifo_empty;

xilinx_fifo_A1 #(
    .DSIZE      (axis_in.DSIZE  )
)stream_packet_fifo_inst (
/*  input          */ .wr_clk       (axis_in.aclk        ),
/*  input          */ .wr_rst       (!axis_in.aresetn    ),
/*  input          */ .rd_clk       (axis_out.aclk       ),
/*  input          */ .rd_rst       (!axis_out.aresetn   ),
/*  input [255:0]  */ .din          (axis_in.axis_tdata  ),
/*  input          */ .wr_en        ((axis_in.axis_tvalid && axis_in.axis_tready)      ),
/*  input          */ .rd_en        ((axis_out.axis_tvalid && axis_out.axis_tready)    ),
/*  output [255:0] */ .dout         (axis_out.axis_tdata ),
/*  output         */ .full         (data_fifo_full      ),
/*  output         */ .empty        (data_fifo_empty     ),
/* output logic[LSIZE-1:0] */  .wcount  (wcount          ),
/* output logic[LSIZE-1:0] */  .rcount  (rcount          )
);

always@(posedge axis_in.aclk,negedge axis_in.aresetn)
    if(~axis_in.aresetn)  empty_size    <= '0;
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

assign w_total_eq_1 = w_bytes_total=='0;

localparam IDEPTH   = (DEPTH<4)? 4 : DEPTH;

independent_clock_fifo #(
    .DEPTH      (IDEPTH     ),
    .DSIZE      (16+1+CSIZE      )
)common_independent_clock_fifo_inst(
/*    input                     */  .wr_clk     (axis_in.aclk        ),
/*    input                     */  .wr_rst_n   (axis_in.aresetn     ),
/*    input                     */  .rd_clk     (axis_out.aclk       ),
/*    input                     */  .rd_rst_n   (axis_out.aresetn    ),
/*    input [DSIZE-1:0]         */  .wdata      ({w_total_eq_1,w_bytes_total,in_cdata}      ),
/*    input                     */  .wr_en      ((axis_in.axis_tvalid && axis_in.axis_tlast && axis_in.axis_tready)      ),
/*    output logic[DSIZE-1:0]   */  .rdata      ({r_total_eq_1,r_bytes_total,out_cdata}      ),
/*    input                     */  .rd_en      ((axis_out.axis_tvalid && axis_out.axis_tlast && axis_out.axis_tready)    ),
/*    output logic              */  .empty      (packet_fifo_empty   ),
/*    output logic              */  .full       (packet_fifo_full    )
);

assign axis_in.axis_tready  = !packet_fifo_full && !data_fifo_full;
assign axis_out.axis_tvalid = !packet_fifo_empty && !data_fifo_empty;
//---<< PACKET >>--------------------------------------
//--->> bytes counter <<-------------------------------
logic reset_w_bytes;
assign #1 reset_w_bytes = axis_in.axis_tvalid && axis_in.axis_tlast && axis_in.axis_tready;

always@(posedge axis_in.aclk,negedge axis_in.aresetn)
    if(~axis_in.aresetn)    w_bytes_total   <= '0;
    else begin
        // if(axis_in.axis_tvalid && axis_in.axis_tlast && axis_in.axis_tready)
        if(reset_w_bytes)
                w_bytes_total   <= '0;
        else if(axis_in.axis_tvalid && axis_in.axis_tready)
                w_bytes_total   <= w_bytes_total + 1'b1;
        else    w_bytes_total   <= w_bytes_total;
    end

logic [15:0]    out_cnt;

always@(posedge axis_out.aclk,negedge axis_out.aresetn)
    if(~axis_out.aresetn)   out_cnt <= '0;
    else begin
        if(axis_out.axis_tvalid && axis_out.axis_tlast && axis_out.axis_tready)
                out_cnt   <= '0;
        else if(axis_out.axis_tvalid && axis_out.axis_tready)
                out_cnt   <= out_cnt + 1'b1;
        else    out_cnt   <= out_cnt;
    end
//---<< bytes counter >>-------------------------------
//--->> READ LAST <<-----------------------------------
logic   native_last;

always@(posedge axis_out.aclk,negedge axis_out.aresetn)
    if(~axis_out.aresetn) native_last   <= 1'b0;
    else begin
        if(axis_out.axis_tvalid && native_last && axis_out.axis_tready)
                native_last <= 1'b0;
        else if(out_cnt == (r_bytes_total-1) && axis_out.axis_tvalid  && axis_out.axis_tready)
                native_last <= 1'b1;
        else    native_last <= native_last;
    end

assign axis_out.axis_tlast  = native_last || r_total_eq_1;
//---<< READ LAST >>-----------------------------------
endmodule

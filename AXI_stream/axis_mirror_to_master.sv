/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2018/1/30 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axis_mirror_to_master #(
    parameter DEPTH = 4
)(
    (* up_stream = "true" *)
    axi_stream_inf.mirror   mirror,
    (* down_stream = "true" *)
    axi_stream_inf.master   master
);

initial begin
    assert(mirror.DSIZE == master.DSIZE)
    else begin
        $error("mirror DSIZE[%d] MUST EQL master DSIZE[%d]",mirror.DSIZE,master.DSIZE);
        $stop;
    end
end


logic       packet_fifo_full;
logic       packet_fifo_empty;
logic       data_fifo_full;
logic       data_fifo_empty;
// logic       axis_tcnt_rd_data;

logic           w_total_eq_1;
logic           r_total_eq_1;

logic [15:0]    w_bytes_total;
logic [15:0]    r_bytes_total;

assign  w_total_eq_1 = mirror.axis_tlast && (mirror.axis_tcnt == 0);

always@(posedge mirror.aclk,negedge mirror.aresetn)
    if(~mirror.aresetn)
        w_bytes_total    <= '0;
    else begin
        if(mirror.axis_tvalid && mirror.axis_tready && mirror.axis_tlast && !data_fifo_full && !packet_fifo_full)
            w_bytes_total   <= '0;
        else if(mirror.axis_tvalid && mirror.axis_tready && !data_fifo_full && !packet_fifo_full)
            w_bytes_total   <= w_bytes_total + 1'b1;
        else
            w_bytes_total   <= w_bytes_total;
    end

independent_clock_fifo #(
    .DEPTH      (DEPTH     ),
    .DSIZE      (1+16      )
)independent_clock_fifo_inst(
/*    input                     */  .wr_clk     (mirror.aclk        ),
/*    input                     */  .wr_rst_n   (mirror.aresetn     ),
/*    input                     */  .rd_clk     (master.aclk        ),
/*    input                     */  .rd_rst_n   (master.aresetn     ),
/*    input [DSIZE-1:0]         */  .wdata      ({w_total_eq_1,w_bytes_total}      ),
/*    input                     */  .wr_en      ((mirror.axis_tvalid && mirror.axis_tlast && mirror.axis_tready && !data_fifo_full && !packet_fifo_full)      ),
/*    output logic[DSIZE-1:0]   */  .rdata      ({r_total_eq_1,r_bytes_total}      ),
/*    input                     */  .rd_en      ((master.axis_tvalid && master.axis_tlast && master.axis_tready)      ),
/*    output logic              */  .empty      (packet_fifo_empty   ),
/*    output logic              */  .full       (packet_fifo_full    )
);

logic [mirror.DSIZE + mirror.KSIZE + 1 - 1 :0 ]   stream_fifo_data;

xilinx_fifo_verb #(
//xilinx_fifo #(
    .DSIZE      (mirror.DSIZE + mirror.KSIZE + 1)
) stream_packet_fifo_inst (
/*  input          */ .wr_clk       (mirror.aclk       ),
/*  input          */ .wr_rst       (!mirror.aresetn   ),
/*  input          */ .rd_clk       (master.aclk       ),
/*  input          */ .rd_rst       (!master.aresetn   ),
/*  input [255:0]  */ .din          ({mirror.axis_tuser,mirror.axis_tkeep,mirror.axis_tdata}  ),
/*  input          */ .wr_en        ((mirror.axis_tvalid && mirror.axis_tready && !packet_fifo_full && !data_fifo_full)    ),
/*  input          */ .rd_en        ((master.axis_tvalid && master.axis_tready && !packet_fifo_empty)   ),
/*  output [255:0] */ .dout         (stream_fifo_data    ),
/*  output         */ .full         (data_fifo_full      ),
/*  output         */ .empty        (data_fifo_empty     ),
/*  output         */ .rdcount      (),
/*  output         */ .wrcount      ()
);

assign {master.axis_tuser,master.axis_tkeep,master.axis_tdata} = stream_fifo_data;
assign master.axis_tvalid   = !data_fifo_empty && !packet_fifo_empty;

//--->> bytes counter <<-------------------------------

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

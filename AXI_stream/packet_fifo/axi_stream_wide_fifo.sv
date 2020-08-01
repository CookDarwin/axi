/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0 2018/2/28 
    use wide_fifo
creaded: 2018/2/28 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axi_stream_wide_fifo #(
    parameter DEPTH          = 2
)(
    (* up_stream = "true" *)
    axi_stream_inf.slaver      axis_in,
    (* down_stream = "true" *)
    axi_stream_inf.master      axis_out
);

initial begin
    assert(axis_in.DSIZE == axis_out.DSIZE)
    else begin
        $error("\naxis_in.DSIZE[%d] MUST EQL axis_out.DSIZE[%d]\n",axis_in.DSIZE,axis_out.DSIZE);
        $stop;
    end
    assert(axis_in.DSIZE+axis_in.KSIZE >= 64)
    else begin
        $error("\nAXIS DSIZE[%d] MUST BE LARGE THAN 64\n",axis_in.DSIZE);
        $stop;
    end
end


//--->> NATIVE FIFO IP <<------------------------------
logic   data_fifo_full;
logic   data_fifo_empty;

wide_fifo #(
    .DSIZE      (axis_in.DSIZE+axis_in.KSIZE+1      )
)wide_fifo_inst(
/*  input               */ .wr_clk       (axis_in.aclk          ),
/*  input               */ .wr_rst       (!axis_in.aresetn      ),
/*  input               */ .rd_clk       (axis_out.aclk         ),
/*  input               */ .rd_rst       (!axis_out.aresetn     ),
/*  input [DSIZE-1:0]   */ .din          ({axis_in.axis_tuser,axis_in.axis_tkeep,axis_in.axis_tdata}    ),
/*  input               */ .wr_en        ((axis_in.axis_tvalid && axis_in.axis_tready)  ),
/*  input               */ .rd_en        ((axis_out.axis_tvalid && axis_out.axis_tready)),
/*  output [DSIZE-1:0]  */ .dout         ({axis_out.axis_tuser,axis_out.axis_tkeep,axis_out.axis_tdata}   ),
/*  output              */ .full         (data_fifo_full        ),
/*  output              */ .empty        (data_fifo_empty       )
);
//---<< NATIVE FIFO IP >>------------------------------

//--->> PACKET <<--------------------------------------
logic   packet_fifo_full;
logic   packet_fifo_empty;
logic [31:0]      w_bytes_total;
logic [31:0]      r_bytes_total;
logic             w_total_eq_1;
logic             r_total_eq_1;

assign w_total_eq_1 = w_bytes_total=='0;

localparam IDEPTH   = (DEPTH<4)? 4 : DEPTH;

independent_clock_fifo #(
    .DEPTH      (IDEPTH     ),
    .DSIZE      (32+1      )
)independent_clock_fifo_inst(
/*    input                     */  .wr_clk     (axis_in.aclk        ),
/*    input                     */  .wr_rst_n   (axis_in.aresetn     ),
/*    input                     */  .rd_clk     (axis_out.aclk       ),
/*    input                     */  .rd_rst_n   (axis_out.aresetn    ),
/*    input [DSIZE-1:0]         */  .wdata      ({w_total_eq_1,w_bytes_total}      ),
/*    input                     */  .wr_en      ((axis_in.axis_tvalid && axis_in.axis_tlast && axis_in.axis_tready)      ),
/*    output logic[DSIZE-1:0]   */  .rdata      ({r_total_eq_1,r_bytes_total}      ),
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

logic [31:0]    out_cnt;

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
//--->> SIM TRACK <<-----------------------------------
// always@(negedge axis_out.aclk)begin
//     if(axis_out.axis_tvalid && axis_out.axis_tready)begin
//         if((out_cnt[7:0] != axis_out.axis_tdata[7:0] + 8) && (out_cnt[7:0] > 8))begin
//             // #(10us)
//             $stop;
//             #(1us);
//         end
//     end
// end

endmodule

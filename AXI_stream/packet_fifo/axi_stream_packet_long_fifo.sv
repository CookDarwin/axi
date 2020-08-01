/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: ###### Thu Apr 30 11:38:38 CST 2020
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axi_stream_packet_long_fifo #(
    parameter DEPTH         = 2,   //2-4
    parameter BYTE_DEPTH    = 8096
)(
    (* up_stream = "true" *)
    axi_stream_inf.slaver      axis_in,
    (* down_stream = "true" *)
    axi_stream_inf.master      axis_out
);

//--->> NATIVE FIFO IP <<------------------------------
// (* dont_touch = "true" *)
logic   data_fifo_full;
// (* dont_touch = "true" *)
logic   data_fifo_empty;
logic [axis_in.DSIZE-1:0]   stream_fifo_data;

fifo_36kb_long #(
    .DSIZE      (axis_out.DSIZE ),
    .DEPTH      (BYTE_DEPTH     )
)fifo_36kb_long_inst(
/*  input              */  .wr_clk      (axis_in.aclk       ),
/*  input              */  .wr_rst      (~axis_in.aresetn   ),
/*  input              */  .rd_clk      (axis_out.aclk      ),
/*  input              */  .rd_rst      (~axis_out.aresetn  ),
/*  input [DSIZE-1:0]  */  .din         (axis_in.axis_tdata ),
/*  input              */  .wr_en       ((axis_in.axis_tvalid && !data_fifo_full && axis_in.axis_tready)             ),
/*  input              */  .rd_en       ((axis_out.axis_tvalid && !data_fifo_empty && axis_out.axis_tready)          ),
/*  output [DSIZE-1:0] */  .dout        (axis_out.axis_tdata    ),
/*  output             */  .full        (data_fifo_full         ),
/*  output             */  .empty       (data_fifo_empty        )
);

// assign axis_out.axis_tdata = axis_out.axis_tvalid? stream_fifo_data : '0;
//---<< NATIVE FIFO IP >>------------------------------

//--->> PACKET <<--------------------------------------
// (* dont_touch = "true" *)
logic   packet_fifo_full;
// (* dont_touch = "true" *)
logic   packet_fifo_empty;
logic [15:0]      w_bytes_total;
logic [15:0]      r_bytes_total;
logic             w_total_eq_1;
logic             r_total_eq_1;

assign w_total_eq_1 = w_bytes_total=='0;

localparam IDEPTH   = (DEPTH<4)? 4 : DEPTH;

independent_clock_fifo #(
    .DEPTH      (IDEPTH     ),
    .DSIZE      (16+1      )
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

logic   cc_fifo_wr_data;
logic   cc_fifo_rd_data;
logic   cc_fifo_wr_en;
logic   cc_fifo_rd_en;
logic   cc_fifo_full;
logic   cc_fifo_empty;

independent_clock_fifo #(
    .DEPTH      (IDEPTH    ),
    .DSIZE      (1         )
)independent_clock_delay_cc_wr_fifo_inst(
/*    input                     */  .wr_clk     (axis_in.aclk        ),
/*    input                     */  .wr_rst_n   (axis_in.aresetn     ),
/*    input                     */  .rd_clk     (axis_out.aclk       ),
/*    input                     */  .rd_rst_n   (axis_out.aresetn    ),
/*    input [DSIZE-1:0]         */  .wdata      (cc_fifo_wr_data     ),
/*    input                     */  .wr_en      (cc_fifo_wr_en       ),
/*    output logic[DSIZE-1:0]   */  .rdata      (cc_fifo_rd_data     ),
/*    input                     */  .rd_en      (cc_fifo_rd_en       ),
/*    output logic              */  .empty      (cc_fifo_empty       ),
/*    output logic              */  .full       (cc_fifo_full        )
);

assign  cc_fifo_wr_en   = 1'b1;
assign  cc_fifo_wr_data = (axis_in.axis_tvalid && axis_in.axis_tlast && axis_in.axis_tready);

assign  cc_fifo_rd_en   = 1'b1;

logic   cc_fifo_rd_data_lat;

latency #(
    .LAT            (6),
    .DSIZE          (1)
)latency_inst(
/*  input             */   .clk     (axis_out.aclk      ),
/*  input             */   .rst_n   (axis_out.aresetn   ),
/*  input [DSIZE-1:0] */   .d       (cc_fifo_rd_data    ),
/*  output[DSIZE-1:0] */   .q       (cc_fifo_rd_data_lat)
);

logic   delay_fifo_empty;
logic   delay_fifo_full;

independent_clock_fifo #(
    .DEPTH      (IDEPTH    ),
    .DSIZE      (1         )
)independent_clock_delay_fifo_inst(
/*    input                     */  .wr_clk     (axis_out.aclk       ),
/*    input                     */  .wr_rst_n   (axis_out.aresetn    ),
/*    input                     */  .rd_clk     (axis_out.aclk       ),
/*    input                     */  .rd_rst_n   (axis_out.aresetn    ),
/*    input [DSIZE-1:0]         */  .wdata      (1'b0                ),
/*    input                     */  .wr_en      (cc_fifo_rd_data_lat ),
/*    output logic[DSIZE-1:0]   */  .rdata      (),
/*    input                     */  .rd_en      ((axis_out.axis_tvalid && axis_out.axis_tlast && axis_out.axis_tready)    ),
/*    output logic              */  .empty      (delay_fifo_empty    ),
/*    output logic              */  .full       (delay_fifo_full     )
);

assign axis_in.axis_tready  = !packet_fifo_full && !data_fifo_full;
assign axis_out.axis_tvalid = !packet_fifo_empty && !data_fifo_empty && !delay_fifo_empty;
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
//--- >> ASSER <<--------------------------------------
initial begin
    wait(axis_out.aresetn);
    forever begin 
        repeat(10)
            @(posedge axis_out.aclk);
        wait(data_fifo_full);
        assert(packet_fifo_full == 1) else begin 
            $error("long fifo full ,data stream is too long");
            $stop;
        end
    end
end
//--- << ASSER >>--------------------------------------
endmodule

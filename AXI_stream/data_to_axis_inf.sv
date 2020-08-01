/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/3/29 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module data_to_axis_inf (
    input   mark_curr_data,
    input   last_flag,
    data_inf_c.slaver       data_slaver,
    axi_stream_inf.master   axis_master
);

logic   data_fifo_empty;
logic   data_fifo_full;
logic   data_fifo_wen;
logic   data_fifo_ren;

xilinx_fifo_verb #(
// xilinx_fifo #(
    .DSIZE      (axis_master.DSIZE  )
)xilinx_fifo_inst(
/*  input             */  .wr_clk   (data_slaver.clock      ),
/*  input             */  .wr_rst   (!data_slaver.rst_n     ),
/*  input             */  .rd_clk   (axis_master.aclk       ),
/*  input             */  .rd_rst   (!axis_master.aresetn   ),
/*  input [DSIZE-1:0] */  .din      (data_slaver.data       ),
/*  input             */  .wr_en    (data_fifo_wen          ),
/*  input             */  .rd_en    (data_fifo_ren          ),
/*  output [DSIZE-1:0]*/  .dout     (axis_master.axis_tdata ),
/*  output            */  .full     (data_fifo_full         ),
/*  output            */  .empty    (data_fifo_empty        )
);

assign  data_fifo_ren   = axis_master.axis_tvalid && axis_master.axis_tready;
assign  data_fifo_wen   = data_slaver.valid && data_slaver.ready && !mark_curr_data;

logic [23:0]    data_length;

always@(posedge data_slaver.clock,negedge data_slaver.rst_n)
    if(~data_slaver.rst_n)  data_length <= '0;
    else begin
        if(last_flag && data_slaver.valid && data_slaver.ready)
                data_length <= '0;
        else if(data_slaver.valid && data_slaver.ready && !mark_curr_data)
                data_length <= data_length + 1'b1;
        else    data_length <= data_length;
    end

logic           have_data;

always@(posedge data_slaver.clock,negedge data_slaver.rst_n)
    if(~data_slaver.rst_n)  have_data   <= 1'b0;
    else begin
        if(last_flag && data_slaver.valid && data_slaver.ready)
                have_data   <= 1'b0;
        else if(data_slaver.valid && data_slaver.ready && !mark_curr_data)
                have_data   <= 1'b1;
        else    have_data   <= have_data;
    end

logic [24:0]    wr_data_length;

assign  wr_data_length[23:0]  = mark_curr_data? data_length-1 : data_length;
assign  wr_data_length[24]    = last_flag && data_slaver.valid && data_slaver.ready && !mark_curr_data && data_length == '0;

logic [23:0]    rd_data_length;
logic           rd_len_eq_1;

logic           last_fifo_empty;
logic           last_fifo_full;
logic           last_wr_en;

assign  last_wr_en  = (last_flag && data_slaver.valid && data_slaver.ready) && (have_data || !mark_curr_data);

independent_clock_fifo #(
    .DEPTH     (4       ),
    .DSIZE     (25      )
)last_independent_clock_fifo_inst(
/*  input                   */  .wr_clk         (data_slaver.clock      ),
/*  input                   */  .wr_rst_n       (data_slaver.rst_n      ),
/*  input                   */  .rd_clk         (axis_master.aclk       ),
/*  input                   */  .rd_rst_n       (axis_master.aresetn    ),
/*  input [DSIZE-1:0]       */  .wdata          (wr_data_length         ),
/*  input                   */  .wr_en          (last_wr_en             ),
/*  output logic[DSIZE-1:0] */  .rdata          ({rd_len_eq_1,rd_data_length}),
/*  input                   */  .rd_en          ((axis_master.axis_tvalid && axis_master.axis_tready && axis_master.axis_tlast)),
/*  output logic            */  .empty          (last_fifo_empty        ),
/*  output logic            */  .full           (last_fifo_full         )
);

assign  axis_master.axis_tvalid     = !last_fifo_empty;
assign  axis_master.axis_tlast      = rd_len_eq_1 || axis_master.axis_tcnt  == rd_data_length;

assign data_slaver.ready            = !last_fifo_full && !data_fifo_full;

endmodule

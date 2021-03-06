/**********************************************
______________   ______________
______________ X ______________
______________  ______________

descript:
author : Cook.Darwin
Version: VERA.0.1 2018-6-3 14:42:19
    add idle lock
creaded: 2017/5/19 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axis_length_split_with_addr #(
    parameter ADDR_STEP = 1024      //1024 := 1
)(
    input [31:0]           origin_addr,
    input [31:0]           length,
    output logic[31:0]     band_addr,
    (* up_stream = "true" *)
    axi_stream_inf.slaver  axis_in,
    (* down_stream = "true" *)
    axi_stream_inf.master  axis_out
);

// localparam ADDR_STEP_INT = int'(ADDR_STEP*1024);

wire    clock,rst_n,clken;
logic  [31:0]   cur_addr;

assign  clock   = axis_in.aclk;
assign  rst_n   = axis_in.aresetn;
assign  clken   = axis_in.aclken;

axi_stream_inf #(.DSIZE(axis_in.DSIZE)) axis_pre (.aclk(clock),.aresetn(rst_n),.aclken(clken));


logic [31:0]        cnt;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  cnt     <= '0;
    else begin
        if(axis_in.axis_tvalid  && axis_in.axis_tready && axis_in.axis_tlast)
                cnt     <= '0;
        else if(axis_in.axis_tvalid  && axis_in.axis_tready && (cnt >= (length-1)))
                cnt     <= '0;
        else if(axis_in.axis_tvalid  && axis_in.axis_tready)
                cnt     <= cnt + 1'b1;
        else    cnt     <= cnt;
    end

logic   new_last;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  new_last    <= 1'b0;
    else begin
        if(axis_in.axis_tvalid  && axis_in.axis_tready && (new_last||axis_in.axis_tlast))
                new_last    <= 1'b0;
        else if(axis_in.axis_tvalid  && axis_in.axis_tready && cnt==(length-2))
                new_last    <= 1'b1;
        else    new_last    <= new_last;
    end

// logic   mark_tail;
//
// always@(posedge clock,negedge rst_n)
//     if(~rst_n)  mark_tail   <= 1'b0;
//     else begin
//         if(axis_in.axis_tvalid  && axis_in.axis_tready && axis_in.axis_tlast)
//                 mark_tail   <= 1'b0;
//         else if(axis_in.axis_tvalid  && axis_in.axis_tready && axis_in.axis_tcnt==(length-1))
//                 mark_tail   <= 1'b1;
//         else    mark_tail   <= mark_tail;
//     end

assign axis_pre.axis_tvalid = axis_in.axis_tvalid;
assign axis_pre.axis_tdata  = axis_in.axis_tdata;
assign axis_pre.axis_tlast  = new_last || axis_in.axis_tlast;
assign axis_pre.axis_tkeep  = axis_in.axis_tkeep;
assign axis_pre.axis_tuser  = axis_in.axis_tuser;

assign axis_in.axis_tready  = axis_pre.axis_tready;

// axis_connect_pipe #(
//     .DSIZE      (axis_in.DSIZE)
// )axis_connect_pipe_inst(
// /*  axi_stream_inf.slaver  */  .axis_in     (axis_pre   ),
// /*  axi_stream_inf.master  */  .axis_out    (axis_out   )
// );

axis_connect_pipe_with_info #(
    .IFSIZE (32)
)axis_connect_pipe_with_info_inst(
/*  input [IFSIZE-1:0]       */  .info_in       (cur_addr   ),
/*  output logic[IFSIZE-1:0] */  .info_out      (band_addr  ),
/*  axi_stream_inf.slaver    */  .axis_in       (axis_pre   ),
/*  axi_stream_inf.master    */  .axis_out      (axis_out   )
);

//--->> ADDR CAL <<---------------------------
logic   idle_lock_addr;
always@(posedge clock,negedge rst_n)
    if(~rst_n)  idle_lock_addr  <= 1'b0;
    else begin
        if(axis_in.axis_tvalid && axis_in.axis_tready && axis_in.axis_tlast)
                idle_lock_addr  <= 1'b0;
        else if(axis_in.axis_tvalid && axis_in.axis_tready)
                idle_lock_addr  <= 1'b1;
        else    idle_lock_addr  <= idle_lock_addr;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  cur_addr    <= origin_addr;
    else begin
        if(axis_in.axis_tvalid && axis_in.axis_tready && axis_in.axis_tlast)
                cur_addr    <= origin_addr;
        // else if(axis_in.axis_tvalid  && axis_in.axis_tready && cnt==(length-2))
        else if(axis_in.axis_tvalid  && axis_in.axis_tready && new_last)
                cur_addr    <= origin_addr + ((axis_in.axis_tcnt+1)*ADDR_STEP)/1024;
        else if(!idle_lock_addr && !axis_in.axis_tvalid)
                cur_addr    <= origin_addr;
        else    cur_addr    <= cur_addr;
    end


endmodule

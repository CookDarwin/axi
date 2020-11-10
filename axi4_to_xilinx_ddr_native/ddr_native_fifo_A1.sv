/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.1.0
    regenerate axis_rd_inf.axis_tlast
creaded: 2018/11/26 
madified:
***********************************************/
`timescale 1ns / 1ps
module ddr_native_fifo_A1 #(
    parameter ADDR_WIDTH            = 27,
    parameter DATA_WIDTH            = 256
)(
    axi_stream_inf.slaver           axis_inf,
    axi_stream_inf.master           axis_rd_inf,
    //---DDR IP
    output logic[ADDR_WIDTH-1:0]    app_addr,
    output logic[2:0]               app_cmd,
    output logic                    app_en,
    output logic[DATA_WIDTH-1:0]    app_wdf_data,
    output logic                    app_wdf_end,
    output logic[DATA_WIDTH/8-1:0]  app_wdf_mask,
    output logic                    app_wdf_wren,
    input  [DATA_WIDTH-1:0]         app_rd_data,
    input                           app_rd_data_end,
    input                           app_rd_data_valid,
    input                           app_rdy,
    input                           app_wdf_rdy,
    input logic                     init_calib_complete
);

assign  app_wdf_mask    = '0;
assign  app_wdf_end     = 1'b1;


initial begin
    assert(axis_inf.DSIZE == (ADDR_WIDTH + DATA_WIDTH + 3))
    else begin
        $error("axis_inf.DSIZE#%0d != (3 + ADDR_WIDTH#%0d + DATA_WIDTH#%0d)",axis_inf.DSIZE,ADDR_WIDTH,DATA_WIDTH);
        $stop;
    end
end

logic       clock,rst_n;
assign  clock   = axis_inf.aclk;
assign  rst_n   = axis_inf.aresetn;

logic   aux_fifo_empty;
logic   aux_fifo_full;
logic   aux_fifo_wr_en;
logic   aux_fifo_rd_en;
logic [ADDR_WIDTH + 3 -1:0]  aux_fifo_wdata,aux_fifo_rdata;

common_fifo #(
    .DEPTH      ( 4     ),
    .DSIZE      (ADDR_WIDTH + 3 )
)common_fifo_addr_inst(
/*  input                   */    .clock        (clock          ),
/*  input                   */    .rst_n        (rst_n          ),
/*  input [DSIZE-1:0]       */    .wdata        (aux_fifo_wdata ),
/*  input                   */    .wr_en        (aux_fifo_wr_en ),
/*  output logic[DSIZE-1:0] */    .rdata        (aux_fifo_rdata ),
/*  input                   */    .rd_en        (aux_fifo_rd_en ),
/*  output logic[CSIZE-1:0] */    .count        (),
/*  output logic            */    .empty        (aux_fifo_empty ),
/*  output logic            */    .full         (aux_fifo_full  )
);

assign  aux_fifo_wdata  =   axis_inf.axis_tdata[DATA_WIDTH +: (ADDR_WIDTH+3)];
assign  aux_fifo_wr_en  =   axis_inf.axis_tvalid && axis_inf.axis_tready;

//-->> DATA
logic   w_fifo_empty;
logic   w_fifo_full;
logic   w_fifo_wr_en;
logic   w_fifo_rd_en;
logic [DATA_WIDTH-1:0]  w_fifo_wdata,w_fifo_rdata;

common_fifo #(
    .DEPTH      ( 4     ),
    .DSIZE      (DATA_WIDTH )
)common_fifo_data_inst(
/*  input                   */    .clock        (clock          ),
/*  input                   */    .rst_n        (rst_n          ),
/*  input [DSIZE-1:0]       */    .wdata        (w_fifo_wdata   ),
/*  input                   */    .wr_en        (w_fifo_wr_en   ),
/*  output logic[DSIZE-1:0] */    .rdata        (w_fifo_rdata   ),
/*  input                   */    .rd_en        (w_fifo_rd_en   ),
/*  output logic[CSIZE-1:0] */    .count        (),
/*  output logic            */    .empty        (w_fifo_empty ),
/*  output logic            */    .full         (w_fifo_full  )
);

assign  axis_inf.axis_tready    = !aux_fifo_full && !w_fifo_full;

assign  w_fifo_wdata    = axis_inf.axis_tdata[DATA_WIDTH-1:0];
assign  w_fifo_wr_en    = aux_fifo_wr_en && axis_inf.axis_tdata[(DATA_WIDTH + ADDR_WIDTH) +: 3] == 3'b000;
assign  app_wdf_data    = w_fifo_rdata;
assign  app_wdf_wren    = !w_fifo_empty;
assign  w_fifo_rd_en    = (app_wdf_wren && app_wdf_rdy);

//-- APP
assign  app_en          = !aux_fifo_empty;
assign  aux_fifo_rd_en  = app_rdy && app_en;
assign  app_cmd         = aux_fifo_rdata[ADDR_WIDTH +: 3];
assign  app_addr        = aux_fifo_rdata[ADDR_WIDTH-1:0];

//-->> STACK
logic   rd_fifo_empty;
logic   rd_fifo_full;
logic   rd_fifo_wr_en;
logic   rd_fifo_rd_en;
logic [8+2:0]  rd_fifo_wdata,rd_fifo_rdata;

common_fifo #(
    .DEPTH      ( 8     ),
    .DSIZE      ( 9+2     )
)common_fifo_rd_last_inst(
/*  input                   */    .clock        (clock          ),
/*  input                   */    .rst_n        (rst_n          ),
/*  input [DSIZE-1:0]       */    .wdata        (rd_fifo_wdata ),
/*  input                   */    .wr_en        (rd_fifo_wr_en ),
/*  output logic[DSIZE-1:0] */    .rdata        (rd_fifo_rdata ),
/*  input                   */    .rd_en        (rd_fifo_rd_en ),
/*  output logic[CSIZE-1:0] */    .count        (),
/*  output logic            */    .empty        (rd_fifo_empty ),
/*  output logic            */    .full         (rd_fifo_full  )
);

assign  rd_fifo_wdata   = {axis_inf.axis_tcnt[8:0]};
assign  rd_fifo_wr_en   = axis_inf.axis_tvalid && axis_inf.axis_tready && axis_inf.axis_tlast && axis_inf.axis_tdata[(DATA_WIDTH + ADDR_WIDTH) +: 3] == 3'b001;
assign  rd_fifo_rd_en   = axis_rd_inf.axis_tvalid && axis_rd_inf.axis_tlast;

// read valid conter
logic[8+2:0]      rd_vld_cnt;
always@(posedge clock,negedge rst_n)
    if(~rst_n)  rd_vld_cnt  <= '0;
    else begin 
        if(axis_rd_inf.axis_tvalid && axis_rd_inf.axis_tlast)
                rd_vld_cnt  <= '0;
        else if(axis_rd_inf.axis_tvalid)
                rd_vld_cnt  <= rd_vld_cnt + 1'b1; 
        else    rd_vld_cnt  <= rd_vld_cnt;
    end 

always@(posedge clock,negedge rst_n)
    if(~rst_n)  axis_rd_inf.axis_tlast  <= 1'b0;
    else begin
        if(!rd_fifo_empty && rd_fifo_rdata == '0)
        // if(axis_rd_inf.axis_tvalid && axis_rd_inf.axis_tready && axis_rd_inf.axis_tlast && axis_rd_inf.axis_tcnt == '0)
                axis_rd_inf.axis_tlast  <= 1'b1;
        else if(axis_rd_inf.axis_tvalid && axis_rd_inf.axis_tready && axis_rd_inf.axis_tlast)
                axis_rd_inf.axis_tlast  <= 1'b0;
        else if(axis_rd_inf.axis_tvalid && rd_vld_cnt >= (rd_fifo_rdata-9'd1) && !rd_fifo_empty)
                axis_rd_inf.axis_tlast  <= 1'b1;
        else    axis_rd_inf.axis_tlast  <= axis_rd_inf.axis_tlast;
    end

//-- APP
assign  axis_rd_inf.axis_tdata  = app_rd_data;
assign  axis_rd_inf.axis_tvalid = app_rd_data_valid;
assign  axis_rd_inf.axis_tkeep  = '1;
assign  axis_rd_inf.axis_tuser  = '0;


// data overflow
(* dont_touch = "true" *)logic   rd_data_overflow;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  rd_data_overflow    <= 1'b0;
    else begin 
        if(axis_rd_inf.axis_tvalid && ~axis_rd_inf.axis_tready)
                rd_data_overflow    <= 1'b1;
        else    rd_data_overflow    <= rd_data_overflow;
    end

endmodule

/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
    xilinx fifo ip wrapper
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/3/1 
madified:
***********************************************/
`timescale 1ns/1ps
`include "define_macro.sv"
module xilinx_fifo #(
    `parameter_string ENABLE_SIM = "FALSE",
    parameter DSIZE = 128
)(
    input               wr_clk,
    input               wr_rst,
    input               rd_clk,
    input               rd_rst,
    input [DSIZE-1:0]   din   ,
    input               wr_en ,
    input               rd_en ,
    output [DSIZE-1:0]  dout  ,
    output              full  ,
    output              empty
);

logic rd_rst_Q,wr_rst_Q;

xilinx_reset_sync xilinx_reset_sync_winst (
    .clk       (wr_clk             ),
    .enable    (1'b1               ),
    .reset_in  (wr_rst | rd_rst    ),
    .reset_out (wr_rst_Q           )
);

xilinx_reset_sync xilinx_reset_sync_rinst (
    .clk       (rd_clk             ),
    .enable    (1'b1               ),
    .reset_in  (wr_rst | rd_rst    ),
    .reset_out (rd_rst_Q           )
);
// import SystemPkg::*;

logic [2:0]     wcnt;
logic [2:0]     rcnt;

always@(posedge wr_clk,posedge wr_rst_Q)
    if(wr_rst_Q) wcnt    <= '0;
    else  begin
        // if(rd_rst_Q)
        if(0)
                wcnt    <= '0;
        else if(wcnt != 3'b111)
                wcnt    <= wcnt + 1'b1;
        else    wcnt    <= wcnt;
    end

always@(posedge rd_clk,posedge rd_rst_Q)
    if(rd_rst_Q) rcnt    <= '0;
    else  begin
        // if(wr_rst_Q)
        if(0)
                rcnt    <= '0;
        else if(rcnt != 3'b111)
                rcnt    <= rcnt + 1'b1;
        else    rcnt    <= rcnt;
    end

logic   en_wr_en,en_rd_en;

always@(posedge wr_clk,posedge wr_rst_Q)
    if(wr_rst_Q) en_wr_en    <= 1'b0;
    else begin
        if(wcnt == 3'b111)
                en_wr_en    <= 1'b1;
        else    en_wr_en    <= 1'b0;
    end

always@(posedge rd_clk,posedge rd_rst_Q)
    if(rd_rst_Q) en_rd_en    <= 1'b0;
    else begin
        if(rcnt == 3'b111)
                en_rd_en    <= 1'b1;
        else    en_rd_en    <= 1'b0;
    end

generate
if(ENABLE_SIM == "TRUE")
independent_clock_fifo #(
    .DEPTH          (8      ),
    .DSIZE          (DSIZE  )
)fifo_inst(
/*  input                   */    .wr_clk       (wr_clk             ),
/*  input                   */    .wr_rst_n     (!wr_rst_Q          ),
/*  input                   */    .rd_clk       (rd_clk             ),
/*  input                   */    .rd_rst_n     (!rd_rst_Q          ),
/*  input [DSIZE-1:0]       */    .wdata        (din                ),
/*  input                   */    .wr_en        ((wr_en && en_wr_en)),
/*  output logic[DSIZE-1:0] */    .rdata        (dout               ),
/*  input                   */    .rd_en        ((rd_en && en_rd_en)),
/*  output logic            */    .empty        (empty              ),
/*  output logic            */    .full         (full               )
);
else if(DSIZE<37)
fifo_36bit #(
    .DSIZE      (DSIZE  )
)fifo_inst(
/*    input              */ .wr_clk             (wr_clk     ),
/*    input              */ .wr_rst             (wr_rst_Q   ),
/*    input              */ .rd_clk             (rd_clk     ),
/*    input              */ .rd_rst             (rd_rst_Q   ),
/*    input [DSIZE-1:0]  */ .din                (din        ),
/*    input              */ .wr_en              ((wr_en && en_wr_en)      ),
/*    input              */ .rd_en              ((rd_en && en_rd_en)      ),
/*    output [DSIZE-1:0] */ .dout               (dout       ),
/*    output             */ .full               (full       ),
/*    output             */ .empty              (empty      )
);
else if(DSIZE<73)
fifo_37_72bit #(
    .DSIZE      (DSIZE  )
)fifo_inst(
/*    input              */ .wr_clk             (wr_clk     ),
/*    input              */ .wr_rst             (wr_rst_Q   ),
/*    input              */ .rd_clk             (rd_clk     ),
/*    input              */ .rd_rst             (rd_rst_Q   ),
/*    input [DSIZE-1:0]  */ .din                (din        ),
/*    input              */ .wr_en              ((wr_en && en_wr_en)      ),
/*    input              */ .rd_en              ((rd_en && en_rd_en)      ),
/*    output [DSIZE-1:0] */ .dout               (dout       ),
/*    output             */ .full               (full       ),
/*    output             */ .empty              (empty      )
);
else if(DSIZE<97)
fifo_73_96bit #(
    .DSIZE      (DSIZE  )
)fifo_inst(
/*    input              */ .wr_clk             (wr_clk     ),
/*    input              */ .wr_rst             (wr_rst_Q   ),
/*    input              */ .rd_clk             (rd_clk     ),
/*    input              */ .rd_rst             (rd_rst_Q   ),
/*    input [DSIZE-1:0]  */ .din                (din        ),
/*    input              */ .wr_en              ((wr_en && en_wr_en)      ),
/*    input              */ .rd_en              ((rd_en && en_rd_en)      ),
/*    output [DSIZE-1:0] */ .dout               (dout       ),
/*    output             */ .full               (full       ),
/*    output             */ .empty              (empty      )
);
else if(DSIZE<145)
fifo_97_144bit #(
    .DSIZE      (DSIZE  )
)fifo_inst(
/*    input              */ .wr_clk             (wr_clk     ),
/*    input              */ .wr_rst             (wr_rst_Q   ),
/*    input              */ .rd_clk             (rd_clk     ),
/*    input              */ .rd_rst             (rd_rst_Q   ),
/*    input [DSIZE-1:0]  */ .din                (din        ),
/*    input              */ .wr_en              ((wr_en && en_wr_en)      ),
/*    input              */ .rd_en              ((rd_en && en_rd_en)      ),
/*    output [DSIZE-1:0] */ .dout               (dout       ),
/*    output             */ .full               (full       ),
/*    output             */ .empty              (empty      )
);
else
initial begin
    $error("\nFIFO DSIZE[%d] is too large\n",DSIZE);
    $stop;
end
endgenerate

endmodule

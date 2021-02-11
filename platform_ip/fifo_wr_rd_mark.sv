/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2018/1/12 
madified:
***********************************************/
`timescale 1ns/1ps
module fifo_wr_rd_mark(
    input           rd_clk,
    input           wr_clk,
    input           rd_rst,
    input           wr_rst,
    output logic    en_rd_en,
    output logic    en_wr_en,
    output logic    fifo_rst
);

import SystemPkg::*;

logic rd_rst_Q,wr_rst_Q;

xilinx_reset_sync xilinx_reset_sync_winst (
    // .clk       (wr_clk             ),
    .clk       (rd_clk             ),
    .enable    (1'b1               ),
    .reset_in  (wr_rst | rd_rst    ),
    .reset_out (wr_rst_Q           )
);

xilinx_reset_sync xilinx_reset_sync_rinst (
    .clk       (wr_clk             ),
    // .clk       (rd_clk             ),
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
        if(rd_rst_Q)
        // if(0)
                wcnt    <= '0;
        else if(wcnt != 3'b111)
                wcnt    <= wcnt + 1'b1;
        else    wcnt    <= wcnt;
    end

always@(posedge rd_clk,posedge rd_rst_Q)
    if(rd_rst_Q) rcnt    <= '0;
    else  begin
        if(wr_rst_Q)
        // if(0)
                rcnt    <= '0;
        else if(rcnt != 3'b111)
                rcnt    <= rcnt + 1'b1;
        else    rcnt    <= rcnt;
    end

// logic   en_wr_en,en_rd_en;
// generate 
//     if(SIM=="FALSE" || SIM=="OFF")begin 
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
//     end else begin 
//         assign en_wr_en = 1'b1;
//         assign en_rd_en = 1'b1;
//     end 
// endgenerate

assign fifo_rst = rd_rst_Q || wr_rst_Q;

endmodule

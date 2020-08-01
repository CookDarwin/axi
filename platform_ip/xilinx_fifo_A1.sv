/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
    xilinx fifo ip wrapper
author : Cook.Darwin
Version: VERA.1.0 : 2017/3/15 
    add count
Version: VERA.1.1 : 2018-4-23 14:57:55
    support DSIZE == 256
creaded: 2017/3/1 
madified:
***********************************************/
`timescale 1ns/1ps
module xilinx_fifo_A1 #(
    parameter DSIZE = 128,
    parameter LSIZE =
    (DSIZE>= 37             )?  9 :         //
    (DSIZE>= 19 && DSIZE<=36)?  9 :         //
    (DSIZE>= 10 && DSIZE<=18)? 10 :         //
    (DSIZE>=  5 && DSIZE<=9 )? 11 :         //
    (DSIZE>=  1 && DSIZE<=4 )? 12 :  1       //
)(
    input                     wr_clk,
    input                     wr_rst,
    input                     rd_clk,
    input                     rd_rst,
    input [DSIZE-1:0]         din   ,
    input                     wr_en ,
    input                     rd_en ,
    output [DSIZE-1:0]        dout  ,
    output                    full  ,
    output                    empty ,
    output logic[LSIZE-1:0]   wcount,
    output logic[LSIZE-1:0]   rcount
);

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
if(DSIZE<37)
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
fifo_97_144bit_A1 #(
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
/*    output             */ .empty              (empty      ),
/*   output logic[LSIZE-1:0] */  .wcount        (wcount     ),
/*   output logic[LSIZE-1:0] */  .rcount        (rcount     )
);
else if(DSIZE<217)
fifo_145_216bit_A1 #(
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
/*    output             */ .empty              (empty      ),
/*   output logic[LSIZE-1:0] */  .wcount        (wcount     ),
/*   output logic[LSIZE-1:0] */  .rcount        (rcount     )
);
else if(DSIZE<289)
fifo_217_288bit_A1 #(
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
/*    output             */ .empty              (empty      ),
/*   output logic[LSIZE-1:0] */  .wcount        (wcount     ),
/*   output logic[LSIZE-1:0] */  .rcount        (rcount     )
);
else if(DSIZE>504 && DSIZE < 576)
fifo_505_576bit_A1 #(
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
/*    output             */ .empty              (empty      ),
/*   output logic[LSIZE-1:0] */  .wcount        (wcount     ),
/*   output logic[LSIZE-1:0] */  .rcount        (rcount     )
);
else
initial begin
    $error("\nFIFO DSIZE[%d] too large\n",DSIZE);
    $stop;
end
endgenerate

endmodule

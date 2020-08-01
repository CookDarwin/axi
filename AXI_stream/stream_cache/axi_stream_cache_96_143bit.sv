/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/3/1 
madified:
***********************************************/
`timescale 1ns/1ps
module axi_stream_cache_96_143bit (
    axi_stream_inf.slaver      axis_in,
    axi_stream_inf.master      axis_out
);

//  <-----Cut code below this line---->

   // FIFO_DUALCLOCK_MACRO: Dual Clock First-In, First-Out (FIFO) RAM Buffer
   //                       Artix-7
   // Xilinx HDL Language Template, version 2016.3

   /////////////////////////////////////////////////////////////////
   // DATA_WIDTH | FIFO_SIZE | FIFO Depth | RDCOUNT/WRCOUNT Width //
   // ===========|===========|============|=======================//
   //   37-72    |  "36Kb"   |     512    |         9-bit         //
   //   19-36    |  "36Kb"   |    1024    |        10-bit         //
   //   19-36    |  "18Kb"   |     512    |         9-bit         //
   //   10-18    |  "36Kb"   |    2048    |        11-bit         //
   //   10-18    |  "18Kb"   |    1024    |        10-bit         //
   //    5-9     |  "36Kb"   |    4096    |        12-bit         //
   //    5-9     |  "18Kb"   |    2048    |        11-bit         //
   //    1-4     |  "36Kb"   |    8192    |        13-bit         //
   //    1-4     |  "18Kb"   |    4096    |        12-bit         //
   /////////////////////////////////////////////////////////////////

logic  EMPTY,FULL,RST;
logic  WR_RST,RD_RST;

always@(posedge axis_in.aclk,negedge axis_in.aresetn)begin
logic [2:0]     cnt;
    if(~axis_in.aresetn)begin
        WR_RST  <= 1'b1;
        cnt     <= '0;
    end else begin
        cnt     <= cnt + 1'b0;
        WR_RST  <= (cnt=='1)? 1'b0 : WR_RST;
    end
end

always@(posedge axis_out.aclk,negedge axis_out.aresetn)begin
logic [2:0]     cnt;
    if(~axis_in.aresetn)begin
        RD_RST  <= 1'b1;
        cnt     <= '0;
    end else begin
        cnt     <= cnt + 1'b0;
        RD_RST  <= (cnt=='1)? 1'b0 : RD_RST;
    end
end

 assign RST = WR_RST || RD_RST;


FIFO_DUALCLOCK_MACRO  #(
    .ALMOST_EMPTY_OFFSET      (9'h010), // Sets the almost empty threshold
    .ALMOST_FULL_OFFSET       (9'h010),  // Sets almost full threshold
    .DATA_WIDTH               (72),   // Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
    .DEVICE                   ("7SERIES"),  // Target device: "7SERIES"
    .FIFO_SIZE                ("36Kb"), // Target BRAM: "18Kb" or "36Kb"
    .FIRST_WORD_FALL_THROUGH  ("TRUE") // Sets the FIFO FWFT to "TRUE" or "FALSE"
) FIFO_DUALCLOCK_MACRO_inst (
    .ALMOSTEMPTY    (),     // 1-bit output almost empty
    .ALMOSTFULL     (),     // 1-bit output almost full
    .DO             (axis_out.axis_tdata[71:0]   ),                   // Output data, width defined by DATA_WIDTH parameter
    .EMPTY          (EMPTY),    // 1-bit output empty
    .FULL           (FULL),     // 1-bit output full
    .RDCOUNT        (),         // Output read count, width determined by FIFO depth
    .RDERR          (),         // 1-bit output read error
    .WRCOUNT        (),         // Output write count, width determined by FIFO depth
    .WRERR          (),         // 1-bit output write error
    .DI             (axis_in.axis_tdata[71:0]    ),                 // Input data, width defined by DATA_WIDTH parameter
    .RDCLK          (axis_out.aclk   ),                                             // 1-bit input read clock
    .RDEN           ((axis_out.axis_tready && axis_out.aclken)   ),                 // 1-bit input read enable
    .RST            (RST),                                                          // 1-bit input reset
    .WRCLK          (axis_in.aclk    ),                                             // 1-bit input write clock
    .WREN           ((axis_in.axis_tvalid && axis_in.aclken)     )                  // 1-bit input write enable
);

FIFO_DUALCLOCK_MACRO  #(
    .ALMOST_EMPTY_OFFSET      (9'h010), // Sets the almost empty threshold
    .ALMOST_FULL_OFFSET       (9'h010),  // Sets almost full threshold
    .DATA_WIDTH               (axis_in.DSIZE+1-72),   // Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
    .DEVICE                   ("7SERIES"),  // Target device: "7SERIES"
    .FIFO_SIZE                ("36Kb"), // Target BRAM: "18Kb" or "36Kb"
    .FIRST_WORD_FALL_THROUGH  ("TRUE") // Sets the FIFO FWFT to "TRUE" or "FALSE"
) FIFO_DUALCLOCK_MACRO_inst_1 (
    .ALMOSTEMPTY    (),     // 1-bit output almost empty
    .ALMOSTFULL     (),     // 1-bit output almost full
    .DO             ({axis_out.axis_tlast,axis_out.axis_tdata[axis_in.DSIZE-1:72]}   ),                   // Output data, width defined by DATA_WIDTH parameter
    .EMPTY          (),    // 1-bit output empty
    .FULL           (),     // 1-bit output full
    .RDCOUNT        (),         // Output read count, width determined by FIFO depth
    .RDERR          (),         // 1-bit output read error
    .WRCOUNT        (),         // Output write count, width determined by FIFO depth
    .WRERR          (),         // 1-bit output write error
    .DI             ({ais_in.axis_tlast,axis_int.axis_tdata[axis_in.DSIZE-1:72]}    ),                 // Input data, width defined by DATA_WIDTH parameter
    .RDCLK          (axis_out.aclk   ),                                             // 1-bit input read clock
    .RDEN           ((axis_out.axis_tready && axis_out.aclken)   ),                 // 1-bit input read enable
    .RST            (RST),                                                          // 1-bit input reset
    .WRCLK          (axis_in.aclk    ),                                             // 1-bit input write clock
    .WREN           ((axis_in.axis_tvalid && axis_in.aclken)     )                  // 1-bit input write enable
);

assign  axis_out.axis_tvalid    = !EMPTY;
assign  axis_in.axis_tready     = !FULL;
   // End of FIFO_DUALCLOCK_MACRO_inst instantiation

endmodule

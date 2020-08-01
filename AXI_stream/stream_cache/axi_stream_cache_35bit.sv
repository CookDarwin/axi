/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/2/28 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module axi_stream_cache_35bit (
    (* up_stream = "true" *)
    axi_stream_inf.slaver      axis_in,
    (* down_stream = "true" *)
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

logic   EMPTY,FULL,RST;
(* ASYNC_REG="TRUE" *)logic   WR_RST  = 1'b1;
(* ASYNC_REG="TRUE" *)logic   RD_RST  = 1'b1;

logic[2:0]     rd_cnt = 3'b000;
logic[2:0]     wr_cnt = 3'b000;

always@(posedge axis_in.aclk)
    if(wr_cnt==3'b111)
            WR_RST  <= 1'b0;
    else    WR_RST  <= WR_RST;

always@(posedge axis_out.aclk)
    if(rd_cnt==3'b111)
            RD_RST  <= 1'b0;
    else    RD_RST  <= RD_RST;

assign RST = WR_RST || RD_RST;

 logic  rd_en = 1'b1;
 logic  wr_en = 1'b1;

//
//
always@(posedge axis_out.aclk)
    rd_cnt  <= rd_cnt + 1'b1;

always@(posedge axis_in.aclk)
    wr_cnt  <= wr_cnt + 1'b1;
//
//  always@(posedge axis_out.aclk,negedge axis_out.aresetn)begin:RD_BLOCK
//  logic[2:0] cnt;
//     if(~axis_out.aresetn)begin
//         rd_en    <= 1'b0;
//         cnt      <= '0;
//     end else begin
//         cnt      <= cnt + 1'b1;
//         rd_en    <=  (cnt==3'b111)? 1'b1 : rd_en;
//     end
// end
//
// always@(posedge axis_in.aclk,negedge axis_in.aresetn)begin:WR_BLOCK
// logic[2:0] cnt;
//    if(~axis_in.aresetn)begin
//        wr_en    <= 1'b0;
//        cnt      <= '0;
//    end else begin
//        cnt      <= cnt + 1'b1;
//        wr_en    <=  (cnt==3'b111)? 1'b1 : wr_en;
//    end
// end


FIFO_DUALCLOCK_MACRO  #(
    .ALMOST_EMPTY_OFFSET      (9'h080), // Sets the almost empty threshold
    .ALMOST_FULL_OFFSET       (9'h080),  // Sets almost full threshold
    .DATA_WIDTH               (1+axis_in.KSIZE+axis_in.DSIZE+1),   // Valid values are 1-72 (37-72 only valid when FIFO_SIZE="36Kb")
    .DEVICE                   ("7SERIES"),  // Target device: "7SERIES"
    .FIFO_SIZE                ("18Kb"), // Target BRAM: "18Kb" or "36Kb"
    .FIRST_WORD_FALL_THROUGH  ("TRUE") // Sets the FIFO FWFT to "TRUE" or "FALSE"
) FIFO_DUALCLOCK_MACRO_inst (
    .ALMOSTEMPTY    (),     // 1-bit output almost empty
    .ALMOSTFULL     (),     // 1-bit output almost full
    .DO             ({axis_out.axis_tuser,axis_out.axis_tkeep,axis_out.axis_tlast,axis_out.axis_tdata}   ),                   // Output data, width defined by DATA_WIDTH parameter
    .EMPTY          (EMPTY),    // 1-bit output empty
    .FULL           (FULL),     // 1-bit output full
    .RDCOUNT        (),         // Output read count, width determined by FIFO depth
    .RDERR          (),         // 1-bit output read error
    .WRCOUNT        (),         // Output write count, width determined by FIFO depth
    .WRERR          (),         // 1-bit output write error
    .DI             ({axis_in.axis_tuser,axis_in.axis_tkeep,axis_in.axis_tlast,axis_in.axis_tdata }    ),                 // Input data, width defined by DATA_WIDTH parameter
    .RDCLK          (axis_out.aclk   ),                                             // 1-bit input read clock
    .RDEN           ((axis_out.axis_tready && axis_out.aclken && axis_out.axis_tvalid) && rd_en  ),                 // 1-bit input read enable
    .RST            (RST),                                                          // 1-bit input reset
    .WRCLK          (axis_in.aclk    ),                                             // 1-bit input write clock
    .WREN           ((axis_in.axis_tvalid && axis_in.aclken && axis_in.axis_tready) && wr_en    )                  // 1-bit input write enable
);

assign  axis_out.axis_tvalid    = !EMPTY;
assign  axis_in.axis_tready     = !FULL;
   // End of FIFO_DUALCLOCK_MACRO_inst instantiation

endmodule

/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.1 2017/5/24 
    use axi4_data_convert_A1
creaded: 2017/3/1 
madified:
***********************************************/
`include "define_macro.sv"
`timescale 1ns/1ps
(* axi4 = "true" *)
module axi4_long_to_axi4_wide_track //#(
    // parameter real ADDR_STEP = 1
//)
(
    `ifdef ILA_TRACK_DEBUG
        track_inf.master        t_inf,
    `endif
    (* up_stream = "true" *)
    axi_inf.slaver      slaver,
    (* down_stream = "true" *)
    axi_inf.master      master          //wide ADDR_STEP == 1
);

// localparam real ADDR_STEP = slaver.DSIZE/(master.DSIZE/8.0);            //addr burst == 8

import SystemPkg::*;

initial begin
    assert(slaver.MODE == master.MODE)
    else begin
        $error("SLAVER AXIS MODE != MASTER AXIS MODE");
        $stop;
    end
end

axi_inf #(
    .IDSIZE    (master.IDSIZE          ),
    .ASIZE     (slaver.ASIZE           ),
    .LSIZE     (slaver.LSIZE           ),
    .DSIZE     (slaver.DSIZE           ),
    .MODE      (slaver.MODE            ),
    .ADDR_STEP (slaver.ADDR_STEP       )
)axi_inf_pout(
    .axi_aclk      (slaver.axi_aclk     ),
    .axi_aresetn    (slaver.axi_aresetn   )
);

// localparam PSIZE = (((128/slaver.DSIZE) * (slaver.DSIZE+0.0)) * master.DSIZE) / slaver.DSIZE;

axi4_partition_OD #(
    // .PSIZE          (master.DSIZE*128/slaver.DSIZE      ),
    .PSIZE          (int'((((128/slaver.DSIZE) * (slaver.DSIZE+0.0)) * master.DSIZE) / slaver.DSIZE      ))
    // .ADDR_STEP      (slaver.DSIZE/(master.DSIZE/8.0)  )
    // .ADDR_STEP      (4*slaver.DSIZE/16.0  )
)axi4_partition_inst(
/*    axi_inf.slaver */ .slaver     (slaver          ),
/*    axi_inf.master */ .master     (axi_inf_pout    )
);

axi_inf #(
    .IDSIZE    (master.IDSIZE          ),
    .ASIZE     (master.ASIZE           ),
    .LSIZE     (master.LSIZE           ),
    .DSIZE     (master.DSIZE           ),
    .MODE      (slaver.MODE            ),
    .ADDR_STEP (master.ADDR_STEP       )
)axi_inf_cdout(
    .axi_aclk      (slaver.axi_aclk     ),
    .axi_aresetn    (slaver.axi_aresetn   )
);

axi4_data_convert_A1 axi4_data_convert_inst(
/*    axi_inf.slaver */ .axi_in     (axi_inf_pout   ),
/*    axi_inf.master */ .axi_out    (axi_inf_cdout  )
);


axi4_packet_fifo #(             //512
    .DEPTH      (4      )
)axi4_packet_fifo_inst(
/*    axi_inf.slaver */ .axi_in     (axi_inf_cdout  ),
/*    axi_inf.master */ .axi_out    (master        )
);


//----->> ILA TRACK <<-------------------------------
//`define ILA_TRACK_DEBUG
`ifdef ILA_TRACK_DEBUG
logic [4:0]     slaver_track_signals;
logic [4:0]     axi_inf_pout_track_signals;
logic [4:0]     axi_inf_cdout_track_signals;

track_axi4_rd track_axi4_rd_inst0(
/*  axi_inf.mirror       */   .axi4_inf         (slaver                 ),
/*  output logic[4:0]    */   .track_signals    (slaver_track_signals   )
);

track_axi4_rd track_axi4_rd_inst1(
/*  axi_inf.mirror       */   .axi4_inf         (axi_inf_pout                 ),
/*  output logic[4:0]    */   .track_signals    (axi_inf_pout_track_signals   )
);

track_axi4_rd track_axi4_rd_inst2(
/*  axi_inf.mirror       */   .axi4_inf         (axi_inf_cdout                 ),
/*  output logic[4:0]    */   .track_signals    (axi_inf_cdout_track_signals   )
);

assign  t_inf.track_trigger = {slaver.axi_arvalid,1'b1};
assign  t_inf.track_signals = {axi_inf_cdout_track_signals,axi_inf_pout_track_signals,slaver_track_signals};

`endif
//-----<< ILA TRACK >>-------------------------------

endmodule

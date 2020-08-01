/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.1 2017/5/24 
    use axi4_data_convert_A1
Version: VERA.1.0 2017/9/30 
    can discard partition
Version: VERB.0.0 2017/12/7 
    if slaver.DSIZE is not 2**N,then 'width_convert' fisrt
creaded: 2017/3/1 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi4 = "true" *)
module axi4_long_to_axi4_wide_verb #(
     parameter PIPE      = "OFF",
     parameter PARTITION = "ON"         //ON OFF
)(
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


//--->> width first <<------------------------------

localparam  WCSIZE = 2**($clog2(slaver.DSIZE));

axi_inf #(
    .IDSIZE    (slaver.IDSIZE          ),
    .ASIZE     (slaver.ASIZE           ),
    .LSIZE     (slaver.LSIZE           ),
    .DSIZE     (WCSIZE                 ),
    .MODE      (slaver.MODE            ),
    .ADDR_STEP (slaver.ADDR_STEP*WCSIZE/slaver.DSIZE       )
)axi_inf_first_wc(
    .axi_aclk      (slaver.axi_aclk     ),
    .axi_aresetn    (slaver.axi_aresetn   )
);

generate
if(WCSIZE != slaver.DSIZE)
axi4_data_convert_A1 axi4_data_convert_inst(
/*    axi_inf.slaver */ .axi_in     (slaver             ),
/*    axi_inf.master */ .axi_out    (axi_inf_first_wc   )
);
else
axi4_direct_verb axi4_direct_verb_inst(
/*  axi_inf.slaver   */ .slaver     (slaver             ),
/*  axi_inf.master   */ .master     (axi_inf_first_wc   )
);
endgenerate
//---<< width first >>------------------------------

axi_inf #(
    .IDSIZE    (master.IDSIZE          ),
    .ASIZE     (axi_inf_first_wc.ASIZE           ),
    .LSIZE     (axi_inf_first_wc.LSIZE           ),
    .DSIZE     (axi_inf_first_wc.DSIZE           ),
    .MODE      (axi_inf_first_wc.MODE            ),
    .ADDR_STEP (axi_inf_first_wc.ADDR_STEP       )
)axi_inf_pout(
    .axi_aclk      (slaver.axi_aclk     ),
    .axi_aresetn    (slaver.axi_aresetn   )
);

axi_inf #(
    .IDSIZE    (master.IDSIZE          ),
    .ASIZE     (master.ASIZE           ),
    .LSIZE     (master.LSIZE           ),
    .DSIZE     (master.DSIZE           ),
    .MODE      (axi_inf_first_wc.MODE            ),
    .ADDR_STEP (master.ADDR_STEP       )
)axi_inf_cdout(
    .axi_aclk      (slaver.axi_aclk     ),
    .axi_aresetn    (slaver.axi_aresetn   )
);


// localparam PSIZE = (((128/slaver.DSIZE) * (slaver.DSIZE+0.0)) * master.DSIZE) / slaver.DSIZE;
generate
if(PARTITION == "ON" || PARTITION == "TRUE")begin
axi4_partition_OD #(
    // .PSIZE          (master.DSIZE*128/slaver.DSIZE      ),
    .PSIZE          (int'((((128/axi_inf_first_wc.DSIZE) * (axi_inf_first_wc.DSIZE+0.0)) * master.DSIZE) / axi_inf_first_wc.DSIZE      ))
    // .ADDR_STEP      (slaver.DSIZE/(master.DSIZE/8.0)  )
    // .ADDR_STEP      (4*slaver.DSIZE/16.0  )
)axi4_partition_inst(
/*    axi_inf.slaver */ .slaver     (axi_inf_first_wc       ),
/*    axi_inf.master */ .master     (axi_inf_pout           )
);

axi4_data_convert_A1 axi4_data_convert_inst(
/*    axi_inf.slaver */ .axi_in     (axi_inf_pout   ),
/*    axi_inf.master */ .axi_out    (axi_inf_cdout  )
);
end else begin
axi4_data_convert_A1 axi4_data_convert_inst(
/*    axi_inf.slaver */ .axi_in     (axi_inf_first_wc   ),
/*    axi_inf.master */ .axi_out    (axi_inf_cdout      )
);

end
endgenerate


axi4_packet_fifo #(             //512
    .PIPE       (PIPE   ),
    .DEPTH      (4      )
)axi4_packet_fifo_inst(
/*    axi_inf.slaver */ .axi_in     (axi_inf_cdout  ),
/*    axi_inf.master */ .axi_out    (master        )
);

endmodule

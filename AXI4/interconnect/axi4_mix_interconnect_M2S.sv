/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
    The slaver dont need to wait current burst finished,when get next burst
author : Cook.Darwin
Version: VERA.0.1 2018/11/17 
    use axi4_rd_mix_interconnect_M2S_A2
creaded: 2017/2/27 
madified:
***********************************************/
`timescale 1ns/1ps
module axi4_mix_interconnect_M2S #(
    parameter NUM = 8
)(
    axi_inf.slaver slaver [NUM-1:0],
    axi_inf.master master
);
`include "define_macro.sv"
`VCS_AXI4_ARRAY_CPT(NUM,slaver,slaver,slaver_rd,Read)
`VCS_AXI4_ARRAY_CPT(NUM,slaver,slaver,slaver_wr,Write)
`VCS_AXI4_CPT_LT(master,master_wr,master,Write)
`VCS_AXI4_CPT_LT(master,master_rd,master,Read)

axi4_wr_interconnect_M2S_A1 #(     //axi4 dont support write burst out-of-order
    .NUM    (NUM    )
)axi4_wr_interconnect_M2S_inst(
/*    axi_inf.slaver_wr */  .slaver     (`slaver_vcs_cptWrite ),     //[NUM-1:0],
/*    axi_inf.master_wr */  .master     (`master_vcs_cptWrite )
);

// axi4_rd_mix_interconnect_M2S_A1 #(
//     .NUM    (NUM    )
// )axi4_rd_mix_interconnect_M2S_inst(
// /*    axi_inf.slaver_rd */  .slaver     (slaver ),      //[NUM-1:0],
// /*    axi_inf.master_rd */  .master     (master )
// );

axi4_rd_mix_interconnect_M2S_A2 #(
    .NUM    (NUM    )
)axi4_rd_mix_interconnect_M2S_inst(
/*    axi_inf.slaver_rd */  .slaver     (`slaver_vcs_cptRead ),      //[NUM-1:0],
/*    axi_inf.master_rd */  .master     (`master_vcs_cptRead )
);

//--->> CheckClock <<----------------
logic [NUM-1:0] cc_done;
logic [NUM-1:0] cc_same;
genvar KK;
generate
for(KK=0;KK<NUM-1;KK++)begin
    CheckPClock CheckPClock_inst(
    /*  input         */      .aclk     (slaver[KK].axi_aclk    ),
    /*  input         */      .bclk     (master.axi_aclk        ),
    /*  output logic  */      .done     (cc_done[KK]        ),
    /*  output logic  */      .same     (cc_same[KK]        )
    );

    initial begin
        wait(cc_done[KK]);
        assert(cc_same[KK])
        else begin
            $error("`axis_direct` clock is not same");
            $stop;
        end
    end
end
endgenerate
//---<< CheckClock >>----------------

endmodule

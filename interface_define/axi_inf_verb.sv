interface axi_inf_verb #(
    parameter IDSIZE    = 1,
    parameter ASIZE     = 32,
    parameter LSIZE     = 1,
    parameter DSIZE     = 32
)(
    input bit axi_aclk      ,
    input bit axi_aresetn
);

axi_wr_aux_inf wr_aux ();
axi_rd_aux_inf rd_aux ();

axi_aw_inf #(
    .IDSIZE   (IDSIZE   ),
    .ASIZE    (ASIZE    ),
    .LSIZE    (LSIZE    )
)aw();

axi_ar_inf #(
    .IDSIZE   (IDSIZE   ),
    .ASIZE    (ASIZE    ),
    .LSIZE    (LSIZE    )
)ar();

axi_wdata_inf #(
    .DSIZE    (DSIZE    )
)wd();

axi_rdata_inf #(
    .DSIZE    (DSIZE    )
)rd();

axi_resp_inf #(
    .IDSIZE (IDSIZE     )
)resp();

// modport master (
// output   wr_aux
// );

endinterface : axi_inf_verb

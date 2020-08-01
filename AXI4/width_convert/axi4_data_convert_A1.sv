/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.1.0 2017/5/23 
    use width convert verb
creaded: 2017/2/20 
madified:
***********************************************/
`timescale 1ns/1ps
module  axi4_data_convert_A1 (
    axi_inf.slaver axi_in,
    axi_inf.master axi_out
);

import SystemPkg::*;

initial begin
    assert(axi_in.MODE == axi_out.MODE)
    else begin
        $error("SLAVER AXIS MODE != MASTER AXIS MODE");
        $stop;
    end

    assert(real'(axi_in.DSIZE)/axi_in.ADDR_STEP == real'(axi_out.DSIZE)/axi_out.ADDR_STEP)
    else begin
        // $error("SLAVER ADDR STEP DONT MATCH MASTER");
        $error("SLAVER ADDR STEP [%d][%d] DONT MATCH MASTER[%d][%d]",axi_in.DSIZE,axi_in.ADDR_STEP,axi_out.DSIZE,axi_out.ADDR_STEP);
        $finish;
    end

end

generate
if(axi_in.MODE=="BOTH" || axi_in.MODE=="ONLY_WRITE")begin:AW_BLOCK
    axi4_data_combin_aflag_pipe_A1 #(
        .MODE       ("WRITE"        ),
        .IDSIZE     (axi_in.IDSIZE  ),
        .ASIZE      (axi_in.ASIZE   ),
        .ILSIZE     (axi_in.LSIZE   ),
        .OLSIZE     (axi_out.LSIZE  ),
        .ISIZE      (axi_in.DSIZE   ),
        .OSIZE      (axi_out.DSIZE  )
    )axi4_data_combin_aflag_pipe_wr(
    /*    input                 */      .clock        (axi_in.axi_aclk    ),
    /*    input                 */      .rst_n        (axi_in.axi_aresetn  ),
    /*    input[IDSIZE-1:0]     */      .in_a_id      (axi_in.axi_awid    ),
    /*    input[ASIZE-1:0]      */      .in_a_addr    (axi_in.axi_awaddr  ),
    /*    input[ILSIZE-1:0]     */      .in_a_len     (axi_in.axi_awlen   ),
    /*    input[2:0]            */      .in_a_size    (axi_in.axi_awsize  ),
    /*    input[1:0]            */      .in_a_burst   (axi_in.axi_awburst ),
    /*    input[0:0]            */      .in_a_lock    (axi_in.axi_awlock  ),
    /*    input[3:0]            */      .in_a_cache   (axi_in.axi_awcache ),
    /*    input[2:0]            */      .in_a_prot    (axi_in.axi_awprot  ),
    /*    input[3:0]            */      .in_a_qos     (axi_in.axi_awqos   ),
    /*    input                 */      .in_a_valid   (axi_in.axi_awvalid ),
    /*    output                */      .in_a_ready   (axi_in.axi_awready ),
    /*    output[IDSIZE-1:0]    */      .out_a_id     (axi_out.axi_awid   ),
    /*    output[ASIZE-1:0]     */      .out_a_addr   (axi_out.axi_awaddr ),
    /*    output[OLSIZE-1:0]    */      .out_a_len    (axi_out.axi_awlen  ),
    /*    output[2:0]           */      .out_a_size   (axi_out.axi_awsize ),
    /*    output[1:0]           */      .out_a_burst  (axi_out.axi_awburst),
    /*    output[0:0]           */      .out_a_lock   (axi_out.axi_awlock ),
    /*    output[3:0]           */      .out_a_cache  (axi_out.axi_awcache),
    /*    output[2:0]           */      .out_a_prot   (axi_out.axi_awprot ),
    /*    output[3:0]           */      .out_a_qos    (axi_out.axi_awqos  ),
    /*    output                */      .out_a_valid  (axi_out.axi_awvalid),
    /*    input                 */      .out_a_ready  (axi_out.axi_awready)
    );
end
endgenerate

generate
if(axi_in.MODE=="BOTH" || axi_in.MODE=="ONLY_READ")begin:AR_BLOCK
    axi4_data_combin_aflag_pipe_A1 #(
        .MODE       ("READ"         ),
        .IDSIZE     (axi_in.IDSIZE  ),
        .ASIZE      (axi_in.ASIZE   ),
        .ILSIZE     (axi_in.LSIZE   ),
        .OLSIZE     (axi_out.LSIZE  ),
        .ISIZE      (axi_in.DSIZE   ),
        .OSIZE      (axi_out.DSIZE  )
    )axi4_data_combin_aflag_pipe_rd(
    /*    input                 */      .clock        (axi_in.axi_aclk    ),
    /*    input                 */      .rst_n        (axi_in.axi_aresetn  ),
    /*    input[IDSIZE-1:0]     */      .in_a_id      (axi_in.axi_arid    ),
    /*    input[ASIZE-1:0]      */      .in_a_addr    (axi_in.axi_araddr  ),
    /*    input[ILSIZE-1:0]     */      .in_a_len     (axi_in.axi_arlen   ),
    /*    input[2:0]            */      .in_a_size    (axi_in.axi_arsize  ),
    /*    input[1:0]            */      .in_a_burst   (axi_in.axi_arburst ),
    /*    input[0:0]            */      .in_a_lock    (axi_in.axi_arlock  ),
    /*    input[3:0]            */      .in_a_cache   (axi_in.axi_arcache ),
    /*    input[2:0]            */      .in_a_prot    (axi_in.axi_arprot  ),
    /*    input[3:0]            */      .in_a_qos     (axi_in.axi_arqos   ),
    /*    input                 */      .in_a_valid   (axi_in.axi_arvalid ),
    /*    output                */      .in_a_ready   (axi_in.axi_arready ),
    /*    output[IDSIZE-1:0]    */      .out_a_id     (axi_out.axi_arid   ),
    /*    output[ASIZE-1:0]     */      .out_a_addr   (axi_out.axi_araddr ),
    /*    output[OLSIZE-1:0]    */      .out_a_len    (axi_out.axi_arlen  ),
    /*    output[2:0]           */      .out_a_size   (axi_out.axi_arsize ),
    /*    output[1:0]           */      .out_a_burst  (axi_out.axi_arburst),
    /*    output[0:0]           */      .out_a_lock   (axi_out.axi_arlock ),
    /*    output[3:0]           */      .out_a_cache  (axi_out.axi_arcache),
    /*    output[2:0]           */      .out_a_prot   (axi_out.axi_arprot ),
    /*    output[3:0]           */      .out_a_qos    (axi_out.axi_arqos  ),
    /*    output                */      .out_a_valid  (axi_out.axi_arvalid),
    /*    input                 */      .out_a_ready  (axi_out.axi_arready)
    );
end
endgenerate

generate
if(axi_in.MODE=="BOTH" || axi_in.MODE=="ONLY_WRITE")begin:WDATA_BLOCK
    width_convert_verb #(
        .ISIZE      (axi_in.DSIZE  ),
        .OSIZE      (axi_out.DSIZE )
    )width_convert_wr(
    /*    input                         */  .clock             (axi_in.axi_aclk    ),
    /*    input                         */  .rst_n             (axi_in.axi_aresetn  ),
    /*    input [DSIZE-1:0]             */  .wr_data           (axi_in.axi_wdata   ),
    /*    input                         */  .wr_vld            (axi_in.axi_wvalid  ),
    /*    output logic                  */  .wr_ready          (axi_in.axi_wready  ),
    /*    input                         */  .wr_last           (axi_in.axi_wlast   ),
    /*    input                         */  .wr_align_last     (1'b0               ),
    /*    output logic[DSIZE*NSIZE-1:0] */  .rd_data           (axi_out.axi_wdata  ),
    /*    output logic                  */  .rd_vld            (axi_out.axi_wvalid ),
    /*    input                         */  .rd_ready          (axi_out.axi_wready ),
    /*    output logic                  */  .rd_last           (axi_out.axi_wlast  )
    );
end
endgenerate

generate
if(axi_in.MODE=="BOTH" || axi_in.MODE=="ONLY_READ")begin:RDATA_BLOCK
    width_convert_verb #(
        .ISIZE      (axi_out.DSIZE  ),
        .OSIZE      (axi_in.DSIZE   )
    )width_convert_rd(
    /*    input                         */  .clock             (axi_in.axi_aclk    ),
    /*    input                         */  .rst_n             (axi_in.axi_aresetn  ),
    /*    input [DSIZE-1:0]             */  .wr_data           (axi_out.axi_rdata  ),
    /*    input                         */  .wr_vld            (axi_out.axi_rvalid ),
    /*    output logic                  */  .wr_ready          (axi_out.axi_rready ),
    /*    input                         */  .wr_last           (axi_out.axi_rlast  ),
    /*    input                         */  .wr_align_last     (1'b0               ),
    /*    output logic[DSIZE*NSIZE-1:0] */  .rd_data           (axi_in.axi_rdata   ),
    /*    output logic                  */  .rd_vld            (axi_in.axi_rvalid  ),
    /*    input                         */  .rd_ready          (axi_in.axi_rready  ),
    /*    output logic                  */  .rd_last           (axi_in.axi_rlast   )
    );
end
endgenerate

generate
if(axi_in.MODE=="BOTH" || axi_in.MODE=="ONLY_READ")
simple_data_pipe_slaver #(
    .DSIZE          (axi_in.IDSIZE)
)rid_data_pipe_inst(
/*    input                    */   .clock       (axi_in.axi_aclk    ),
/*    input                    */   .rst_n       (axi_in.axi_aresetn  ),
/*    input [DSIZE-1:0]        */   .indata      (axi_out.axi_rid    ),
/*    input                    */   .invalid     (axi_out.axi_rvalid ),
/*    output logic             */   .inready     (axi_out.axi_rready ),
/*    output logic[DSIZE-1:0]  */   .outdata     (axi_in.axi_rid     ),
/*    inpit  logic             */   .outvalid    (axi_in.axi_rvalid  ),
/*    input                    */   .outready    (axi_in.axi_rready  )
);
endgenerate
//----<< READ ID >>------------

generate
if(axi_in.MODE=="BOTH" || axi_in.MODE=="ONLY_WRITE")
simple_data_pipe #(
    .DSIZE          (2)
)bresp_data_pipe_inst(
/*    input                    */   .clock       (axi_in.axi_aclk    ),
/*    input                    */   .rst_n       (axi_in.axi_aresetn  ),
/*    input [DSIZE-1:0]        */   .indata      (axi_out.axi_bresp  ),
/*    input                    */   .invalid     (axi_out.axi_bvalid ),
/*    output logic             */   .inready     (axi_out.axi_bready ),
/*    output logic[DSIZE-1:0]  */   .outdata     (axi_in.axi_bresp   ),
/*    output logic             */   .outvalid    (axi_in.axi_bvalid  ),
/*    input                    */   .outready    (axi_in.axi_bready  )
);
endgenerate

generate
if(axi_in.MODE=="BOTH" || axi_in.MODE=="ONLY_WRITE")
simple_data_pipe_slaver #(
    .DSIZE          (axi_in.IDSIZE)
)bid_data_pipe_inst(
/*    input                    */   .clock       (axi_in.axi_aclk    ),
/*    input                    */   .rst_n       (axi_in.axi_aresetn  ),
/*    input [DSIZE-1:0]        */   .indata      (axi_out.axi_bid    ),
/*    input                    */   .invalid     (axi_out.axi_bvalid ),
/*    output logic             */   .inready     (axi_out.axi_bready ),
/*    output logic[DSIZE-1:0]  */   .outdata     (axi_in.axi_bid     ),
/*    input  logic             */   .outvalid    (axi_in.axi_bvalid  ),
/*    input                    */   .outready    (axi_in.axi_bready  )
);
endgenerate

int         slim_wcnt;
int         wide_wcnt;

int         slim_rcnt;
int         wide_rcnt;

assign slim_wcnt    = axi_in.axi_wcnt;
assign wide_wcnt    = axi_out.axi_wcnt;

assign slim_rcnt    = axi_in.axi_rcnt;
assign wide_rcnt    = axi_out.axi_rcnt;

endmodule

/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/4/7 
madified:
***********************************************/
`timescale 1ns/1ps
module axi4_wr_burst_track #(
    parameter MAX_LEN   = 16,
    parameter MAX_CYCLE = 1000
)(
    axi_inf.mirror_wr axi4_mirror
);

import GlobalPkg::*;

logic LSIZE =
(axi4_mirror.IDSIZE>= 37                          )?  9 :         //
(axi4_mirror.IDSIZE>= 19 && axi4_mirror.IDSIZE<=36)?  9 :         //
(axi4_mirror.IDSIZE>= 10 && axi4_mirror.IDSIZE<=18)? 10 :         //
(axi4_mirror.IDSIZE>=  5 && axi4_mirror.IDSIZE<=9 )? 11 :         //
(axi4_mirror.IDSIZE>=  1 && axi4_mirror.IDSIZE<=4 )? 12 :  1      ; //

logic   fifo_empty;
logic   fifo_full;

logic [7:0]     wcnt;
logic [axi4_mirror.IDSIZE-1:0]  chk_id;

generate
if(FAMIRY != "kintexu")
fifo_36bit_A1 #(
    .DSIZE      (axi4_mirror.IDSIZE)
)fifo_36bit_A1_inst(
/*  input                    */   .wr_clk   (axi4_mirror.axi_aclk   ),
/*  input                    */   .wr_rst   (!axi4_mirror.axi_aresetn ),
/*  input                    */   .rd_clk   (axi4_mirror.axi_aclk   ),
/*  input                    */   .rd_rst   (!axi4_mirror.axi_aresetn ),
/*  input [DSIZE-1:0]        */   .din      (axi4_mirror.axi_awid   ),
/*  input                    */   .wr_en    ((axi4_mirror.axi_awvalid && axi4_mirror.axi_awready)),
/*  input                    */   .rd_en    ((axi4_mirror.axi_bvalid && axi4_mirror.axi_bready)),
/*  output [DSIZE-1:0]       */   .dout     (chk_id                 ),
/*  output                   */   .full     (fifo_full              ),
/*  output                   */   .empty    (fifo_empty             ),
/*  output logic[LSIZE-1:0]  */   .wcount   (wcnt                   ),
/*  output logic[LSIZE-1:0]  */   .rcount   ()
);
else
fifo_ku_36bit #(
    .DSIZE      (axi4_mirror.IDSIZE)
)fifo_36bit_A1_inst(
/*  input                    */   .wr_clk   (axi4_mirror.axi_aclk   ),
/*  input                    */   .wr_rst   (!axi4_mirror.axi_aresetn ),
/*  input                    */   .rd_clk   (axi4_mirror.axi_aclk   ),
/*  input                    */   .rd_rst   (!axi4_mirror.axi_aresetn ),
/*  input [DSIZE-1:0]        */   .din      (axi4_mirror.axi_awid   ),
/*  input                    */   .wr_en    ((axi4_mirror.axi_awvalid && axi4_mirror.axi_awready)),
/*  input                    */   .rd_en    ((axi4_mirror.axi_bvalid && axi4_mirror.axi_bready)),
/*  output [DSIZE-1:0]       */   .dout     (chk_id                 ),
/*  output                   */   .full     (fifo_full              ),
/*  output                   */   .empty    (fifo_empty             ),
/*  output logic[LSIZE-1:0]  */   .wrcount   (wcnt                   ),
/*  output logic[LSIZE-1:0]  */   .rdcount   ()
);
endgenerate

//(* dont_touch="true" *)
logic       wr_overflow;

always@(posedge axi4_mirror.axi_aclk,negedge axi4_mirror.axi_aresetn)
    if(~axi4_mirror.axi_aresetn) wr_overflow <= 1'b0;
    else begin
        if(wcnt > MAX_LEN || (fifo_full && !fifo_empty) )
                wr_overflow <= 1'b1;
        else    wr_overflow <= wr_overflow;
    end

//(* dont_touch="true" *)
logic       wrong_id;

always@(posedge axi4_mirror.axi_aclk,negedge axi4_mirror.axi_aresetn)
    if(~axi4_mirror.axi_aresetn) wrong_id    <= 1'b0;
    else begin
        if(axi4_mirror.axi_bvalid && axi4_mirror.axi_bready)begin
            if(axi4_mirror.axi_bid != chk_id)
                    wrong_id    <= 1'b1;
            else    wrong_id    <= wrong_id;
        end else    wrong_id    <= wrong_id;
    end

//(* dont_touch="true" *)
logic       resp_overflow;

always@(posedge axi4_mirror.axi_aclk,negedge axi4_mirror.axi_aresetn)
    if(~axi4_mirror.axi_aresetn) resp_overflow   <= 1'b0;
    else begin
        if(axi4_mirror.axi_bvalid && axi4_mirror.axi_bready)begin
            if(fifo_empty)
                    resp_overflow   <= 1'b1;
            else    resp_overflow   <= resp_overflow;
        end else    resp_overflow   <= resp_overflow;
    end

//(* dont_touch="true" *)
logic   timeout_error;

logic [15:0]    tcnt;

always@(posedge axi4_mirror.axi_aclk,negedge axi4_mirror.axi_aresetn)
    if(~axi4_mirror.axi_aresetn) tcnt    <= '0;
    else begin
        if((axi4_mirror.axi_awvalid && axi4_mirror.axi_awready))
                tcnt    <= 'b1;
        else if((axi4_mirror.axi_wvalid && axi4_mirror.axi_wready))
                tcnt    <= tcnt;
        else if(axi4_mirror.axi_bvalid && axi4_mirror.axi_bready)
                tcnt    <= '0;
        else if(tcnt > '0)
                tcnt <= tcnt + 1'b1;
        else    tcnt    <= tcnt;
    end

always@(posedge axi4_mirror.axi_aclk,negedge axi4_mirror.axi_aresetn)
    if(~axi4_mirror.axi_aresetn) timeout_error   <= 1'b0;
    else begin
        if(tcnt > MAX_CYCLE)
                timeout_error   <= 1'b1;
        else    timeout_error   <= timeout_error;
    end

initial begin
    fork
        wait(wr_overflow);
        wait(wrong_id);
        wait(resp_overflow);
        wait(timeout_error);
    join_any
    #(10us);
    $finish;
end

endmodule

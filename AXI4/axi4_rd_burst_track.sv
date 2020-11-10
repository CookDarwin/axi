/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.1 2017/10/31 
    add ku support
creaded: 2017/4/7 
madified:
***********************************************/
`timescale 1ns/1ps
module axi4_rd_burst_track #(
    parameter MAX_LEN   = 16,
    parameter MAX_CYCLE = 1000
)(
    axi_inf.mirror_rd axi4_mirror
);
import GlobalPkg::*;

logic LSIZE =
(axi4_mirror.IDSIZE>= 37                          )?  9 :         //
(axi4_mirror.IDSIZE>= 19 && axi4_mirror.IDSIZE<=36)?  9 :         //
(axi4_mirror.IDSIZE>= 10 && axi4_mirror.IDSIZE<=18)? 10 :         //
(axi4_mirror.IDSIZE>=  5 && axi4_mirror.IDSIZE<=9 )? 11 :         //
(axi4_mirror.IDSIZE>=  1 && axi4_mirror.IDSIZE<=4 )? 12 :  1      ; //

//(* dont_touch="true" *)
logic   fifo_empty;
//(* dont_touch="true" *)
logic   fifo_full;

//(* dont_touch="true" *)
logic [10:0]     rcnt;
//(* dont_touch="true" *)
logic [axi4_mirror.IDSIZE-1:0]  chk_id;

//(* dont_touch="true" *)
logic [axi4_mirror.IDSIZE-1:0]  arid;
//(* dont_touch="true" *)
logic [axi4_mirror.IDSIZE-1:0]  rid;

assign arid = axi4_mirror.axi_arid;
assign  rid = axi4_mirror.axi_rid;

generate
if(FAMIRY != "kintexu")
fifo_36bit_A1 #(
    .DSIZE      (axi4_mirror.IDSIZE)
)fifo_36bit_A1_inst(
/*  input                    */   .wr_clk   (axi4_mirror.axi_aclk   ),
/*  input                    */   .wr_rst   (!axi4_mirror.axi_aresetn ),
/*  input                    */   .rd_clk   (axi4_mirror.axi_aclk   ),
/*  input                    */   .rd_rst   (!axi4_mirror.axi_aresetn ),
/*  input [DSIZE-1:0]        */   .din      (axi4_mirror.axi_arid   ),
/*  input                    */   .wr_en    ((axi4_mirror.axi_arvalid && axi4_mirror.axi_arready)),
/*  input                    */   .rd_en    ((axi4_mirror.axi_rvalid && axi4_mirror.axi_rready && axi4_mirror.axi_rlast)),
/*  output [DSIZE-1:0]       */   .dout     (chk_id                 ),
/*  output                   */   .full     (fifo_full              ),
/*  output                   */   .empty    (fifo_empty             ),
/*  output logic[LSIZE-1:0]  */   .wcount   (rcnt                   ),
/*  output logic[LSIZE-1:0]  */   .rcount   ()
);
else
fifo_ku_36bit #(
    .DSIZE      (axi4_mirror.IDSIZE)
)fifo_ku_36bit_inst(
/*  input                    */   .wr_clk   (axi4_mirror.axi_aclk   ),
/*  input                    */   .wr_rst   (!axi4_mirror.axi_aresetn ),
/*  input                    */   .rd_clk   (axi4_mirror.axi_aclk   ),
/*  input                    */   .rd_rst   (!axi4_mirror.axi_aresetn ),
/*  input [DSIZE-1:0]        */   .din      (axi4_mirror.axi_arid   ),
/*  input                    */   .wr_en    ((axi4_mirror.axi_arvalid && axi4_mirror.axi_arready)),
/*  input                    */   .rd_en    ((axi4_mirror.axi_rvalid && axi4_mirror.axi_rready && axi4_mirror.axi_rlast)),
/*  output [DSIZE-1:0]       */   .dout     (chk_id                 ),
/*  output                   */   .full     (fifo_full              ),
/*  output                   */   .empty    (fifo_empty             ),
/*  output logic[LSIZE-1:0]  */   .wrcount   (rcnt                   ),
/*  output logic[LSIZE-1:0]  */   .rdcount   ()
);
endgenerate

//(* dont_touch="true" *)
logic       rd_overflow;

always@(posedge axi4_mirror.axi_aclk,negedge axi4_mirror.axi_aresetn)
    if(~axi4_mirror.axi_aresetn) rd_overflow <= 1'b0;
    else begin
        if(rcnt > MAX_LEN || (fifo_full && !fifo_empty) )
                rd_overflow <= 1'b1;
        else    rd_overflow <= rd_overflow;
    end

//(* dont_touch="true" *)
logic       wrong_id;

always@(negedge axi4_mirror.axi_aclk,negedge axi4_mirror.axi_aresetn)
    if(~axi4_mirror.axi_aresetn) wrong_id    <= 1'b0;
    else begin
        if(axi4_mirror.axi_rvalid && axi4_mirror.axi_rready && axi4_mirror.axi_rlast)begin
            if(axi4_mirror.axi_rid != chk_id)
                    wrong_id    <= 1'b1;
            else    wrong_id    <= wrong_id;
        end else    wrong_id    <= wrong_id;
    end

//(* dont_touch="true" *)
logic   timeout_error;

logic [15:0]    tcnt;

always@(posedge axi4_mirror.axi_aclk,negedge axi4_mirror.axi_aresetn)
    if(~axi4_mirror.axi_aresetn) tcnt    <= '0;
    else begin
        if((axi4_mirror.axi_arvalid && axi4_mirror.axi_arready))
                tcnt    <= 'b1;
        else if((axi4_mirror.axi_rvalid && axi4_mirror.axi_rready && axi4_mirror.axi_rlast))
                tcnt    <= '0;
        else if((axi4_mirror.axi_rvalid && axi4_mirror.axi_rready))
                tcnt    <= tcnt;
        else if(tcnt > '0)
                tcnt <= tcnt + 1'b1;
        else    tcnt    <= tcnt;
    end

logic [31:0]        rd_burst_len;
always@(posedge axi4_mirror.axi_aclk,negedge axi4_mirror.axi_aresetn)
    if(~axi4_mirror.axi_aresetn) rd_burst_len    <= '0;
    else begin
        if(axi4_mirror.axi_arvalid && axi4_mirror.axi_arready)
                rd_burst_len    <= axi4_mirror.axi_arlen;
        else    rd_burst_len    <= rd_burst_len;
    end

always@(posedge axi4_mirror.axi_aclk,negedge axi4_mirror.axi_aresetn)
    if(~axi4_mirror.axi_aresetn) timeout_error   <= 1'b0;
    else begin
        if(tcnt >= MAX_CYCLE + rd_burst_len)
                timeout_error   <= 1'b1;
        else    timeout_error   <= timeout_error;
    end

initial begin 
    @(posedge rd_overflow);
    $error("%t,READ CMD OVERFLOW",$time);
    #(1us);
    $stop;
end

initial begin 
    @(posedge wrong_id);
    $error("%t,READ WRONG ID,expect<%d> but<%d>",$time,chk_id,axi4_mirror.axi_rid);
    #(1us);
    $stop;
end 

initial begin 
    @(posedge timeout_error);
    $error("%t,READ TIME OUT",$time);
    #(1us);
    $stop;
end

endmodule

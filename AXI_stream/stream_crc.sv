/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/1/22 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi_stream = "true" *)
module stream_crc (
    (* mirror_stream = "true" *)
    axi_stream_inf.mirror   axis_in,
    output logic [31:0]     crc
);


logic [15:0]        rd_data;
logic               rd_vld;
logic               rd_last;
logic [31:0]        rd_data_sum;

width_combin #(
    .DSIZE      (axis_in.DSIZE  ),
    .NSIZE      (2              )
)width_combin_inst(
/*    input                         */  .clock               (axis_in.aclk          ),
/*    input                         */  .rst_n               (axis_in.aresetn       ),
/*    input [DSIZE-1:0]             */  .wr_data             (axis_in.axis_tdata    ),
/*    input                         */  .wr_vld              (axis_in.axis_tvalid  && axis_in.aclken && axis_in.axis_tready),
/*    output logic                  */  .wr_ready            (                      ),
/*    input                         */  .wr_last             (axis_in.axis_tlast    ),
/*    input                         */  .wr_align_last       (axis_in.axis_tlast    ),
/*    output logic[DSIZE*NSIZE-1:0] */  .rd_data             (rd_data               ),
/*    output logic                  */  .rd_vld              (rd_vld                ),
/*    input                         */  .rd_ready            (1'b1                  ),
/*    output logic                  */  .rd_last             (rd_last               )
);

logic       trigger;
always@(posedge axis_in.aclk,negedge axis_in.aresetn)
    if(~axis_in.aresetn)    trigger <= 1'b0;
    else                    trigger <= rd_vld && rd_last;

always@(posedge axis_in.aclk,negedge axis_in.aresetn)
    if(~axis_in.aresetn) rd_data_sum     <= 32'd0;
    else begin
        if(trigger)     rd_data_sum     <= 32'd0;
        else begin
            if(rd_vld)
                    rd_data_sum <= rd_data_sum + rd_data;
            else    rd_data_sum <= rd_data_sum;
        end
    end

always@(posedge axis_in.aclk,negedge axis_in.aresetn)
    if(~axis_in.aresetn)   crc   <= 32'd0;
    else begin
        if(trigger)
                crc     <= rd_data_sum;
        else    crc     <= crc;
    end


endmodule

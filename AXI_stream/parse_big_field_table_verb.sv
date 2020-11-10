/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript: 解析大块的值域用于  common_frame_table
author : Cook.Darwin
Version: VERA.2.0 2017/9/11 
    resever value
Version: VERA.2.0 2017/12/11 
    use parse_common_frame_table_A2
Version: VERB.0.0 ###### Tue Oct 20 09:42:34 CST 2020
    rebuild
creaded: 2016/12/22 
madified:
***********************************************/
`timescale 1ns/1ps
module parse_big_field_table_verb #(
    parameter   DSIZE         = 8,
    parameter   FIELD_LEN     = 16*8,     //MAX 16*8
    parameter   TRY_PARSE     = "OFF"
)(
    output logic[0:DSIZE*FIELD_LEN-1]       value,
    output logic                            out_valid,
    axi_stream_inf.slaver                   cm_tb_s,
    axi_stream_inf.master                   cm_tb_m,
    axi_stream_inf.mirror                   cm_mirror
);

import SystemPkg::*;

initial begin 
    assert(DSIZE == cm_tb_s.DSIZE)
    else begin 
        $error("DSIZE<%d> != stream.DSIZE<%d>",DSIZE, cm_tb_s.DSIZE);
    end 
end

wire        clock,rst_n,clken;

axi_stream_inf #(.DSIZE(DSIZE)) parse_stream (.aclk(clock),.aresetn(rst_n),.aclken(clken));

generate
if(TRY_PARSE == "ON")begin

assign      clock   = cm_mirror.aclk;
assign      rst_n   = cm_mirror.aresetn;
assign      clken   = cm_mirror.aclken;

assign parse_stream.axis_tkeep = cm_mirror.axis_tkeep ;
assign parse_stream.axis_tuser = cm_mirror.axis_tuser ;
assign parse_stream.axis_tlast = cm_mirror.axis_tlast ;
assign parse_stream.axis_tdata = cm_mirror.axis_tdata ;
assign parse_stream.axis_tvalid= cm_mirror.axis_tvalid;
assign parse_stream.axis_tready= cm_mirror.axis_tready;
if(SIM=="FALSE" || SIM =="OFF")
    assign cm_tb_s.axis_tready     = cm_mirror.axis_tready;
end else begin

assign      clock   = cm_tb_s.aclk;
assign      rst_n   = cm_tb_s.aresetn;
assign      clken   = cm_tb_s.aclken;


assign parse_stream.axis_tkeep = cm_tb_s.axis_tkeep ;
assign parse_stream.axis_tuser = cm_tb_s.axis_tuser ;
assign parse_stream.axis_tlast = cm_tb_s.axis_tlast ;
assign parse_stream.axis_tdata = cm_tb_s.axis_tdata ;
assign parse_stream.axis_tvalid= cm_tb_s.axis_tvalid;
assign parse_stream.axis_tready= cm_tb_m.axis_tready;
assign cm_tb_s.axis_tready     = cm_tb_m.axis_tready;
end
endgenerate

logic   region_valid;

always_ff@(posedge clock,negedge rst_n)begin 
    if(~rst_n)  region_valid   <= 1'b1;
    else begin 
        if(parse_stream.axis_tvalid && parse_stream.axis_tready && parse_stream.axis_tlast)
                region_valid    <= 1'b1;
        else if(parse_stream.axis_tvalid && parse_stream.axis_tready && parse_stream.axis_tcnt == (FIELD_LEN-1'b1))
                region_valid    <= 1'b0;
        else    region_valid    <= region_valid;
    end
end

localparam  VSIZE = $clog2(FIELD_LEN);
logic[DSIZE-1:0]    value_array [0:FIELD_LEN-1];

always_ff@(posedge clock,negedge rst_n)begin 
    if(~rst_n)  
        foreach(value_array[i])
            value_array[i]   <= '0;
    else begin 
        if(region_valid)begin
            value_array[parse_stream.axis_tcnt[VSIZE-1:0]]    <= parse_stream.axis_tdata;
        end
    end
end

assign value    = {>>{value_array}};

always_ff@(posedge clock,negedge rst_n)begin 
    if(~rst_n)  out_valid   <= 1'b0;
    else begin
        if(parse_stream.axis_tvalid && parse_stream.axis_tready && parse_stream.axis_tlast)
            if(out_valid)
                    out_valid    <= 1'b0;
            else    out_valid    <= 1'b1;
        else if(parse_stream.axis_tvalid && parse_stream.axis_tready && parse_stream.axis_tcnt == (FIELD_LEN-1'b1))
                out_valid    <= 1'b1;
        else if(region_valid)
                out_valid   <= 1'b0;
        else    out_valid    <= out_valid;
    end
end

endmodule

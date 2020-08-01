/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/3/1 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi4 = "true" *)
module idata_pool_axi4 #(
    parameter DSIZE     = 8
)(
    input [31:0]                source_addr,
    input [31:0]                size,
    input                       valid,
    output                      ready,
    output logic                last_drop,
    input [DSIZE-1:0]           data,
    output                      empty,
    input                       wr_en,
    input                       sewage_valve,
    (* axi4_down = "true" *)
    axi_inf.master_wr           axi_master
);

initial begin
    if(DSIZE != axi_master.DSIZE)begin
        $error("DATA POOL AXI4 DATA WIDTH ERROR");
        $finish;
    end
end

axi_stream_inf #(.DSIZE(axi_master.IDSIZE+axi_master.ASIZE+axi_master.LSIZE)) addr_len_inf     (.aclk(axi_master.axi_aclk),.aresetn(axi_master.axi_aresetn),.aclken(1'b1));

logic [axi_master.IDSIZE-1:0]           id;
logic [axi_master.ASIZE-1:0]            addr;
logic [axi_master.LSIZE-1:0]            length;

assign  id      = '0;
assign  addr    = source_addr[axi_master.ASIZE-1:0];
assign  length  = size[axi_master.LSIZE:0]-1;

assign addr_len_inf.axis_tdata  = {id,addr,length};

logic   stream_en;

axi4_wr_auxiliary_gen_without_resp axi4_wr_auxiliary_gen_inst(
/*    axi_stream_inf.slaver     */  .id_add_len_in  (addr_len_inf          ),      //tlast is not necessary
/*    axi_inf.master_wr_aux     */  .axi_wr_aux     (axi_master            ),
/*    output                    */  .stream_en      (stream_en             )
);

assign  addr_len_inf.axis_tvalid    = valid && (size[axi_master.LSIZE:0]!='0);
assign  ready                       = addr_len_inf.axis_tready;

// logic   empty;

logic   force_rd_en;

always@(posedge axi_master.axi_aclk,negedge axi_master.axi_aresetn)
    if(~axi_master.axi_aresetn)  force_rd_en <= 1'b0;
    else begin
        // if(ready && sewage_valve && !empty)
        if(sewage_valve && !empty)
                 force_rd_en <= 1'b1;
        else     force_rd_en <= 1'b0;
    end

xilinx_fifo_verb #(
//xilinx_fifo #(
    .DSIZE      (DSIZE )
)xilinx_fifo_inst(
/*    input              */ .wr_clk     (axi_master.axi_aclk   ),
/*    input              */ .wr_rst     (!axi_master.axi_aresetn),
/*    input              */ .rd_clk     (axi_master.axi_aclk   ),
/*    input              */ .rd_rst     (!axi_master.axi_aresetn),
/*    input [DSIZE-1:0]  */ .din        (data                  ),
/*    input              */ .wr_en      ((wr_en && !full   )   ),
/*    input              */ .rd_en      (((axi_master.axi_wvalid && axi_master.axi_wready && stream_en) || force_rd_en) ),
/*    output [DSIZE-1:0] */ .dout       (axi_master.axi_wdata  ),
/*    output             */ .full       (full               ),
/*    output             */ .empty      (empty              )
);

assign axi_master.axi_wvalid    = !empty && stream_en;

always@(posedge axi_master.axi_aclk,negedge axi_master.axi_aresetn)
    if(~axi_master.axi_aresetn)    last_drop   <=  '0;
    else begin
        last_drop   <= axi_master.axi_wvalid && axi_master.axi_wready && axi_master.axi_wlast;
    end

always@(posedge axi_master.axi_aclk,negedge axi_master.axi_aresetn)
    if(~axi_master.axi_aresetn)   axi_master.axi_wlast   <= 1'b0;
    else begin
        if(axi_master.axi_awlen=='0 && axi_master.axi_awvalid && axi_master.axi_awready)
                axi_master.axi_wlast   <= 1'b1;
        else if(axi_master.axi_wcnt == (axi_master.axi_awlen-1) && axi_master.axi_wvalid && axi_master.axi_wready)
                axi_master.axi_wlast   <= 1'b1;
        else if(axi_master.axi_wlast && axi_master.axi_wvalid && axi_master.axi_wready)
                axi_master.axi_wlast   <= 1'b0;
        else    axi_master.axi_wlast   <= axi_master.axi_wlast;
    end

assign axi_master.axi_bready    = 1'b1;

endmodule

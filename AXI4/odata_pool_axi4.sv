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
module odata_pool_axi4 #(
    parameter DSIZE= 8
)(
    //-->> READ RELATED
    input  logic                rd_clk,
    input  logic                rd_rst_n,
    output logic [DSIZE-1:0]    data,
    output logic                empty,
    input                       rd_en,
    //====================
    input [31:0]                source_addr,
    input [31:0]                size,
    input                       valid,
    output                      ready,
    output logic                last_drop,
    axi_inf.master_rd           axi_master
);

logic           fifo_empty;
logic           fifo_full;
logic [31:0]    fifo_addr;
logic [31:0]    fifo_size;
logic           fifo_rd_en;

common_fifo #(
    .DEPTH      (4  ),
    .DSIZE      (64 )
)common_fifo_inst(
/*  input                    */   .clock    (axi_master.axi_aclk    ),
/*  input                    */   .rst_n    (axi_master.axi_aresetn  ),
/*  input [DSIZE-1:0]        */   .wdata    ({source_addr,size}     ),
/*  input                    */   .wr_en    ((valid && !fifo_full)  ),
/*  output logic[DSIZE-1:0]  */   .rdata    ({fifo_addr,fifo_size}  ),
/*  input                    */   .rd_en    ((fifo_rd_en && !fifo_empty)),
/*  output logic[CSIZE-1:0]  */   .count    (                   ),
/*  output logic             */   .empty    (fifo_empty             ),
/*  output logic             */   .full     (fifo_full              )
);

assign ready    = !fifo_full;

initial begin
    if(DSIZE != axi_master.DSIZE)begin
        $error("DATA POOL AXI4 DATA WIDTH ERROR DSIZE[%d]--axi_master.DSIZE[%d]",DSIZE,axi_master.DSIZE);
        $finish;
    end
end

axi_stream_inf #(.DSIZE(axi_master.IDSIZE+axi_master.ASIZE+axi_master.LSIZE)) addr_len_inf     (.aclk(axi_master.axi_aclk),.aresetn(axi_master.axi_aresetn),.aclken(1'b1));

logic [axi_master.IDSIZE-1:0]           id;
logic [axi_master.ASIZE-1:0]            addr;
logic [axi_master.LSIZE-1:0]            length;

assign  id      = '0;
assign  addr    = fifo_addr[axi_master.ASIZE-1:0];
assign  length  = fifo_size[axi_master.LSIZE:0]-1;

assign addr_len_inf.axis_tdata  = {id,addr,length};

axi4_rd_auxiliary_gen_A1 axi4_rd_auxiliary_gen_inst(
/*    axi_stream_inf.slaver     */  .id_add_len_in  (addr_len_inf   ),      //tlast is not necessary
/*    axi_inf.master_rd_aux     */  .axi_rd_aux     (axi_master            )
);

assign  addr_len_inf.axis_tvalid    = !fifo_empty && (fifo_size[axi_master.LSIZE:0]!='0);
assign  fifo_rd_en                  = addr_len_inf.axis_tready;

logic   full;
// logic   empty;

logic     xilinx_fifo_wr_en;
logic     xilinx_fifo_rd_en;
logic     xilinx_fifo_empty;

assign xilinx_fifo_wr_en   = (axi_master.axi_rvalid && axi_master.axi_rready);
assign xilinx_fifo_rd_en   = rd_en && !empty;

xilinx_fifo_verb #(
//xilinx_fifo #(
    .DSIZE      (DSIZE )
)xilinx_fifo_inst(
/*    input              */ .wr_clk     (axi_master.axi_aclk   ),
/*    input              */ .wr_rst     (!axi_master.axi_aresetn),
/*    input              */ .rd_clk     (rd_clk                ),
/*    input              */ .rd_rst     (!rd_rst_n             ),
/*    input [DSIZE-1:0]  */ .din        (axi_master.axi_rdata  ),
/*    input              */ .wr_en      (xilinx_fifo_wr_en  ),
/*    input              */ .rd_en      (xilinx_fifo_rd_en  ),
/*    output [DSIZE-1:0] */ .dout       (data               ),
/*    output             */ .full       (full               ),
/*    output             */ .empty      (empty              )
);

assign xilinx_fifo_empty = empty && rd_rst_n;

// long_fifo #(
//     .DSIZE      (DSIZE  ),
//     .LENGTH     (8192   )
// )long_fifo_inst(
//     /*    input              */ .wr_clk     (axi_master.axi_aclk   ),
//     /*    input              */ .wr_rst     (!axi_master.axi_aresetn),
//     /*    input              */ .rd_clk     (rd_clk                ),
//     /*    input              */ .rd_rst     (!rd_rst_n             ),
//     /*    input [DSIZE-1:0]  */ .din        (axi_master.axi_rdata  ),
//     /*    input              */ .wr_en      ((axi_master.axi_rvalid && axi_master.axi_rready) ),
//     /*    input              */ .rd_en      (rd_en              ),
//     /*    output [DSIZE-1:0] */ .dout       (data               ),
//     /*    output             */ .full       (full               ),
//     /*    output             */ .empty      (empty              )
// );

assign axi_master.axi_rready   = !full;


always@(posedge axi_master.axi_aclk,negedge axi_master.axi_aresetn)
    if(~axi_master.axi_aresetn)    last_drop   <=  '0;
    else begin
        last_drop   <= axi_master.axi_rvalid && axi_master.axi_rready && axi_master.axi_rlast;
    end

endmodule

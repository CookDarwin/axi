/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.1.0 2017/9/18 上午11:07:26
    use axis out
Version: VERA.2.0 ###### Tue Jan 7 09:47:51 CST 2020
    data_inf_c replace valid ready
Version: VERA.3.0 ###### Mon Sep 21 14:31:30 CST 2020
    add ex info
creaded: 2017/3/1 下午6:12:34
madified:
***********************************************/
`timescale 1ns/1ps
module odata_pool_axi4_A3 #(
    parameter   DSIZE    = 32
)(
    axi_stream_inf.master       out_axis,
    data_inf_c.slaver           addr_size_inf,  // ADDR: 32 SIZE: 32
    input [DSIZE-1:0]           in_ex_info,        // sync addr_size_inf
    output[DSIZE-1:0]           out_ex_info,       // sync out_axis last
    axi_inf.master_rd           axi_master
);

`include "define_macro.sv"

logic           fifo_empty;
logic           fifo_full;
logic [31:0]    fifo_addr;
logic [31:0]    fifo_size;
logic           fifo_rd_en;

independent_clock_fifo #(
    .DEPTH      (4   ),
    .DSIZE      (64  )
)independent_clock_fifo_inst_req(
/*  input                   */    .wr_clk     (addr_size_inf.clock      ),          
/*  input                   */    .wr_rst_n   (addr_size_inf.rst_n      ),          
/*  input                   */    .rd_clk     (axi_master.axi_aclk      ),          
/*  input                   */    .rd_rst_n   (axi_master.axi_aresetn   ),          
/*  input [DSIZE-1:0]       */    .wdata      (addr_size_inf.data       ),          
/*  input                   */    .wr_en      (addr_size_inf.valid && addr_size_inf.ready   ),          
/*  output logic[DSIZE-1:0] */    .rdata      ({fifo_addr,fifo_size}    ),          
/*  input                   */    .rd_en      ((fifo_rd_en && !fifo_empty)  ),          
/*  output logic            */    .empty      (fifo_empty               ),          
/*  output logic            */    .full       (fifo_full                )      
);

assign  addr_size_inf.ready     = !fifo_full;

initial begin
    if(out_axis.DSIZE != axi_master.DSIZE)begin
        $error("DATA POOL AXI4 DATA WIDTH ERROR DSIZE[%d]--axi_master.DSIZE[%d]",out_axis.DSIZE,axi_master.DSIZE);
        $finish;
    end
end

axi_stream_inf #(.DSIZE(axi_master.IDSIZE+axi_master.ASIZE+axi_master.LSIZE)) addr_len_inf     (.aclk(axi_master.axi_aclk),.aresetn(axi_master.axi_aresetn),.aclken(1'b1));

logic [axi_master.IDSIZE-1:0]           id;
logic [axi_master.ASIZE-1:0]            addr;
logic [axi_master.LSIZE-1:0]            length;
logic                                   force_align_status;

assign  id      = '0;
assign  addr    = fifo_addr[axi_master.ASIZE-1:0];
assign  length  = fifo_size[axi_master.LSIZE:0];

assign addr_len_inf.axis_tdata  = {id,addr,length};

`VCS_AXI4_CPT_LT(axi_master,master_rd,master_rd_aux,)
axi4_rd_auxiliary_gen_A1 axi4_rd_auxiliary_gen_inst(
/*    axi_stream_inf.slaver     */  .id_add_len_in  (addr_len_inf   ),      //tlast is not necessary
/*    axi_inf.master_rd_aux     */  .axi_rd_aux     (`axi_master_vcs_cpt            )
);

// assign  addr_len_inf.axis_tvalid    = !fifo_empty && (fifo_size[axi_master.LSIZE:0]!='0);
assign  addr_len_inf.axis_tvalid    = !fifo_empty;
assign  fifo_rd_en                  = addr_len_inf.axis_tready;

//--->> FIFO

logic   axis_fifo_empty;
logic   axis_fifo_full;
logic   axis_fifo_rd_en;
logic [out_axis.DSIZE+1-1:0]    axis_fifo_rd_data;

//--->> forece rd_en <<---------------------------

logic   force_rd_en;

logic   cmded_empty;

independent_clock_fifo #(
    .DEPTH  (4  ),
    .DSIZE  (1  )
)independent_clock_fifo_inst(
/*  input                    */   .wr_clk           (axi_master.axi_aclk   ),
/*  input                    */   .wr_rst_n         (axi_master.axi_aresetn ),
/*  input                    */   .rd_clk           (out_axis.aclk         ),
/*  input                    */   .rd_rst_n         (out_axis.aresetn      ),
/*  input [DSIZE-1:0]        */   .wdata            (1'b1),
/*  input                    */   .wr_en            (axi_master.axi_arready && axi_master.axi_arvalid),
/*  output logic[DSIZE-1:0]  */   .rdata            (),
/*  input                    */   .rd_en            (out_axis.axis_tvalid && out_axis.axis_tready && out_axis.axis_tlast),
/*  output logic             */   .empty            (cmded_empty           ),
/*  output logic             */   .full             ()
);

assign force_rd_en  = cmded_empty && !axis_fifo_empty;
//---<< forece rd_en >>---------------------------

xilinx_fifo_verb #(
//xilinx_fifo #(
    .DSIZE      (out_axis.DSIZE+1 )
)xilinx_fifo_inst(
/*    input              */ .wr_clk     (axi_master.axi_aclk   ),
/*    input              */ .wr_rst     (!axi_master.axi_aresetn),
/*    input              */ .rd_clk     (out_axis.aclk         ),
/*    input              */ .rd_rst     (!out_axis.aresetn     ),
/*    input [DSIZE-1:0]  */ .din        ({axi_master.axi_rlast,axi_master.axi_rdata}  ),
/*    input              */ .wr_en      ((axi_master.axi_rvalid && axi_master.axi_rready) ),
/*    input              */ .rd_en      (axis_fifo_rd_en  || force_rd_en     ),
/*    output [DSIZE-1:0] */ .dout       (axis_fifo_rd_data     ),
/*    output             */ .full       (axis_fifo_full        ),
/*    output             */ .empty      (axis_fifo_empty       ),
/*    output [LSIZE-1:0] */ .rdcount    (),
/*    output [LSIZE-1:0] */ .wrcount    ()
);


assign axi_master.axi_rready   = !axis_fifo_full;

assign out_axis.axis_tdata  = axis_fifo_rd_data[out_axis.DSIZE-1:0];
assign out_axis.axis_tlast  = axis_fifo_rd_data[out_axis.DSIZE];
assign out_axis.axis_tvalid = !axis_fifo_empty;
assign out_axis.axis_tkeep  = '1;
assign axis_fifo_rd_en      = out_axis.axis_tvalid && out_axis.axis_tready;


//--->> force_align_status <<---------------------

// (* dont_touch = "true" *)
logic [23:0]    axi4_rd_cnt;

always@(posedge axi_master.axi_aclk)
    if(axi_master.axi_rvalid && axi_master.axi_rready && axi_master.axi_rlast)
            axi4_rd_cnt <= '0;
    else if(axi_master.axi_rvalid && axi_master.axi_rready)
            axi4_rd_cnt <= axi4_rd_cnt + 1'b1;
    else    axi4_rd_cnt <= axi4_rd_cnt;

always@(posedge axi_master.axi_aclk ,negedge axi_master.axi_aresetn)
    if(!axi_master.axi_aresetn)
            force_align_status  <= 1'b0;
    else if(axi_master.axi_rvalid && axi_master.axi_rready && axi_master.axi_rlast)
            force_align_status  <= axi_master.axi_rcnt != axi4_rd_cnt;
    else if(axis_fifo_empty && cmded_empty)
            force_align_status  <= 1'b0;
    else    force_align_status  <= force_align_status;

//---<< force_align_status >>---------------------
//--->> EX INFO <<--------------------------------
independent_clock_fifo #(
    .DEPTH      (10     ),
    .DSIZE      (DSIZE  )
)independent_clock_fifo_inst_ex(
/*  input                   */    .wr_clk     (addr_size_inf.clock      ),          
/*  input                   */    .wr_rst_n   (addr_size_inf.rst_n      ),          
/*  input                   */    .rd_clk     (out_axis.aclk            ),          
/*  input                   */    .rd_rst_n   (out_axis.aresetn         ),          
/*  input [DSIZE-1:0]       */    .wdata      (in_ex_info               ),          
/*  input                   */    .wr_en      (addr_size_inf.valid && addr_size_inf.ready                           ),          
/*  output logic[DSIZE-1:0] */    .rdata      (out_ex_info              ),          
/*  input                   */    .rd_en      (out_axis.axis_tvalid && out_axis.axis_tready && out_axis.axis_tlast  ),          
/*  output logic            */    .empty      (               ),          
/*  output logic            */    .full       (               )      
);
//---<< EX INFO >>--------------------------------

endmodule

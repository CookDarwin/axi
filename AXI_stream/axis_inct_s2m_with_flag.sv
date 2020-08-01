/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2018-3-28 16:20:13
madified:
***********************************************/
`timescale 1ns/1ps
module axis_inct_s2m_with_flag #(
    parameter   NUM = 8
)(
    input [NUM-1:0]         idle_flag,
    axi_stream_inf.slaver   s00,
    axi_stream_inf.master   m00  [NUM-1:0]
);

logic   clock,rst_n;

assign  clock = s00.aclk;
assign  rst_n = s00.aresetn;

logic [$clog2(NUM)-1:0]     decode_addr;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  decode_addr <= '0;
    else begin
        decode_addr   <= '0;
        foreach(idle_flag[i])
            if(idle_flag[i])
                decode_addr   <= i;
    end


logic   rd_en;
logic   wr_en;
logic [NUM-1:0] vld_rdy_lst;

genvar KK;
generate
for(KK=0;KK<NUM;KK++)
    assign vld_rdy_lst[KK]  = m00[KK].axis_tvalid && m00[KK].axis_tready && m00[KK].axis_tlast;
endgenerate

always@(posedge clock,negedge rst_n)
    if(~rst_n)  wr_en   <= 1'b0;
    else        wr_en   <= s00.axis_tvalid && s00.axis_tready && s00.axis_tcnt == '0;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  rd_en   <= 1'b0;
    else begin
        rd_en   <= |vld_rdy_lst;
    end


logic [$clog2(NUM)-1:0]     rd_s2m_addr;

common_fifo #(
    .DEPTH      (4              ),
    .DSIZE      ($clog2(NUM)    )
)common_fifo_rd_stack_ist(
/*  input                    */   .clock        (clock  ),
/*  input                    */   .rst_n        (rst_n  ),
/*  input [DSIZE-1:0]        */   .wdata        (decode_addr          ),
/*  input                    */   .wr_en        (wr_en                ),
/*  output logic[DSIZE-1:0]  */   .rdata        (rd_s2m_addr          ),
/*  input                    */   .rd_en        (rd_en                ),
/*  output logic[CSIZE-1:0]  */   .count        (),
/*  output logic             */   .empty        (),
/*  output logic             */   .full         ()
);


axi_stream_interconnect_S2M #(
    .NUM    (NUM    )
)axi_stream_interconnect_S2M_inst(
/*  input [NSIZE-1:0]     */ .addr          (rd_s2m_addr    ),
/*  axi_stream_inf.slaver */ .s00           (s00            ),
/*  axi_stream_inf.master */ .m00           (m00            )//[NUM-1:0]
);

endmodule

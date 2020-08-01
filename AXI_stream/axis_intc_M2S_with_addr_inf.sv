/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2019/1/8 
madified:
***********************************************/
`timescale 1ns/1ps
module axis_intc_M2S_with_addr_inf #(
    parameter       NUM = 8
)(
    data_inf_c.master       addr_inf,       //inf.DSIZE = $clog2(NUM)
    axi_stream_inf.slaver   s00 [NUM-1:0],
    axi_stream_inf.master   m00
);


data_inf_c #(.DSIZE(m00.DSIZE+1+1+m00.KSIZE) ) s00_data_inf [NUM-1:0] (m00.aclk,m00.aresetn);
data_inf_c #(.DSIZE(m00.DSIZE+1+1+m00.KSIZE) ) m00_data_inf (m00.aclk,m00.aresetn);
axi_stream_inf #(.DSIZE(m00.DSIZE),.FreqM(m00.FreqM)) m00_pre (m00.aclk,m00.aresetn,m00.aclken);

logic [NUM-1:0] last;
logic [NUM-1:0] vld_rdy;

genvar KK;
generate
for(KK=0;KK<NUM;KK++)begin
    assign last[KK]     = s00[KK].axis_tlast;
    assign vld_rdy[KK]  = s00[KK].axis_tvalid && s00[KK].axis_tready;
end
endgenerate

generate
for(KK=0;KK<NUM;KK++)begin
assign s00_data_inf[KK].data    = {s00[KK].axis_tkeep,s00[KK].axis_tuser,s00[KK].axis_tlast,s00[KK].axis_tdata};
assign s00_data_inf[KK].valid   = s00[KK].axis_tvalid;
assign s00[KK].axis_tready      = s00_data_inf[KK].ready;
end
endgenerate

data_c_pipe_intc_M2S_verc #(
    .PRIO   ("BEST_LAST"    ),   //BEST_ROBIN BEST_LAST ROBIN LAST WAIT_IDLE FORCE_ROBIN
    .NUM    (NUM            )
)data_c_pipe_intc_M2S_verc_inst(
/*  input [NUM-1:0]      */       .last         (last           ),             //ctrl prio
/*  data_inf_c.slaver    */       .s00          (s00_data_inf   ),//[NUM-1:0],
/*  data_inf_c.master    */       .m00          (m00_data_inf   )
);

assign {m00_pre.axis_tkeep,m00_pre.axis_tuser,m00_pre.axis_tlast,m00_pre.axis_tdata} = m00_data_inf.data;
assign m00_pre.axis_tvalid      = m00_data_inf.valid;
assign m00_data_inf.ready   = m00_pre.axis_tready;

//--->> ADDR CTRL <<-----------------------
logic                   wr_en;
logic[$clog2(NUM)-1:0]  wdata;
logic                   rd_en;
logic[$clog2(NUM)-1:0]  rdata;
logic                   empty;
logic                   full;

always_ff@(posedge m00.aclk,negedge m00.aresetn)
    if(~m00.aresetn)    wr_en   <= 1'b0;
    else begin
        // for(int II=0;II < NUM;II++)begin
        //
        // end
        wr_en   <= |(last & vld_rdy);
    end

always_ff@(posedge m00.aclk,negedge m00.aresetn)
    if(~m00.aresetn)    wdata   <= '0;
    else begin
        wdata   <= '0;
        for(int II=0;II < NUM;II++)begin
            if(vld_rdy[II])
                    wdata   <= II;
            else    wdata   <= wdata;
        end
    end

independent_clock_fifo #(
    .DEPTH      (4  ),
    .DSIZE      ($clog2(NUM)  )
)independent_clock_fifo_inst(
/*  input                    */   .wr_clk       (m00.aclk           ),
/*  input                    */   .wr_rst_n     (m00.aresetn        ),
/*  input                    */   .rd_clk       (addr_inf.clock     ),
/*  input                    */   .rd_rst_n     (addr_inf.rst_n     ),
/*  input [DSIZE-1:0]        */   .wdata        (wdata              ),
/*  input                    */   .wr_en        (wr_en              ),
/*  output logic[DSIZE-1:0]  */   .rdata        (rdata              ),
/*  input                    */   .rd_en        (rd_en              ),
/*  output logic             */   .empty        (empty              ),
/*  output logic             */   .full         (full               )
);

assign  addr_inf.data       = rdata;
assign  addr_inf.valid      = !empty;
assign  rd_en               = addr_inf.ready;
//---<< ADDR CTRL >>-----------------------
//--->> PIPE <<----------------------------
axis_valve_with_pipe #(
    .MODE       ("HEAD")
)axis_valve_with_pipe_inst(
/*  input                  */  .button      (!full      ),          //[1] OPEN ; [0] CLOSE
/*  axi_stream_inf.slaver  */  .axis_in     (m00_pre    ),
/*  axi_stream_inf.master  */  .axis_out    (m00        )
);
//---<< PIPE >>----------------------------
endmodule

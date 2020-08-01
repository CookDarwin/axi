/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
    build from axi_stream_interconnect_M2S
Version: VERA.0.1
    when valid set high one clock,after that,set low,signal will be locked uncorrect
creaded: 2017/1/3 
madified:
***********************************************/
`timescale 1ns/1ps
module axi_stream_interconnect_M2S_noaddr #(
    parameter   NUM   = 8,
    // parameter   DSIZE = 8,
    parameter   NSIZE =  NUM <= 2? 1 :
                         NUM <= 4? 2 :
                         NUM <= 8? 3 :
                         NUM <= 16?4 : 5
)(
    axi_stream_inf.slaver  s00 [NUM-1:0],
    axi_stream_inf.master  m00
);

initial begin
    $error("The module `axi_stream_interconnect_M2S_noaddr` has be abandon, please use `axi_stream_interconnect_M2S_A1`");
    $stop;
end

logic[NSIZE-1:0]    addr;
logic               addr_vld;
logic[NSIZE-1:0]    curr_addr;

//localparam  DSIZE   = m00.DSIZE;
// localparam  KSIZE   = (DSIZE/8 > 0)? DSIZE/8 : 1;

data_inf #(.DSIZE(m00.DSIZE+1+1+m00.KSIZE) ) s00_data_inf [NUM-1:0] ();
data_inf #(.DSIZE(m00.DSIZE+1+1+m00.KSIZE) ) m00_data_inf ();

genvar KK;
generate
for(KK=0;KK<NUM;KK++)begin
assign s00_data_inf[KK].valid                           = s00[KK].axis_tvalid;
assign s00_data_inf[KK].data/*[m00.DSIZE-1:0]*/         = {s00[KK].axis_tkeep,s00[KK].axis_tuser,s00[KK].axis_tlast,s00[KK].axis_tdata};
// assign s00_data_inf[KK].data[m00.DSIZE]                 = s00[KK].axis_tlast;
// assign s00_data_inf[KK].data[m00.DSIZE+1]               = s00[KK].axis_tuser;
// assign s00_data_inf[KK].data[m00.DSIZE+m00.KSIZE+1-:m00.KSIZE]  = s00[KK].axis_tkeep;
assign s00[KK].axis_tready                              = s00_data_inf[KK].ready;
end
endgenerate


data_pipe_interconnect_M2S #(
    // .DSIZE      (m00.DSIZE+m00.KSIZE+1+1     ),
    .NUM        (NUM       )
)data_pipe_interconnect_M2S_inst(
/*    input                 */    .clock            (m00.aclk       ),
/*    input                 */    .rst_n            (m00.aresetn    ),
/*    input                 */    .clk_en           (m00.aclken     ),
/*    input                  */   .vld_sw           (addr_vld       ),
/*    input [NSIZE-1:0]      */   .sw               (addr           ),
/*    output logic[NSIZE-1:0]*/   .curr_path        (curr_addr      ),
/*    data_inf.slaver       */    .s00              (s00_data_inf   ),
/*    data_inf.master       */    .m00              (m00_data_inf   )
);

assign m00.axis_tdata            = m00_data_inf.data[m00.DSIZE-1:0];
assign m00.axis_tvalid           = m00_data_inf.valid;
assign m00.axis_tlast            = m00_data_inf.data[m00.DSIZE];
assign m00.axis_tuser            = m00_data_inf.data[m00.DSIZE+1];
assign m00_data_inf.ready        = m00.axis_tready;
assign m00.axis_tkeep            = m00_data_inf.data[m00.DSIZE+m00.KSIZE+1-:m00.KSIZE];

//--->> ADDR STATUS <<---------------------
logic [NUM-1:0]     svld;

generate
for(KK=0;KK<NUM;KK++)begin
    assign svld[KK]     = s00[KK].axis_tvalid;
end
endgenerate

logic   lock_addr;
logic [NUM-1:0]     start_s;
logic [NUM-1:0]     relex;

generate
for(KK=0;KK<NUM;KK++)begin
    assign #1 start_s[KK]     = s00[KK].axis_tvalid;
    assign #1 relex[KK]       = s00[KK].axis_tvalid && s00[KK].axis_tready && s00[KK].axis_tlast;
end
endgenerate

int II;

always@(posedge m00.aclk)begin:LOCK_BLOCK
    if(~m00.aresetn)    lock_addr   <= 1'b0;
    else begin
        if(|relex)
                lock_addr   <= 1'b0;
        else if(|start_s)
                lock_addr   <= 1'b1;
        else    lock_addr   <= lock_addr;
    end
end

logic [NSIZE-1:0]   addr_t = {NSIZE{1'b0}};

always@(*)begin
    addr_t = 0;
    for(II=0;II<NUM;II++)begin
        addr_t  = svld[NUM-1-II]? (NUM-1-II) : addr_t;
    end
end

//-------------------------------------------
// when this
//   __  __
//__| |_|  ....... valid

logic [NUM-1:0]   svld_t_q;

always@(posedge m00.aclk)begin
    if(~m00.aresetn)    svld_t_q    <= '0;
    else begin
        svld_t_q    <= svld;
    end
end

always@(posedge m00.aclk)begin
    if(~m00.aresetn)    addr    <= {NSIZE{1'b0}};
    else begin
        // if(lock_addr && (svld_t_q == svld))
        if(lock_addr)
                addr    <= addr;
        else    addr    <= addr_t;
    end
end

always@(posedge m00.aclk)begin
    if(~m00.aresetn)    addr_vld    <= 1'b0;
    else begin
        if(lock_addr)
                addr_vld    <= addr ==  curr_addr;
        else    addr_vld    <= 1'b0;
    end
end
//---<< ADDR STATUS >>---------------------
endmodule

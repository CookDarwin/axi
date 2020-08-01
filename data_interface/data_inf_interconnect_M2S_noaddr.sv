/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
    build from axi_stream_interconnect_M2S_noaddr
creaded: 2017/3/16 
madified:
***********************************************/
`timescale 1ns/1ps
module data_inf_interconnect_M2S_noaddr #(
    parameter   NUM   = 8,
    parameter   NSIZE =  $clog2(NUM),
    parameter   PRIO  = "OFF"
)(
    input            clock,
    input            rst_n,
    data_inf.slaver  s00 [NUM-1:0],
    data_inf.master  m00
);

logic[NSIZE-1:0]    addr;
logic               addr_vld;
logic[NSIZE-1:0]    curr_addr;


data_inf #(.DSIZE(m00.DSIZE) ) s00_data_inf [NUM-1:0] ();
data_inf #(.DSIZE(m00.DSIZE) ) m00_data_inf ();

genvar KK;
generate
for(KK=0;KK<NUM;KK++)begin
assign s00_data_inf[KK].valid                           = s00[KK].valid;
assign s00_data_inf[KK].data/*[m00.DSIZE-1:0]*/         = s00[KK].data;
assign s00[KK].ready                                    = s00_data_inf[KK].ready;
end
endgenerate


data_pipe_interconnect_M2S #(
    // .DSIZE      (m00.DSIZE     ),
    .NUM        (NUM       )
)data_pipe_interconnect_M2S_inst(
/*    input                 */    .clock            (clock          ),
/*    input                 */    .rst_n            (rst_n          ),
/*    input                 */    .clk_en           (1'b1           ),
/*    input                  */   .vld_sw           (addr_vld       ),
/*    input [NSIZE-1:0]      */   .sw               (addr           ),
/*    output logic[NSIZE-1:0]*/   .curr_path        (curr_addr      ),
/*    data_inf.slaver       */    .s00              (s00_data_inf   ),
/*    data_inf.master       */    .m00              (m00_data_inf   )
);

assign m00.data                  = m00_data_inf.data[m00.DSIZE-1:0];
assign m00.valid                 = m00_data_inf.valid;
assign m00_data_inf.ready        = m00.ready;

//--->> ADDR STATUS <<---------------------
logic [NUM-1:0]     svld;

generate
for(KK=0;KK<NUM;KK++)begin
    assign svld[KK]     = s00[KK].valid;
end
endgenerate

logic   lock_addr;
logic [NUM-1:0]     start_s;
logic [NUM-1:0]     relex;

generate
for(KK=0;KK<NUM;KK++)begin
    assign start_s[KK]     = s00[KK].valid;
    assign relex[KK]       = s00[KK].valid && s00[KK].ready;
end
endgenerate

int II;

always@(posedge clock)begin:LOCK_BLOCK
    if(~rst_n)    lock_addr   <= 1'b0;
    else begin
        if(|relex)
                lock_addr   <= 1'b0;
        else if(|start_s)
                lock_addr   <= 1'b1;
        else    lock_addr   <= lock_addr;
    end
end

//--->> PRIORITY <<-----------------------

logic [NUM-1:0]     priority_array;

always@(posedge clock)begin:PRIO_BLOCK
    if(~rst_n)  priority_array  <= '0;
    else begin
        foreach(relex[II])begin
            priority_array      <= '0;
            priority_array[II]  <= relex[II];
        end
    end
end
//---<< PRIORITY >>-----------------------
logic [NSIZE-1:0]   addr_t = {NSIZE{1'b0}};

always_comb begin
    addr_t  = '0;
    for(II=0;II<NUM;II++)begin
        if(PRIO == "OFF")
                addr_t  = (svld[NUM-1-II]                       ) ? (NUM-1-II) : addr_t;
        else    addr_t  = (svld[NUM-1-II] && !priority_array[II]) ? (NUM-1-II) : addr_t;
    end
end

always@(posedge clock)begin
    if(~rst_n)    addr    <= {NSIZE{1'b0}};
    else begin
        if(!lock_addr)
                addr    <= addr_t;
        else    addr    <= addr;
    end
end

always@(posedge clock)begin
    if(~rst_n)    addr_vld    <= 1'b0;
    else begin
        if(lock_addr)
                addr_vld    <= addr ==  curr_addr;
        else    addr_vld    <= 1'b0;
    end
end
//---<< ADDR STATUS >>---------------------
endmodule

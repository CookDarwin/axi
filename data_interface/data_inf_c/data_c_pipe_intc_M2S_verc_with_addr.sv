/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
    multi slaver to simple master
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/8/24 
madified:
***********************************************/
`timescale 1ns/1ps
module data_c_pipe_intc_M2S_verc_with_addr #(
    parameter   NUM   = 8,
    parameter   NSIZE =  NUM <= 2? 1 :
                         NUM <= 4? 2 :
                         NUM <= 8? 3 :
                         NUM <= 16?4 : 5
)(
    input [NUM-1:0]             last,
    data_inf_c.slaver           addr_inf,
    data_inf_c.slaver           s00 [NUM-1:0],
    data_inf_c.master           m00
);
logic                      clock;
logic                      rst_n;

assign clock    = m00.clock;
assign rst_n    = m00.rst_n;

//--->> PREPARE <<-------------------------------
genvar KK;
logic [NUM-1:0]         to_up_ready_array;
logic [NUM-1:0]         from_up_vld_array;
logic [m00.DSIZE-1:0]   from_up_data;
logic [m00.DSIZE-1:0]   from_up_data_array [NUM-1:0];
logic                   from_down_ready;
logic                   from_up_vld;
logic                   to_up_ready;
logic                   to_down_vld;
logic [$clog2(NUM)-1:0]       curr_path;

assign from_down_ready  = m00.ready;
assign to_down_vld      = m00.valid;

assign from_up_vld      = from_up_vld_array[curr_path];
assign to_up_ready      = to_up_ready_array[curr_path];

generate
for(KK=0;KK<NUM;KK++)begin
    assign from_up_vld_array[KK]    = s00[KK].valid;
    assign s00[KK].ready            = to_up_ready_array[KK];
    assign from_up_data_array[KK]   = s00[KK].data;
end
endgenerate

assign  from_up_data    = from_up_data_array[curr_path];
//---<< PREPARE >>-------------------------------
typedef enum {  IDLE                    ,
                EM_CN_EM_BUF            ,     //  empty connector,empty buffer
                VD_CN_EM_BUF            ,     //  valid connector,empty buffer
                VD_CN_VD_BUF_CLD_OPU    ,     //  valid connector,valid buffer,close down stream ,open upstream
                VD_CN_VD_BUF_OPD_CLU    ,     //  valid connector,valid buffer,open down stream ,close upstream
                OVER_FLOW                     //  error
            } STATUS;

STATUS      cstate,nstate;

always@(posedge clock,negedge rst_n)
    if(~rst_n)   cstate  <= IDLE;
    else         cstate  <= nstate;

wire        empty_buffer;
reg         connector_vld;

always_comb begin
    case(cstate)
    IDLE:       nstate  = EM_CN_EM_BUF;
    EM_CN_EM_BUF:
        if(from_up_vld && to_up_ready)
                nstate  = VD_CN_EM_BUF;
        else    nstate  = EM_CN_EM_BUF;
    VD_CN_EM_BUF:
        if(from_up_vld && to_up_ready)begin
            if(from_down_ready || !connector_vld)
                    nstate = VD_CN_EM_BUF;
            else    nstate = VD_CN_VD_BUF_CLD_OPU;
        end else begin
            if(!connector_vld)
                    nstate = EM_CN_EM_BUF;
            else    nstate = VD_CN_EM_BUF;
        end
    VD_CN_VD_BUF_CLD_OPU:
            nstate = VD_CN_VD_BUF_OPD_CLU;
    VD_CN_VD_BUF_OPD_CLU:
        if(empty_buffer)
                nstate = VD_CN_EM_BUF;
        else    nstate = VD_CN_VD_BUF_OPD_CLU;
    default:    nstate = IDLE;
    endcase
end


//--->> to up ready signal <<---------------
logic                   curr_path_vld;
// logic [NSIZE-1:0]       next_path;
reg                     over_buf_vld;
always@(posedge clock,negedge rst_n)
    if(~rst_n)   to_up_ready_array   <= '0;
    else begin
        to_up_ready_array   <= '0;
        case(nstate)
        EM_CN_EM_BUF,VD_CN_EM_BUF:
            // to_up_ready_array[next_path]  <= curr_path_vld;
            if(addr_inf.valid && addr_inf.ready)
                    to_up_ready_array[addr_inf.data]  <= 1'b1;
            else if(curr_path_vld && to_up_ready && from_up_vld && last[curr_path])
                    to_up_ready_array[curr_path]      <= 1'b0;
            else if(curr_path_vld)
                    to_up_ready_array[curr_path]      <= 1'b1;
        VD_CN_VD_BUF_CLD_OPU:begin
            to_up_ready_array   <= '0;
        end
        default:;
        endcase
    end

//---<< to up ready signal >>---------------
//--->> CURR PATH CTRL <<-------------------
// assign next_path = (addr_inf.valid && addr_inf.ready)? addr_inf.data : next_path;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  curr_path   <= '0;
    else begin
        if(addr_inf.valid && addr_inf.ready)
                curr_path   <= addr_inf.data;
        else    curr_path   <= curr_path;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  curr_path_vld   <= '0;
    else begin
        if(addr_inf.valid && addr_inf.ready && !curr_path_vld)
                curr_path_vld   <= 1'b1;
        // else if(addr_inf.valid && addr_inf.ready && curr_path_vld && to_up_ready && from_up_vld)
        //         curr_path_vld   <= 1'b1;
        else if(to_up_ready && from_up_vld && last[curr_path] && curr_path_vld)
                curr_path_vld   <= 1'b0;
        else    curr_path_vld   <= curr_path_vld;
    end

assign addr_inf.ready = !curr_path_vld;


//---<< CURR PATH CTRL >>-------------------
//--->> CONNECTOR <<------------------
reg [m00.DSIZE-1:0]     connector;
reg [m00.DSIZE-1:0]     over_buf;
always@(posedge clock,negedge rst_n)
    if(~rst_n)   connector   <= '0;
    else
        case(nstate)
        VD_CN_EM_BUF:
            if(from_up_vld && to_up_ready)
                    connector   <= from_up_data;
            else    connector   <= connector;
        VD_CN_VD_BUF_OPD_CLU:
            if(from_down_ready && to_down_vld)
                    connector   <= over_buf;
            else    connector   <= connector;
        default:connector   <= connector;
        endcase


always@(posedge clock,negedge rst_n)
    if(~rst_n)   connector_vld   <= 1'b0;
    else
        case(nstate)
        VD_CN_EM_BUF:
            if(~(from_up_vld & to_up_ready) && from_down_ready)
                    connector_vld   <= 1'b0;
            else    connector_vld   <= 1'b1;
        VD_CN_VD_BUF_OPD_CLU:
                    connector_vld   <= 1'b1;
        default:connector_vld   <= 1'b0;
        endcase
//---<< CONNECTOR >>------------------
//----->> BUFFER <<---------------------
always@(posedge clock,negedge rst_n)begin:BUFFER_BLOCK
    if(~rst_n)begin
        over_buf    <= '0;
    end else begin
        case(nstate)
        VD_CN_VD_BUF_CLD_OPU:begin
            if(from_up_vld && !over_buf_vld)
                    over_buf    <= from_up_data;
            else    over_buf    <= over_buf;
        end
        VD_CN_VD_BUF_OPD_CLU:begin
            if(from_down_ready && to_down_vld)begin
                    over_buf    <= '0;
            end
        end
        default:;
        endcase
end end

always@(posedge clock,negedge rst_n)
    if(~rst_n)   over_buf_vld    <= 1'b0;
    else
        case(nstate)
        VD_CN_VD_BUF_CLD_OPU:
                over_buf_vld <= from_up_vld;
        VD_CN_VD_BUF_OPD_CLU:
            if(from_down_ready && to_down_vld)
                    over_buf_vld <= 1'b0;
            else    over_buf_vld <= over_buf_vld;
        default:    over_buf_vld    <= 1'b0;
        endcase

assign empty_buffer = !over_buf_vld;
//-----<< BUFFER >>---------------------
assign m00.data     = connector;
assign m00.valid    = connector_vld;

endmodule

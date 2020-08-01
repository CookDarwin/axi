/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
    simple slaver to multi master
author : Cook.Darwin
Version: VERA.0.0
    build from data_pipe_interconnect_MM_S0
Version: VERA.1.0
    add lazy data
creaded: 2016/12/28 
madified:
***********************************************/
`timescale 1ns/1ps
module data_pipe_interconnect_S2M_A1 #(
    parameter   DSIZE = 8,
    parameter   NUM   = 8,
    parameter   NSIZE =  $clog2(NUM),
    parameter   LAZISE= 1
)(
    input               clock,
    input               rst_n,
    input               clk_en,
    input [NSIZE-1:0]   addr,       // sync to s00.valid
    // output logic[2:0]   curr_path,
    output[LAZISE-1:0]  m00_lazy_data [NUM-1:0],
    input [LAZISE-1:0]  s00_lazy_data ,
    data_inf.master     m00 [NUM-1:0],
    data_inf.slaver     s00
);


//-->> PARH DEF

logic [NSIZE-1:0]        from_up_path;
logic [NSIZE-1:0]        to_down_path;
logic [NSIZE-1:0]        over_buf_path;

logic              from_up_vld;
logic[DSIZE-1:0]   from_up_data;
logic              to_up_ready;

// logic[7:0]         to_up_ready_array;
logic [NUM-1:0]    to_down_vld_array;
logic [NUM-1:0]    from_down_ready_array;

logic              from_down_ready;
logic              to_down_vld;
logic[DSIZE-1:0]   to_down_data;


assign  from_up_vld     = s00.valid;
assign  from_up_data    = s00.data;
assign  s00.ready       = to_up_ready;

int II;
genvar KK;
generate
for(KK=0;KK<NUM;KK++)begin
    assign  m00[KK].data    = to_down_data;
    assign  m00[KK].valid   = to_down_vld_array[KK];
    assign  from_down_ready_array[KK] = m00[KK].ready;
end
endgenerate

assign from_down_ready = from_down_ready_array[to_down_path];

typedef enum {
    IDLE                ,
    EM_CN_EM_BUF        ,//  empty connector,empty buffer
    VD_CN_EM_BUF        ,//  valid connector,empty buffer
    VD_CN_VD_BUF_CLD_OPU,//  valid connector,valid buffer,close down stream ,open upstream
    VD_CN_VD_BUF_OPD_CLU,//  valid connector,valid buffer,open down stream ,close upstream
    OVER_FLOW            //  error
} STATUS;

STATUS      cstate,nstate;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)   cstate  <= IDLE;
    else         cstate  <= nstate;

reg         over_flow_buffer;
wire        empty_buffer;
wire        full_buffer;
reg         connector_vld;

always@(*)
    case(cstate)
    IDLE:       nstate  = EM_CN_EM_BUF;
    EM_CN_EM_BUF:
        if(from_up_vld && to_up_ready && clk_en)
                nstate  = VD_CN_EM_BUF;
        else    nstate  = EM_CN_EM_BUF;
    VD_CN_EM_BUF:
        if(from_up_vld && to_up_ready && clk_en)begin
            if(from_down_ready || !connector_vld)
                    nstate = VD_CN_EM_BUF;
            else    nstate = VD_CN_VD_BUF_CLD_OPU;
        end else begin
            if(!connector_vld)
                    nstate = EM_CN_EM_BUF;
            else    nstate = VD_CN_EM_BUF;
        end
    VD_CN_VD_BUF_CLD_OPU:
        if(over_flow_buffer)
                nstate = OVER_FLOW;
        //else if(from_up_vld && to_up_ready && clk_en)
        else if(full_buffer && clk_en)
                nstate = VD_CN_VD_BUF_OPD_CLU;
        else    nstate = VD_CN_VD_BUF_CLD_OPU;
    VD_CN_VD_BUF_OPD_CLU:
        if(empty_buffer && clk_en)
                nstate = VD_CN_EM_BUF;
        else    nstate = VD_CN_VD_BUF_OPD_CLU;
    OVER_FLOW:  nstate = OVER_FLOW;
    default:    nstate = IDLE;
    endcase
//--->> current path <<---------------------
// logic curr_path_vld;
//
// always@(posedge clock/*,negedge rst_n*/)
//     if(~rst_n)  curr_path   <= 3'd0;
//     else
//         case(nstate)
//         IDLE,EM_CN_EM_BUF:
//                 curr_path   <= sw;
//         default:curr_path   <= curr_path;
//         endcase
//
// always@(posedge clock/*,negedge rst_n*/)
//     if(~rst_n)  curr_path_vld   <= 1'd0;
//     else
//         case(nstate)
//         IDLE,EM_CN_EM_BUF:
//                 curr_path_vld   <= sw_vld;
//         default:curr_path_vld   <= curr_path_vld;
//         endcase
//---<< current path >>---------------------
//--->> to up ready signal <<---------------
reg             to_u_ready_reg;
reg             over_buf_vld;
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)   to_up_ready   <= 1'd0;
    else begin
        to_up_ready   <= 1'd0;
        case(nstate)
        EM_CN_EM_BUF,VD_CN_EM_BUF:
            if(clk_en)
                    to_up_ready  <= 1'b1;
            else    to_up_ready  <= to_up_ready;
        VD_CN_VD_BUF_CLD_OPU:begin
            if(clk_en)begin
                if(from_up_vld && to_up_ready)
                        to_up_ready   <= 1'b0;
                else    to_up_ready   <= to_up_ready;
            end else    to_up_ready   <= to_up_ready;
        end
        default:to_up_ready<= 1'b0;
        endcase
    end

// assign to_up_ready  = to_u_ready_reg;
//---<< to up ready signal >>---------------
//--->> CONNECTOR <<------------------
reg [DSIZE-1:0]     connector;
// reg                 connector_vld;
reg [DSIZE-1:0]     over_buf;
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)   connector   <= {DSIZE{1'b0}};
    else
        case(nstate)
        VD_CN_EM_BUF:
            if(from_up_vld && to_up_ready && clk_en)
                    connector   <= from_up_data;
            else    connector   <= connector;
        VD_CN_VD_BUF_OPD_CLU:
            if(from_down_ready && to_down_vld && clk_en)
                    connector   <= over_buf;
            else    connector   <= connector;
        IDLE,EM_CN_EM_BUF:
                connector   <= {DSIZE{1'b0}};
        default:connector   <= connector;
        endcase


always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)   connector_vld   <= 1'b0;
    else
        case(nstate)
        VD_CN_EM_BUF:
            if(~(from_up_vld & to_up_ready) && from_down_ready && clk_en)
                    connector_vld   <= 1'b0;
            else    connector_vld   <= 1'b1;
        VD_CN_VD_BUF_OPD_CLU:
            if(clk_en)
                    connector_vld   <= 1'b1;
            else    connector_vld   <= connector_vld;
        default:connector_vld   <= 1'b0;
        endcase
//---<< CONNECTOR >>------------------
//----->> BUFFER <<---------------------
always@(posedge clock/*,negedge rst_n*/)begin:BUFFER_BLOCK
    if(~rst_n)begin
        over_buf    <= {DSIZE{1'b0}};
    end else begin
        case(nstate)
        VD_CN_VD_BUF_CLD_OPU:begin
            if(from_up_vld && !over_buf_vld && clk_en)
                    over_buf    <= from_up_data;
            else    over_buf    <= over_buf;
        end
        VD_CN_VD_BUF_OPD_CLU:begin
            if(from_down_ready && to_down_vld && clk_en)begin
                    over_buf    <= {DSIZE{1'b0}};
            end
        end
        default:;
        endcase
end end

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)   over_buf_vld    <= 1'b0;
    else
        case(nstate)
        VD_CN_VD_BUF_CLD_OPU:
            if(clk_en)
                    over_buf_vld <= from_up_vld;
            else    over_buf_vld <= over_buf_vld;
        VD_CN_VD_BUF_OPD_CLU:
            if(from_down_ready && to_down_vld && clk_en)
                    over_buf_vld <= 1'b0;
            else    over_buf_vld <= over_buf_vld;
        default:    over_buf_vld    <= 1'b0;
        endcase

assign empty_buffer = !over_buf_vld;
assign full_buffer  =  over_buf_vld;
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)   over_flow_buffer    <= 1'b0;
    else
        case(nstate)
        VD_CN_VD_BUF_CLD_OPU:
            if( over_buf_vld && to_up_ready && from_up_vld && clk_en)
                    over_flow_buffer    <= 1'b1;
            else    over_flow_buffer    <= 1'b0;
        default:    over_flow_buffer    <= 1'b0;
        endcase
//-----<< BUFFER >>---------------------
//----->> to down data <<---------------
reg         to_d_wr_en_reg;

// always@(posedge clock/*,negedge rst_n*/)
//     if(~rst_n)  to_d_wr_en_reg  <= 1'b0;
//     else
//         case(nstate)
//         VD_CN_EM_BUF:
//             if(~(from_up_vld & to_up_ready) && from_down_ready && clk_en)
//                     to_d_wr_en_reg  <= 1'b0;
//             else    to_d_wr_en_reg  <= 1'b1;
//         VD_CN_VD_BUF_OPD_CLU:
//             if(clk_en)
//                     to_d_wr_en_reg  <= 1'b1;
//             else    to_d_wr_en_reg  <= to_d_wr_en_reg;
//         default:to_d_wr_en_reg  <= 1'b0;
//         endcase

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  to_down_vld_array  <= {NUM{1'b0}};
    else begin
        to_down_vld_array  <= {NUM{1'b0}};
        case(nstate)
        VD_CN_EM_BUF:
            if(~(from_up_vld & to_up_ready) && from_down_ready && clk_en)
                    to_down_vld_array[to_down_path]  <= 1'b0;
            else    to_down_vld_array[from_up_path]  <= 1'b1;
        VD_CN_VD_BUF_OPD_CLU:
            if(clk_en)
                    to_down_vld_array[to_down_path]  <= 1'b1;
            else    to_down_vld_array[to_down_path]  <= to_down_vld_array[to_down_path];
        default:    to_down_vld_array[to_down_path]  <= 1'b0;
        endcase
    end
//-----<< to down data >>---------------
assign to_down_data = connector;
// assign to_down_vld  = to_d_wr_en_reg;
assign to_down_vld = to_down_vld_array[to_down_path];

//--->> PATH CTRL <<-------------------
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)   to_down_path   <= {(NSIZE){1'b0}};
    else
        case(nstate)
        VD_CN_EM_BUF:
            if(from_up_vld && to_up_ready && clk_en)
                    to_down_path   <= addr;
            else    to_down_path   <= to_down_path;
        VD_CN_VD_BUF_OPD_CLU:
            if(from_down_ready && to_down_vld && clk_en)
                    to_down_path   <= over_buf_path;
            else    to_down_path   <= to_down_path;
        default:to_down_path   <= to_down_path;
        endcase

always@(posedge clock/*,negedge rst_n*/)begin:BUFFER_PATH_BLOCK
    if(~rst_n)begin
        over_buf_path    <= {(NSIZE){1'b0}};
    end else begin
        case(nstate)
        VD_CN_VD_BUF_CLD_OPU:begin
            if(from_up_vld && !over_buf_vld && clk_en)
                    over_buf_path    <= addr;
            else    over_buf_path    <= over_buf_path;
        end
        VD_CN_VD_BUF_OPD_CLU:begin
            if(from_down_ready && to_down_vld && clk_en)begin
                    over_buf_path    <= {(NSIZE){1'b0}};
            end
        end
        default:;
        endcase
end end

assign from_up_path   = addr;
//---<< PATH CTRL >>-------------------
//--->> LAZY CONNECTOR <<------------------
reg [LAZISE-1:0]    lazy_connector;
// reg                 connector_vld;
reg [LAZISE-1:0]    lazy_over_buf;
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)   lazy_connector   <= '0;
    else
        case(nstate)
        VD_CN_EM_BUF:
            if(from_up_vld && to_up_ready && clk_en)
                    lazy_connector   <= s00_lazy_data;
            else    lazy_connector   <= lazy_connector;
        VD_CN_VD_BUF_OPD_CLU:
            if(from_down_ready && to_down_vld && clk_en)
                    lazy_connector   <= lazy_over_buf;
            else    lazy_connector   <= lazy_connector;
        IDLE:
                lazy_connector   <= {DSIZE{1'b0}};
        default:lazy_connector   <= lazy_connector;
        endcase

//---<< LAZY CONNECTOR >>------------------
//----->> LAZY BUFFER <<---------------------
always@(posedge clock/*,negedge rst_n*/)begin:LAZY_BUFFER_BLOCK
    if(~rst_n)begin
        lazy_over_buf    <= '0;
    end else begin
        case(nstate)
        VD_CN_VD_BUF_CLD_OPU:begin
            if(from_up_vld && !over_buf_vld && clk_en)
                    lazy_over_buf    <= s00_lazy_data;
            else    lazy_over_buf    <= lazy_over_buf;
        end
        VD_CN_VD_BUF_OPD_CLU:begin
            if(from_down_ready && to_down_vld && clk_en)begin
                    lazy_over_buf    <= {DSIZE{1'b0}};
            end
        end
        default:;
        endcase
end end
//-----<< LAZY BUFFER >>---------------------

generate
for(KK=0;KK<NUM;KK++)begin
    assign  m00_lazy_data[KK]    = lazy_connector;
end
endgenerate

endmodule

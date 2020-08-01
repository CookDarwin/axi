/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version:
creaded: 2016/11/14 
madified:2016/12/12 
    VD_CN_EM_BUF -> VD_CN_EM_BUF, when from_up_vld && to_up_ready && !connector_vld
***********************************************/
`timescale 1ns/1ps
module data_pipe_interconnect #(
    parameter   DSIZE = 8
)(
    input               clock,
    input               rst_n,
    input               clk_en,
    input               vld_sw,
    input [2:0]         sw,
    output logic[2:0]   curr_path,

    data_inf.slaver     s00,
    data_inf.slaver     s01,
    data_inf.slaver     s02,
    data_inf.slaver     s03,
    data_inf.slaver     s04,
    data_inf.slaver     s05,
    data_inf.slaver     s06,
    data_inf.slaver     s07,

    data_inf.master     m00
);

logic              from_up_vld;
logic[DSIZE-1:0]   from_up_data;
logic              to_up_ready;

logic[7:0]         to_up_ready_array;

logic              from_down_ready;
logic              to_down_vld;
logic[DSIZE-1:0]   to_down_data;

assign  from_down_ready = m00.ready;
assign  m00.valid       = to_down_vld;
assign  m00.data        = to_down_data;

always@(*)
    case(curr_path)
    0:  from_up_vld = s00.valid;
    1:  from_up_vld = s01.valid;
    2:  from_up_vld = s02.valid;
    3:  from_up_vld = s03.valid;
    4:  from_up_vld = s04.valid;
    5:  from_up_vld = s05.valid;
    6:  from_up_vld = s06.valid;
    7:  from_up_vld = s07.valid;
    default:
        from_up_vld = s00.valid;
    endcase

always@(*)
    case(curr_path)
    0:  from_up_data = s00.data;
    1:  from_up_data = s01.data;
    2:  from_up_data = s02.data;
    3:  from_up_data = s03.data;
    4:  from_up_data = s04.data;
    5:  from_up_data = s05.data;
    6:  from_up_data = s06.data;
    7:  from_up_data = s07.data;
    default:
        from_up_data = s00.data;
    endcase

// always@(*)
//     case(curr_path)
//     0:  to_up_ready = to_up_ready_array[0];
//     1:  to_up_ready = to_up_ready_array[1];
//     2:  to_up_ready = to_up_ready_array[2];
//     3:  to_up_ready = to_up_ready_array[3];
//     4:  to_up_ready = to_up_ready_array[4];
//     5:  to_up_ready = to_up_ready_array[5];
//     6:  to_up_ready = to_up_ready_array[6];
//     7:  to_up_ready = to_up_ready_array[7];
//     default:
//         to_up_ready = to_up_ready_array[0];
//     endcase
assign to_up_ready = to_up_ready_array[curr_path];

assign  s00.ready   = to_up_ready_array[0];
assign  s01.ready   = to_up_ready_array[1];
assign  s02.ready   = to_up_ready_array[2];
assign  s03.ready   = to_up_ready_array[3];
assign  s04.ready   = to_up_ready_array[4];
assign  s05.ready   = to_up_ready_array[5];
assign  s06.ready   = to_up_ready_array[6];
assign  s07.ready   = to_up_ready_array[7];



reg [3:0]       cstate,nstate;
localparam      IDLE                    = 4'd0,
                EM_CN_EM_BUF            = 4'd1,     //  empty connector,empty buffer
                VD_CN_EM_BUF            = 4'd2,     //  valid connector,empty buffer
                VD_CN_VD_BUF_CLD_OPU    = 4'd3,     //  valid connector,valid buffer,close down stream ,open upstream
                VD_CN_VD_BUF_OPD_CLU    = 4'd4,     //  valid connector,valid buffer,open down stream ,close upstream
                OVER_FLOW               = 4'd5;     //  error

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
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  curr_path   <= 3'd0;
    else
        case(nstate)
        IDLE,EM_CN_EM_BUF:
                curr_path   <= sw;
        default:curr_path   <= curr_path;
        endcase
//---<< current path >>---------------------
//--->> to up ready signal <<---------------
reg             to_u_ready_reg;
reg             over_buf_vld;
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)   to_up_ready_array   <= 8'd0;
    else begin
        to_up_ready_array   <= 8'd0;
        case(nstate)
        EM_CN_EM_BUF,VD_CN_EM_BUF:
            if(clk_en)
                    to_up_ready_array[curr_path]  <= vld_sw;
            else    to_up_ready_array[curr_path]  <= to_up_ready_array[curr_path] && vld_sw;
        VD_CN_VD_BUF_CLD_OPU:begin
            if(clk_en)begin
                if(from_up_vld && to_up_ready)
                        to_up_ready_array[curr_path]   <= 1'b0;
                else    to_up_ready_array[curr_path]   <= to_up_ready_array[curr_path] && vld_sw ;
            end else    to_up_ready_array[curr_path]   <= to_up_ready_array[curr_path] && vld_sw;
        end
        default:to_up_ready_array[curr_path]   <= 1'b0;
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

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  to_d_wr_en_reg  <= 1'b0;
    else
        case(nstate)
        VD_CN_EM_BUF:
            if(~(from_up_vld & to_up_ready) && from_down_ready && clk_en)
                    to_d_wr_en_reg  <= 1'b0;
            else    to_d_wr_en_reg  <= 1'b1;
        VD_CN_VD_BUF_OPD_CLU:
            if(clk_en)
                    to_d_wr_en_reg  <= 1'b1;
            else    to_d_wr_en_reg  <= to_d_wr_en_reg;
        default:to_d_wr_en_reg  <= 1'b0;
        endcase
//-----<< to down data >>---------------
assign to_down_data = connector;
assign to_down_vld  = to_d_wr_en_reg;

endmodule

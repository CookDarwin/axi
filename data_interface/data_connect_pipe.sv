/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version:VERA.0.1 2017/1/19 
creaded: 2016/9/27 
madified:
    VD_CN_EM_BUF -> VD_CN_EM_BUF, when from_up_vld && to_up_ready && !connector_vld
***********************************************/
`timescale 1ns/1ps
module data_connect_pipe #(
    parameter   DSIZE = 8
)(
    input               clock,
    input               rst_n,
    input               clk_en,
    input               from_up_vld,
    input [DSIZE-1:0]   from_up_data,
    output              to_up_ready,

    input               from_down_ready,
    output              to_down_vld,
    output[DSIZE-1:0]   to_down_data
);

initial begin
    $error("The module `data_connect_pipe` has be abandon, please use `data_c_pipe_inf`");
    $stop;
end


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


//--->> to down write enable <<-------
// reg         to_d_wr_en;
// always@(posedge clock/*,negedge rst_n*/)
//     if(~rst_n)   to_d_wr_en  <= 1'b0;
//     else
//         case(nstate)
//         VD_CN_EM_BUF,VD_CN_VD_BUF_OPD_CLU:
//             if(clk_en)
//                     to_d_wr_en  <= 1'b1;
//             else    to_d_wr_en  <= to_d_wr_en;
//         default:to_d_wr_en  <= 1'b0;
//         endcase
// assign  to_down_vld = to_d_wr_en;
//---<< to down write enable >>-------
//--->> to up ready signal <<---------------
reg             to_u_ready_reg;
reg             over_buf_vld;
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)   to_u_ready_reg  <= 1'b0;
    else
        case(nstate)
        EM_CN_EM_BUF,VD_CN_EM_BUF:
            if(clk_en)
                    to_u_ready_reg  <= 1'b1;
            else    to_u_ready_reg  <= to_u_ready_reg;
        VD_CN_VD_BUF_CLD_OPU:begin
            if(clk_en)begin
                if(from_up_vld && to_up_ready)
                        to_u_ready_reg  <= 1'b0;
                else    to_u_ready_reg  <= to_u_ready_reg;
            end else    to_u_ready_reg  <= to_u_ready_reg;
        end
        default:to_u_ready_reg  <= 1'b0;
        endcase

assign to_up_ready  = to_u_ready_reg;
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
        // IDLE,EM_CN_EM_BUF,VD_CN_VD_BUF_CLD_OPU:
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

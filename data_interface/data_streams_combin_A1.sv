/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________descript:
author : Cook.Darwin
Version: VERA.0.0
    build from data_streams_scaler VA.0.1
Version: VERA.1.0
    A.0.0 can't combin only one data of head_inf
Version: VERA.1.1 2018-4-12 16:00:08
    FSH_VD_CN_EM_BUF_OPD_CLU status shauld process valid currect;
creaded: 2016/12/19 
madified:
***********************************************/
`timescale 1ns/1ps
module data_streams_combin_A1 #(
    parameter   MODE = "BOTH",       //HEAD END BOTH
    parameter   DSIZE = 8
)(
    input               clock,
    input               rst_n,
    input               clk_en,
    input               trigger_signal,
    input               head_last,
    input               body_last,
    input               end_last,

    data_inf.slaver     head_inf,
    data_inf.slaver     body_inf,
    data_inf.slaver     end_inf,

    data_inf.master     m00
);

initial begin
    $error("The module `data_streams_combin_A1` has be abandon, please use `data_c_scaler_A1`");
    $stop;
end

logic   connector_vld;
logic   empty_buffer;
logic   over_flow_buffer;
logic   full_buffer;
logic   over_buf_vld;

typedef enum {  IDLE,
                HEAD_EM_CN_EM_BUF,               //  empty connector,empty buffer
                HEAD_VD_CN_EM_BUF,               //  valid connector,empty buffer
                HEAD_VD_CN_VD_BUF_CLD_OPU,       //  valid connector,valid buffer,close down stream ,open upstream
                HEAD_VD_CN_VD_BUF_OPD_CLU,       //  valid connector,valid buffer,open down stream ,close upstream

                BODY_EM_CN_EM_BUF,
                BODY_VD_CN_EM_BUF,
                BODY_VD_CN_VD_BUF_CLD_OPU,
                BODY_VD_CN_VD_BUF_OPD_CLU,

                END_EM_CN_EM_BUF,
                END_VD_CN_EM_BUF,
                END_VD_CN_VD_BUF_CLD_OPU,
                END_VD_CN_VD_BUF_OPD_CLU,

                FSH_VD_CN_EM_BUF_OPD_CLU,        // complete, valid connector,empty buffer,open down stream ,close upstream
                OVER_FLOW
            }   STATUS;

STATUS cstate,nstate;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)   cstate  <= IDLE;
    else         cstate  <= nstate;

logic       head_last_flag;
logic       body_last_flag;
logic       end_last_flag;

always@(*)
    case(cstate)
    IDLE:
        // if(body_inf.valid)begin
        if(trigger_signal)begin
            if(MODE=="BOTH" || MODE=="HEAD")
                    nstate  = HEAD_EM_CN_EM_BUF;
            else    nstate  = BODY_EM_CN_EM_BUF;
        end else    nstate  = IDLE;
    //--->>HEAD STATUS <<----------
    HEAD_EM_CN_EM_BUF:
        if(head_inf.valid && head_inf.ready && clk_en)begin
            if(m00.ready || !connector_vld)begin
                if(head_last)
                        nstate = BODY_VD_CN_EM_BUF;
                else    nstate = HEAD_VD_CN_EM_BUF;
            end else    nstate = HEAD_VD_CN_VD_BUF_CLD_OPU;
        // if(head_inf.valid && head_inf.ready && clk_en)begin
        //     if(!head_last)
        //             nstate  = HEAD_VD_CN_EM_BUF;
        //     else    nstate = BODY_VD_CN_EM_BUF;
        end
        else    nstate  = HEAD_EM_CN_EM_BUF;
    HEAD_VD_CN_EM_BUF:
        if(head_inf.valid && head_inf.ready && clk_en)begin
            if(m00.ready || !connector_vld)begin
                if(head_last)
                        nstate = BODY_VD_CN_EM_BUF;
                else    nstate = HEAD_VD_CN_EM_BUF;
            end
            else    nstate = HEAD_VD_CN_VD_BUF_CLD_OPU;
        end else begin
            if(!connector_vld)
                    nstate = HEAD_EM_CN_EM_BUF;
            else    nstate = HEAD_VD_CN_EM_BUF;
        end
    HEAD_VD_CN_VD_BUF_CLD_OPU:
        if(over_flow_buffer)
                nstate = OVER_FLOW;
        //else if(from_up_vld && to_up_ready && clk_en)
        else if(full_buffer && clk_en)
                nstate = HEAD_VD_CN_VD_BUF_OPD_CLU;
        else    nstate = HEAD_VD_CN_VD_BUF_CLD_OPU;
    HEAD_VD_CN_VD_BUF_OPD_CLU:
        if(empty_buffer && clk_en)begin
            if(head_last_flag)
                    nstate = BODY_VD_CN_EM_BUF;
            else    nstate = HEAD_VD_CN_EM_BUF;
        end else    nstate = HEAD_VD_CN_VD_BUF_OPD_CLU;
    //---<<HEAD STATUS >>----------
    //--->>BODY STATUS <<----------
    BODY_EM_CN_EM_BUF:
        // if(body_inf.valid && body_inf.ready && clk_en)
        //         nstate  = BODY_VD_CN_EM_BUF;
        if(body_inf.valid && body_inf.ready && clk_en)begin
            if(m00.ready || !connector_vld)begin
                if(body_last)begin
                    if(MODE == "BOTH" || MODE == "END")
                            nstate = END_VD_CN_EM_BUF;
                    else    nstate = FSH_VD_CN_EM_BUF_OPD_CLU;
                end
                else    nstate = BODY_VD_CN_EM_BUF;
            end else    nstate = BODY_VD_CN_VD_BUF_CLD_OPU;
        end
        else    nstate  = BODY_EM_CN_EM_BUF;
    BODY_VD_CN_EM_BUF:
        if(body_inf.valid && body_inf.ready && clk_en)begin
            if(m00.ready || !connector_vld)begin
                if(body_last)begin
                    if(MODE == "BOTH" || MODE == "END")
                            nstate = END_VD_CN_EM_BUF;
                    else    nstate = FSH_VD_CN_EM_BUF_OPD_CLU;
                end
                else    nstate = BODY_VD_CN_EM_BUF;
            end
            else    nstate = BODY_VD_CN_VD_BUF_CLD_OPU;
        end else begin
            if(!connector_vld)
                    nstate = BODY_EM_CN_EM_BUF;
            else    nstate = BODY_VD_CN_EM_BUF;
        end
    BODY_VD_CN_VD_BUF_CLD_OPU:
        if(over_flow_buffer)
                nstate = OVER_FLOW;
        //else if(from_up_vld && to_up_ready && clk_en)
        else if(full_buffer && clk_en)
                nstate = BODY_VD_CN_VD_BUF_OPD_CLU;
        else    nstate = BODY_VD_CN_VD_BUF_CLD_OPU;
    BODY_VD_CN_VD_BUF_OPD_CLU:
        if(empty_buffer && clk_en)begin
            if(!body_last_flag)
                    nstate = BODY_VD_CN_EM_BUF;
            else begin
                if(MODE == "BOTH" || MODE == "END")
                        nstate = END_VD_CN_EM_BUF;
                else    nstate = FSH_VD_CN_EM_BUF_OPD_CLU;
            end
        end else    nstate = BODY_VD_CN_VD_BUF_OPD_CLU;
    //---<<BODY STATUS >>----------
    //--->>END STATUS <<----------
    END_EM_CN_EM_BUF:
        // if(body_inf.valid && body_inf.ready && clk_en)
        //         nstate  = END_VD_CN_EM_BUF;
        if(end_inf.valid && end_inf.ready && clk_en)begin
            if(m00.ready || !connector_vld)begin
                if(end_last)
                        nstate = FSH_VD_CN_EM_BUF_OPD_CLU;
                else    nstate = END_VD_CN_EM_BUF;
            end
            else    nstate = END_VD_CN_VD_BUF_CLD_OPU;
        end
        else    nstate  = END_EM_CN_EM_BUF;
    END_VD_CN_EM_BUF:
        if(end_inf.valid && end_inf.ready && clk_en)begin
            if(m00.ready || !connector_vld)begin
                if(end_last)
                        nstate = FSH_VD_CN_EM_BUF_OPD_CLU;
                else    nstate = END_VD_CN_EM_BUF;
            end
            else    nstate = END_VD_CN_VD_BUF_CLD_OPU;
        end else begin
            if(!connector_vld)
                    nstate = END_EM_CN_EM_BUF;
            else    nstate = END_VD_CN_EM_BUF;
        end
    END_VD_CN_VD_BUF_CLD_OPU:
        if(over_flow_buffer)
                nstate = OVER_FLOW;
        //else if(from_up_vld && to_up_ready && clk_en)
        else if(full_buffer && clk_en)
                nstate = END_VD_CN_VD_BUF_OPD_CLU;
        else    nstate = END_VD_CN_VD_BUF_CLD_OPU;
    END_VD_CN_VD_BUF_OPD_CLU:
        if(empty_buffer && clk_en)begin
            if(end_last_flag)
                    nstate = FSH_VD_CN_EM_BUF_OPD_CLU;
            else    nstate = END_VD_CN_EM_BUF;
        end else    nstate = END_VD_CN_VD_BUF_OPD_CLU;
    //---<<END STATUS >>----------
    FSH_VD_CN_EM_BUF_OPD_CLU:
        // if(m00.ready && m00.valid)
        //         nstate = IDLE;
        // else    nstate = FSH_VD_CN_EM_BUF_OPD_CLU;

        if(!m00.valid)      // now,last byte has be trans
                nstate = IDLE;
        else    nstate = FSH_VD_CN_EM_BUF_OPD_CLU;
    OVER_FLOW:  nstate = OVER_FLOW;
    default:    nstate = IDLE;
    endcase

//---->> LAST TO BUFFER <<-----------------
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  head_last_flag  <= 1'b0;
    else
        case(nstate)
        HEAD_EM_CN_EM_BUF,HEAD_VD_CN_VD_BUF_CLD_OPU,HEAD_VD_CN_VD_BUF_OPD_CLU:begin
            if(head_inf.valid && head_inf.ready && clk_en && head_last)
                    head_last_flag  <= 1'b1;
            else    head_last_flag  <= head_last_flag;
        end
        IDLE,HEAD_EM_CN_EM_BUF,BODY_VD_CN_EM_BUF:
                head_last_flag  <= 1'b0;
        default:;
        endcase

//
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  body_last_flag  <= 1'b0;
    else
        case(nstate)
        BODY_VD_CN_VD_BUF_CLD_OPU,BODY_VD_CN_VD_BUF_OPD_CLU:begin
            if(body_inf.valid && body_inf.ready && clk_en && body_last)
                    body_last_flag  <= 1'b1;
            else    body_last_flag  <= body_last_flag;
        end
        IDLE,HEAD_EM_CN_EM_BUF,END_VD_CN_EM_BUF:
                body_last_flag  <= 1'b0;
        default:;
        endcase

//
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  end_last_flag  <= 1'b0;
    else
        case(nstate)
        END_VD_CN_VD_BUF_CLD_OPU,END_VD_CN_VD_BUF_OPD_CLU:begin
            if(end_inf.valid && end_inf.ready && clk_en && end_last)
                    end_last_flag  <= 1'b1;
            else    end_last_flag  <= end_last_flag;
        end
        IDLE,HEAD_EM_CN_EM_BUF,END_VD_CN_VD_BUF_CLD_OPU,FSH_VD_CN_EM_BUF_OPD_CLU:
                end_last_flag  <= 1'b0;
        default:;
        endcase
//----<< LAST TO BUFFER >>-----------------
//------------------------------------------
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)   head_inf.ready  <= 1'b0;
    else
        case(nstate)
        HEAD_EM_CN_EM_BUF,HEAD_VD_CN_EM_BUF:
            if(clk_en)
                    head_inf.ready  <= 1'b1;
            else    head_inf.ready  <= head_inf.ready;
        HEAD_VD_CN_VD_BUF_CLD_OPU:begin
            if(clk_en)begin
                if(head_inf.valid && head_inf.ready)
                        head_inf.ready  <= 1'b0;
                else    head_inf.ready  <= head_inf.ready;
            end else    head_inf.ready  <= head_inf.ready;
        end
        default:head_inf.ready  <= 1'b0;
        endcase
//
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)   body_inf.ready  <= 1'b0;
    else
        case(nstate)
        BODY_EM_CN_EM_BUF,BODY_VD_CN_EM_BUF:
            if(clk_en)
                    body_inf.ready  <= 1'b1;
            else    body_inf.ready  <= body_inf.ready;
        BODY_VD_CN_VD_BUF_CLD_OPU:begin
            if(clk_en)begin
                if(body_inf.valid && body_inf.ready)
                        body_inf.ready  <= 1'b0;
                else    body_inf.ready  <= body_inf.ready;
            end else    body_inf.ready  <= body_inf.ready;
        end
        default:body_inf.ready  <= 1'b0;
        endcase
//
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)   end_inf.ready  <= 1'b0;
    else
        case(nstate)
        END_EM_CN_EM_BUF,END_VD_CN_EM_BUF:
            if(clk_en)
                    end_inf.ready  <= 1'b1;
            else    end_inf.ready  <= end_inf.ready;
        END_VD_CN_VD_BUF_CLD_OPU:begin
            if(clk_en)begin
                if(end_inf.valid && end_inf.ready)
                        end_inf.ready  <= 1'b0;
                else    end_inf.ready  <= end_inf.ready;
            end else    end_inf.ready  <= end_inf.ready;
        end
        default:end_inf.ready  <= 1'b0;
        endcase

//---<< to up ready signal >>---------------
//--->> CONNECTOR <<------------------
reg [DSIZE-1:0]     connector;
reg [DSIZE-1:0]     over_buf;


always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)   connector   <= {DSIZE{1'b0}};
    else
        case(nstate)
        //--HEAD
        HEAD_VD_CN_EM_BUF:
            if(head_inf.valid && head_inf.ready && clk_en)
                    connector   <= head_inf.data;
            else    connector   <= connector;
        HEAD_VD_CN_VD_BUF_OPD_CLU:
            if(m00.ready && m00.valid && clk_en)
                    connector   <= over_buf;
            else    connector   <= connector;
        //--BODY
        BODY_VD_CN_EM_BUF:
            if(head_inf.valid & head_inf.ready & head_last & (m00.ready||!connector_vld) & clk_en)        //JUMP MOMMENT
                    connector   <= head_inf.data;
            else if(body_inf.valid && body_inf.ready && clk_en)
                    connector   <= body_inf.data;
            else    connector   <= connector;
        BODY_VD_CN_VD_BUF_OPD_CLU:
            if(m00.ready && m00.valid && clk_en)
                    connector   <= over_buf;
            else    connector   <= connector;
        //--END
        END_VD_CN_EM_BUF:
            if(body_inf.valid & body_inf.ready & body_last & (m00.ready||!connector_vld) & clk_en)        //JUMP MOMMENT
                    connector   <= body_inf.data;
            else if(end_inf.valid && end_inf.ready && clk_en)
                    connector   <= end_inf.data;
            else    connector   <= connector;
        END_VD_CN_VD_BUF_OPD_CLU:
            if(m00.ready && m00.valid && clk_en)
                    connector   <= over_buf;
            else    connector   <= connector;
        FSH_VD_CN_EM_BUF_OPD_CLU:begin
            if(MODE=="HEAD")begin
                if(body_inf.valid & body_inf.ready & m00.ready & clk_en)
                        connector  <= body_inf.data;
                else    connector   <= connector;
            end else begin
                if(end_inf.valid && end_inf.ready && clk_en)
                        connector  <= end_inf.data;
                else    connector  <= connector;
            end
        end
        default:connector   <= connector;
        endcase


always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)   connector_vld   <= 1'b0;
    else
        case(nstate)
        //--HEAD
        HEAD_VD_CN_EM_BUF:
            if(~(head_inf.valid & head_inf.ready) && m00.ready && clk_en)
                    connector_vld   <= 1'b0;
            else    connector_vld   <= 1'b1;
        HEAD_VD_CN_VD_BUF_OPD_CLU:
            if(clk_en)
                    connector_vld   <= 1'b1;
            else    connector_vld   <= connector_vld;
        //--BODY
        BODY_VD_CN_EM_BUF:
            if(head_inf.valid & head_inf.ready & head_last & m00.ready & clk_en)        //JUMP MOMMENT
                    connector_vld   <= 1'b1;
            else if(~(body_inf.valid & body_inf.ready) && m00.ready && clk_en)
                    connector_vld   <= 1'b0;
            else    connector_vld   <= 1'b1;
        BODY_VD_CN_VD_BUF_OPD_CLU:
            if(clk_en)
                    connector_vld   <= 1'b1;
            else    connector_vld   <= connector_vld;
        //--END
        END_VD_CN_EM_BUF:
            if(body_inf.valid & body_inf.ready & body_last & m00.ready & clk_en)        //JUMP MOMMENT
                    connector_vld   <= 1'b1;
            else if(~(end_inf.valid & end_inf.ready) && m00.ready && clk_en)
                    connector_vld   <= 1'b0;
            else    connector_vld   <= 1'b1;
        END_VD_CN_VD_BUF_OPD_CLU:
            if(clk_en)
                    connector_vld   <= 1'b1;
            else    connector_vld   <= connector_vld;
        FSH_VD_CN_EM_BUF_OPD_CLU:
            if(clk_en)begin
                if(m00.ready & connector_vld)
                        connector_vld   <= 1'b0;
                else    connector_vld   <= 1'b1;
            end else    connector_vld   <= connector_vld;
        default:connector_vld   <= 1'b0;
        endcase
//---<< CONNECTOR >>------------------
//----->> BUFFER <<---------------------

always@(posedge clock/*,negedge rst_n*/)begin:BUFFER_BLOCK
    if(~rst_n)begin
        over_buf    <= {DSIZE{1'b0}};
    end else begin
        case(nstate)
        //--HEAD
        HEAD_VD_CN_VD_BUF_CLD_OPU:begin
            if(head_inf.valid && !over_buf_vld && clk_en)
                    over_buf    <= head_inf.data;
            else    over_buf    <= over_buf;
        end
        HEAD_VD_CN_VD_BUF_OPD_CLU:begin
            if(m00.ready && m00.valid && clk_en)begin
                    over_buf    <= {DSIZE{1'b0}};
            end
        end
        //--BODY
        BODY_VD_CN_VD_BUF_CLD_OPU:begin
            if(body_inf.valid && !over_buf_vld && clk_en)
                    over_buf    <= body_inf.data;
            else    over_buf    <= over_buf;
        end
        BODY_VD_CN_VD_BUF_OPD_CLU:begin
            if(m00.ready && m00.valid && clk_en)begin
                    over_buf    <= {DSIZE{1'b0}};
            end
        end
        //--END
        END_VD_CN_VD_BUF_CLD_OPU:begin
            if(end_inf.valid && !over_buf_vld && clk_en)
                    over_buf    <= end_inf.data;
            else    over_buf    <= over_buf;
        end
        END_VD_CN_VD_BUF_OPD_CLU:begin
            if(m00.ready && m00.valid && clk_en)begin
                    over_buf    <= {DSIZE{1'b0}};
            end
        end
        default:;
        endcase
end end

// always@(posedge clock/*,negedge rst_n*/)
//     if(~rst_n)   over_buf_vld    <= 1'b0;
//     else
//         case(nstate)
//         VD_CN_VD_BUF_CLD_OPU:
//             if(clk_en)
//                     over_buf_vld <= from_up_vld;
//             else    over_buf_vld <= over_buf_vld;
//         VD_CN_VD_BUF_OPD_CLU:
//             if(from_down_ready && to_down_vld && clk_en)
//                     over_buf_vld <= 1'b0;
//             else    over_buf_vld <= over_buf_vld;
//         default:    over_buf_vld    <= 1'b0;
//         endcase

//
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)   over_buf_vld    <= 1'b0;
    else
        case(nstate)
        //--HEAD
        HEAD_VD_CN_VD_BUF_CLD_OPU:
            if(clk_en)
                    over_buf_vld <= head_inf.valid;
            else    over_buf_vld <= over_buf_vld;
        HEAD_VD_CN_VD_BUF_OPD_CLU:
            if(m00.ready && m00.valid && clk_en)
                    over_buf_vld <= 1'b0;
            else    over_buf_vld <= over_buf_vld;
        //--BODY
        BODY_VD_CN_VD_BUF_CLD_OPU:
            if(clk_en)
                    over_buf_vld <= body_inf.valid;
            else    over_buf_vld <= over_buf_vld;
        BODY_VD_CN_VD_BUF_OPD_CLU:
            if(m00.ready && m00.valid && clk_en)
                    over_buf_vld <= 1'b0;
            else    over_buf_vld <= over_buf_vld;
        //--END
        END_VD_CN_VD_BUF_CLD_OPU:
            if(clk_en)
                    over_buf_vld <= end_inf.valid;
            else    over_buf_vld <= over_buf_vld;
        END_VD_CN_VD_BUF_OPD_CLU:
            if(m00.ready && m00.valid && clk_en)
                    over_buf_vld <= 1'b0;
            else    over_buf_vld <= over_buf_vld;
        default:    over_buf_vld    <= 1'b0;
        endcase

assign empty_buffer = !over_buf_vld;
assign full_buffer  =  over_buf_vld;
// always@(posedge clock/*,negedge rst_n*/)
//     if(~rst_n)   over_flow_buffer    <= 1'b0;
//     else
//         case(nstate)
//         VD_CN_VD_BUF_CLD_OPU:
//             if( over_buf_vld && to_up_ready && from_up_vld && clk_en)
//                     over_flow_buffer    <= 1'b1;
//             else    over_flow_buffer    <= 1'b0;
//         default:    over_flow_buffer    <= 1'b0;
//         endcase

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)   over_flow_buffer    <= 1'b0;
    else
        case(nstate)
        //--HEAD--
        HEAD_VD_CN_VD_BUF_CLD_OPU:
            if( over_buf_vld && head_inf.ready && head_inf.valid && clk_en)
                    over_flow_buffer    <= 1'b1;
            else    over_flow_buffer    <= 1'b0;
        //--BODY--
        BODY_VD_CN_VD_BUF_CLD_OPU:
            if( over_buf_vld && body_inf.ready && body_inf.valid && clk_en)
                    over_flow_buffer    <= 1'b1;
            else    over_flow_buffer    <= 1'b0;
        //--END--
        END_VD_CN_VD_BUF_CLD_OPU:
            if( over_buf_vld && end_inf.ready && end_inf.valid && clk_en)
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
//
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  to_d_wr_en_reg  <= 1'b0;
    else
        case(nstate)
        //--HEAD--
        HEAD_VD_CN_EM_BUF:
            if(~(head_inf.valid & head_inf.ready) && m00.ready && clk_en)
                    to_d_wr_en_reg  <= 1'b0;
            else    to_d_wr_en_reg  <= 1'b1;
        HEAD_VD_CN_VD_BUF_OPD_CLU:
            if(clk_en)
                    to_d_wr_en_reg  <= 1'b1;
            else    to_d_wr_en_reg  <= to_d_wr_en_reg;
        //--BODY--
        BODY_VD_CN_EM_BUF:
            if(head_inf.valid & head_inf.ready & head_last & m00.ready & clk_en)        //JUMP MOMMENT
                    to_d_wr_en_reg  <= 1'b1;
            else if(~(body_inf.valid & body_inf.ready) && m00.ready && clk_en)
                    to_d_wr_en_reg  <= 1'b0;
            else    to_d_wr_en_reg  <= 1'b1;
        BODY_VD_CN_VD_BUF_OPD_CLU:
            if(clk_en)
                    to_d_wr_en_reg  <= 1'b1;
            else    to_d_wr_en_reg  <= to_d_wr_en_reg;
        ///--END--
        END_VD_CN_EM_BUF:
            if(body_inf.valid & body_inf.ready & body_last & m00.ready & clk_en)        //JUMP MOMMENT
                    to_d_wr_en_reg  <= 1'b1;
            else if(~(end_inf.valid & end_inf.ready) && m00.ready && clk_en)
                    to_d_wr_en_reg  <= 1'b0;
            else    to_d_wr_en_reg  <= 1'b1;
        END_VD_CN_VD_BUF_OPD_CLU:
            if(clk_en)
                    to_d_wr_en_reg  <= 1'b1;
            else    to_d_wr_en_reg  <= to_d_wr_en_reg;
        FSH_VD_CN_EM_BUF_OPD_CLU:
            if(clk_en)begin
                if(m00.valid & m00.ready)
                        to_d_wr_en_reg  <= 1'b0;
                else    to_d_wr_en_reg  <= 1'b1;
            end else    to_d_wr_en_reg  <= to_d_wr_en_reg;
        default:    to_d_wr_en_reg  <= 1'b0;
        endcase
//-----<< to down data >>---------------
assign m00.data     = connector;
assign m00.valid    = to_d_wr_en_reg;

endmodule

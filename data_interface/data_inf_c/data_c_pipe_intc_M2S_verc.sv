/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
    multi slaver to simple master
author : Cook.Darwin
Version: VERA.0.0
    build from data_pipe_interconnect
Version: VERC.0.0 2017/8/23 
    more effection
Version: VERC.0.1 2017/12/7 
    add FORCE_ROBIN
Vsersion: VERC.0.2 2018/11/28 
    LINE: 164 -> 165
creaded: 2016/12/28 
madified:
***********************************************/
`timescale 1ns/1ps
`include "define_macro.sv"
(* data_inf_c = "true" *)
module data_c_pipe_intc_M2S_verc #(
    `parameter_string   PRIO = "BEST_LAST",   //BEST_ROBIN BEST_LAST ROBIN LAST WAIT_IDLE FORCE_ROBIN
    parameter   NUM   = 8,
    //(* show = "false" *)
    parameter   NSIZE =  NUM <= 2? 1 :
                         NUM <= 4? 2 :
                         NUM <= 8? 3 :
                         NUM <= 16?4 : 5
)(
    input [NUM-1:0]             last,             //ctrl prio
    data_inf_c.slaver           s00 [NUM-1:0],
    (* down_stream = "true" *)
    data_inf_c.master           m00
);


initial begin
    assert(PRIO != "BEST_ROBIN")
    else begin 
        $display("BEST_ROBIN TEST False!!!");
        $stop();
    end 

    assert(PRIO != "BEST_LAST")
    else begin 
        $display("BEST_LAST TEST False!!!");
        $stop();
    end 

    assert(PRIO != "ROBIN")
    else begin 
        $display("ROBIN TEST False!!!");
        $stop();
    end 
end
//--->> CHECK NUM <<-----------------
// initial begin
//     assert(NUM == 2**($clog2(NUM)))
//     else begin
//         $error(" `data_c_pipe_intc_M2S_verc` NUM[%d] MUST BE 2**X ",NUM);
//         $stop;
//     end
// end
//---<< CHECK NUM >>-----------------
//--->> CheckClock <<----------------
logic [NUM-1:0]     cc_done;
logic [NUM-1:0]     cc_same;
genvar JJ;
generate
for(JJ=0;JJ<NUM;JJ++)begin:CheckPClock_BLOCK
    CheckPClock CheckPClock_inst(
    /*  input         */      .aclk     (s00[JJ].clock  ),
    /*  input         */      .bclk     (m00.clock      ),
    /*  output logic  */      .done     (cc_done[JJ]    ),
    /*  output logic  */      .same     (cc_same[JJ]    )
    );

    initial begin
        wait(cc_done[JJ]);
        assert(cc_same[JJ])
        else begin
            $error("`data_c_pipe_intc_M2S_verc` clock[%d] is not same",JJ);
            $stop;
        end
    end

end
endgenerate
//---<< CheckClock >>----------------
logic                      clock;
logic                      rst_n;

assign clock    = m00.clock;
assign rst_n    = m00.rst_n;

//--->> PREPARE <<-------------------------------
genvar KK;
logic [NUM-1:0]         to_up_ready_array;
bit   [NUM-1:0]         from_up_vld_array;
bit   [NUM-1:0]         from_up_vld_array_mark_last;
logic [m00.DSIZE-1:0]   from_up_data;
logic [m00.DSIZE-1:0]   from_up_data_array [NUM-1:0];
logic                   from_down_ready;
logic                   from_up_vld;
logic                   to_up_ready;
logic                   to_down_vld;
logic [NSIZE-1:0]       curr_path;

assign from_down_ready  = m00.ready;
assign to_down_vld      = m00.valid;

assign from_up_vld      = from_up_vld_array[curr_path];
assign to_up_ready      = to_up_ready_array[curr_path];

generate
for(KK=0;KK<NUM;KK++)begin
    assign from_up_vld_array[KK]    = s00[KK].valid;
    assign s00[KK].ready            = to_up_ready_array[KK];
    assign from_up_data_array[KK]   = s00[KK].data;
    assign from_up_vld_array_mark_last[KK]  = (s00[KK].valid && (!last[KK])) || (s00[KK].valid && last[KK] && !s00[KK].ready);
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
logic [NSIZE-1:0]       next_path;
reg                     over_buf_vld;
always@(posedge clock,negedge rst_n)
    if(~rst_n)   to_up_ready_array   <= '0;
    else begin
        to_up_ready_array   <= '0;
        case(nstate)
        EM_CN_EM_BUF,VD_CN_EM_BUF:
            if(PRIO == "BEST_LAST")begin
                if(from_up_vld && to_up_ready && last[curr_path])
                        to_up_ready_array[next_path]    <= 1'b1;
                else    to_up_ready_array[curr_path]    <= 1'b1;
            // end else    to_up_ready_array[next_path]    <= 1'b1;
            end else    to_up_ready_array[curr_path]    <= 1'b1;
        VD_CN_VD_BUF_CLD_OPU:begin
            to_up_ready_array   <= '0;
        end
        default:;
        endcase
    end

//---<< to up ready signal >>---------------
//--->> CURR PATH CTRL <<-------------------
int CC,II;
logic [NSIZE-1:0]   Q_next_path;

generate
if(PRIO=="BEST_ROBIN")begin
//--------------------------------------------
next_prio #(
    .NUM    (NUM)
)next_prio_inst(
/*  input [NSIZE-1:0]        */    .curr_addr   (curr_path          ),
/*  input [NUM-1:0]          */    .array       (from_up_vld_array  ),
/*  output logic[NSIZE-1:0]  */    .next_addr   (next_path          )
);
//============================================
end else if(PRIO=="BEST_LAST")begin
//--------------------------------------------
next_prio #(
    .NUM    (NUM)
)next_prio_inst(
/*  input [NSIZE-1:0]        */    .curr_addr   (curr_path          ),
/*  input [NUM-1:0]          */    .array       (from_up_vld_array_mark_last  ),
/*  output logic[NSIZE-1:0]  */    .next_addr   (next_path          )
);
//============================================
end else if(PRIO=="ROBIN")begin
//--------------------------------------------
always@(*) begin
    if(!from_up_vld)
        Q_next_path   = curr_path + 1'b1;
    else if(from_up_vld && to_up_ready)
        if(curr_path >= NUM - 1)
                Q_next_path   = '0;
        else    Q_next_path   = curr_path + 1'b1;
    else        Q_next_path   = curr_path;
end
//=============================================
end else if(PRIO=="FORCE_ROBIN")begin
//--------------------------------------------
always@(*) begin
    if(from_up_vld && to_up_ready)
        if(curr_path >= NUM - 1)
                Q_next_path   = '0;
        else    Q_next_path   = curr_path + 1'b1;
    else        Q_next_path   = curr_path;
end
//=============================================
end else if(PRIO=="LAST")begin
//--------------------------------------------
always@(*) begin
    if(from_up_vld && to_up_ready && last[curr_path])
        if(curr_path >= NUM - 1)
                Q_next_path   = '0;
        else    Q_next_path   = curr_path + 1'b1;
    else        Q_next_path   = curr_path;
end
//=============================================
end else if(PRIO=="WAIT_IDLE")begin
//--------------------------------------------
always@(*) begin
    if(!from_up_vld)
        if(curr_path >= NUM - 1)
                Q_next_path   = '0;
        else    Q_next_path   = curr_path + 1'b1;
    else        Q_next_path   = curr_path;
end
//=============================================
end
endgenerate

logic [NUM-1:0]   curr_exec;

generate
if(PRIO=="ROBIN" || PRIO=="LAST" || PRIO=="WAIT_IDLE" || PRIO=="FORCE_ROBIN")begin
//--------------------------------
always@(posedge clock,negedge rst_n)
    if(~rst_n)  curr_path   <= '0;
    else begin
        // curr_path   <= next_path;
        if(next_path < NUM)
                curr_path   <= next_path;
        else    curr_path   <= '0;
    end

assign next_path    = Q_next_path;
//=================================
end else if(PRIO=="BEST_ROBIN")begin
//--------------------------------
always@(posedge clock,negedge rst_n)
    if(~rst_n)  curr_path   <= '0;
    else begin
        if(from_up_vld !== 1'b1)
                // curr_path   <= next_path;
                if(next_path < NUM)
                        curr_path   <= next_path;
                else    curr_path   <= '0;
        else if(from_up_vld && to_up_ready)
                // curr_path   <= next_path;
                if(next_path < NUM)
                        curr_path   <= next_path;
                else    curr_path   <= '0;
        else    curr_path   <= curr_path;
    end
//=================================
end else if(PRIO=="BEST_LAST")begin
//--------------------------------
always@(posedge clock,negedge rst_n)
    if(~rst_n)  curr_exec   <= '0;
    else begin
        foreach(curr_exec[i])begin
            if(from_up_vld_array[i] & to_up_ready_array[i] & last[i])
                    curr_exec[i]   <= 1'b0;
            else if(from_up_vld_array[i])
                    curr_exec[i]   <= 1'b1;
            else    curr_exec[i]   <= curr_exec[i];
        end
        // if(from_up_vld && to_up_ready)
        //         idle_curr   <= 1'b0;
        // else    idle_curr   <= idle_curr;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  curr_path   <= '0;
    else begin
        if(!curr_exec[curr_path] && !from_up_vld)
                curr_path   <= next_path;
        else if(from_up_vld && to_up_ready && last[curr_path])
        // if(from_up_vld && to_up_ready && last[curr_path])
                curr_path   <= next_path;
        else    curr_path   <= curr_path;
    end
//=================================
end else begin
initial begin
    $error("data_c_pipe_intc_M2S_verc PRIO WRONG !!!");
    $stop;
end
end
endgenerate
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

/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.1 
    add nextpath free sel enabel
creaded: ###### Wed Aug 12 09:50:52 CST 2020
madified:
***********************************************/
`timescale 1ns/1ps
`include "define_macro.sv"
(* data_inf_c = "true" *)
module data_c_pipe_intc_M2S_best_last #(
    parameter   NUM   = 8,
    parameter   NSIZE = $clog2(NUM)
)(
    input [NUM-1:0]             last,             //ctrl prio
    data_inf_c.slaver           s00 [NUM-1:0],
    data_inf_c.master           m00
);

// initial begin 
//     assert(NUM<=8)
//     else begin 
//         $error("NUM[%0d] must <= 8",NUM);
//         $stop;
//     end

// end

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
            $error("`data_c_pipe_intc_M2S_best_last` clock[%d] is not same",JJ);
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

genvar  KK;
integer CC;
logic [NUM-1:0]         from_up_vld_array;
logic [NUM-1:0]         to_up_ready_array;
logic [NSIZE-1:0]       curr_path;
logic [NSIZE-1:0]       next_path;
logic [m00.DSIZE-1:0]   from_up_data_array [NUM-1:0];
logic [NUM-1:0]         up_vld_rdy_last_array;
logic [NUM-1:0]         up_vld_rdy_array;

generate
for(KK=0;KK<NUM;KK++)begin
    assign from_up_vld_array[KK]    = s00[KK].valid;
    assign s00[KK].ready            = to_up_ready_array[KK];
    assign from_up_data_array[KK]   = s00[KK].data;
    assign up_vld_rdy_last_array[KK]= from_up_vld_array[KK] & to_up_ready_array[KK] & last[KK];
    assign up_vld_rdy_array[KK]     = from_up_vld_array[KK] & to_up_ready_array[KK];
end
endgenerate

//--->> Contrl curr_path loop <<--------------------
// logic   idle_record;

// always_ff@(posedge clock,negedge rst_n)
//     if(~rst_n)
//         idle_record <= 1'b0;
//     else begin 
//         if(~idle_record)
//                 idle_record <= |(from_up_vld_array & to_up_ready_array);
//         else    idle_record <= idle_record;
//     end 
logic new_path_free;

always_ff@(posedge clock,negedge rst_n)
    if(~rst_n)  new_path_free   <= 1'b1;
    else begin 
        if(|up_vld_rdy_last_array)
                new_path_free   <= 1'b1;
        else if(|up_vld_rdy_array)
                new_path_free   <= 1'b0;
        else    new_path_free   <= new_path_free;
    end 


logic   new_path;

always_comb begin 
    next_path = curr_path;

    if(new_path_free)begin 
        if(~from_up_vld_array[curr_path])begin 
            foreach(from_up_vld_array[i])begin 
                for(CC=i+1;CC<i+NUM;CC++)begin 
                    if(from_up_vld_array[CC%NUM])begin 
                        next_path   = CC%NUM;
                    end
                end
            end 
        end
    end

    foreach(up_vld_rdy_last_array[i])begin 
        if(up_vld_rdy_last_array[i])begin 
            // foreach(from_up_vld_array[x])begin 

            // end
            for(CC=i+1;CC<i+NUM;CC++)begin 
                if(from_up_vld_array[CC%NUM])begin 
                    next_path   = CC%NUM;
                end
            end
        end
    end
end

always_ff@(posedge clock,negedge rst_n)
    if(~rst_n)  curr_path   <= '0;
    else begin 
        curr_path   <= next_path;

        // if(!from_up_vld_array[curr_path])begin 
        //     // if(curr_path == NUM-1)begin 
        //     //     curr_path   <= '0;
        //     // end else begin 
        //     //     curr_path   <=  curr_path + 1'b1;
        //     // end
        //     curr_path   <= next_path;
        // end else begin 
        //     curr_path   <= curr_path;
        // end

        // foreach(up_vld_rdy_last_array[i])begin 
        //     if(up_vld_rdy_last_array[i])begin 
        //         curr_path   <= next_path;
        //     end
        // end
    end

//---<< Contrl curr_path loop >>--------------------

logic       from_up_vld;
logic       to_up_ready;
logic       from_down_ready;
logic       to_down_vld;

assign  from_up_vld = from_up_vld_array[curr_path];
assign  to_up_ready = to_up_ready_array[curr_path];
assign  from_down_ready = m00.ready;

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
    if(~rst_n)   cstate  <= EM_CN_EM_BUF;
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
always@(posedge clock,negedge rst_n)
    if(~rst_n)   to_up_ready_array   <= '0;
    else begin
        to_up_ready_array               <= '0;
        // to_up_ready_array[next_path]    <= 1'b1;
        case(nstate)
        EM_CN_EM_BUF:
            to_up_ready_array[next_path]    <= 1'b1;
            // to_up_ready_array[next_path]    <= |from_up_vld_array;
        VD_CN_EM_BUF:
            to_up_ready_array[next_path]    <= 1'b1;   // 
            // to_up_ready_array[next_path]    <= |from_up_vld_array;
        VD_CN_VD_BUF_CLD_OPU:begin
            to_up_ready_array   <= '0;
        end
        default:;
        endcase
        
    end
//---<< to up ready signal >>---------------
//--->> CONNECTOR <<------------------
reg [m00.DSIZE-1:0]     connector;
reg [m00.DSIZE-1:0]     over_buf;
logic                   over_buf_vld;
logic[m00.DSIZE-1:0]    from_up_data;

// assign from_up_data = from_up_data_array[next_path];
assign from_up_data = from_up_data_array[curr_path];

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

assign to_down_vld  = connector_vld;

endmodule


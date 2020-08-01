/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
    simple slaver to multi master
author : Cook.Darwin
Version: VERA.0.0
    build from data_pipe_interconnect_MM_S0
Version: VERA.0.1 2017/4/20 
    addr must smaller than num
Version: VERB.0.0 2017/8/4 
    rebuild
creaded: 2016/12/28 
madified:
***********************************************/
`timescale 1ns/1ps
module data_pipe_interconnect_S2M_verb #(
    parameter   NUM   = 8,
    parameter   NSIZE =  $clog2(NUM)
)(
    input               clock,
    input               rst_n,
    input               clk_en,
    input [NSIZE-1:0]   addr,       // sync to s00.valid
    // output logic[2:0]   curr_path,

    data_inf.master     m00 [NUM-1:0],
    data_inf.slaver     s00
);


//-->> PARH DEF

logic                   from_up_vld;
logic[s00.DSIZE-1:0]    from_up_data;
logic                   to_up_ready;

// logic[7:0]         to_up_ready_array;
logic [NUM-1:0]         to_down_vld_array;
logic [NUM-1:0]         from_down_ready_array;

logic[s00.DSIZE-1:0]    to_down_data;


assign  from_up_vld     = s00.valid;
assign  from_up_data    = s00.data;
assign  s00.ready       = to_up_ready;

int II;
genvar KK;
generate
for(KK=0;KK<NUM;KK++)begin
    assign  m00[KK].data    = m00[KK].valid? to_down_data : '0;
    assign  m00[KK].valid   = to_down_vld_array[KK];
    assign  from_down_ready_array[KK] = m00[KK].ready;
end
endgenerate

typedef enum {
    IDLE                ,
    EM_CN_EM_BUF        ,//  empty connector,empty buffer
    VD_CN_EM_BUF        ,//  valid connector,empty buffer
    BURST_VD_CN_EM_BUF  ,//
    LAT_VD_CN_EM_BUF    ,//
    RE_VD_CN_EM_BUF     ,//  OVER -> VD_CN_EM_BUF
    VD_CN_VD_BUF_CLD_OPU,//  valid connector,valid buffer,close down stream ,open upstream
    VD_CN_VD_BUF_OPD_CLU,//  valid connector,valid buffer,open down stream ,close upstream
    OVER_FLOW            //  error
} STATUS;

STATUS      cstate,nstate;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)   cstate  <= IDLE;
    else         cstate  <= nstate;

reg [NUM-1:0]        connector_vld_array;

always@(*)
    case(cstate)
    IDLE:       nstate  = EM_CN_EM_BUF;
    EM_CN_EM_BUF:
        if(from_up_vld && to_up_ready && clk_en && (addr < NUM))
                nstate  = VD_CN_EM_BUF;
        else    nstate  = EM_CN_EM_BUF;
    VD_CN_EM_BUF:
        if(~clk_en)
                nstate  = VD_CN_EM_BUF;
        else if(|(from_down_ready_array & to_down_vld_array) )begin
            if(from_up_vld && to_up_ready && (addr < NUM))
                     nstate = BURST_VD_CN_EM_BUF;
            else     nstate = EM_CN_EM_BUF;
        end else if(from_up_vld && to_up_ready && (addr < NUM))begin
            if(|(from_down_ready_array & to_down_vld_array) )
                    nstate = BURST_VD_CN_EM_BUF;
            else    nstate = VD_CN_VD_BUF_CLD_OPU;
        end else begin
            if( !(|connector_vld_array) )
                    nstate = EM_CN_EM_BUF;
            else    nstate = LAT_VD_CN_EM_BUF;
        end
    RE_VD_CN_EM_BUF:
        if(~clk_en)
                nstate  = RE_VD_CN_EM_BUF;
        else if(|(from_down_ready_array & to_down_vld_array) )begin
            if(from_up_vld && to_up_ready && (addr < NUM))
                     nstate = BURST_VD_CN_EM_BUF;
            else     nstate = EM_CN_EM_BUF;
        end else if(from_up_vld && to_up_ready && (addr < NUM))begin
            if(|(from_down_ready_array & to_down_vld_array) )
                    nstate = BURST_VD_CN_EM_BUF;
            else    nstate = VD_CN_VD_BUF_CLD_OPU;
        end else begin
            if( !(|connector_vld_array) )
                    nstate = EM_CN_EM_BUF;
            else    nstate = LAT_VD_CN_EM_BUF;
        end
    LAT_VD_CN_EM_BUF:
        if(~clk_en)
                nstate  = LAT_VD_CN_EM_BUF;
        else if(|(from_down_ready_array & to_down_vld_array) )begin
            if(from_up_vld && to_up_ready && (addr < NUM))
                     nstate = BURST_VD_CN_EM_BUF;
            else     nstate = EM_CN_EM_BUF;
        end else if(from_up_vld && to_up_ready && (addr < NUM))begin
            if(|(from_down_ready_array & to_down_vld_array) )
                    nstate = BURST_VD_CN_EM_BUF;
            else    nstate = VD_CN_VD_BUF_CLD_OPU;
        end else begin
            if( !(|connector_vld_array) )
                    nstate = EM_CN_EM_BUF;
            else    nstate = LAT_VD_CN_EM_BUF;
        end
    BURST_VD_CN_EM_BUF:
        if(~clk_en)
                nstate  = BURST_VD_CN_EM_BUF;
        else if(|(from_down_ready_array & to_down_vld_array) )begin
            if(from_up_vld && to_up_ready && (addr < NUM))
                     nstate = BURST_VD_CN_EM_BUF;
            else     nstate = EM_CN_EM_BUF;
        end else if(from_up_vld && to_up_ready && (addr < NUM))begin
            if(|(from_down_ready_array & to_down_vld_array) )
                    nstate = BURST_VD_CN_EM_BUF;
            else    nstate = VD_CN_VD_BUF_CLD_OPU;
        end else begin
            if( !(|connector_vld_array) )
                    nstate = EM_CN_EM_BUF;
            else    nstate = LAT_VD_CN_EM_BUF;
        end
    VD_CN_VD_BUF_CLD_OPU:
        if(clk_en)
                nstate = VD_CN_VD_BUF_OPD_CLU;
        else    nstate = VD_CN_VD_BUF_CLD_OPU;
    VD_CN_VD_BUF_OPD_CLU:
        if(|(from_down_ready_array & to_down_vld_array) && clk_en)
                nstate = RE_VD_CN_EM_BUF;
        else    nstate = VD_CN_VD_BUF_OPD_CLU;
    // OVER_FLOW:  nstate = OVER_FLOW;
    default:    nstate = IDLE;
    endcase
//--->> to up ready signal <<---------------
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)   to_up_ready   <= 1'd0;
    else begin
        to_up_ready   <= 1'd0;
        case(nstate)
        EM_CN_EM_BUF,VD_CN_EM_BUF,RE_VD_CN_EM_BUF,LAT_VD_CN_EM_BUF,BURST_VD_CN_EM_BUF:
                to_up_ready  <= 1'b1;
        default:to_up_ready<= 1'b0;
        endcase
    end

//---<< to up ready signal >>---------------
//--->> CONNECTOR <<------------------
reg [s00.DSIZE-1:0]     connector;
// reg                 connector_vld;
reg [s00.DSIZE-1:0]     over_buf;
always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)   connector   <= '0;
    else
        case(nstate)
        VD_CN_EM_BUF,BURST_VD_CN_EM_BUF:
                connector   <= from_up_data;
        RE_VD_CN_EM_BUF:
                connector   <= over_buf;
        IDLE,EM_CN_EM_BUF:
                connector   <= '0;
        default:connector   <= connector;
        endcase


logic [NUM-1:0]   over_buf_vld_array;
logic [NSIZE-1:0] record_vld_addr;

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)   connector_vld_array   <= '0;
    else
        case(nstate)
        VD_CN_EM_BUF,BURST_VD_CN_EM_BUF:begin
            connector_vld_array         <= '0;
            // connector_vld_array[addr]   <= 1'b1;
            if(addr < NUM )
                connector_vld_array[addr]   <= 1'b1;
        end
        RE_VD_CN_EM_BUF:
            connector_vld_array   <= over_buf_vld_array;
        IDLE,EM_CN_EM_BUF:
            connector_vld_array   <= '0;
        VD_CN_VD_BUF_CLD_OPU:
            connector_vld_array   <= '0;
        VD_CN_VD_BUF_OPD_CLU:
            connector_vld_array[record_vld_addr]    <= 1'b1;
        default:    connector_vld_array   <= connector_vld_array;
        endcase

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)  record_vld_addr <= '0;
    else
        case(nstate)
        VD_CN_VD_BUF_CLD_OPU:
            foreach(connector_vld_array[i])
                if(connector_vld_array[i])
                    record_vld_addr <= i;
        default:    record_vld_addr <= record_vld_addr;
        endcase

//---<< CONNECTOR >>------------------
//----->> BUFFER <<---------------------
always@(posedge clock/*,negedge rst_n*/)begin:BUFFER_BLOCK
    if(~rst_n)begin
        over_buf    <= '0;
    end else begin
        case(nstate)
        VD_CN_VD_BUF_CLD_OPU:
            over_buf    <= from_up_data;
        RE_VD_CN_EM_BUF:
            over_buf    <= '0;
        default:;
        endcase
end end

always@(posedge clock/*,negedge rst_n*/)
    if(~rst_n)   over_buf_vld_array    <= '0;
    else
        case(nstate)
        VD_CN_VD_BUF_CLD_OPU:begin
                over_buf_vld_array          <= '0;
                if(addr < NUM )
                    over_buf_vld_array[addr]    <= 1'b1;
        end
        RE_VD_CN_EM_BUF:
                    over_buf_vld_array <= '0;
        VD_CN_VD_BUF_OPD_CLU:
                    over_buf_vld_array <= over_buf_vld_array;
        default:    over_buf_vld_array <= '0;
        endcase

//-----<< BUFFER >>---------------------
//----->> to down data <<---------------
assign to_down_vld_array = connector_vld_array;
//-----<< to down data >>---------------
assign to_down_data = connector;

endmodule

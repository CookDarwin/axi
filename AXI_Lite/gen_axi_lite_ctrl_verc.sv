/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERB.0.0
    add interrupt to axil bresp
    why "lock"
    1 multi cmd
    2 intrq
Version: VERB.0.0 2017/6/19 
    last cmd must keep lock low
creaded: 2017/1/11 
madified:2017/5/2 
***********************************************/
`timescale 1ns/1ps

module gen_axi_lite_ctrl_verc #(
    parameter   NUM = 32
)(
    input                           from_up_trigger,
    output logic                    to_domn_trigger,
    axi_lite_inf.master             lite,
    Lite_Addr_Data_CMD.slaver       addrdatac   [NUM-1:0],
    output logic [lite.DSIZE-1:0]   lite_rdata,
    output logic                    lite_intrq_done
);


genvar KK;

logic[lite.ASIZE-1:0]       addr [NUM-1:0];
logic[lite.DSIZE-1:0]       wdata[NUM-1:0];
logic[lite.DSIZE-1:0]       rdata[NUM-1:0];

logic[NUM-1:0]              wr_rd_type;
logic[NUM-1:0]              wait_intrq;
logic[NUM-1:0]              intrq;

logic[NUM-1:0]              keep_read;
logic[lite.DSIZE-1:0]       meet_rdata[NUM-1:0];
logic[lite.DSIZE-1:0]       meet_keep[NUM-1:0];
logic[NUM-1:0]             en_keep;

generate
    for(KK=0;KK<NUM;KK++)begin
        assign addr[KK]         = addrdatac[KK].addr;
        assign wdata[KK]        = addrdatac[KK].wdata;
        assign addrdatac[KK].rdata  = rdata[KK];
        assign wr_rd_type[KK]   = addrdatac[KK].wr_rd_type;
        assign wait_intrq[KK]   = addrdatac[KK].wait_intrq;
        assign intrq[KK]        = addrdatac[KK].intrq;
        assign keep_read[KK]    = addrdatac[KK].keep_read;
        assign meet_rdata[KK]   = addrdatac[KK].meet_rdata;
        assign meet_keep[KK]    = addrdatac[KK].meet_keep;
        assign en_keep[KK]      = addrdatac[KK].en_keep;
    end
endgenerate

wire    clock,rst_n;

assign clock    = lite.axi_aclk;
assign rst_n    = lite.axi_aresetn;

localparam NSIZE =  (NUM+2) <=  2   ? 1 :
                    (NUM+2) <=  4   ? 2 :
                    (NUM+2) <=  8   ? 3 :
                    (NUM+2) <= 16   ? 4 :
                    (NUM+2) <= 32   ? 5 :
                    (NUM+2) <= 64   ? 6 :
                    (NUM+2) <= 128  ? 7 :
                    (NUM+2) <= 256  ? 8 : 16;

logic [NSIZE-1:0]   state;

//--->> RECORD INTRQ <<---------------------------
logic       rst_recd_wr_rd_ok;
logic       recd_wr_rd_ok;
logic       wr_rd_ok;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  recd_wr_rd_ok   <= 1'b0;
    else begin
        if(rst_recd_wr_rd_ok)
                recd_wr_rd_ok   <= 1'b0;
        else if(wr_rd_ok)
                recd_wr_rd_ok   <= 1'b1;
        else    recd_wr_rd_ok   <= recd_wr_rd_ok;
    end
//---<< RECORD INTRQ >>---------------------------

always@(posedge clock)
    if(~rst_n)  state   <= {NSIZE{1'b0}};
    else begin
        if(from_up_trigger && state=={NSIZE{1'b0}})
                state   <= 1;
        else begin
            if(state == (NUM+1) )
                    state   <= {NSIZE{1'b0}} ;
            else if(wr_rd_ok)
                    state   <= state + (!wait_intrq[state-1]);
            else if(recd_wr_rd_ok && wait_intrq[state-1])
                    state   <= state + (lite.axi_bready && lite.axi_bvalid && lite.axi_bresp == 2'b01);
            else    state   <= state ;
        end
    end

//--->> CMD LOCK <<-------------------------
always@(posedge clock)
    if(~rst_n)  lite.axi_awlock <= 1'b0;
    else begin
        if(state==0 || state == (NUM + 1))
                lite.axi_awlock <= 1'b0;
        else if( state == (NUM))

            if(lite.axi_awvalid && lite.axi_awready)
                    lite.axi_awlock <= 1'b0;
            else    lite.axi_awlock <= lite.axi_awlock;

        else    lite.axi_awlock <= 1'b1;
    end

always@(posedge clock)
    if(~rst_n)  lite.axi_arlock <= 1'b0;
    else begin
        if(state==0 || state == (NUM+1))
                lite.axi_arlock <= 1'b0;
        else    lite.axi_arlock <= 1'b1;
    end
//---<< CMD LOCK >>-------------------------


logic         wr_ok;
logic         wr_data_ok,wr_addr_ok;

logic         rd_ok;
logic         rd_addr_ok;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  wr_ok   <= 1'b0;
    else        wr_ok   <= ( (lite.axi_awready && lite.axi_awvalid) || wr_addr_ok ) && ((lite.axi_wready && lite.axi_wvalid) || wr_data_ok) && (lite.axi_bready && lite.axi_bvalid);

always@(posedge clock,negedge rst_n)
    if(~rst_n)  rd_ok   <= 1'b0;
    else begin
        if(en_keep[state-1])
            rd_ok   <= ( (lite.axi_arready && lite.axi_arvalid) || rd_addr_ok ) && (lite.axi_rready && lite.axi_rvalid) && (!keep_read[state-1] || (lite.axi_rdata & meet_keep[state-1])==(meet_rdata[state-1] & meet_keep[state-1]));
        else
            rd_ok   <= ( (lite.axi_arready && lite.axi_arvalid) || rd_addr_ok ) && (lite.axi_rready && lite.axi_rvalid) && (!keep_read[state-1] || lite.axi_rdata==meet_rdata[state-1]);
    end

assign wr_rd_ok = wr_ok | rd_ok;
//--->> FLAG <<----------------------------
logic               flag;
logic [NSIZE-1:0]   old_state;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  old_state   <= {NSIZE{1'b0}};
    else        old_state   <= state;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  flag    <= 1'b0;
    else        flag    <= state != old_state && state != (NUM+1);

assign rst_recd_wr_rd_ok    = flag;
//---<< FLAG >>----------------------------
//--->> CTRL <<-----------------------------------
always@(posedge clock,negedge rst_n)
    if(~rst_n)  wr_data_ok  <= 1'b0;
    else begin
        // if(flag)
        //         wr_data_ok  <= 1'b0;
        // else
        if(~wr_data_ok)begin
            if(lite.axi_wready && lite.axi_wvalid)
                    wr_data_ok  <= 1'b1;
            else    wr_data_ok  <= 1'b0;
        end else begin
            if(lite.axi_bready && lite.axi_bvalid)
                    wr_data_ok  <= 1'b0;
            else    wr_data_ok  <= 1'b1;
        end
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  wr_addr_ok  <= 1'b0;
    else begin
        // if(flag)
        //         wr_addr_ok  <= 1'b0;
        // else
        if(~wr_addr_ok)begin
            if(lite.axi_awready && lite.axi_awvalid)
                    wr_addr_ok  <= 1'b1;
            else    wr_addr_ok  <= 1'b0;
        end else begin
            if(lite.axi_bready && lite.axi_bvalid)
                    wr_addr_ok  <= 1'b0;
            else    wr_addr_ok  <= 1'b1;
        end
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  rd_addr_ok  <= 1'b0;
    else begin
        if(flag)
                rd_addr_ok  <= 1'b0;
        else if(~rd_addr_ok)begin
            if(lite.axi_arready && lite.axi_arvalid)
                    rd_addr_ok  <= 1'b1;
            else    rd_addr_ok  <= 1'b0;
        end else begin
            if(lite.axi_rvalid && lite.axi_rready)
                    rd_addr_ok  <= 1'b0;
            else    rd_addr_ok  <= 1'b1;
        end
    end
//---<< CTRL >>-----------------------------------
//--->> ADDR WR <<-------------------------
always@(posedge clock,negedge rst_n)
    if(~rst_n)  lite.axi_awvalid     <= 1'b0;
    else begin
        if(state > 0 && state < NUM+1)begin
            if(flag)
                    lite.axi_awvalid     <= wr_rd_type[state-1]==addrdatac[0].WRITE ;
            else if(lite.axi_awvalid && lite.axi_awready)
                    lite.axi_awvalid     <= 1'b0;
            else    lite.axi_awvalid     <= lite.axi_awvalid;
        end else    lite.axi_awvalid     <= 1'b0;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  lite.axi_awaddr     <= {lite.ASIZE{1'b0}};
    else begin
        if(state > 0 && state < NUM+1)begin
            if(wr_rd_type[state-1]==addrdatac[0].WRITE)
                    lite.axi_awaddr     <= addr[state-1];
            else    lite.axi_awaddr     <= lite.axi_awaddr;
        end else    lite.axi_awaddr     <= lite.axi_awaddr;
    end
//---<< ADDR WR >>-------------------------
//--->> DATA WR <<-------------------------
always@(posedge clock,negedge rst_n)
    if(~rst_n)  lite.axi_wvalid     <= 1'b0;
    else begin
        if(state > 0 && state < NUM+1)begin
            if(flag)
                    lite.axi_wvalid     <= wr_rd_type[state-1]==addrdatac[0].WRITE ;
            else if(lite.axi_wvalid && lite.axi_wready)
                    lite.axi_wvalid     <= 1'b0;
            else    lite.axi_wvalid     <= lite.axi_wvalid;
        end else    lite.axi_wvalid     <= 1'b0;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  lite.axi_wdata     <= {lite.DSIZE{1'b0}};
    else begin
        if(state > 0 && state < NUM+1)begin
            if(wr_rd_type[state-1]==addrdatac[0].WRITE)
                    lite.axi_wdata     <= wdata[state-1];
            else    lite.axi_wdata     <= lite.axi_wdata;
        end else    lite.axi_wdata     <= lite.axi_wdata;
    end
//---<< DATA WR >>-------------------------
//--->> RESP WR <<-------------------------
// always@(posedge clock,negedge rst_n)
//     if(~rst_n)  lite.axi_bready     <= 1'b0;
//     else begin
//         if(state > 0 && state < NUM+1)begin
//             if(flag)
//                     lite.axi_bready     <= wr_rd_type[state-1]==addrdatac[0].WRITE ;
//             else if(lite.axi_bready && lite.axi_bvalid)
//                     lite.axi_bready     <= 1'b0;
//             else    lite.axi_bready     <= lite.axi_bready;
//         end else    lite.axi_bready     <= 1'b0;
//     end
assign lite.axi_bready     = 1'b1;
//---<< RESP WR >>-------------------------
//--->> INTERRUPT DONE <<------------------
always@(posedge clock,negedge rst_n)
    if(~rst_n)  lite_intrq_done <= 1'b0;
    else begin
        lite_intrq_done <= (lite.axi_bready && lite.axi_bvalid && lite.axi_bresp == 2'b01) && wait_intrq[state-1];
    end
//---<< INTERRUPT DONE >>------------------
//--->> ADDR RD <<-------------------------
logic       resend_rd;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  resend_rd   <= 1'b0;
    else begin
        if(keep_read[state-1])
            if(en_keep[state-1])
                resend_rd   <= ( rd_addr_ok ) && (lite.axi_rready && lite.axi_rvalid && (lite.axi_rdata & meet_keep[state-1]) != (meet_rdata[state-1] & meet_keep[state-1]));
            else
                resend_rd   <= ( rd_addr_ok ) && (lite.axi_rready && lite.axi_rvalid && lite.axi_rdata != meet_rdata[state-1]);
        else    resend_rd   <= 1'b0;
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  lite.axi_arvalid     <= 1'b0;
    else begin
        if(state > 0 && state < NUM+1)begin
            if(flag || resend_rd)
                    lite.axi_arvalid     <= wr_rd_type[state-1]==addrdatac[0].READ ;
            else if(lite.axi_arvalid && lite.axi_arready)
                    lite.axi_arvalid     <= 1'b0;
            else    lite.axi_arvalid     <= lite.axi_arvalid;
        end else    lite.axi_arvalid     <= 1'b0;
    end
//
always@(posedge clock,negedge rst_n)
    if(~rst_n)  lite.axi_araddr     <= {lite.ASIZE{1'b0}};
    else begin
        if(state > 0 && state < NUM+1)begin
            if(wr_rd_type[state-1]==addrdatac[0].READ)
                    lite.axi_araddr     <= addr[state-1];
            else    lite.axi_araddr     <= lite.axi_araddr;
        end else    lite.axi_araddr     <= lite.axi_araddr;
    end
//---<< ADDR RD >>-------------------------
//--->> DATA RD <<-------------------------
always@(posedge clock,negedge rst_n)
    if(~rst_n)  lite.axi_rready     <= 1'b0;
    else begin
        if(state > 0 && state < NUM+1)begin
            if(flag || resend_rd)
                    lite.axi_rready     <= wr_rd_type[state-1]==addrdatac[0].READ ;
            else if(lite.axi_rready && lite.axi_rvalid)
                    lite.axi_rready     <= 1'b0;
            else    lite.axi_rready     <= lite.axi_rready;
        end else    lite.axi_rready     <= 1'b0;
    end
//
always@(posedge clock,negedge rst_n)
    if(~rst_n)  ;
    else begin
        if(state > 0 && state < NUM+1)begin
            if(wr_rd_type[state-1]==addrdatac[0].READ)
                    rdata[state-1]      <= (lite.axi_rready && lite.axi_rvalid)? lite.axi_rdata : rdata[state-1];
            else    rdata[state-1]      <= rdata[state-1];
        end else    rdata[state-1]      <= rdata[state-1];
    end
//---<< DARA RD >>-------------------------
always@(posedge clock,negedge rst_n)
    if(~rst_n)  to_domn_trigger <= 1'b0;
    else        to_domn_trigger <= state == NUM+1;

//--->> common rdata <<-------------------
always@(posedge clock,negedge rst_n)
    if(~rst_n)  lite_rdata  <= {lite.DSIZE{1'b0}};
    else        lite_rdata  <= (lite.axi_rready && lite.axi_rvalid)? lite.axi_rdata : lite_rdata;
//---<< common rdata >>-------------------
endmodule:gen_axi_lite_ctrl_verc

module Lite_Addr_Data_List_A1 (     // add meet keep
    Lite_Addr_Data_CMD.master   addrdatac,
    input int                   addr,
    input int                   wdata,
    output int                  rdata,
    input int                   wr_rd_type,
    input int                   wait_intrq,
    input int                   intrq,
    input int                   keep_read,
    input int                   meet_rdata,
    input int                   meet_keep
);

assign addrdatac.addr       = addr[addrdatac.ASIZE-1:0];
assign addrdatac.wdata      = wdata[addrdatac.DSIZE-1:0];
assign addrdatac.wr_rd_type = wr_rd_type[0];
assign addrdatac.wait_intrq = wait_intrq[0];
assign addrdatac.intrq      = intrq[0];
assign addrdatac.keep_read  = keep_read[0];
assign addrdatac.meet_rdata = meet_rdata[addrdatac.DSIZE-1:0];
assign addrdatac.meet_keep  = meet_keep;
assign addrdatac.en_keep    = 1'b1;
assign rdata                = addrdatac.rdata;

endmodule:Lite_Addr_Data_List_A1

module Lite_Addr_Data_RD_MEET_KEEP(
    Lite_Addr_Data_CMD.master   addrdatac,
    input int                   addr,
    input int                   meet_rdata,
    input int                   meet_keep
);

Lite_Addr_Data_List_A1 Lite_Addr_Data_List_inst(
/*    Lite_Addr_Data_CMD.master */  .addrdatac  (addrdatac  ),
/*    input int                 */  .addr       (addr       ),
/*    input int                 */  .wdata      (0          ),
/*    output int                */  .rdata      (           ),
/*    input int                 */  .wr_rd_type ({31'd0,addrdatac.READ}    ),
/*    input int                 */  .wait_intrq (          0),
/*    input int                 */  .intrq      (          0),
/*    input int                 */  .keep_read  (          1),
/*    input int                 */  .meet_rdata (meet_rdata ),
/*    input int                 */  .meet_keep  (meet_keep  )
);
endmodule:Lite_Addr_Data_RD_MEET_KEEP

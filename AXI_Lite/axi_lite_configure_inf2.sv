/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
    use lite inf2
creaded: 2018-3-20 18:13:24
madified:
***********************************************/
`timescale 1ns/1ps
module axi_lite_configure_inf2 #(
    parameter   TOTAL_NUM = 32
)(
    axi_lite_inf2.slaver                    axil,
    common_configure_reg_interface.master   cfg_inf [TOTAL_NUM-1:0]
);


int II;
genvar KK;

wire        clock,rst_n;
assign      clock   = axil.axi_aclk;
assign      rst_n   = axil.axi_aresetn;


logic       winterrupt_en,rinterrupt_en;

typedef enum {IDLE,WGET_ADDR_DATA,RGET_ADDR,SEND_DATA,RESP,DONE,WINTR,RINTR} STATUS;

STATUS cstate,nstate;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  cstate  <= IDLE;
    else        cstate  <= nstate;

logic   addr_sto,data_sto;

always@(*)
    case(cstate)
    IDLE:
        if(axil.axi_awvalid)
                nstate  = WGET_ADDR_DATA;
        else if(axil.axi_arvalid)
                nstate  = RGET_ADDR;
        else    nstate  = IDLE;
    WGET_ADDR_DATA:
        if(addr_sto && data_sto)
                nstate  = RESP;
        else    nstate  = WGET_ADDR_DATA;
    RESP:
        if(axil.axi_bready && axil.axi_bvalid)begin
            if(winterrupt_en)
                    nstate  = WINTR;
            else    nstate  = DONE;
        end else    nstate  = RESP;
    WINTR:
        if(axil.axi_bready && axil.axi_bvalid)
                nstate  = DONE;
        else    nstate  = WINTR;
    RGET_ADDR:  nstate  = SEND_DATA;
    SEND_DATA:
        if(axil.axi_rready)begin
            if(rinterrupt_en)
                    nstate  = RINTR;
            else    nstate  = DONE;
        end else    nstate  = SEND_DATA;
    RINTR:
        if(axil.axi_bready && axil.axi_bvalid)
                nstate  = DONE;
        else    nstate  = RINTR;
    DONE:       nstate  = IDLE;
    default:    nstate  = IDLE;
    endcase

//---->> ADDR READY <<--------------------------
logic s_axi_awready;
assign axil.axi_awready = s_axi_awready;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  s_axi_awready    <= 1'b0;
    else
        case(nstate)
        IDLE:   s_axi_awready    <= 1'b1;
        default:s_axi_awready    <= 1'b0;
        endcase
//
logic s_axi_arready;
assign axil.axi_arready = s_axi_arready;
always@(posedge clock,negedge rst_n)
    if(~rst_n)  s_axi_arready    <= 1'b0;
    else
        case(nstate)
        IDLE:   s_axi_arready    <= 1'b1;
        default:s_axi_arready    <= 1'b0;
        endcase
//----<< ADDR READY >>--------------------------
//---->> W DATA READY <<------------------------
logic s_axi_wready;
assign axil.axi_wready = s_axi_wready;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  s_axi_wready    <= 1'b0;
    else
        case(nstate)
        IDLE:
                s_axi_wready    <= 1'b1;
        WGET_ADDR_DATA:
            if(axil.axi_wvalid && axil.axi_wready)
                    s_axi_wready    <= 1'b0;
            else    s_axi_wready    <= axil.axi_wready;
        default:s_axi_wready    <= 1'b0;
        endcase
//----<< W DATA READY >>------------------------
//---->> RESP <<-------------------------------
logic   wrintr_bvalid;
logic   rdintr_bvalid;
logic   s_axi_bvalid;
assign  axil.axi_bvalid = s_axi_bvalid;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  s_axi_bvalid    <= 1'b0;
    else
        case(nstate)
        RESP:   s_axi_bvalid    <= 1'b1;
        WINTR:begin
            if(wrintr_bvalid)
                    s_axi_bvalid     <= 1'b1;
            else    s_axi_bvalid     <= 1'b0;
        end
        RINTR:begin
            if(rdintr_bvalid)
                    s_axi_bvalid     <= 1'b1;
            else    s_axi_bvalid     <= 1'b0;
        end
        default:s_axi_bvalid    <= 1'b0;
        endcase

logic[1:0]   s_axi_bresp;
assign axil.axi_bresp = s_axi_bresp;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  s_axi_bresp    <= 2'b00;
    else
        case(nstate)
        RESP:   s_axi_bresp    <= 2'b00;
        WINTR:begin
                s_axi_bresp    <= 2'b01;
        end
        RINTR:begin
                s_axi_bresp    <= 2'b01;
        end
        default:s_axi_bresp    <= 2'b00;
        endcase
//----<< RESP >>-------------------------------
//---->> ADDR PROC <<--------------------------
logic /*[ASIZE-1:0]*/ [TOTAL_NUM-1:0]      waddr ;
logic /*[ASIZE-1:0]*/ [TOTAL_NUM-1:0]      raddr ;
logic [axil.ASIZE-1:0]  cfg_addr [TOTAL_NUM-1:0] ;
logic [TOTAL_NUM-1:0]   winterrupt_enable;
logic [TOTAL_NUM-1:0]   rinterrupt_enable;

logic [TOTAL_NUM-1:0]    interrupt_trigger;

generate
    for(KK=0;KK<TOTAL_NUM;KK++)begin
        assign cfg_addr[KK]             = cfg_inf[KK].addr;
        assign winterrupt_enable[KK]    = cfg_inf[KK].interrupt_enable;
        assign rinterrupt_enable[KK]    = cfg_inf[KK].interrupt_enable;
        assign interrupt_trigger[KK]    = cfg_inf[KK].interrupt_trigger;
    end
endgenerate

always@(posedge clock,negedge rst_n)
    if(~rst_n)  waddr   <= {TOTAL_NUM{1'b0}};
    else
        if(axil.axi_awvalid)begin
            for(II=0;II<TOTAL_NUM;II++)
                waddr[II]   <= axil.axi_awaddr == cfg_addr[II];
        end else begin
                waddr   <= waddr;
        end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  winterrupt_en   <= 1'b0;
    else
        if(axil.axi_awvalid)begin
            for(II=0;II<TOTAL_NUM;II++)begin
                if(axil.axi_awaddr == cfg_addr[II])
                    winterrupt_en   <= winterrupt_enable[II];
            end
        end else begin
                winterrupt_en   <= winterrupt_en;
        end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  wrintr_bvalid   <= 1'b0;
    else begin
        foreach(waddr[i])
            if(waddr[i])
                wrintr_bvalid   <= interrupt_trigger[i];
    end
//
always@(posedge clock,negedge rst_n)
    if(~rst_n)  raddr   <= {TOTAL_NUM{1'b0}};
    else
        if(axil.axi_arvalid)begin
            for(II=0;II<TOTAL_NUM;II++)
                raddr[II]   <= axil.axi_araddr == cfg_addr[II];
        end else begin
                raddr   <= raddr;
        end
//
always@(posedge clock,negedge rst_n)
    if(~rst_n)  rinterrupt_en   <= 1'b0;
    else
        if(axil.axi_arvalid)begin
            for(II=0;II<TOTAL_NUM;II++)begin
                if(axil.axi_araddr == cfg_addr[II])
                    rinterrupt_en   <=  rinterrupt_enable[II];
            end
        end else begin
                rinterrupt_en   <= rinterrupt_en;
        end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  rdintr_bvalid   <= 1'b0;
    else begin
        foreach(raddr[i])
            if(raddr[i])
                rdintr_bvalid   <= interrupt_trigger[i];
    end

always@(posedge clock,negedge rst_n)
    if(~rst_n)  addr_sto    <= 1'b0;
    else
        case(nstate)
        IDLE:   addr_sto    <= 1'b0;
        WGET_ADDR_DATA:begin
            if(axil.axi_awvalid && axil.axi_awready)
                    addr_sto    <= 1'b1;
            else    addr_sto    <= addr_sto;
        end
        default:;
        endcase
//----<< ADDR PROC >>--------------------------
//---->> LOCK WDATA <<-------------------------
logic [axil.DSIZE-1:0]       wdata;
always@(posedge clock,negedge rst_n)
    if(~rst_n)  wdata    <= {axil.DSIZE{1'b0}};
    else
        case(nstate)
        IDLE:   wdata    <= {axil.DSIZE{1'b0}};
        default:begin
            if(axil.axi_wvalid && axil.axi_wready)
                    wdata    <= axil.axi_wdata;
            else    wdata    <= wdata;
        end
        endcase

//
always@(posedge clock,negedge rst_n)
    if(~rst_n)  data_sto    <= 1'b0;
    else
        case(nstate)
        IDLE:   data_sto    <= 1'b0;
        default:begin
            if(axil.axi_wvalid && axil.axi_wready)
                    data_sto    <= 1'b1;
            else    data_sto    <= data_sto;
        end
        endcase
//----<< LOCK WDATA >>-------------------------
//---->> WDATA ENABLE <<-----------------------
logic   wr_reg_en;

always@(posedge clock,negedge rst_n)
    if(~rst_n)  wr_reg_en   <= 1'b0;
    else begin
        if(axil.axi_wvalid && axil.axi_wready && axil.axi_awvalid && axil.axi_awready)
                wr_reg_en   <= 1'b1;
        else if(addr_sto && axil.axi_wvalid && axil.axi_wready)
                wr_reg_en   <= 1'b1;
        else if(data_sto && axil.axi_awvalid && axil.axi_awready)
                wr_reg_en   <= 1'b1;
        else    wr_reg_en   <= 1'b0;
    end
//----<< WDATA ENABLE >>-----------------------
//---->> WRITE REG <<--------------------------
generate
for(KK=0;KK<TOTAL_NUM;KK++)begin:WR_REG_BLOCK
always@(posedge clock,negedge rst_n)begin
    if(~rst_n)begin
            cfg_inf[KK].wdata   <= cfg_inf[KK].default_value;
    end else begin
        if(cfg_inf[KK].rst)
            cfg_inf[KK].wdata   <= cfg_inf[KK].default_value;
        else if(wr_reg_en)begin
            cfg_inf[KK].wdata   <= waddr[KK]? wdata : cfg_inf[KK].wdata;
        end else begin
            cfg_inf[KK].wdata   <= cfg_inf[KK].wdata;
        end
    end
end
end
endgenerate
//---- << WRITE REG >>--------------------------
//---- >> READ REG <<---------------------------
logic [axil.DSIZE-1:0]      cfg_rdata [TOTAL_NUM-1:0];
generate
    for(KK=0;KK<TOTAL_NUM;KK++)
        assign cfg_rdata[KK]    = cfg_inf[KK].rdata;
endgenerate

logic [axil.DSIZE-1:0]  s_axi_rdata;
assign axil.axi_rdata = s_axi_rdata;
always@(posedge clock,negedge rst_n)begin:READ_REG_BLOCK
    if(~rst_n)  s_axi_rdata  <= {axil.DSIZE{1'b0}};
    else
        case(nstate)
        SEND_DATA:begin
            for(II=0;II<TOTAL_NUM;II++)
                if(raddr[II])
                    s_axi_rdata  <= cfg_rdata[II];
        end
        default:s_axi_rdata  <= axil.axi_rdata;
        endcase
end

logic   s_axi_rvalid;
assign  axil.axi_rvalid = s_axi_rvalid;
always@(posedge clock,negedge rst_n)
    if(~rst_n)  s_axi_rvalid  <= 1'b0;
    else
        case(nstate)
        SEND_DATA:
                s_axi_rvalid  <= 1'b1;
        default:s_axi_rvalid  <= 1'b0;
        endcase

//---- << READ REG >>---------------------------
`ifdef CHECK_CFG_ADDR
logic [cfg_inf[0].ASIZE-1:0]    chk_queue [$];
logic [cfg_inf[0].ASIZE-1:0]    cfg_addr_tmp [CFG_NUM-1:0];
genvar KK;
generate
    for(KK=0;KK<CFG_NUM;KK++)
        assign cfg_addr_tmp[KK] = cfg_inf[KK].addr;
endgenerate

initial begin
    #100;
    foreach(cfg_addr_tmp[i])begin
        for(chk_queue[j])begin
            if(cfg_addr_tmp[i] == chk_queue[j])begin
                $error("AT FILE:[%s],CFG ERROR, CFG[%d] ,CFG_ADDR[%h]",`__FILE__,i,cfg_addr_tmp[i]);
                $stop;
            end
        end
    end
end
`endif
endmodule

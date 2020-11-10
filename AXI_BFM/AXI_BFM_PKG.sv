/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2016/12/27 
madified:
***********************************************/
package AxiBfmPkg ;

typedef struct {
    logic [32-1:0]   addr;
    logic [32-1:0]   data;
    string           name = "";
} AddrData;

typedef struct {
    int   id;
    int   addr;
    int   len;
}   IdAddrLen_S ;

task automatic sync_clk_wait(const ref bit clock,ref logic condition);
    forever begin
        @(posedge clock);
        if(condition)
            break;
    end
endtask:sync_clk_wait


class AxiLiteMasterBfm_c #(
    parameter ASIZE  = 12,
    parameter DSIZE  = 32,
    parameter FreqM  = 1
);

AddrData addr_data [$];

virtual axi_lite_inf #(
    .ASIZE      (ASIZE  ),
    .DSIZE      (DSIZE  ),
    .FreqM      (FreqM  )
)axil;

function new (virtual axi_lite_inf #(.ASIZE(ASIZE),.DSIZE(DSIZE),.FreqM(FreqM)) b);
    axil = b;
endfunction:new


task master_reset;
    begin
        #1 ;
        axil.axi_awvalid   =  0;
        axil.axi_awaddr    =  0;
        axil.axi_wvalid    =  0;
        axil.axi_wdata     =  0;
        axil.axi_bready    =  0;
        axil.axi_arvalid   =  0;
        axil.axi_araddr    =  0;
        axil.axi_rready    =  0;
    end
endtask:master_reset

task automatic wr_data(ref AddrData addr_data [$],input logic relex_last=0);
int     length;
    length = addr_data.size;
    master_reset;
    @(posedge axil.axi_aclk);
    axil.axi_awlock = 1;
    axil.axi_arlock = 0;
    foreach(addr_data[i])begin
        $write("====>>> WRITING AXI LITE: N[%s]  A[%h] D[%d] ...... ",addr_data[i].name,addr_data[i].addr,addr_data[i].data);
        fork:ADDR_DATA_FORK
            fork:CMD_LOOP
                axil.axi_awvalid    = #1    1;
                axil.axi_awaddr     = #1    addr_data[i].addr;
                if(relex_last)begin
                    if(i != length - 1)
                            axil.axi_awlock = 1'b1;
                    else
                            axil.axi_awlock = 1'b0;
                end

                begin
                    forever begin
                        @(posedge axil.axi_aclk);
                        if(axil.axi_awready)begin
                            axil.axi_awvalid    = #1    0;
                            break;
                        end
                    end
                    $write(" CMD DONE !");
                end
            join
            fork:DATA_LOOP
                axil.axi_wvalid     = #1    1;
                axil.axi_wdata      = #1    addr_data[i].data;
                begin
                    forever begin
                        @(posedge axil.axi_aclk);
                        if(axil.axi_wready)begin
                            axil.axi_wvalid     = #1    0;
                            break;
                        end
                    end
                    $write(" DONE DONE !");
                end
            join
        join
        fork:RESP_LOOP
            axil.axi_bready = #1    1;
            begin
                forever begin
                    @(posedge axil.axi_aclk);
                    if(axil.axi_bvalid)
                        break;
                end
                $write(" RESP DONE !");
            end
        join
        $write(" DONE!!!\n");
    end
    axil.axi_awlock = 0;
    master_reset;
endtask:wr_data

task automatic  rd_data(ref AddrData addr_data [$]);
    master_reset;
    this.addr_data = {};
    @(posedge axil.axi_aclk);
    axil.axi_arlock = 1;
    axil.axi_awlock = 0;
    foreach(addr_data[i])fork
        this.addr_data[i].name = addr_data[i].name;
        $write("====>>> READING AXI LITE: N[%s] A[%h] ...... ",addr_data[i].name,addr_data[i].addr);
        fork:CMD_LOOP
            axil.axi_arvalid    = #1    1;
            axil.axi_araddr     = #1    addr_data[i].addr;
            this.addr_data[i].addr = addr_data[i].addr;
            begin
                forever begin
                    @(posedge axil.axi_aclk);
                    if(axil.axi_arready)begin
                        axil.axi_arvalid    = #1    0;
                        break;
                    end
                end
                $write(" CMD DONE !");
            end
        join
        fork:DATA_LOOP
            axil.axi_rready     = #1    1;
            begin
                forever begin
                    @(posedge axil.axi_aclk);
                    if(axil.axi_rvalid)begin
                        // addr_data[i]    = #1 axil.axi_rdata;
                        axil.axi_rready        = #1    0;
                        this.addr_data[i].data =  axil.axi_rdata;
                        break;
                    end
                end
                $write(" >>>D[%h]  DATA DONE !!!\n",axil.axi_rdata);
            end
        join
    join
    axil.axi_arlock = 0;
    addr_data = this.addr_data;
endtask:rd_data

endclass:AxiLiteMasterBfm_c

class AxiLiteSlaverBfm_c #(
    parameter ASIZE  = 12,
    parameter DSIZE  = 32,
    parameter FreqM  = 1
);

int  mem [int];

virtual axi_lite_inf #(
    .ASIZE      (ASIZE  ),
    .DSIZE      (DSIZE  ),
    .FreqM      (FreqM  )
)axil;

function new (virtual axi_lite_inf #(.ASIZE(ASIZE),.DSIZE(DSIZE),.FreqM(FreqM)) b);
    axil = b;
endfunction:new

task slaver_wr_reset;
    begin
        #1 ;
        axil.axi_awready   =  0;
        axil.axi_wready    =  0;
        axil.axi_bresp     =  0;
        axil.axi_bvalid    =  0;
    end
endtask:slaver_wr_reset

task slaver_rd_reset;
    begin
        #1 ;
        axil.axi_arready   =  0;
        axil.axi_rdata     =  0;
        axil.axi_rvalid    =  0;
    end
endtask:slaver_rd_reset

task automatic wr_data();
AddrData addr_data;
    slaver_wr_reset;
    @(posedge axil.axi_aclk);
    wait(axil.axi_awvalid);
    begin
        // $write("====>>> WRITING AXI LITE: N[%s]  A[%h] D[%d] ...... ",addr_data[i].name,addr_data[i].addr,addr_data[i].data);
        fork:ADDR_DATA_FORK
            fork:CMD_LOOP
                axil.axi_awready    = #1    1;
                begin
                    forever begin
                        @(posedge axil.axi_aclk);
                        if(axil.axi_awready && axil.axi_awvalid)begin
                            addr_data.addr     = axil.axi_awaddr;
                            axil.axi_awready   = #1    0;
                            break;
                        end
                    end
                end
            join
            fork:DATA_LOOP
                axil.axi_wready     = #1    1;
                begin
                    forever begin
                        @(posedge axil.axi_aclk);
                        if(axil.axi_wready && axil.axi_wvalid)begin
                            addr_data.data      = axil.axi_wdata;
                            axil.axi_wready     = #1    0;
                            break;
                        end
                    end
                end
            join
        join
        fork:RESP_LOOP
            axil.axi_bvalid = #1    1;
            axil.axi_bresp  = 0;
            begin
                forever begin
                    @(posedge axil.axi_aclk);
                    if(axil.axi_bvalid && axil.axi_bready)begin
                        #1;
                        axil.axi_bvalid = 0;
                        break;
                    end
                end
            end
        join
    end
    mem[addr_data.addr] = addr_data.data;
    $write("\n====>>> WRITING AXI LITE: N[%s]  A[%h] D[%d]\n",addr_data.name,addr_data.addr,addr_data.data);
    slaver_wr_reset;
endtask:wr_data


task automatic  rd_data();
AddrData addr_data;
int     data_tmp;
    slaver_rd_reset;
    @(posedge axil.axi_aclk);
    wait(axil.axi_arvalid);
    begin
        fork:CMD_LOOP
            axil.axi_arready    = #1    1;
            begin
                forever begin
                    @(posedge axil.axi_aclk);
                    if(axil.axi_arready && axil.axi_arvalid)begin
                        addr_data.addr      = axil.axi_araddr;
                        data_tmp            = mem[addr_data.addr];
                        axil.axi_arready    = #1    0;
                        break;
                    end
                end
                $write(" RD Lite CMD DONE !");
            end
        join
        fork:DATA_LOOP
            axil.axi_rvalid     =    1;
            // axil.axi_rdata      = addr_data.data;
            axil.axi_rdata      = data_tmp;
            begin
                forever begin
                    @(posedge axil.axi_aclk);
                    if(axil.axi_rvalid && axil.axi_rready)begin
                        axil.axi_rvalid        = #1    0;
                        break;
                    end
                end
            end
        join
    end
    $write("\n====>>> READING AXI LITE: N[%s] A[%h]\n",addr_data.name,addr_data.addr);
    slaver_rd_reset;
endtask:rd_data

endclass : AxiLiteSlaverBfm_c

class AxiStreamSlaverBfm_c #(
    parameter   DSIZE = 8,
    parameter   FreqM = 1
);

logic[DSIZE-1:0]    data_squeue [$];

virtual axi_stream_inf #(.DSIZE(DSIZE),.FreqM(FreqM)) axis_inf;

function new (virtual axi_stream_inf #(.DSIZE(DSIZE),.FreqM(FreqM)) b);
    axis_inf = b;
endfunction:new

task automatic get_data(int rate = 100,bit info=1);
int     rm;
    wait(axis_inf.aresetn);
    data_squeue = {};
    forever begin
        rm  = $urandom_range(0,99);
        if(rm < rate)
                axis_inf.axis_tready    = #(1ps) 1;
        else    axis_inf.axis_tready    = #(1ps) 0;

        @(posedge axis_inf.aclk)
        if(axis_inf.axis_tvalid && axis_inf.axis_tready)begin
            data_squeue.push_back(axis_inf.axis_tdata);
            if(axis_inf.axis_tlast)
                break;
        end
    end
    #(1ps)
    axis_inf.axis_tready    = 0;
    if(info)
        $display("AXI GET LENGTH [%d] DATA DONE!!!",data_squeue.size());
endtask:get_data

endclass:AxiStreamSlaverBfm_c

class AxiStreamMasterBfm_c #(
    parameter DSIZE = 8,
    parameter MSG   = "ON",
    parameter FreqM = 1
);

virtual axi_stream_inf #(.DSIZE(DSIZE),.FreqM(FreqM)) axis_inf;

function new (virtual axi_stream_inf #(.DSIZE(DSIZE),.FreqM(FreqM)) b);
    axis_inf = b;
    axis_inf.axis_tvalid    = 0;
    axis_inf.axis_tlast     = 0;
    axis_inf.axis_tdata     = 0;
    axis_inf.axis_tkeep     = 0;
endfunction:new

task automatic resize_queue(
    int                 len,
    ref logic [DSIZE-1:0]   in_queue [$],
    ref logic [DSIZE-1:0]   out_queue[$]
);
int real_len;
int d_len;
int r_len;
out_queue   = {};
if(len == 0)
    out_queue = in_queue;
else if(len <= in_queue.size())
    out_queue   = in_queue[0:(len-1)];
else begin
    real_len    = in_queue.size();
    d_len = len/real_len;
    r_len = len%real_len;
    for(int i=0;i<d_len;i++)
        out_queue = {out_queue,in_queue};
    out_queue = {out_queue,in_queue[0:(r_len-1)]};

end
// $display("---%d--%d--%d",len,in_queue.size(),out_queue.size());
endtask:resize_queue

task automatic gen_axi_stream (
    int                    length,
    int                    valid_ramdon_percent,
    ref  [DSIZE-1:0] data_s [$]

);
int     rt;
logic [DSIZE-1:0]   data_ss[$];
    resize_queue(length,data_s,data_ss);
    // $display("ORIGIN LENGTH: %d,REAL LENGTH: %d",data_s.size(),data_ss.size());
    @(posedge axis_inf.aclk);
    #(1ps);
    if(MSG=="ON")begin
        $display("_______________SEND___________________");
        $display("%t,GEN AXI STREAM LEN = %d",$time,data_ss.size());
    end
    while(1)begin
        rt = $urandom_range(99,0);
        axis_inf.axis_tvalid = (rt < valid_ramdon_percent);
        if(axis_inf.axis_tvalid)begin
            axis_inf.axis_tdata  = data_ss.size() != 0? data_ss.pop_front : axis_inf.axis_tdata;
            axis_inf.axis_tkeep  = '1;
            axis_inf.axis_tlast  = data_ss.size() == 0;

            sync_clk_wait(axis_inf.aclk,axis_inf.axis_tready);

            if(axis_inf.axis_tlast)begin
                // axis_inf.axis_tlast = 0;
                // @(posedge axis_inf.aclk);
                // #(1ps);
                break;
            end
            // @(posedge axis_inf.aclk);
            #(1ps);
        end else begin
            @(posedge axis_inf.aclk);
        end
    end
    #(1ps);
    axis_inf.axis_tvalid    = 0;
    axis_inf.axis_tlast     = 0;
    axis_inf.axis_tkeep     = '0;
    if(MSG=="ON")
        $display("===============SEND===================");
endtask:gen_axi_stream

endclass:AxiStreamMasterBfm_c

//---------------------------------------------------------------------
// AXI 4 Master BFM
//____________________________________________________________________
class Axi4MasterBfm_c #(
    parameter IDSIZE    = 1,
    parameter ASIZE     = 32,
    parameter LSIZE     = 1,
    parameter DSIZE     = 32,
    parameter MSG       = "ON",
    parameter ADDR_STEP = 32'hFFFF_FFFF,
    parameter FreqM     = 1
);
mailbox wid_box;
// typedef struct {
//     logic [IDSIZE-1:0]  id;
//     logic [ASIZE-1:0]   addr;
//     logic [LSIZE-1:0]   len;
// }   IdAddrLen_S ;

IdAddrLen_S tra_ar_od [$];

virtual axi_inf #(
    .IDSIZE    (IDSIZE  ),
    .ASIZE     (ASIZE   ),
    .LSIZE     (LSIZE   ),
    .DSIZE     (DSIZE   ),
    .ADDR_STEP (ADDR_STEP),
    .FreqM     (FreqM   )
) inf;


function new (virtual axi_inf #(.IDSIZE(IDSIZE),.ASIZE(ASIZE),.LSIZE(LSIZE),.DSIZE(DSIZE),.ADDR_STEP(ADDR_STEP),.FreqM(FreqM)) b);
    inf = b;
    wid_box = new();
endfunction:new

task wr_reset_status;
    inf.axi_awid     = 0;
    inf.axi_awaddr   = 0;
    inf.axi_awlen    = 0;
    inf.axi_awsize   = 0;
    inf.axi_awburst  = 0;
    inf.axi_awlock   = 0;
    inf.axi_awcache  = 0;
    inf.axi_awprot   = 0;
    inf.axi_awqos    = 0;
    inf.axi_awvalid  = 0;

    inf.axi_wdata    = 0;
    inf.axi_wstrb    = 0;
    inf.axi_wlast    = 0;
    inf.axi_wvalid   = 0;

    inf.axi_bready   = 0;
endtask:wr_reset_status
task rd_reset_status;
    inf.axi_arid     = 0;
    inf.axi_araddr   = 0;
    inf.axi_arlen    = 0;
    inf.axi_arsize   = 0;
    inf.axi_arburst  = 0;
    inf.axi_arlock   = 0;
    inf.axi_arcache  = 0;
    inf.axi_arprot   = 0;
    inf.axi_arqos    = 0;
    inf.axi_arvalid  = 0;
    inf.axi_rready   = 0;
endtask:rd_reset_status

task automatic init ();
    fork
        wr_reset_status();
        rd_reset_status();
    join
endtask:init

task automatic sync_wait(ref logic condition);
    forever begin
        @(posedge inf.axi_aclk);
        if(condition)
            break;
    end
endtask:sync_wait


task automatic aw_task(logic [ASIZE-1:0]    addr,logic [LSIZE-1:0]  len);
    wr_reset_status();
    if(MSG=="ON")
        $display("AXI4 Write ADDR[%h],LEN[%d]",addr,len);

    @(posedge inf.axi_aclk);
    inf.axi_awvalid = 1;
    inf.axi_awlen   = len-1;
    inf.axi_awaddr  = addr;
    inf.axi_awid    = $urandom_range(10,0);
    sync_wait(inf.axi_awready);
    inf.axi_awvalid = 0;
    // wid_box.put(inf.axi_awid);
endtask:aw_task

task automatic wdata_task(
    int                    length,
    int                    valid_ramdon_percent,
    ref  [DSIZE-1:0] data_s [$]
);
    if(MSG=="ON")
        ;
    gen_axi_stream(length,valid_ramdon_percent,data_s);
endtask:wdata_task

task automatic wbrep_task();
    inf.axi_bready  = 1;
    sync_wait(inf.axi_bvalid);
    inf.axi_bready  = 0;
    if(MSG=="ON")
        $display("WRITE BURST COMPLETE!!!");
endtask:wbrep_task

task automatic ar_task(logic [ASIZE-1:0]    addr,logic [LSIZE-1:0]  len);
    // @(posedge inf.axi_aclk);
    inf.axi_arvalid = 1;
    // @(posedge inf.axi_aclk);
    // $stop;
    inf.axi_arid    = $urandom_range(10,0);
    inf.axi_arlen   = len-1;
    inf.axi_araddr  = addr;
    sync_wait(inf.axi_arready);
    // forever begin 
    //     @(negedge inf.axi_aclk);
    //     if(inf.axi_arready)begin 
    //         break;
    //     end 
    // end
    // @(negedge inf.axi_aclk);
    #(1ps);
    inf.axi_arvalid = 0;
    if(MSG=="ON")
        $display("%t,MASTER AXI4 READ ADDR[%h]",$time,addr);
endtask:ar_task

task automatic ar_od_task(int id,int    addr,int  len);
IdAddrLen_S ial;
    inf.axi_arvalid = 1;
    inf.axi_arlen   = len-1;
    inf.axi_araddr  = addr;
    inf.axi_arid    = id;
    sync_wait(inf.axi_arready);
    ial.id  = inf.axi_arid;
    ial.addr = inf.axi_araddr;
    ial.len = inf.axi_arlen;
    #(1ps);
    inf.axi_arvalid = 0;
    if(MSG=="ON")
        $display("%t,MASTER AXI4 READ ADDR[%h]",$time,addr);
    tra_ar_od.push_back(ial);
endtask:ar_od_task

task automatic gen_axi_stream (
    int                    length,
    int                    valid_ramdon_percent,
    ref  [DSIZE-1:0] data_s [$]

);
int     index;
int     cc = 0;
int     data_len;
int     rt;
logic [DSIZE-1:0]   data_ss[$];
logic[DSIZE-1:0]    curr_data;
int    real_len;

    data_len = data_s.size();
    cc=0;

    if(length==0)
            real_len    = data_len;
    else    real_len    = length;

    repeat(real_len)begin
        index = cc%data_len;
        data_ss[cc] = data_s[index];
        cc++;
    end
    // $display("ORIGIN LENGTH: %d,REAL LENGTH: %d",data_s.size(),data_ss.size());
    if(MSG=="ON")begin
        $display("__________________________________");
        $display("GEN AXI4 write burst STREAM LEN = %d",data_ss.size());
    end
    while(1)begin
        rt = $urandom_range(99,0);

        if(rt < valid_ramdon_percent)begin
            inf.axi_wvalid  = 1;
            #(1ps);
            inf.axi_wdata  = data_ss.size() != 0? data_ss.pop_front : inf.axi_wdata;
            inf.axi_wlast  = data_ss.size() == 0;
            sync_wait(inf.axi_wready);
            // forever begin 
            //     @(negedge inf.axi_aclk);
            //     if(inf.axi_wready)begin 
            //         break;
            //     end
            // end
            if(inf.axi_wlast)
                break;
        end else begin
            inf.axi_wvalid  = 0;
            inf.axi_wlast   = 0;
            @(posedge inf.axi_aclk);
        end

    end

    #(1ps)
    // @(negedge inf.axi_aclk);
    inf.axi_wvalid    = 0;
    inf.axi_wlast     = 0;
    if(MSG=="ON")
        $display("==================================");
endtask:gen_axi_stream

task automatic get_axi_data(int rate = 100,ref logic [DSIZE-1:0]    data [$]);
int     rm;
    data = {};
    forever begin
        rm  = $urandom_range(0,99);
        if(rm < rate)
                inf.axi_rready    = 1;
        else    inf.axi_rready    = 0;
        if(inf.axi_rready)begin
            sync_wait(inf.axi_rvalid);
            // forever begin 
            //     @(negedge inf.axi_aclk);
            //     if(inf.axi_rvalid)begin 
            //         // @(posedge inf.axi_aclk);
            //         break;
            //     end
            // end

            data.push_back(inf.axi_rdata);
            if(inf.axi_rlast)begin
                // @(posedge inf.axi_aclk);
                    break;
            end
        end else begin
            @(posedge inf.axi_aclk);
        end
    end
    #(1ps);
    inf.axi_rready    = 0;
    if(MSG=="ON")
        $display("%t,MASTER AXI4 READ LENGTH [%d] DATA DONE!!!",$time,data.size());
endtask:get_axi_data

//public
task automatic write_burst(
    logic[ASIZE-1:0]       addr,
    int                    length,
    int                    valid_ramdon_percent,
    ref  [DSIZE-1:0]       data_s [$]
);
int     len ;
    if(length==0)
            len = data_s.size();
    else    len = length;

    aw_task(addr,len);
    wdata_task(len,valid_ramdon_percent,data_s);
    wbrep_task();
endtask:write_burst

task automatic read_burst(
    logic[ASIZE-1:0]       addr,
    int                    length,
    int                    ready_ramdon_percent,
    ref  [DSIZE-1:0]       data_s [$]
);
    ar_task(addr,length);
    get_axi_data(ready_ramdon_percent,data_s);
endtask:read_burst

logic [DSIZE-1:0]       rd_queue [$];

task automatic out_of_order_read_burst(
    ref IdAddrLen_S        ial [$],
    int                    ready_ramdon_percent,
    ref  [DSIZE-1:0]       data_s [$]
);
    fork
        foreach(ial[i])
            ar_od_task(ial[i].id,ial[i].addr,ial[i].len);
        foreach(ial[i])
            get_axi_data(ready_ramdon_percent,data_s);
    join
    if(MSG=="ON")
        $display("%t,MASTER AXI4 OUT OF ORDER READ BURST DONE!!!",$time);
endtask:out_of_order_read_burst


endclass:Axi4MasterBfm_c
//----------------------------------------------------------------------
// AXI 4 Slaver BFM
//____________________________________________________________________
class Axi4SlaverBfm_c #(
    parameter IDSIZE    = 1,
    parameter ASIZE     = 32,
    parameter LSIZE     = 1,
    parameter DSIZE     = 32,
    parameter MSG       = "ON",
    parameter ADDR_STEP = 32'hFFFF_FFFF,
    parameter FreqM     = 1
);
mailbox wid_box;
mailbox rid_box;

virtual axi_inf #(
    .IDSIZE    (IDSIZE  ),
    .ASIZE     (ASIZE   ),
    .LSIZE     (LSIZE   ),
    .DSIZE     (DSIZE   ),
    .ADDR_STEP (ADDR_STEP),
    .FreqM     (FreqM   )
) inf;


IdAddrLen_S rev_ar_OD   [$];

function new (virtual axi_inf #(.IDSIZE(IDSIZE),.ASIZE(ASIZE),.LSIZE(LSIZE),.DSIZE(DSIZE),.ADDR_STEP(ADDR_STEP),.FreqM(FreqM)) b);
    inf = b;
    wid_box = new();
    rid_box = new();

    inf.axi_rvalid  = 0;
    inf.axi_arready = 0;
endfunction:new

task automatic sync_wait(ref logic condition);
    forever begin
        @(negedge inf.axi_aclk);
        if(condition)begin 
            @(posedge inf.axi_aclk);
            break;
        end
    end
endtask:sync_wait

task automatic create_wr_transaction();
    inf.axi_awready = 1;
    inf.axi_wready  = 1;
    inf.axi_bid     = 0;
    inf.axi_bvalid  = 0;
    inf.axi_bresp   = 0;
endtask:create_wr_transaction

task automatic create_rd_transaction();
    inf.axi_arready = 1;
    inf.axi_rvalid  = 0;
    inf.axi_rid     = 0;
    inf.axi_rdata   = 0;
    inf.axi_rlast   = 0;
    inf.axi_rresp   = 0;
endtask:create_rd_transaction

task automatic create_transaction();
    create_wr_transaction();
    create_rd_transaction();
endtask:create_transaction

task automatic aw_task(ref logic[ASIZE-1:0] addr,ref logic[LSIZE-1:0]   len);
    inf.axi_awready = 1;
    sync_wait(inf.axi_awvalid);
    if(MSG=="ON")begin
        $display("%t,SLAVER AXI4 WRITE BURST REQ ADDR[%h],LEN[%d]",$time,inf.axi_awaddr,inf.axi_awlen);
    end
    addr = inf.axi_awaddr;
    len =  inf.axi_awlen;
    wid_box.put(inf.axi_awid);
endtask:aw_task

task automatic ar_task(ref logic[ASIZE-1:0] addr,ref logic[LSIZE-1:0]   len);
    inf.axi_arready = 1;
    sync_wait(inf.axi_arvalid);
    inf.axi_arready = 0;
    if(MSG=="ON")begin
        $display("%t,SLAVER AXI4 READ BURST REQ ADDR[%h],LEN[%d]",$time,inf.axi_araddr,inf.axi_arlen);
    end
    addr = inf.axi_araddr;
    len =  inf.axi_arlen;
    rid_box.put(inf.axi_arid);
endtask:ar_task


task automatic ar_od_task();
IdAddrLen_S  ial;
    inf.axi_arready = 1;
    sync_wait(inf.axi_arvalid);
    ial.id      = inf.axi_arid;
    ial.addr    = inf.axi_araddr;
    ial.len     = inf.axi_arlen;
    rid_box.put(inf.axi_arid);
    if(MSG=="ON")begin
        $display("%t,SLAVER AXI4 READ BURST REQ ID [%d] ADDR[%h],LEN[%d]",$time,ial.id,ial.addr,ial.len);
    end
    rev_ar_OD.push_back(ial);
endtask:ar_od_task

task automatic wdata_task(
    int                   ready_ramdon_percent,
    ref logic[DSIZE-1:0]  data [$]);
int     rt;
    data    = {};
    forever begin
        rt = $urandom_range(99,0);
        if(rt < ready_ramdon_percent)begin
            inf.axi_wready  = 1;
            sync_wait(inf.axi_wvalid);
            data    = {data,inf.axi_wdata};
            if(inf.axi_wlast)
                break;
        end else begin
            inf.axi_wready  = 0;
            @(posedge inf.axi_aclk);
        end
    end
    if(MSG=="ON")
        $display("%t,AXI4 GET DATA LEN [%d]",$time,data.size());
endtask:wdata_task

task automatic rdata_task(
    int                   len,
    int                   valid_ramdon_percent,
    ref logic[DSIZE-1:0]  data [$]
);
int rt;
logic[DSIZE-1:0]    data_queue[$];
    resize_queue(len+1,data,data_queue);
    // $display("AXI4 READ BURST SLAVER DONE !!! LEN [%d]",len);
    rid_box.get(inf.axi_rid);
    forever begin
        rt = $urandom_range(99,0);
        if(rt < valid_ramdon_percent)begin
            inf.axi_rvalid  = 1;
            inf.axi_rdata  = data_queue.size() != 0? data_queue.pop_front : inf.axi_rdata;
            inf.axi_rlast  = data_queue.size() == 0;
            sync_wait(inf.axi_rready);
            if(inf.axi_rlast)
                break;
        end else begin
            inf.axi_rvalid  = 0;
            inf.axi_rlast   = 0;
            @(posedge   inf.axi_aclk);
        end
    end
    inf.axi_rvalid  = 0;
    inf.axi_rlast   = 0;
    inf.axi_arready = 1;
    if(MSG=="ON")
        $display("%t,AXI4 READ BURST SLAVER DONE !!! LEN [%0d]",$time,len);
endtask:rdata_task

task automatic rdata_od_task(
    int                   id,
    int                   len,
    int                   valid_ramdon_percent,
    ref logic[DSIZE-1:0]  data [$]
);
int rt;
logic[DSIZE-1:0]    data_queue[$];
    resize_queue(len,data,data_queue);
    // $display(">>>>>>AXI4 READ BURST SLAVER DONE !!! LEN [%d][%d]",len,data_queue.size());
    rid_box.get(inf.axi_rid);
    forever begin
        rt = $urandom_range(99,0);
        // inf.axi_rid     = id;
        if(rt < valid_ramdon_percent)begin
            inf.axi_rvalid  = 1;
            inf.axi_rdata  = data_queue.size() != 0? data_queue.pop_front : inf.axi_rdata;
            inf.axi_rlast  = data_queue.size() == 0;
            sync_wait(inf.axi_rready);
            if(inf.axi_rlast)begin
                @(posedge   inf.axi_aclk);
                break;
            end
        end else begin
            inf.axi_rvalid  = 0;
            inf.axi_rlast   = 0;
            @(posedge   inf.axi_aclk);
        end
    end
    inf.axi_rvalid  = 0;
    inf.axi_rlast   = 0;
    if(MSG=="ON")
        $display("%t,AXI4 READ BURST SLAVER DONE !!! LEN [%d]",$time,len);
endtask:rdata_od_task

task automatic wbresp_task();
    inf.axi_bresp = '0;
    inf.axi_bvalid = 1;
    wid_box.get(inf.axi_bid);
    sync_wait(inf.axi_bready);
    inf.axi_bvalid = 0;
    if(MSG=="ON")
        $display("%t,AXI4 WRITE BUSRT BRESP DONE !!!",$time);
endtask:wbresp_task

task automatic resize_queue(
    int                 len,
    ref logic [DSIZE-1:0]   in_queue [$],
    ref logic [DSIZE-1:0]   out_queue[$]
);
int real_len;
int d_len;
int r_len;
out_queue   = {};
if(len == 0)
    out_queue = in_queue;
else if(len <= in_queue.size())
    out_queue   = in_queue[0:(len-1)];
else begin
    real_len    = in_queue.size();
    d_len = len/real_len;
    r_len = len%real_len;
    for(int i=0;i<d_len;i++)
        out_queue = {out_queue,in_queue};
    out_queue = {out_queue,in_queue[0:(r_len-1)]};

end
// $display("---%d--%d--%d",len,in_queue.size(),out_queue.size());
endtask:resize_queue

task automatic burst_write(
    ref logic[ASIZE-1:0]   addr,
    ref logic[LSIZE-1:0]   length,
    input int              ready_ramdon_percent,
    ref  [DSIZE-1:0]       data_s [$]
);
    aw_task(addr,length);
    wdata_task(ready_ramdon_percent,data_s);
    wbresp_task();
endtask:burst_write

task automatic burst_read(
    ref logic[ASIZE-1:0]   addr,
    ref logic[LSIZE-1:0]   length,
    int                    valid_ramdon_percent,
    ref  [DSIZE-1:0]       data_s [$]
);

    ar_task(addr,length);
    rdata_task(int'(length),valid_ramdon_percent,data_s);
endtask:burst_read


logic [ASIZE-1:0]       wr_addr,rd_addr;
logic [LSIZE-1:0]       wr_len,rd_len;
logic [DSIZE-1:0]       wr_queue [$];
logic [DSIZE-1:0]       rd_queue [$];

task automatic run (int valid_ramdon_percent,int ready_ramdon_percent);
    create_transaction();
    fork
        forever begin
            burst_write(wr_addr,wr_len,ready_ramdon_percent,wr_queue);
        end
        forever begin
            burst_read(rd_addr,rd_len,valid_ramdon_percent,rd_queue);
        end
    join_none
endtask:run

task automatic out_fo_order_burst_read(
    int                    valid_ramdon_percent
);
IdAddrLen_S idl;
logic [DSIZE-1:0]       rd_queue [$];
rd_queue    = {0,1,2,3,4,5,6,7,8,9};
fork
    forever begin
        ar_od_task();
    end
    forever begin
        forever begin
            @(posedge inf.axi_aclk);
            if(rev_ar_OD.size()>0)
                break;
        end
        idl = rev_ar_OD.pop_front();
        rdata_od_task(idl.id,int'(idl.len+1),valid_ramdon_percent,rd_queue);
    end
join_none
endtask:out_fo_order_burst_read


endclass:Axi4SlaverBfm_c

endpackage:AxiBfmPkg

// package AXI_BFM_PKG;
//     import AxiBfmPkg::*;
//     export AxiBfmPkg::*;
// endpackage

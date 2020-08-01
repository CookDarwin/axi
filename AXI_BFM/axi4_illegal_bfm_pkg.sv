package AxiIllegalBfmPkg ;
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

task automatic sync_clk_wait(ref bit clock,ref logic condition);
    forever begin
        @(posedge clock);
        if(condition)
            break;
    end
endtask:sync_clk_wait


typedef struct {
    int                 offset_len;
    bit                 last_off;
    bit                 aw_off;
    bit                 ar_off;
} axi4_illegal_s;



//---------------------------------------------------------------------
// AXI 4 Master BFM
//____________________________________________________________________
class Axi4IllMasterBfm_c #(
    parameter IDSIZE    = 1,
    parameter ASIZE     = 32,
    parameter LSIZE     = 1,
    parameter DSIZE     = 32,
    parameter MSG       = "ON",
    parameter ADDR_STEP = 32'hFFFF_FFFF
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
    .ADDR_STEP (ADDR_STEP)
) inf;


function new (virtual axi_inf #(.IDSIZE(IDSIZE),.ASIZE(ASIZE),.LSIZE(LSIZE),.DSIZE(DSIZE),.ADDR_STEP(ADDR_STEP)) b);
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


task automatic aw_task(logic [ASIZE-1:0]    addr,logic [LSIZE-1:0]  len,bit aw_off=0);
    wr_reset_status();
    if(MSG=="ON")
        $display("AXI4 Write ADDR[%h],LEN[%d]",addr,len);

    @(posedge inf.axi_aclk);
    if(~aw_off)begin
        inf.axi_awvalid = 1;
        inf.axi_awlen   = len-1;
        inf.axi_awaddr  = addr;
        inf.axi_awid    = $urandom_range(10,0);
        sync_wait(inf.axi_awready);
        inf.axi_awvalid = 0;
    end else begin
        if(MSG=="ON")
            $display("AXI4 Write AW ON");
        @(posedge inf.axi_aclk);
    end
    // wid_box.put(inf.axi_awid);
endtask:aw_task

task automatic wdata_task(
    bit                    last_off,
    int                    length,
    int                    valid_ramdon_percent,
    ref  [DSIZE-1:0] data_s [$]
);
    if(MSG=="ON")
        ;
    gen_axi_stream(last_off,length,valid_ramdon_percent,data_s);
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
    inf.axi_arvalid = 0;
    if(MSG=="ON")
        $display("%t,MASTER AXI4 READ ADDR[%h]",$time,addr);
    tra_ar_od.push_back(ial);
endtask:ar_od_task

task automatic gen_axi_stream (
    bit                    last_off,
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
int     real_len;
bit     virtual_last;

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
            inf.axi_wdata   = data_ss.size() != 0? data_ss.pop_front : inf.axi_wdata;
            virtual_last    = data_ss.size() == 0;
            if(~last_off)begin
                inf.axi_wlast  = data_ss.size() == 0;
            end

            sync_wait(inf.axi_wready);
            if(virtual_last)
                break;
        end else begin
            inf.axi_wvalid  = 0;
            inf.axi_wlast   = 0;
            virtual_last    = 0;
            @(posedge inf.axi_aclk);
        end

    end

    #1
    inf.axi_wvalid    = 0;
    inf.axi_wlast     = 0;
    virtual_last      = 0;
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
            data.push_back(inf.axi_rdata);
            if(inf.axi_rlast)begin
                    break;
            end
        end else begin
            @(posedge inf.axi_aclk);
        end
    end
    inf.axi_rready    = 0;
    if(MSG=="ON")
        $display("%t,MASTER AXI4 READ LENGTH [%d] DATA DONE!!!",$time,data.size());
endtask:get_axi_data

//public
task automatic write_burst(
    ref  axi4_illegal_s    illegal_s,
    input logic[ASIZE-1:0]       addr,
    input int                    length,
    input int                    valid_ramdon_percent,
    ref  [DSIZE-1:0]       data_s [$]
);
int     len ;
    if(length==0)
            len = data_s.size();
    else    len = length;

    aw_task(addr,len,illegal_s.aw_off);
    wdata_task(illegal_s.last_off,len+illegal_s.offset_len,valid_ramdon_percent,data_s);
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
endtask:out_of_order_read_burst


endclass:Axi4IllMasterBfm_c
//----------------------------------------------------------------------
// AXI 4 Slaver BFM
//____________________________________________________________________
class Axi4IllSlaverBfm_c #(
    parameter IDSIZE    = 1,
    parameter ASIZE     = 32,
    parameter LSIZE     = 1,
    parameter DSIZE     = 32,
    parameter MSG       = "ON",
    parameter ADDR_STEP = 32'hFFFF_FFFF
);
mailbox wid_box;
mailbox rid_box;

virtual axi_inf #(
    .IDSIZE    (IDSIZE  ),
    .ASIZE     (ASIZE   ),
    .LSIZE     (LSIZE   ),
    .DSIZE     (DSIZE   ),
    .ADDR_STEP (ADDR_STEP)
) inf;


IdAddrLen_S rev_ar_OD   [$];

function new (virtual axi_inf #(.IDSIZE(IDSIZE),.ASIZE(ASIZE),.LSIZE(LSIZE),.DSIZE(DSIZE),.ADDR_STEP(ADDR_STEP)) b);
    inf = b;
    wid_box = new();
    rid_box = new();

    inf.axi_rvalid  = 0;
    inf.axi_arready = 0;
endfunction:new

task automatic sync_wait(ref logic condition);
    forever begin
        @(posedge inf.axi_aclk);
        if(condition)
            break;
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


endclass:Axi4IllSlaverBfm_c


endpackage

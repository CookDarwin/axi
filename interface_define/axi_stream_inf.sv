//2017/3/15 
interface axi_stream_inf #(
    parameter DSIZE     = 32,
    parameter real FreqM    = 1,
    parameter KSIZE     = (DSIZE/8 > 0)? DSIZE/8 : 1,
    parameter CSIZE     = 32,        //cnt size
    // parameter KSIZE   = 1
    parameter USIZE     = 1
)(
    input bit   aclk ,
    input bit   aresetn,
    input bit   aclken
);



logic[DSIZE-1:0]       axis_tdata    ;
logic                  axis_tvalid   ;
logic                  axis_tready   ;
logic[USIZE-1:0]       axis_tuser    ;
logic                  axis_tlast    ;
logic[KSIZE-1:0]       axis_tkeep    ;
logic[CSIZE-1:0]       axis_tcnt     ;

modport master (
input     aclk ,
input     aresetn,
input     aclken,
output    axis_tdata   ,
output    axis_tvalid  ,
input     axis_tready  ,
output    axis_tuser   ,
output    axis_tlast   ,
output    axis_tkeep   ,
input     axis_tcnt
);

modport slaver (
input    aclk ,
input    aresetn,
input    aclken,
input    axis_tdata   ,
input    axis_tvalid  ,
output   axis_tready  ,
input    axis_tuser   ,
input    axis_tlast   ,
input    axis_tkeep   ,
input    axis_tcnt
);

modport mirror (
input    aclk ,
input    aresetn,
input    aclken,
input    axis_tdata   ,
input    axis_tvalid  ,
input    axis_tready  ,
input    axis_tuser   ,
input    axis_tlast   ,
input    axis_tkeep   ,
input    axis_tcnt
);

modport out_mirror (
input    aclk ,
input    aresetn,
input    aclken,
output   axis_tdata   ,
output   axis_tvalid  ,
output   axis_tready  ,
output   axis_tuser   ,
output   axis_tlast   ,
output   axis_tkeep   ,
input    axis_tcnt
);


always@(posedge aclk,negedge aresetn)
    if(~aresetn)  axis_tcnt <= '0;
    else begin
        if(axis_tvalid && axis_tready && axis_tlast)
                axis_tcnt  <= '0;
        else if(axis_tvalid && axis_tready)
                axis_tcnt  <= axis_tcnt + 1'b1;
        else    axis_tcnt  <= axis_tcnt;
    end

// always@(posedge aclk,negedge aresetn)
//     if(~aresetn)  axis_tcnt[1:0] <= '0;
//     else begin
//         if(axis_tvalid && axis_tready && axis_tlast)
//                 axis_tcnt[1:0]  <= '0;
//         else if(axis_tvalid && axis_tready)
//                 axis_tcnt[1:0]  <= axis_tcnt[1:0] + 1'b1;
//         else    axis_tcnt[1:0]  <= axis_tcnt[1:0];
//     end
//
// always@(posedge aclk,negedge aresetn)
//     if(~aresetn)  axis_tcnt[CSIZE-1:2] <= '0;
//     else begin
//         if(axis_tvalid && axis_tready && axis_tlast)
//                 axis_tcnt[CSIZE-1:2]  <= '0;
//         else if(axis_tvalid && axis_tready)
//                 axis_tcnt[CSIZE-1:2]  <= axis_tcnt[CSIZE-1:2] + (&axis_tcnt[1:0]);
//         else    axis_tcnt[CSIZE-1:2]  <= axis_tcnt[CSIZE-1:2];
//     end

endinterface:axi_stream_inf

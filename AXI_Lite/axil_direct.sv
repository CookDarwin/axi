/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/11/16 
madified:
***********************************************/
`timescale 1ns/1ps
module axil_direct(
    axi_lite_inf.slaver     slaver,
    axi_lite_inf.master     master
);

initial begin
    assert(slaver.DSIZE == master.DSIZE)
    else begin
        $error("\nSLAVER DSIZE[%d] must eql MASTER's[%d]\n",slaver.DSIZE,master.DSIZE);
        $stop;
    end

    assert(slaver.ASIZE == master.ASIZE)
    else begin
        $error("\nSLAVER ASIZE[%d] must eql MASTER's[%d]\n",slaver.ASIZE,master.ASIZE);
        $stop;
    end

end

assign    master.axi_awvalid     = slaver.axi_awvalid  ;
assign    master.axi_awaddr      = slaver.axi_awaddr   ;
assign    master.axi_awlock      = slaver.axi_awlock   ;
assign    master.axi_wvalid      = slaver.axi_wvalid   ;
assign    master.axi_wdata       = slaver.axi_wdata    ;
assign    master.axi_bready      = slaver.axi_bready   ;
assign    master.axi_arvalid     = slaver.axi_arvalid  ;
assign    master.axi_araddr      = slaver.axi_araddr   ;
assign    master.axi_arlock      = slaver.axi_arlock   ;
assign    master.axi_rready      = slaver.axi_rready   ;


assign  slaver.axi_awready     =  master.axi_awready     ;
assign  slaver.axi_wready      =  master.axi_wready      ;
assign  slaver.axi_bresp       =  master.axi_bresp       ;
assign  slaver.axi_bvalid      =  master.axi_bvalid      ;
assign  slaver.axi_arready     =  master.axi_arready     ;
assign  slaver.axi_rvalid      =  master.axi_rvalid      ;
assign  slaver.axi_rdata       =  master.axi_rdata       ;

endmodule

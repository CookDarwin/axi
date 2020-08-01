
// `include "E:\\work\\xilinx\\AXI4\\AXI4_BFM\\axi_interface.sv"
module axi_life_master #(
    parameter ASIZE = 8,
    parameter DSIZE = 32
)(
    axi_lite_inf.master inf
);

logic[DSIZE-1:0]        read_data;

initial begin
    set_idle;
end

task set_idle;
    inf.axi_awvalid    = 1'd0;
    inf.axi_awaddr     = {ASIZE{1'd0}};
    inf.axi_wvalid     = 1'd0;
    inf.axi_wdata      = {DSIZE{1'd0}};
    inf.axi_bready     = 1'd1;
    inf.axi_arvalid    = 1'd0;
    inf.axi_araddr     = {ASIZE{1'd0}};
    inf.axi_rready     = 1'b1;
endtask:set_idle

task automatic  read (input [ASIZE-1:0]    addr,output logic [DSIZE-1:0]   data);
    wait(inf.axi_aresetn);
    @(posedge inf.axi_aclk);
    inf.axi_arvalid    = 1'b1;
    inf.axi_araddr     = addr;
    inf.axi_rready     = 1'b1;
    fork
        begin
            wait(inf.axi_arready);
            @(posedge inf.axi_aclk);
            inf.axi_arvalid    = 1'b0;
        end
        begin
            wait(inf.axi_rvalid)
            @(posedge inf.axi_aclk);
            inf.axi_rready     = 1'b0;
        end
    join

    read_data = inf.axi_rdata;
    data = read_data;
    //--->> set idle <<--------
    inf.axi_arvalid    = 1'b0;
    inf.axi_araddr     = {ASIZE{1'b0}};
    inf.axi_rready     = 1'b1;
    $display("Lite Read %h,result %h",addr,read_data);
endtask:read

task write(
    input [ASIZE-1:0]   addr ,
    input [DSIZE-1:0]   data
);
event   brs;
    wait(inf.axi_aresetn);
    @(posedge inf.axi_aclk);

    inf.axi_awvalid    = 1'b1;
    inf.axi_awaddr     = addr;
    inf.axi_wvalid     = 1'b1;
    inf.axi_wdata      = data;
    inf.axi_bready     = 1'd1;
    fork
        begin
            wait(inf.axi_awready);
            @(posedge inf.axi_aclk);
            inf.axi_awvalid    = 1'b0;
        end
        begin
            wait(inf.axi_wready);
            ->brs;
            @(posedge inf.axi_aclk);
            inf.axi_wvalid     = 1'b0;
        end
        begin
            wait(brs.triggered);
            wait(inf.axi_bvalid);
            @(posedge inf.axi_aclk);
            if(inf.axi_bresp == 2'b10)begin
                $display("AXI WRITE SLAVE ERROR");
                $stop;
            end else if(inf.axi_bresp == 2'b11)begin
                $display("AXI WRITE DECODE ERROR");
                $stop;
            end
        end
    join
    @(posedge inf.axi_aclk);
    //--->>set idle <<------
    inf.axi_bready     = 1'd1;
    inf.axi_awvalid    = 1'b0;
    inf.axi_awaddr     = {ASIZE{1'b0}};
    inf.axi_wvalid     = 1'b0;
    inf.axi_wdata      = {DSIZE{1'b0}};
endtask:write

endmodule

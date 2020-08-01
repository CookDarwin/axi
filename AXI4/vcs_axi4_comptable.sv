/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
created: ###### Tue Sep 10 15:48:12 CST 2019
madified:
***********************************************/
`timescale 1ns/1ps
`include "define_macro.sv"
module vcs_axi4_comptable #(
    `parameter_string   ORIGIN = "master",
    `parameter_string   TO     = "slaver"
)(
    axi_inf         origin,
    axi_inf         to
);

generate
if(TO=="mirror")begin  
    if(ORIGIN=="slaver" || ORIGIN=="master")begin 
        assign to.axi_awid     = origin.axi_awid   ;
        assign to.axi_awaddr   = origin.axi_awaddr ;
        assign to.axi_awlen    = origin.axi_awlen  ;
        assign to.axi_awsize   = origin.axi_awsize ;
        assign to.axi_awburst  = origin.axi_awburst;
        assign to.axi_awlock   = origin.axi_awlock ;
        assign to.axi_awcache  = origin.axi_awcache;
        assign to.axi_awprot   = origin.axi_awprot ;
        assign to.axi_awqos    = origin.axi_awqos  ;
        assign to.axi_awvalid  = origin.axi_awvalid;
        assign to.axi_awready  = origin.axi_awready;
        assign to.axi_wdata    = origin.axi_wdata  ;
        assign to.axi_wstrb    = origin.axi_wstrb  ;
        assign to.axi_wlast    = origin.axi_wlast  ;
        assign to.axi_wvalid   = origin.axi_wvalid ;
        assign to.axi_wready   = origin.axi_wready ;
        assign to.axi_bready   = origin.axi_bready ;
        assign to.axi_bid      = origin.axi_bid    ;
        assign to.axi_bresp    = origin.axi_bresp  ;
        assign to.axi_bvalid   = origin.axi_bvalid ;
        assign to.axi_arid     = origin.axi_arid   ;
        assign to.axi_araddr   = origin.axi_araddr ;
        assign to.axi_arlen    = origin.axi_arlen  ;
        assign to.axi_arsize   = origin.axi_arsize ;
        assign to.axi_arburst  = origin.axi_arburst;
        assign to.axi_arlock   = origin.axi_arlock ;
        assign to.axi_arcache  = origin.axi_arcache;
        assign to.axi_arprot   = origin.axi_arprot ;
        assign to.axi_arqos    = origin.axi_arqos  ;
        assign to.axi_arvalid  = origin.axi_arvalid;
        assign to.axi_arready  = origin.axi_arready;
        assign to.axi_rready   = origin.axi_rready ;
        assign to.axi_rid      = origin.axi_rid    ;
        assign to.axi_rdata    = origin.axi_rdata  ;
        assign to.axi_rresp    = origin.axi_rresp  ;
        assign to.axi_rlast    = origin.axi_rlast  ;
        assign to.axi_rvalid   = origin.axi_rvalid ;
    end else begin 
        initial begin
            $error("vcs_axi4_comptable ORIGIN[%s] => [%s] ERROR",ORIGIN,TO);
            $stop;
        end
    end
end else if(TO=="mirror_rd")begin 
    if(ORIGIN=="slaver" || ORIGIN=="master" || ORIGIN=="slaver_rd" || ORIGIN=="master_rd" || ORIGIN=="mirror")begin 
        assign  to.axi_arid     = origin.axi_arid   ;
        assign  to.axi_araddr   = origin.axi_araddr ;
        assign  to.axi_arlen    = origin.axi_arlen  ;
        assign  to.axi_arsize   = origin.axi_arsize ;
        assign  to.axi_arburst  = origin.axi_arburst;
        assign  to.axi_arlock   = origin.axi_arlock ;
        assign  to.axi_arcache  = origin.axi_arcache;
        assign  to.axi_arprot   = origin.axi_arprot ;
        assign  to.axi_arqos    = origin.axi_arqos  ;
        assign  to.axi_arvalid  = origin.axi_arvalid;
        assign  to.axi_arready  = origin.axi_arready;
        assign  to.axi_rready   = origin.axi_rready ;
        assign  to.axi_rid      = origin.axi_rid    ;
        assign  to.axi_rdata    = origin.axi_rdata  ;
        assign  to.axi_rresp    = origin.axi_rresp  ;
        assign  to.axi_rlast    = origin.axi_rlast  ;
        assign  to.axi_rvalid   = origin.axi_rvalid ;
    end else begin
        initial begin
            $error("vcs_axi4_comptable ORIGIN[%s] => [%s] ERROR",ORIGIN,TO);
            $stop;
        end 
    end
end else if(ORIGIN=="slaver")begin 
    if(TO=="slaver_wr")begin 
        assign   to.axi_awid     = origin.axi_awid    ; 
        assign   to.axi_awaddr   = origin.axi_awaddr  ; 
        assign   to.axi_awlen    = origin.axi_awlen   ; 
        assign   to.axi_awsize   = origin.axi_awsize  ; 
        assign   to.axi_awburst  = origin.axi_awburst ; 
        assign   to.axi_awlock   = origin.axi_awlock  ; 
        assign   to.axi_awcache  = origin.axi_awcache ; 
        assign   to.axi_awprot   = origin.axi_awprot  ; 
        assign   to.axi_awqos    = origin.axi_awqos   ; 
        assign   to.axi_awvalid  = origin.axi_awvalid ; 
        assign   origin.axi_awready  = to.axi_awready ; 
        assign   to.axi_wdata    = origin.axi_wdata   ; 
        assign   to.axi_wstrb    = origin.axi_wstrb   ; 
        assign   to.axi_wlast    = origin.axi_wlast   ; 
        assign   to.axi_wvalid   = origin.axi_wvalid  ; 
        assign   origin.axi_wready   = to.axi_wready  ; 
        assign   to.axi_bready   = origin.axi_bready  ; 
        assign   origin.axi_bid      = origin.axi_bid     ; 
        assign   origin.axi_bresp    = to.axi_bresp   ; 
        assign   origin.axi_bvalid   = to.axi_bvalid  ; 
    end else if(TO=="slaver_rd")begin 
        assign    to.axi_arid     = origin.axi_arid   ;
        assign    to.axi_araddr   = origin.axi_araddr ;
        assign    to.axi_arlen    = origin.axi_arlen  ;
        assign    to.axi_arsize   = origin.axi_arsize ;
        assign    to.axi_arburst  = origin.axi_arburst;
        assign    to.axi_arlock   = origin.axi_arlock ;
        assign    to.axi_arcache  = origin.axi_arcache;
        assign    to.axi_arprot   = origin.axi_arprot ;
        assign    to.axi_arqos    = origin.axi_arqos  ;
        assign    to.axi_arvalid  = origin.axi_arvalid;
        assign    to.axi_rready   = origin.axi_rready ;
        assign    origin.axi_arready  = to.axi_arready;
        assign    origin.axi_rid      = to.axi_rid    ;
        assign    origin.axi_rdata    = to.axi_rdata  ;
        assign    origin.axi_rresp    = to.axi_rresp  ;
        assign    origin.axi_rlast    = to.axi_rlast  ;
        assign    origin.axi_rvalid   = to.axi_rvalid ;
    end else begin 
        initial begin
            $error("vcs_axi4_comptable ORIGIN[%s] => [%s] ERROR",ORIGIN,TO);
            $stop;
        end
    end 
end  else if(ORIGIN == "master_rd")begin 
    if(TO == "master_rd_aux")begin 
        assign   to.axi_arid      = origin.axi_arid   ;
        assign   to.axi_araddr    = origin.axi_araddr ;
        assign   to.axi_arlen     = origin.axi_arlen  ;
        assign   to.axi_arsize    = origin.axi_arsize ;
        assign   to.axi_arburst   = origin.axi_arburst;
        assign   to.axi_arlock    = origin.axi_arlock ;
        assign   to.axi_arcache   = origin.axi_arcache;
        assign   to.axi_arprot    = origin.axi_arprot ;
        assign   to.axi_arqos     = origin.axi_arqos  ;
        assign   to.axi_arvalid   = origin.axi_arvalid;
        assign   origin.axi_arready = to.axi_arready  ;
        assign   origin.axi_rready  = to.axi_rready   ;
        assign   origin.axi_rid     = to.axi_rid      ;
        assign   origin.axi_rresp   = to.axi_rresp    ;
        assign   origin.axi_rlast   = to.axi_rlast    ;
        assign   origin.axi_rvalid  = to.axi_rvalid   ;
    end else if(TO == "master")begin
        assign     to.axi_arid     = origin.axi_arid   ;
        assign     to.axi_araddr   = origin.axi_araddr ;
        assign     to.axi_arlen    = origin.axi_arlen  ;
        assign     to.axi_arsize   = origin.axi_arsize ;
        assign     to.axi_arburst  = origin.axi_arburst;
        assign     to.axi_arlock   = origin.axi_arlock ;
        assign     to.axi_arcache  = origin.axi_arcache;
        assign     to.axi_arprot   = origin.axi_arprot ;
        assign     to.axi_arqos    = origin.axi_arqos  ;
        assign     to.axi_arvalid  = origin.axi_arvalid;
        assign     to.axi_rready   = origin.axi_rready ;
        assign     origin.axi_arready = to.axi_arready ;
        assign     origin.axi_rid     = to.axi_rid     ;
        assign     origin.axi_rdata   = to.axi_rdata   ;
        assign     origin.axi_rresp   = to.axi_rresp   ;
        assign     origin.axi_rlast   = to.axi_rlast   ;
        assign     origin.axi_rvalid  = to.axi_rvalid  ;
    end else begin 
        initial begin
            $error("vcs_axi4_comptable ORIGIN[%s] => [%s] ERROR",ORIGIN,TO);
            $stop;
        end
    end 
end else if(ORIGIN=="master")begin 
    if(TO=="master_wr")begin 
        // assign    origin.axi_awid     = to.axi_awid   ;
        // assign    origin.axi_awaddr   = to.axi_awaddr ;
        // assign    origin.axi_awlen    = to.axi_awlen  ;
        // assign    origin.axi_awsize   = to.axi_awsize ;
        // assign    origin.axi_awburst  = to.axi_awburst;
        // assign    origin.axi_awlock   = to.axi_awlock ;
        // assign    origin.axi_awcache  = to.axi_awcache;
        // assign    origin.axi_awprot   = to.axi_awprot ;
        // assign    origin.axi_awqos    = to.axi_awqos  ;
        // assign    origin.axi_awvalid  = to.axi_awvalid;
        // assign    to.axi_awready  = origin.axi_awready;
        // assign    origin.axi_wdata    = to.axi_wdata  ;
        // assign    origin.axi_wstrb    = to.axi_wstrb  ;
        // assign    origin.axi_wlast    = to.axi_wlast  ;
        // assign    origin.axi_wvalid   = to.axi_wvalid ;
        // assign    to.axi_wready   = origin.axi_wready ;
        // assign    origin.axi_bready   = to.axi_bready ;
        // assign    to.axi_bid      = origin.axi_bid    ;
        // assign    to.axi_bresp    = origin.axi_bresp  ;
        // assign    to.axi_bvalid   = origin.axi_bvalid ;

        assign    to.axi_awid     = origin.axi_awid   ;
        assign    to.axi_awaddr   = origin.axi_awaddr ;
        assign    to.axi_awlen    = origin.axi_awlen  ;
        assign    to.axi_awsize   = origin.axi_awsize ;
        assign    to.axi_awburst  = origin.axi_awburst;
        assign    to.axi_awlock   = origin.axi_awlock ;
        assign    to.axi_awcache  = origin.axi_awcache;
        assign    to.axi_awprot   = origin.axi_awprot ;
        assign    to.axi_awqos    = origin.axi_awqos  ;
        assign    to.axi_awvalid  = origin.axi_awvalid;
        assign    to.axi_wdata    = origin.axi_wdata  ;
        assign    to.axi_wstrb    = origin.axi_wstrb  ;
        assign    to.axi_wlast    = origin.axi_wlast  ;
        assign    to.axi_wvalid   = origin.axi_wvalid ;
        assign    to.axi_bready   = origin.axi_bready ;
        assign    origin.axi_wready   = to.axi_wready ;
        assign    origin.axi_awready  = to.axi_awready;
        assign    origin.axi_bid      = to.axi_bid    ;
        assign    origin.axi_bresp    = to.axi_bresp  ;
        assign    origin.axi_bvalid   = to.axi_bvalid ;
    end else if (TO == "master_rd") begin 
        assign   to.axi_arid      = origin.axi_arid   ;
        assign   to.axi_araddr    = origin.axi_araddr ;
        assign   to.axi_arlen     = origin.axi_arlen  ;
        assign   to.axi_arsize    = origin.axi_arsize ;
        assign   to.axi_arburst   = origin.axi_arburst;
        assign   to.axi_arlock    = origin.axi_arlock ;
        assign   to.axi_arcache   = origin.axi_arcache;
        assign   to.axi_arprot    = origin.axi_arprot ;
        assign   to.axi_arqos     = origin.axi_arqos  ;
        assign   to.axi_arvalid   = origin.axi_arvalid;
        assign   origin.axi_arready = to.axi_arready  ;
        assign   to.axi_rready  = origin.axi_rready   ;
        assign   origin.axi_rid     = to.axi_rid      ;
        assign   origin.axi_rresp   = to.axi_rresp    ;
        assign   origin.axi_rlast   = to.axi_rlast    ;
        assign   origin.axi_rvalid  = to.axi_rvalid   ;
    end else begin 
        initial begin
            $error("vcs_axi4_comptable ORIGIN[%s] => [%s] ERROR",ORIGIN,TO);
            $stop;
        end
    end
end else if(ORIGIN == "master_wr_aux_no_resp")begin 
    if(TO=="master" || TO == "master_wr")begin 
        assign   to.axi_awid     = origin.axi_awid   ;
        assign   to.axi_awaddr   = origin.axi_awaddr ;
        assign   to.axi_awlen    = origin.axi_awlen  ;
        assign   to.axi_awsize   = origin.axi_awsize ;
        assign   to.axi_awburst  = origin.axi_awburst;
        assign   to.axi_awlock   = origin.axi_awlock ;
        assign   to.axi_awcache  = origin.axi_awcache;
        assign   to.axi_awprot   = origin.axi_awprot ;
        assign   to.axi_awqos    = origin.axi_awqos  ;
        assign   to.axi_awvalid  = origin.axi_awvalid;
        assign   origin.axi_awready  = to.axi_awready;
        assign   origin.axi_wlast    = to.axi_wlast  ;
        assign   origin.axi_wvalid   = to.axi_wvalid ;
        assign   origin.axi_wready   = to.axi_wready ;
    end else begin
        initial begin
            $error("vcs_axi4_comptable ORIGIN[%s] => [%s] ERROR",ORIGIN,TO);
            $stop;
        end
    end 
end else if(ORIGIN == "master_rd_aux")begin 
    if(TO=="master" || TO=="master_rd")begin 
        assign   to.axi_arid      = origin.axi_arid   ;
        assign   to.axi_araddr    = origin.axi_araddr ;
        assign   to.axi_arlen     = origin.axi_arlen  ;
        assign   to.axi_arsize    = origin.axi_arsize ;
        assign   to.axi_arburst   = origin.axi_arburst;
        assign   to.axi_arlock    = origin.axi_arlock ;
        assign   to.axi_arcache   = origin.axi_arcache;
        assign   to.axi_arprot    = origin.axi_arprot ;
        assign   to.axi_arqos     = origin.axi_arqos  ;
        assign   to.axi_arvalid   = origin.axi_arvalid;
        assign   origin.axi_arready = to.axi_arready  ;
        assign   origin.axi_rready  = to.axi_rready   ;
        assign   origin.axi_rid     = to.axi_rid      ;
        assign   origin.axi_rresp   = to.axi_rresp    ;
        assign   origin.axi_rlast   = to.axi_rlast    ;
        assign   origin.axi_rvalid  = to.axi_rvalid   ;
    end else begin 
        initial begin
            $error("vcs_axi4_comptable ORIGIN[%s] => [%s] ERROR",ORIGIN,TO);
            $stop;
        end
    end 
end else if(ORIGIN=="master_wr")begin 
    if(TO=="master")begin 
        assign    to.axi_awid     = origin.axi_awid   ;
        assign    to.axi_awaddr   = origin.axi_awaddr ;
        assign    to.axi_awlen    = origin.axi_awlen  ;
        assign    to.axi_awsize   = origin.axi_awsize ;
        assign    to.axi_awburst  = origin.axi_awburst;
        assign    to.axi_awlock   = origin.axi_awlock ;
        assign    to.axi_awcache  = origin.axi_awcache;
        assign    to.axi_awprot   = origin.axi_awprot ;
        assign    to.axi_awqos    = origin.axi_awqos  ;
        assign    to.axi_awvalid  = origin.axi_awvalid;
        assign    to.axi_wdata    = origin.axi_wdata  ;
        assign    to.axi_wstrb    = origin.axi_wstrb  ;
        assign    to.axi_wlast    = origin.axi_wlast  ;
        assign    to.axi_wvalid   = origin.axi_wvalid ;
        assign    to.axi_bready   = origin.axi_bready ;
        assign    origin.axi_wready   = to.axi_wready ;
        assign    origin.axi_awready  = to.axi_awready;
        assign    origin.axi_bid      = to.axi_bid    ;
        assign    origin.axi_bresp    = to.axi_bresp  ;
        assign    origin.axi_bvalid   = to.axi_bvalid ;
    end else begin 
        initial begin
            $error("vcs_axi4_comptable ORIGIN[%s] => [%s] ERROR",ORIGIN,TO);
            $stop;
        end
    end 
end else begin 
    initial begin
        $error("vcs_axi4_comptable ORIGIN[%s] => [%s] ERROR",ORIGIN,TO);
        $stop;
    end
end

endgenerate


endmodule
/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.1.0
    just fot tdl
Version: VERC.0.0 
    just fot tdl, use class parameter
creaded: 2017/4/5 
madified:
***********************************************/
`timescale 1ns/1ps
`include "define_macro.sv"
(* axi4 = "true" *)
module axi4_direct_verc #(
    `parameter_string MODE  = "BOTH_to_BOTH",    //ONLY_READ to BOTH,ONLY_WRITE to BOTH,BOTH to BOTH,BOTH to ONLY_READ,BOTH to ONLY_WRITE
    `parameter_string SLAVER_MODE  = "BOTH",    //
    `parameter_string MASTER_MODE  = "BOTH",    //
    //(* show = "false" *)
    `parameter_string IGNORE_IDSIZE = "FALSE",  //(* show = "false" *)
    `parameter_string IGNORE_DSIZE  = "FALSE",  //(* show = "false" *)
    `parameter_string IGNORE_ASIZE = "FALSE",   //(* show = "false" *)
    `parameter_string IGNORE_LSIZE = "FALSE"    //(* show = "false" *)
)(
    (* axi4_up = "true" *)
    axi_inf.slaver      slaver,
    (* axi4_down = "true" *)
    axi_inf.master      master
);


import SystemPkg::*;

initial begin
    #(1us);
    if(IGNORE_IDSIZE == "FALSE")begin
        assert(slaver.IDSIZE <= master.IDSIZE)      //idsize of slaver can be smaller thane master's
        else begin
            $error("SLAVER AXIS IDSIZE != MASTER AXIS IDSIZE");
            $finish;
        end
    end
    if(IGNORE_DSIZE == "FALSE")begin
        assert(slaver.DSIZE == master.DSIZE)
        else $error("SLAVER AXIS DSIZE != MASTER AXIS DSIZE");
    end
    if(IGNORE_ASIZE == "FALSE")begin
        assert(slaver.ASIZE == master.ASIZE)
        else $error("SLAVER AXIS ASIZE != MASTER AXIS ASIZE");
    end
    if(IGNORE_LSIZE == "FALSE")begin
        assert(slaver.LSIZE == master.LSIZE)
        else $error("SLAVER AXIS LSIZE != MASTER AXIS LSIZE");
    end
    case(MODE)
    "BOTH_to_BOTH","BOTH_to_ONLY_READ","BOTH_to_ONLY_WRITE":
        assert(slaver.MODE =="BOTH" && SLAVER_MODE=="BOTH")
        else $error("SLAVER AXIS MODE<%s> != BOTH",slaver.MODE);
    "ONLY_READ_to_BOTH":
        assert(slaver.MODE == "ONLY_READ" && SLAVER_MODE=="ONLY_READ")
        else $error("SLAVER AXIS MODE != ONLY_READ");
    "ONLY_WRITE_to_BOTH","ONLY_WRITE_to_ONLY_WRITE":
        assert(slaver.MODE == "ONLY_WRITE" && SLAVER_MODE=="ONLY_WRITE")
        else begin
            $error("SLAVER AXIS MODE != ONLY_WRITE");
            $finish;
        end
    "ONLY_READ_to_ONLY_READ":
        assert(slaver.MODE == "ONLY_READ" && SLAVER_MODE=="ONLY_READ")
        else $error("SLAVER AXIS MODE != ONLY_READ");
    default:
        assert(slaver.MODE == "_____")
        else $error("SLAVER AXIS MODE ERROR")  ;
    endcase

    case(MODE)
    "ONLY_WRITE_to_BOTH","ONLY_READ_to_BOTH","BOTH_to_BOTH":
        assert(master.MODE == "BOTH" && MASTER_MODE=="BOTH")
        else $error("MASTER AXIS MODE != BOTH");
    "BOTH_to_ONLY_READ":
        assert(master.MODE == "ONLY_READ" && MASTER_MODE=="ONLY_READY")
        else $error("MASTER AXIS MODE != ONLY_READ");
    "BOTH_to_ONLY_WRITE","ONLY_WRITE_to_ONLY_WRITE":
        assert(master.MODE == "ONLY_WRITE" && MASTER_MODE=="ONLY_WRITE")
        else $error("MASTER AXIS MODE != ONLY_WRITE");
    "ONLY_READ_to_ONLY_READ":
        assert(master.MODE == "ONLY_READ" && MASTER_MODE=="ONLY_READ")
        else $error("MASTER AXIS MODE != ONLY_READ");
    default:
        assert(master.MODE == "_____")
        else $error("MASTER AXIS MODE ERROR");
    endcase

end

generate
    if(MASTER_MODE!="ONLY_READ")begin
        assign master.axi_awid     = slaver.axi_awid   ;
        assign master.axi_awaddr   = slaver.axi_awaddr ;
        assign master.axi_awlen    = slaver.axi_awlen  ;
        assign master.axi_awsize   = slaver.axi_awsize ;
        assign master.axi_awburst  = slaver.axi_awburst;
        assign master.axi_awlock   = slaver.axi_awlock ;
        assign master.axi_awcache  = slaver.axi_awcache;
        assign master.axi_awprot   = slaver.axi_awprot ;
        assign master.axi_awqos    = slaver.axi_awqos  ;
        assign master.axi_awvalid  = slaver.axi_awvalid;
        assign slaver.axi_awready  = master.axi_awready;
        assign master.axi_wdata    = slaver.axi_wdata  ;
        assign master.axi_wstrb    = slaver.axi_wstrb  ;
        assign master.axi_wlast    = slaver.axi_wlast  ;
        assign master.axi_wvalid   = slaver.axi_wvalid ;
        assign slaver.axi_wready   = master.axi_wready ;
        assign master.axi_bready   = slaver.axi_bready ;
        assign slaver.axi_bid      = master.axi_bid    ;
        assign slaver.axi_bresp    = master.axi_bresp  ;
        assign slaver.axi_bvalid   = master.axi_bvalid ;
    end
endgenerate


generate
    if(MASTER_MODE!="ONLY_WRITE")begin
        assign master.axi_arid     = slaver.axi_arid   ;
        assign master.axi_araddr   = slaver.axi_araddr ;
        assign master.axi_arlen    = slaver.axi_arlen  ;
        assign master.axi_arsize   = slaver.axi_arsize ;
        assign master.axi_arburst  = slaver.axi_arburst;
        assign master.axi_arlock   = slaver.axi_arlock ;
        assign master.axi_arcache  = slaver.axi_arcache;
        assign master.axi_arprot   = slaver.axi_arprot ;
        assign master.axi_arqos    = slaver.axi_arqos  ;
        assign master.axi_arvalid  = slaver.axi_arvalid;
        assign slaver.axi_arready  = master.axi_arready;
        assign master.axi_rready   = slaver.axi_rready ;
        assign slaver.axi_rid      = master.axi_rid    ;
        assign slaver.axi_rdata    = master.axi_rdata  ;
        assign slaver.axi_rresp    = master.axi_rresp  ;
        assign slaver.axi_rlast    = master.axi_rlast  ;
        assign slaver.axi_rvalid   = master.axi_rvalid ;
    end
endgenerate

endmodule

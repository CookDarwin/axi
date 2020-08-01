/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERB.0.0 2017/12/28 
    use wr rd verb
creaded: 2017/11/3 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi4 = "true" *)
module axi4_pipe_verb(
    (* axi4_up = "true" *)
    axi_inf.slaver   slaver,
    (* axi4_down = "true" *)
    axi_inf.master   master
);

initial begin
    assert(slaver.MODE == master.MODE)
    else begin
        $error("\nAXI PIPE MODE dont eql [%s] !=  [%s]\n",slaver.MODE,master.MODE);
        $finish;
    end
end

generate
if(slaver.MODE == "BOTH" || slaver.MODE == "ONLY_WRITE")
axi4_wr_pipe_verb axi4_wr_pipe_inst(
/*  axi_inf.slaver_wr */  .slaver       (slaver ),
/*  axi_inf.master_wr */  .master       (master )
);
endgenerate

generate
if(slaver.MODE == "BOTH" || slaver.MODE == "ONLY_READ")
axi4_rd_pipe_verb axi4_rd_pipe_inst(
/*  axi_inf.slaver_rd */  .slaver       (slaver     ),
/*  axi_inf.master_rd */  .master       (master     )
);
endgenerate

endmodule

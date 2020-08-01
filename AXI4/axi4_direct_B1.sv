/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/4/5 
madified:
***********************************************/
`timescale 1ns/1ps
(* axi4 = "true" *)
module axi4_direct_B1 (
    (* up_stream = "true" *)
    axi_inf.slaver      slaver,
    (* down_stream = "true" *)
    axi_inf.master      master
);


generate
if(slaver.MODE == "ONLY_READ" && master.MODE == "ONLY_READ")
axi4_direct_A1 #(
    .MODE   ("ONLY_READ_to_ONLY_READ")    //ONLY_READ to BOTH,ONLY_WRITE to BOTH,BOTH to BOTH,BOTH to ONLY_READ,BOTH to ONLY_WRITE
)axi4_direct_inst_ONLY_READ_to_ONLY_READ(
/*  axi_inf.slaver */     .slaver   (slaver ),
/*  axi_inf.master */     .master   (master )
);
else if(slaver.MODE == "ONLY_READ" && master.MODE == "BOTH")
axi4_direct_A1 #(
    .MODE   ("ONLY_READ_to_BOTH")    //ONLY_READ to BOTH,ONLY_WRITE to BOTH,BOTH to BOTH,BOTH to ONLY_READ,BOTH to ONLY_WRITE
)axi4_direct_inst_ONLY_READ_to_BOTH(
/*  axi_inf.slaver */     .slaver   (slaver ),
/*  axi_inf.master */     .master   (master )
);
else if(slaver.MODE == "ONLY_WRITE" && master.MODE == "BOTH")
axi4_direct_A1 #(
    .MODE   ("ONLY_WRITE_to_BOTH")    //ONLY_READ to BOTH,ONLY_WRITE to BOTH,BOTH to BOTH,BOTH to ONLY_READ,BOTH to ONLY_WRITE
)axi4_direct_inst_ONLY_WRITE_to_BOTH(
/*  axi_inf.slaver */     .slaver   (slaver ),
/*  axi_inf.master */     .master   (master )
);
else if(slaver.MODE == "ONLY_WRITE" && master.MODE == "ONLY_WRITE")
axi4_direct_A1 #(
    .MODE   ("ONLY_WRITE_to_ONLY_WRITE")    //ONLY_READ to BOTH,ONLY_WRITE to BOTH,BOTH to BOTH,BOTH to ONLY_READ,BOTH to ONLY_WRITE
)axi4_direct_inst_ONLY_WRITE_to_ONLY_WRITE(
/*  axi_inf.slaver */     .slaver   (slaver ),
/*  axi_inf.master */     .master   (master )
);
else if(slaver.MODE == "BOTH" && master.MODE == "ONLY_WRITE")
axi4_direct_A1 #(
    .MODE   ("BOTH_to_ONLY_WRITE")    //ONLY_READ to BOTH,ONLY_WRITE to BOTH,BOTH to BOTH,BOTH to ONLY_READ,BOTH to ONLY_WRITE
)axi4_direct_inst_BOTH_to_ONLY_WRITE(
/*  axi_inf.slaver */     .slaver   (slaver ),
/*  axi_inf.master */     .master   (master )
);
else if(slaver.MODE == "BOTH" && master.MODE == "ONLY_READ")
axi4_direct_A1 #(
    .MODE   ("BOTH_to_ONLY_READ")    //ONLY_READ to BOTH,ONLY_WRITE to BOTH,BOTH to BOTH,BOTH to ONLY_READ,BOTH to ONLY_WRITE
)axi4_direct_inst_BOTH_to_ONLY_READ(
/*  axi_inf.slaver */     .slaver   (slaver ),
/*  axi_inf.master */     .master   (master )
);
else if(slaver.MODE == "BOTH" && master.MODE == "BOTH")
axi4_direct_A1 #(
    .MODE   ("BOTH_to_BOTH")    //ONLY_READ to BOTH,ONLY_WRITE to BOTH,BOTH to BOTH,BOTH to ONLY_READ,BOTH to ONLY_WRITE
)axi4_direct_inst_BOTH_to_BOTH(
/*  axi_inf.slaver */     .slaver   (slaver ),
/*  axi_inf.master */     .master   (master )
);

endgenerate

endmodule

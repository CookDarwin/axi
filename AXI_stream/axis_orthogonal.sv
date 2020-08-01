/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2019/1/8 
madified:
***********************************************/
`timescale 1ns/1ps
module axis_orthogonal #(
    parameter   NUM = 8
)(
    axi_stream_inf.slaver   s00[NUM-1:0],
    axi_stream_inf.master   m00[NUM-1:0]
);

axi_stream_inf #(.DSIZE(m00[0].DSIZE),.FreqM(m00[0].FreqM)) pre_m00 [NUM-1:0]  (m00[0].aclk,m00[0].aresetn,m00[0].aclken);

logic [NUM-1:0]     empty;

genvar KK;
generate
for(KK=0;KK<NUM;KK++)begin
axis_base_pipe axis_base_pipe_inst(
/*  output logic           */  .empty       (empty[KK]      ),
/*  axi_stream_inf.slaver  */  .axis_in     (s00[KK]        ),
/*  axi_stream_inf.master  */  .axis_out    (pre_m00[KK]    )
);
end
endgenerate

logic [NUM-1:0]     enable;

always@(posedge m00[0].aclk,negedge m00[0].aresetn)
    if(~m00[0].aresetn) enable[0]  <= 1'b0;
    else begin
        if(!(|enable[NUM-1:1]))
                enable[0]   <= !empty[0];
        else    enable[0]   <= enable[0];
    end

generate
for(KK=1;KK<NUM;KK++)begin
    always@(posedge m00[0].aclk,negedge m00[0].aresetn)
        if(~m00[0].aresetn) enable[KK]  <= 1'b0;
        else begin
            if(!(|(enable & (~(1<<KK)))))
                    enable[KK]  <= (&(empty[KK-1:0])) && !empty[KK];
            else    enable[KK]  <= enable[KK];
        end
end
endgenerate

generate
for(KK=0;KK<NUM;KK++)begin
axis_valve axis_valve_inst(
/*  input                  */  .button      (enable[KK]         ),          //[1] OPEN ; [0] CLOSE
/*  axi_stream_inf.slaver  */  .axis_in     (pre_m00[KK]        ),
/*  axi_stream_inf.master  */  .axis_out    (m00[KK]            )
);
end
endgenerate

endmodule

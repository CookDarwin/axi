/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
created: xxxx.xx.xx
madified:
***********************************************/
`timescale 1ns/1ps

module axis_insert_copy (
    input [15:0]            insert_seed,
    input [7:0]             insert_len,
    axi_stream_inf.slaver   in_inf,
    axi_stream_inf.master   out_inf
);

//==========================================================================
//-------- define ----------------------------------------------------------
logic  clock;
logic  rst_n;
logic insert_tri;
axi_stream_inf #(.DSIZE(in_inf.DSIZE),.USIZE(1)) in_inf_valve (.aclk(in_inf.aclk),.aresetn(in_inf.aresetn),.aclken(1'b1)) ;
//==========================================================================
//-------- instance --------------------------------------------------------
axis_connect_pipe axis_connect_pipe_inst(
/* axi_stream_inf.slaver */.axis_in  (in_inf_valve ),
/* axi_stream_inf.master */.axis_out (out_inf      )
);
//==========================================================================
//-------- expression ------------------------------------------------------
assign  clock = in_inf.aclk;
assign  rst_n = in_inf.aresetn;

assign  in_inf_valve.axis_tdata = in_inf.axis_tdata;
assign  in_inf_valve.axis_tvalid = ( in_inf.axis_tvalid|insert_tri);
assign  in_inf_valve.axis_tuser = in_inf.axis_tuser;
assign  in_inf_valve.axis_tkeep = in_inf.axis_tkeep;
assign  in_inf.axis_tready = ( in_inf_valve.axis_tready&~insert_tri);
assign  in_inf_valve.axis_tlast = ( in_inf.axis_tlast&~insert_tri);

always_ff@(posedge clock,negedge rst_n) begin 
    if(~rst_n)begin
         insert_tri <= 1'b0;
    end
    else begin
        if( insert_seed=='0)begin
            if(in_inf.axis_tvalid && in_inf.axis_tready && in_inf.axis_tlast)begin
                 insert_tri <= 1'b1;
            end
            else if(in_inf.axis_tvalid && in_inf.axis_tready)begin
                 insert_tri <= ( in_inf_valve.axis_tcnt>=( insert_len-1'b1));
            end
            else begin
                 insert_tri <= insert_tri;
            end
        end
        else begin
             insert_tri <= ( in_inf_valve.axis_tcnt>=( insert_seed-1'b1)&& in_inf_valve.axis_tvalid && in_inf_valve.axis_tready && ( in_inf_valve.axis_tcnt<( insert_seed+insert_len- 1'b1))&& ~in_inf.axis_tlast);
        end
    end
end

endmodule

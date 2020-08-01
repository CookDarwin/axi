/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/9/19 
madified:
***********************************************/
`timescale 1ns/1ps
module fifo_ku #(
    parameter DSIZE     = 18
)(
    input                    wr_clk,
    input                    wr_rst,
    input                    rd_clk,
    input                    rd_rst,
    input [DSIZE-1:0]        din   ,
    input                    wr_en ,
    input                    rd_en ,
    output logic[DSIZE-1:0]  dout  ,
    output logic             full  ,
    output logic             empty ,
    output logic[14-1:0]     rdcount,
    output logic[14-1:0]     wrcount
);

localparam  BIT72 = 64,
            BIT36 = 32;
genvar KK;

localparam N64   = DSIZE/BIT72;
localparam N64_1 = (N64==0)? 1 : N64;
localparam N32   = DSIZE/BIT36;
localparam D32   = DSIZE%BIT36 != 0;
localparam NP = N64*2 == N32;       // last user 18bit


logic [BIT72-1:0]      n64_din  [N64_1-1:0];
logic [BIT72-1:0]      n64_dout [N64_1-1:0];
logic               n64_empty[N64_1-1:0];
logic               n64_full [N64_1-1:0];
logic [14-1:0]      n64_rdcount [N64_1-1:0];
logic [14-1:0]      n64_wrcount [N64_1-1:0];

logic [BIT72-1:0]       l64_din  ;
logic [BIT72-1:0]       l64_dout ;
logic                   l64_empty;
logic                   l64_full ;
logic [14-1:0]          l64_rdcount;
logic [14-1:0]          l64_wrcount;

logic [BIT36-1:0]       l32_din  ;
logic [BIT36-1:0]       l32_dout ;
logic                   l32_empty;
logic                   l32_full ;
logic [13-1:0]          l32_rdcount;
logic [13-1:0]          l32_wrcount;


generate
if(DSIZE < BIT36)begin

fifo_ku_18bit #(
    .DSIZE  (DSIZE)
)fifo_ku_18bit_inst(
/*  input              */ .wr_clk   (wr_clk     ),
/*  input              */ .wr_rst   (wr_rst     ),
/*  input              */ .rd_clk   (rd_clk     ),
/*  input              */ .rd_rst   (rd_rst     ),
/*  input [DSIZE-1:0]  */ .din      (din        ),
/*  input              */ .wr_en    (wr_en      ),
/*  input              */ .rd_en    (rd_en      ),
/*  output [DSIZE-1:0] */ .dout     (dout       ),
/*  output             */ .full     (full       ),
/*  output             */ .empty    (empty      ),
/*  output [LSIZE-1:0] */ .rdcount  (rdcount[12:0]    ),
/*  output [LSIZE-1:0] */ .wrcount  (wrcount[12:0]    )
);
assign rdcount[13]  = 1'b0;
assign wrcount[13]  = 1'b0;
end else if(DSIZE < BIT72 )begin
fifo_ku_36bit #(
    .DSIZE  (DSIZE)
)fifo_ku_36bit_inst(
/*  input              */ .wr_clk   (wr_clk     ),
/*  input              */ .wr_rst   (wr_rst     ),
/*  input              */ .rd_clk   (rd_clk     ),
/*  input              */ .rd_rst   (rd_rst     ),
/*  input [DSIZE-1:0]  */ .din      (din        ),
/*  input              */ .wr_en    (wr_en      ),
/*  input              */ .rd_en    (rd_en      ),
/*  output [DSIZE-1:0] */ .dout     (dout       ),
/*  output             */ .full     (full       ),
/*  output             */ .empty    (empty      ),
/*  output [LSIZE-1:0] */ .rdcount  (rdcount[13:0]    ),
/*  output [LSIZE-1:0] */ .wrcount  (wrcount[13:0]    )
);
end else begin

for(KK=0;KK<N64;KK++)begin
fifo_ku_36bit #(
    .DSIZE  (BIT72)
)fifo_ku_36bit_inst(
/*  input              */ .wr_clk   (wr_clk     ),
/*  input              */ .wr_rst   (wr_rst     ),
/*  input              */ .rd_clk   (rd_clk     ),
/*  input              */ .rd_rst   (rd_rst     ),
/*  input [DSIZE-1:0]  */ .din      (n64_din[KK]        ),
/*  input              */ .wr_en    (wr_en      ),
/*  input              */ .rd_en    (rd_en      ),
/*  output [DSIZE-1:0] */ .dout     (n64_dout[KK]       ),
/*  output             */ .full     (n64_full[KK]       ),
/*  output             */ .empty    (n64_empty[KK]      ),
/*  output [LSIZE-1:0] */ .rdcount  (n64_rdcount[KK]    ),
/*  output [LSIZE-1:0] */ .wrcount  (n64_wrcount[KK]    )
);
// assign n64_din[KK]  = din[DSIZE-1-(N64_1-1-KK)*BIT72-:BIT72];
assign n64_din[KK]  = din[DSIZE-1-KK*BIT72-:BIT72];
end

assign rdcount  = n64_rdcount[0];
assign wrcount  = n64_wrcount[0];
assign full     = n64_full[0];
assign empty    = n64_empty[0];

if(DSIZE%BIT72 > BIT36)begin
fifo_ku_36bit #(
    .DSIZE  (DSIZE%BIT72)
)fifo_ku_36bit_inst(
/*  input              */ .wr_clk   (wr_clk             ),
/*  input              */ .wr_rst   (wr_rst             ),
/*  input              */ .rd_clk   (rd_clk             ),
/*  input              */ .rd_rst   (rd_rst             ),
/*  input [DSIZE-1:0]  */ .din      (l64_din            ),
/*  input              */ .wr_en    (wr_en              ),
/*  input              */ .rd_en    (rd_en              ),
/*  output [DSIZE-1:0] */ .dout     (l64_dout           ),
/*  output             */ .full     (l64_full           ),
/*  output             */ .empty    (l64_empty          ),
/*  output [LSIZE-1:0] */ .rdcount  (l64_rdcount        ),
/*  output [LSIZE-1:0] */ .wrcount  (l64_wrcount        )
);
assign l64_din  = din[DSIZE%BIT72-1:0];

end else if(DSIZE%BIT72 <= BIT36 && DSIZE%BIT72 != 0)begin
fifo_ku_18bit #(
    .DSIZE  (DSIZE%BIT72)
)fifo_ku_18bit_inst(
/*  input              */ .wr_clk   (wr_clk             ),
/*  input              */ .wr_rst   (wr_rst             ),
/*  input              */ .rd_clk   (rd_clk             ),
/*  input              */ .rd_rst   (rd_rst             ),
/*  input [DSIZE-1:0]  */ .din      (l32_din            ),
/*  input              */ .wr_en    (wr_en              ),
/*  input              */ .rd_en    (rd_en              ),
/*  output [DSIZE-1:0] */ .dout     (l32_dout           ),
/*  output             */ .full     (l32_full           ),
/*  output             */ .empty    (l32_empty          ),
/*  output [LSIZE-1:0] */ .rdcount  (l32_rdcount        ),
/*  output [LSIZE-1:0] */ .wrcount  (l32_wrcount        )
);
assign l32_din = din[DSIZE%BIT72-1:0];
end

end
endgenerate

int CC;

generate
if(DSIZE>BIT72)begin
    if(DSIZE%BIT72 > BIT36)begin
        always@(*) begin
            // foreach(n64_dout[i])begin
            for(CC=0;CC<N64_1;CC++)begin
                dout[DSIZE-1-CC*BIT72-:BIT72]  = n64_dout[CC];
            end
            if(DSIZE%BIT72 > BIT36)begin
                dout[DSIZE%BIT72-1:0] = l64_dout;
            end if(DSIZE%BIT72 <= BIT36 && DSIZE%BIT72 != 0)begin
                ;
            end
        end
        // assign dout = {{>>{n64_dout}},l64_dout[DSIZE%BIT72-1:0]};
    end else if(DSIZE%BIT72 <= BIT36 && DSIZE%BIT72 != 0) begin
        always@(*) begin
            // foreach(n64_dout[i])begin
            for(CC=0;CC<N64_1;CC++)begin
                dout[DSIZE-1-CC*BIT72-:BIT72]  = n64_dout[CC];
            end
            if(DSIZE%BIT72 > BIT36)begin
                ;
            end if(DSIZE%BIT72 <= BIT36 && DSIZE%BIT72 != 0)begin
                dout[DSIZE%BIT72-1:0] = l32_dout;
            end
        end
        // assign dout = {{>>{n64_dout}},l32_dout[DSIZE%BIT72-1:0]};
    end else begin
        always@(*)begin
            for(CC=0;CC<N64_1;CC++)begin
                dout[DSIZE-1-CC*BIT72-:BIT72]  = n64_dout[CC];
            end
        end
        // assign dout = {>>{n64_dout}};
    end
end
endgenerate


endmodule

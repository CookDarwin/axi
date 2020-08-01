/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2016/8/26 
madified:
***********************************************/
interface video_native_inf #(
    parameter DSIZE = 24,
    parameter real FreqM    = 1
)(
    input bit   pclk ,
    input bit   prst_n
);

logic vsync;
logic hsync;
logic de;
logic blank;
logic field;
logic[DSIZE-1:0]    data;
logic[23:0]        vactive;
logic[23:0]        hactive;

logic [15:0]       v_index;
logic [15:0]       h_index;

logic	vs_raising;
logic   vs_falling;
logic	hs_raising;
logic   hs_falling;
logic	de_raising;
logic   de_falling;

modport compact_in (
    input       pclk,
    input       prst_n,
    input       vsync,
    input       hsync,
    input       de,
    input       data,
    input       vactive,
    input       hactive,
    input       v_index,
    input       h_index,
    input       vs_raising,
    input       vs_falling,
    input       hs_raising,
    input       hs_falling,
    input       de_raising,
    input       de_falling
);

modport compact_out (
    input       pclk,
    input       prst_n,
    output      vsync,
    output      hsync,
    output      de,
    output      data,
    output      vactive,
    output      hactive,
    input       v_index,
    input       h_index,
    input       vs_raising,
    input       vs_falling,
    input       hs_raising,
    input       hs_falling,
    input       de_raising,
    input       de_falling
);


// edge_generator #(
// 	.MODE		("NORMAL" 	)  // FAST NORMAL BEST
// )gen_vs_edge(
// 	.clk		(pclk     ),
// 	.rst_n      (prst_n   ),
// 	.in         (vsync    ),
// 	.raising    (vs_raising         ),
// 	.falling    (vs_falling         )
// );

always@(posedge pclk,negedge prst_n)begin:VS_EDGE
logic   vs_lat;
    if(~prst_n)begin
        vs_lat      <= 1'b0;
        vs_raising  <= 1'b0;
        vs_falling  <= 1'b0;
    end else begin
        vs_lat  <= vsync;
        vs_raising  <= vsync && !vs_lat;
        vs_falling  <= !vsync && vs_lat;
    end
end



// edge_generator #(
// 	.MODE		("NORMAL" 	)  // FAST NORMAL BEST
// )gen_hs_edge(
// 	.clk		(pclk	  ),
// 	.rst_n      (prst_n   ),
// 	.in         (hsync    ),
// 	.raising    (hs_raising         ),
// 	.falling    (hs_falling         )
// );

always@(posedge pclk,negedge prst_n)begin:HS_EDGE
logic   hs_lat;
    if(~prst_n)begin
        hs_lat      <= 1'b0;
        hs_raising  <= 1'b0;
        hs_falling  <= 1'b0;
    end else begin
        hs_lat  <= hsync;
        hs_raising  <= hsync && !hs_lat;
        hs_falling  <= !hsync && hs_lat;
    end
end


// edge_generator #(
// 	.MODE		("NORMAL" 	)  // FAST NORMAL BEST
// )gen_de_edge(
// 	.clk		(pclk	  ),
// 	.rst_n      (prst_n   ),
// 	.in         (de       ),
// 	.raising    (de_raising         ),
// 	.falling    (de_falling         )
// );

always@(posedge pclk,negedge prst_n)begin:DE_EDGE
logic   de_lat;
    if(~prst_n)begin
        de_lat      <= 1'b0;
        de_raising  <= 1'b0;
        de_falling  <= 1'b0;
    end else begin
        de_lat  <= de;
        de_raising  <= de && !de_lat;
        de_falling  <= !de && de_lat;
    end
end


always@(posedge pclk,negedge prst_n)
    if(~prst_n) v_index <= '0;
    else begin
        if(vs_raising)
                v_index <= '0;
        else if(de_falling)
                v_index <= v_index + 1'b1;
        else    v_index <= v_index;
    end

always@(posedge pclk,negedge prst_n)
    if(~prst_n) h_index <= '0;
    else begin
        if(vs_raising)
                h_index <= '0;
        else if(de)
                h_index <= h_index + 1'b1;
        else if(de_falling)
                h_index <= '0;
        else    h_index <= h_index;
    end


endinterface

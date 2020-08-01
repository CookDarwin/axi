interface axi_lite_inf #(
    parameter ASIZE = 32,
    parameter DSIZE = 32,
    parameter real FreqM    = 1
)(input bit axi_aclk,input bit axi_aresetn);

logic               axi_awvalid    ;
logic               axi_awready    ;
logic[ASIZE-1:0]    axi_awaddr     ;
logic               axi_awlock     ;
logic               axi_wvalid     ;
logic               axi_wready     ;
logic[DSIZE-1:0]    axi_wdata      ;
logic [1:0]         axi_bresp      ;
logic               axi_bvalid     ;
logic               axi_bready     ;
logic               axi_arvalid    ;
logic               axi_arready    ;
logic[ASIZE-1:0]    axi_araddr     ;
logic               axi_arlock     ;
logic               axi_rvalid     ;
logic               axi_rready     ;
logic [DSIZE-1:0]   axi_rdata      ;
logic [1:0]         axi_rresp      ;
logic               timeout;

//--->> TIME CTRL <<---------------
always@(posedge axi_aclk,negedge axi_aresetn)begin:TIME_BLOCK
logic   cen;
logic   crst;
logic [23:0]    tcnt;
    if(~axi_aresetn)begin
        tcnt    <= 24'd0;
        cen     <= 1'b0;
        crst    <= 1'b0;
    end else begin
        //-->> COUNT ENABLE
        if(axi_awready && axi_awvalid)
                cen     <= 1'b1;
        else if(axi_arready && axi_arvalid)
                cen     <= 1'b1;
        else if(axi_bready && axi_bvalid)
                cen     <= 1'b0;
        else if(axi_rvalid && axi_rready)
                cen     <= 1'b0;
        else    cen     <= cen;
        //-->> COUNT RST
        if(axi_awready && axi_awvalid)
                crst    <= 1'b1;
        else if(axi_arready && axi_arvalid)
                crst    <= 1'b1;
        else if(axi_wready && axi_wvalid)
                crst    <= 1'b1;
        else if(axi_rready && axi_rvalid)
                crst    <= 1'b1;
        else    crst    <= 1'b0;
        //-->> COUNT
        if(crst)
                tcnt    <= 24'd0;
        else if(cen)
                tcnt    <= tcnt + 1'b1;
        else    tcnt    <= tcnt;
        //-->> RESULT
        timeout <= &tcnt;
    end
end
//---<< TIME CTRL >>---------------

modport master(
input                axi_aclk       ,
input                axi_aresetn     ,
output               axi_awvalid    ,
input                axi_awready    ,
output               axi_awaddr     ,
output               axi_awlock     ,
output               axi_wvalid     ,
input                axi_wready     ,
output               axi_wdata      ,
input                axi_bresp      ,
input                axi_bvalid     ,
output               axi_bready     ,
output               axi_arvalid    ,
input                axi_arready    ,
output               axi_araddr     ,
output               axi_arlock     ,
input                axi_rvalid     ,
output               axi_rready     ,
input                axi_rdata      ,
input                axi_rresp      ,
input                timeout
// import  function logic [ASIZE-1:0]  get_addr(input [31:0] name,input int id=0)       //Vivado dont support export function
);


modport slaver(
input               axi_aclk       ,
input               axi_aresetn     ,
input               axi_awvalid    ,
output              axi_awready    ,
input               axi_awaddr     ,
input               axi_awlock     ,
input               axi_wvalid     ,
output              axi_wready     ,
input               axi_wdata      ,
output              axi_bresp      ,
output              axi_bvalid     ,
input               axi_bready     ,
input               axi_arvalid    ,
output              axi_arready    ,
input               axi_araddr     ,
input               axi_arlock     ,
output              axi_rvalid     ,
input               axi_rready     ,
output              axi_rdata      ,
output              axi_rresp      ,
input               timeout
// export              get_addr//Vivado dont support export function
);

// modport cn_down_addr(
//     import  function logic [ASIZE-1:0]  get_addr(input [31:0] name,input int id=0)
// );
//
// modport cn_up_addr(
//     export  get_addr
// );

modport mirror(
input                axi_aclk       ,
input                axi_aresetn     ,
input                axi_awvalid    ,
input                axi_awready    ,
input                axi_awaddr     ,
input                axi_awlock     ,
input                axi_wvalid     ,
input                axi_wready     ,
input                axi_wdata      ,
input                axi_bresp      ,
input                axi_bvalid     ,
input                axi_bready     ,
input                axi_arvalid    ,
input                axi_arready    ,
input                axi_araddr     ,
input                axi_arlock     ,
input                axi_rvalid     ,
input                axi_rready     ,
input                axi_rdata      ,
input                axi_rresp      ,
input                timeout
// import  function logic [ASIZE-1:0]  get_addr(input [31:0] name,input int id=0)       //Vivado dont support export function
);

modport master_wr(
input                axi_aclk       ,
input                axi_aresetn     ,
output               axi_awvalid    ,
input                axi_awready    ,
output               axi_awaddr     ,
output               axi_awlock     ,
output               axi_wvalid     ,
input                axi_wready     ,
output               axi_wdata      ,
input                axi_bresp      ,
input                axi_bvalid     ,
output               axi_bready     ,
input                timeout
// import  function logic [ASIZE-1:0]  get_addr(input [31:0] name,input int id=0)       //Vivado dont support export function
);

modport slaver_wr(
input               axi_aclk       ,
input               axi_aresetn     ,
input               axi_awvalid    ,
output              axi_awready    ,
input               axi_awaddr     ,
input               axi_awlock     ,
input               axi_wvalid     ,
output              axi_wready     ,
input               axi_wdata      ,
output              axi_bresp      ,
output              axi_bvalid     ,
input               axi_bready     ,
input               timeout
// export              get_addr//Vivado dont support export function
);

modport master_rd(
input                axi_aclk       ,
input                axi_aresetn    ,
output               axi_arvalid    ,
input                axi_arready    ,
output               axi_araddr     ,
output               axi_arlock     ,
input                axi_rvalid     ,
output               axi_rready     ,
input                axi_rdata      ,
input                axi_rresp      ,
input                timeout
// import  function logic [ASIZE-1:0]  get_addr(input [31:0] name,input int id=0)       //Vivado dont support export function
);

modport slaver_rd(
input               axi_aclk       ,
input               axi_aresetn    ,
input               axi_arvalid    ,
output              axi_arready    ,
input               axi_araddr     ,
input               axi_arlock     ,
output              axi_rvalid     ,
input               axi_rready     ,
output              axi_rdata      ,
output              axi_rresp      ,
input               timeout
// export              get_addr//Vivado dont support export function
);

endinterface:axi_lite_inf


interface axi_lite_inf2 #(
    parameter ASIZE = 32,
    parameter DSIZE = 32
)(input bit axi_aclk,input bit axi_aresetn);

wire               axi_awvalid    ;
wire               axi_awready    ;
wire[ASIZE-1:0]    axi_awaddr     ;
wire               axi_awlock     ;
wire               axi_wvalid     ;
wire               axi_wready     ;
wire[DSIZE-1:0]    axi_wdata      ;
wire [1:0]         axi_bresp      ;
wire               axi_bvalid     ;
wire               axi_bready     ;
wire               axi_arvalid    ;
wire               axi_arready    ;
wire[ASIZE-1:0]    axi_araddr     ;
wire               axi_arlock     ;
wire               axi_rvalid     ;
wire               axi_rready     ;
wire [DSIZE-1:0]   axi_rdata      ;

logic               timeout;

//--->> TIME CTRL <<---------------
always@(posedge axi_aclk,negedge axi_aresetn)begin:TIME_BLOCK
logic   cen;
logic   crst;
logic [23:0]    tcnt;
    if(~axi_aresetn)begin
        tcnt    <= 24'd0;
        cen     <= 1'b0;
        crst    <= 1'b0;
    end else begin
        //-->> COUNT ENABLE
        if(axi_awready && axi_awvalid)
                cen     <= 1'b1;
        else if(axi_arready && axi_arvalid)
                cen     <= 1'b1;
        else if(axi_bready && axi_bvalid)
                cen     <= 1'b0;
        else if(axi_rvalid && axi_rready)
                cen     <= 1'b0;
        else    cen     <= cen;
        //-->> COUNT RST
        if(axi_awready && axi_awvalid)
                crst    <= 1'b1;
        else if(axi_arready && axi_arvalid)
                crst    <= 1'b1;
        else if(axi_wready && axi_wvalid)
                crst    <= 1'b1;
        else if(axi_rready && axi_rvalid)
                crst    <= 1'b1;
        else    crst    <= 1'b0;
        //-->> COUNT
        if(crst)
                tcnt    <= 24'd0;
        else if(cen)
                tcnt    <= tcnt + 1'b1;
        else    tcnt    <= tcnt;
        //-->> RESULT
        timeout <= &tcnt;
    end
end
//---<< TIME CTRL >>---------------

modport master(
input                axi_aclk       ,
input                axi_aresetn     ,
output               axi_awvalid    ,
input                axi_awready    ,
output               axi_awaddr     ,
output               axi_awlock     ,
output               axi_wvalid     ,
input                axi_wready     ,
output               axi_wdata      ,
input                axi_bresp      ,
input                axi_bvalid     ,
output               axi_bready     ,
output               axi_arvalid    ,
input                axi_arready    ,
output               axi_araddr     ,
output               axi_arlock     ,
input                axi_rvalid     ,
output               axi_rready     ,
input                axi_rdata      ,
input                timeout
// import  function logic [ASIZE-1:0]  get_addr(input [31:0] name,input int id=0)       //Vivado dont support export function
);


modport slaver(
input               axi_aclk       ,
input               axi_aresetn     ,
input               axi_awvalid    ,
output              axi_awready    ,
input               axi_awaddr     ,
input               axi_awlock     ,
input               axi_wvalid     ,
output              axi_wready     ,
input               axi_wdata      ,
output              axi_bresp      ,
output              axi_bvalid     ,
input               axi_bready     ,
input               axi_arvalid    ,
output              axi_arready    ,
input               axi_araddr     ,
input               axi_arlock     ,
output              axi_rvalid     ,
input               axi_rready     ,
output              axi_rdata      ,
input               timeout
// export              get_addr//Vivado dont support export function
);

// modport cn_down_addr(
//     import  function logic [ASIZE-1:0]  get_addr(input [31:0] name,input int id=0)
// );
//
// modport cn_up_addr(
//     export  get_addr
// );


endinterface:axi_lite_inf2

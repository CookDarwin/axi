/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERB.0.0 2017/5/8 
    slaver lite control,passive
creaded: 2017/5/3 
madified:
***********************************************/
`include "axil_macro.sv"

// `define CheckParamPair(X,Y)\
// initial begin\
//     Check_Param_Pair(X,Y,`__FILE__,`__LINE__,`"X != Y`");\
// end

`define INHERIT_AXIS(a,b)   axi_stream_inf #(.DSIZE(a.DSIZE)) b (.aclk(a.aclk),.aresetn(a.aresetn),.aclken(a.aclken));

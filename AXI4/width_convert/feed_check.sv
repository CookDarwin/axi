/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/12/6 
madified:
**********************************************/
`timescale 1ns/1ps
module feed_check #(
    parameter ASIZE = 128,
    parameter BSIZE = 192,
    parameter LIST  = "OFF"
)(
    input               aclock,
    input [ASIZE-1:0]   adata,
    input               amark,
    input               avld,
    input               bclock,
    input [BSIZE-1:0]   bdata,
    input               bmark,
    input               bvld
);

logic [ASIZE-1:0]   atmp;
logic [BSIZE-1:0]   btmp;

mailbox ab      = new(8);
mailbox bb      = new(8);

mailbox abit    = new(64);
mailbox bbit    = new(64);

always@(negedge aclock)begin
    if(avld && !amark)begin
        ab.put(adata);
    end
end

always@(negedge bclock)begin
    if(bvld && !bmark)begin
        bb.put(bdata);
    end
end

initial begin
int II;
    forever begin
        ab.get(atmp);
        for(II=0;II<ASIZE;II++)begin
            abit.put(atmp[ASIZE-1-II]);
        end
    end
end

initial begin
int II;
    forever begin
        bb.get(btmp);
        for(II=0;II<BSIZE;II++)begin
            bbit.put(btmp[BSIZE-1-II]);
        end
    end
end

initial begin:CHECK_BLOCK
int     index;
logic   achk,bchk;
    index = 0;
    forever begin
        abit.get(achk);
        bbit.get(bchk);
        if(LIST=="ON")begin
            if(index%4==0)
                $write(" ");
            if(achk == bchk)
                $write("%b",achk);
            else
                $write("(%b:%b)",achk,bchk);
        end
        assert(achk == bchk)
        else begin
            $error("\n TOW FEEDs DONT MATCH A-FEED[%d]  B-FEED[%d]\n",index/ASIZE,index/BSIZE);
            // repeat(10)
            //     @(negedge aclock);
            $stop;
        end
        index = index + 1;
    end
end

endmodule

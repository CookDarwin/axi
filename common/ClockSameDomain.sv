/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: xxxx.xx.xx 
madified:
***********************************************/
`timescale 1ns/1ps
module ClockSameDomain (
    input               aclk,
    input               bclk,
    output logic        done,
    output logic        same,
    output integer      aFreqK,
    output integer      bFreqK
);

import  SystemPkg::*;

realtime     a2b;
realtime     b2a;
// realtime     x2x;
// realtime     y2y;

realtime     a2a;
realtime     b2b;

generate 
    if(SIM=="TRUE" || SIM=="ON")begin 
        initial begin
            done = 0;
            same = 1;
            repeat(100)begin
                @(posedge aclk);
                @(posedge bclk);
            end
            @(posedge aclk);
            a2b = $realtime;
            @(posedge bclk);
            a2b = $realtime - a2b;

            @(posedge bclk);
            b2a = $realtime;
            @(posedge aclk);
            b2a = $realtime - b2a;
            @(posedge aclk);

            @(posedge aclk);
            a2a = $realtime;
            @(posedge aclk);
            a2a = $realtime - a2a;

            @(posedge bclk);
            b2b = $realtime;
            @(posedge bclk);
            b2b = $realtime - b2b;
            @(posedge bclk);
            @(posedge aclk);

            if($pow(a2a - b2b,2) < 0.0001)begin 
                if(a2b < b2a) begin
                    if((a2b < b2a - 0.001) && $pow( b2a - a2a - a2b,2) > 0.0001)begin
                            // $display(" (a2b[%0f] < b2a[%0f] - 0.001) && (a2b != b2a - a2a[%0f]) ", a2b, b2a, a2a);
                            same    = 0;
                    end else    
                            same    = 1;
                end else begin 
                    if((a2b > b2a + 0.001) && $pow(b2a + a2a - a2b,2)>0.0001)begin 
                            // $display(" (a2b > b2a + 0.001) && (a2b != b2a + a2a) ");
                            same    = 0;
                    end else    
                            same    = 1;
                end
            end else begin 
                // $display(" a2a<%0f> != b2b<%0f>",a2a,b2b);
                same    = 0;
            end 

            // if(a2b < (b2a + 0.001) || a2b > (b2a - 0.001))
            //         same = 1;
            // else    same = 0;

            repeat(10)begin
                @(posedge aclk);
                @(posedge bclk);
            end

            @(posedge aclk);
            a2a = $realtime;
            @(posedge aclk);
            aFreqK  = $rtoi( $realtime*1000 - a2a*1000);

            @(posedge bclk);
            b2b = $realtime;
            @(posedge bclk);
            bFreqK  = $rtoi( $realtime*1000 - b2b*1000);

            done = 1;
        end

        // initial begin
        //     repeat(100) begin 
        //         @(posedge aclk);
        //         @(posedge bclk);
        //     end 
        //     @(posedge aclk);
        //     a2a = $realtime;
        //     @(posedge aclk);
        //     aFreqK  = $rtoi( $realtime*1000 - a2a*1000);

        //     @(posedge bclk);
        //     b2b = $realtime;
        //     @(posedge bclk);
        //     bFreqK  = $rtoi( $realtime*1000 - b2b*1000);

        // end
    end else begin 
        assign done    = 1;
        assign same    = 1;
        assign aFreqK  = 100;
        assign bFreqK  = 100; 
    end
endgenerate

endmodule

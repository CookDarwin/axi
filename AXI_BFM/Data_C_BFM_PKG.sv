/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2017/8/25 
madified:
***********************************************/
package DataCBfmPkg;
import AxiBfmPkg::sync_clk_wait;


class DataCMaster_c #(
    parameter DSIZE = 8
);

virtual data_inf_c #(.DSIZE(DSIZE)) data_inf;

randc logic [DSIZE-1:0]  rdata;
// constraint rdata_c_external;
constraint rdata_c_external {
    if(DSIZE>13)
        rdata inside {[2**13:2**13+1079],[2**14:2**14+1079]};
    else
        rdata < 1080;
}

function new(virtual data_inf_c #(DSIZE) b );
    data_inf = b;
endfunction:new


task automatic gen_rand_data(int rate,int length);
int cnt;
    data_inf.valid  = 0;
    data_inf.data   = 0;
    cnt = 0;
    wait(data_inf.rst_n);
    forever begin
        @(posedge data_inf.clock);
        if(rate > $urandom_range(99,0))begin
            data_inf.valid  = 1;
            this.randomize();
            data_inf.data   = rdata;
            sync_clk_wait(data_inf.clock,data_inf.ready);
            data_inf.valid  = 0;
            cnt = cnt + 1;
            if(cnt == length)
                break;
        end else begin
            data_inf.valid  = 0;
        end
    end
    data_inf.valid  = 0;
    data_inf.data   = 0;
    @(posedge data_inf.clock);
endtask:gen_rand_data

endclass:DataCMaster_c

class DataCSlaver_c #(
    parameter DSIZE = 8
);

virtual data_inf_c #(.DSIZE(DSIZE)) data_inf;

function new(virtual data_inf_c #(DSIZE) b );
    data_inf = b;
endfunction:new

task automatic get_data(int rate,int length);
int cnt;
    data_inf.ready = 0;
    cnt = 0;
    wait(data_inf.rst_n);
    forever begin
        @(posedge data_inf.clock);
        if(data_inf.ready && data_inf.valid)begin
            cnt = cnt + 1'b1;
            if(cnt == length)
                break;
        end
        if(rate > $urandom_range(99,0))begin
            data_inf.ready  = 1;
        end else begin
            data_inf.ready  = 0;
        end
    end

    @(posedge data_inf.clock);
endtask:get_data

endclass:DataCSlaver_c

endpackage:DataCBfmPkg

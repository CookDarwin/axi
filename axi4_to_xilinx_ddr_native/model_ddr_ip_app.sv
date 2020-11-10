/**********************************************
_______________________________________ 
___________    Cook Darwin   __________    
_______________________________________
descript:
author : Cook.Darwin
Version: VERA.0.0
creaded: 2016/10/12
madified:
***********************************************/
`timescale 1ns / 1ps
module model_ddr_ip_app #(
    parameter ADDR_WIDTH            = 27,
    parameter DATA_WIDTH            = 256,
    parameter MARK_X                = "OFF",
    parameter DISPLAY               = "ON"
)(
    input                           clock,
    input  [ADDR_WIDTH-1:0]         app_addr,
    input  [2:0]                    app_cmd,
    input                           app_en,
    input  [DATA_WIDTH-1:0]         app_wdf_data,
    input                           app_wdf_end,
    input  [DATA_WIDTH/8-1:0]       app_wdf_mask,
    input                           app_wdf_wren,
    output logic[DATA_WIDTH-1:0]    app_rd_data,
    output logic                    app_rd_data_end,
    output logic                    app_rd_data_valid,
    output logic                    app_rdy,
    output logic                    app_wdf_rdy,
    output logic                    init_calib_complete
);

initial begin
    init_calib_complete = 0;
    #(10us);
    init_calib_complete = 1;
end

// logic[ADDR_WIDTH-1:0] mbx   [$];

mailbox wr_mbx  = new();
mailbox rd_mbx  = new();

task automatic ramdon_signal (int  rate,ref logic data);
int     rt;
    forever begin
        rt = $urandom_range(99,0);
        if(rt < rate)begin
            data    = 1;
        end else begin
            data    = 0;
        end
        @(posedge clock);
        #(1ps);
    end
    @(negedge clock);
endtask:ramdon_signal

task automatic ramdon_signal_time (int t,int  rate,ref logic data);
int     rt;
int     cnt;
    cnt = 0;
    while(cnt < t) begin
        rt = $urandom_range(99,0);
        if(rt < rate)begin
            data    = 1;
            cnt ++;
        end else begin
            data    = 0;
        end
        @(posedge clock);
    end
endtask:ramdon_signal_time

task automatic cmd ();
    app_rdy = 1;
    fork
        ramdon_signal(99,app_rdy);
    join_none
endtask:cmd

task automatic write();
    app_wdf_rdy = 1;
    fork
        ramdon_signal(99,app_wdf_rdy);
    join_none
endtask:write

task automatic sync_wait(ref logic condition);
    forever begin
        @(posedge clock);
        if(condition)
            break;
    end
endtask:sync_wait

logic [DATA_WIDTH-1:0]      data_mem [logic[ADDR_WIDTH-1:0]];
logic [ADDR_WIDTH-1:0]      addr_queue [$];
logic [DATA_WIDTH-1:0]      data_queue [$];

task automatic write_cmd ();
    fork
        forever begin
            forever begin
                @(negedge clock);
                if(app_en && app_rdy && app_cmd == 2'b00)begin
                    break;
                end
            end
            addr_queue.push_back(app_addr);
            // $display("%t PUSH ADDR %h",$time,app_addr);
        end
    join_none
endtask:write_cmd

task automatic write_data ();
logic [ADDR_WIDTH-1:0]      addr;
logic [DATA_WIDTH-1:0]      data;
    fork
        forever begin
            forever begin
                @(negedge clock);
                if(app_wdf_rdy && app_wdf_wren)
                    break;
            end
            data_queue.push_back(app_wdf_data);
            // $display("%t PUSH DATA %h",$time,app_wdf_data);
            if(app_wdf_data==29'h0378)
                $stop;
        end

        forever begin
            forever begin
                @(negedge clock);
                if(data_queue.size() > 0  && addr_queue.size() > 0)
                    break;
            end
            addr    = addr_queue.pop_front();
            data    = data_queue.pop_front();
            // if( |addr == 1'b0 || addr == 1'b1)
            data_mem[addr]  = data;
            if(DISPLAY=="ON" && DISPLAY=="TRUE")
                $display("WRITE DDR ADDR[%h],DATA[%h]",addr,data);
        end
    join_none
endtask : write_data

task automatic read_cmd();
    // mbx = {};
    fork
        forever begin
            forever begin
                @(negedge clock);
                if(app_en && app_rdy && app_cmd == 2'b01)begin
                    // $display("READ DDR ADDR[%h]",app_addr);
                    wr_mbx.put(app_addr);
                end
            end
            // fork
            //     begin
            //         repeat(40)
            //             @(posedge clock);
            //         mbx.put(app_addr);
            //         $display("PUT MAILBOX FINISH");
            //     end
            // join_none
            // fork
            //     read_resp(50,mbx);
            // join_none
        end
    join_none
endtask:read_cmd

initial begin:CONNECT_MBX
int addr;
int i;
    forever begin
        @(posedge clock);
        i = wr_mbx.num();
        if(i)begin
            // $display("WR MAILBOX HAVE DATA");
            repeat(20)
                @(posedge clock);
            i = wr_mbx.num();
            repeat(i) begin
                wr_mbx.get(addr);
                rd_mbx.put(addr);
                // $display("READ CMD SHIFT ADDR[%h]",addr);
            end
        end
    end
end


task automatic read_resp(int rate);
int     rt;
int     addr;
    // app_rd_data_valid   = 0;
    fork
        forever begin
            app_rd_data_valid = 0;

            // $display("GET ADDR[%h] MAILBOX FINISH",addr);
            // rt = 0;
            // repeat(20)
            //     @(posedge clock);

            while(app_rd_data_valid==0)begin
                rt = $urandom_range(99,0);
                if(rt < rate)begin
                    rd_mbx.get(addr);
                    // $display("APP ADDR [%h]",data_s.pop_front);
                    app_rd_data_valid   = 1;
                    app_rd_data         = data_mem[addr];
                    // if(MARK_X == "ON" || MARK_X == "TRUE")begin
                    //     if(|app_rd_data == 1'bx)
                    //             app_rd_data <= '1;
                    // end
                    if(DISPLAY=="ON" && DISPLAY=="TRUE")
                        $display("READ DDR ADDR[%h],DATA[%h]",addr,app_rd_data);
                    foreach(app_rd_data[i])begin
                        if(MARK_X == "ON" || MARK_X == "TRUE")begin
                            if(app_rd_data[i] === 1'bx)
                                // app_rd_data[i]  = 1'b1;
                                app_rd_data[i]  = $urandom_range(1,0);
                        end
                    end
                end else begin
                    app_rd_data_valid = 0;
                end
                @(posedge clock);
            end
            // app_rd_data_valid = 0;
        end
    join_none
endtask:read_resp

// task automatic read_resp_simple();
// int len;
//     fork
//          forever begin
//             forever begin
//                 @(posedge clock);
//                 if(app_en && app_rdy && app_cmd == 2'b01)
//                     break;
//                 if(mbx.size()>0)
//                     break;
//             end
//             repeat(15)
//                 @(posedge   clock);
//             len = mbx.size();
//             if(len > 0)begin
//                 ramdon_signal_time(len,50,app_rd_data_valid);
//                 // for(int i=0;i<len;i++)
//                     // $display("APP DDR [%h]",mbx.pop_front);
//             end
//             app_rd_data_valid = 0;
//         end
//     join_none
// endtask:read_resp_simple

// task automatic read_resp_direct();
// int len;
//     fork
//         forever begin
//             @(posedge clock);
//             if(app_en && app_rdy && app_cmd == 2'b01)begin
//                     app_rd_data_valid   = 1;
//             end else begin
//                     app_rd_data_valid   = 0;
//             end
//         end
//     join_none
// endtask:read_resp_direct


// always@(posedge clock)begin
//     if(app_en && app_rdy && app_cmd == 2'b01)begin
//             app_rd_data_valid   = 1;
//             // app_rd_data         = $urandom_range(15,0);
//             app_rd_data         = data_mem[app_addr];
//     end else begin
//             app_rd_data_valid   = 0;
//     end
// end

initial begin
    write_cmd ();
    write_data ();
end

initial begin
    cmd();
    write();
    read_cmd();
    read_resp(100);
    // read_resp_simple();
    // read_resp_direct();
end


endmodule

module test_write_mem();

logic[31:0] BRAM [2:0][3:0][4:0];

initial begin 
    BRAM[0][0][0] = 1;
    BRAM[0][0][1] = 2;
    BRAM[0][0][2] = 3;
    BRAM[0][0][3] = 4;
    BRAM[0][0][4] = 5;

    BRAM[0][1][0] = 11;
    BRAM[0][2][1] = 12;
    BRAM[0][2][2] = 13;
    BRAM[0][2][3] = 14;
    BRAM[0][2][4] = 15;

    $writememh("/home/myw357/work/FPGA/acce_20201211/git_repo/wmy/axi/common/mem_format.coe",BRAM);

end

endmodule
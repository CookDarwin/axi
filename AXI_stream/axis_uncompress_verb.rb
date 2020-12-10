
require_hdl 'gen_origin_axis_A2.sv'

TdlBuild.axis_uncompress_verb(__dir__) do 
    parameter.ASIZE     8   #          //ASIZE + LSIZE = AXIS DATA WIDTH
    parameter.LSIZE     8   #
    parameter.STEP      1
    port.axi_stream_inf.slaver   - 'axis_zip'   #       //ASIZE+LSIZE '0' meet 1 length
    port.axi_stream_inf.master   - 'axis_unzip' #       //ASIZE

    Initial do 
        assert( axis_zip.DSIZE == (param.ASIZE+param.LSIZE), " axis_zip.DSIZE<%0d> != (param.ASIZE<%0d>+param.LSIZE<%0d>)", axis_zip.DSIZE, param.ASIZE, param.LSIZE)
        assert( axis_unzip.DSIZE == param.ASIZE, "axis_unzip.DSIZE<%0d> != param.ASIZE<%0d>", axis_unzip.DSIZE, param.ASIZE)
    end

    logic[32]   - 'cc_length'
    logic[32]   - 'cc_start'

    Assign do 
        cc_length   <= axis_zip.axis_tdata[param.LSIZE-1,0]+1.b1
        cc_start    <= axis_zip.axis_tdata[param.ASIZE+param.LSIZE-1,param.LSIZE]
    end

    gen_origin_axis_A2.gen_origin_axis_A2_inst do |h| #(
        h.param.MODE                    "RANGE"
        h.input.enable                  axis_zip.axis_tvalid    
        h.output.logic.ready            axis_zip.axis_tready
        h.input[32].length              cc_length
        h.input[32].start               cc_start
        h.port.axis.master.axis_out     axis_unzip
    end
end
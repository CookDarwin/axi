files = [
    'E:\work\AXI\macro\axi4_base_files_add_to_vivado.tcl',
    'E:\work\AXI\macro\axis_base_files_add_to_vivado.tcl',
    'E:\work\AXI\macro\base_files_add_to_vivado.tcl',
    'E:\work\AXI\macro\data_inf_base_files_add_to_vivado.tcl',
    'E:\work\AXI\macro\lite_inf_base_files_add_to_vivado.tcl',
    'E:\work\AXI\macro\tmp.tcl'
]


def stand(path)
    all_str = File.open(path,'r'){ |f| f.read }
    all_str.gsub!(/\\\s*$/,'>>>>')
    all_str.gsub!("\n","[NNNNN]")
    all_str.gsub!("\r","[RRRRR]")
    all_str.gsub!("\\","/")
    all_str.gsub!('>>>>',"\\")
    all_str.gsub!(/\\\s*$/,"\n")
    all_str.gsub!("[NNNNN]","\n")
    all_str.gsub!("[RRRRR]","\r")
    return all_str
end


files.each_index do |index|
    all_str = stand(files[index])
    File.open("tcl_"+File.basename(files[index]),'w'){ |wf| wf.puts all_str  }
end

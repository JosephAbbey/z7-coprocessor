# Export the project to a TCL script
write_project_tcl -use_bd_files {D:/repos/z7-coprocessor/project/coprocessor.tcl}

# Export the hardware platform to a file for Vitis
write_hw_platform -fixed -include_bit -force -file D:/repos/z7-coprocessor/project/top_wrapper.xsa

class reg_seq_item extends uvm_sequence_item;
  //============================
  // Constructor
  //============================
  function new(string name = "reg_seq_item");
    super.new(name);
  endfunction
  
  rand bit [31:0] wdata, rdata, addr;
  rand bit rd;
  rand bit wr;
  rand bit [3:0] strb;
  rand bit slv_err, status;
  
  //===========================
  // UVM MACROS AUTOMATION
  //===========================
  `uvm_object_utils_begin(reg_seq_item);
  
    `uvm_field_int(wdata, UVM_ALL_ON);
    `uvm_field_int(addr, UVM_ALL_ON);
    `uvm_field_int(rdata, UVM_ALL_ON);
    `uvm_field_int(strb, UVM_ALL_ON);
    `uvm_field_int(status, UVM_ALL_ON|UVM_NOCOMPARE);
    `uvm_field_int(rd, UVM_ALL_ON|UVM_NOCOMPARE);
    `uvm_field_int(slv_err, UVM_ALL_ON);
  
  `uvm_object_utils_end
  
endclass: reg_seq_item
  
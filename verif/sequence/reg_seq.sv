class reg_seq extends uvm_sequence #(reg_seq_item);
  //=============================//
  //  UVM FACTORY REGISTRATION   //
  //=============================//
  `uvm_object_utils(reg_seq)
  
  //==========================
  // Constructor
  //==========================
  function new(string name = "reg_seq");
    super.new(name);
  endfunction
  
  my_block reg_model;
  uvm_reg regs[$];
  uvm_event in_scb_evnt;
  int match = 0, mismatch = 0;
  
  //=================
  // Task body
  //=================
  task body();
    
    string regname;
    uvm_status_e status;
    logic [31:0] wr_data, rd_data, exp_data;
    in_scb_evnt = uvm_event_pool::get_global("ingr_scb_evnt");

    if(!(uvm_config_db #(my_block)::get(null, "*", "reg_model", reg_model)))begin
      `uvm_fatal(get_type_name(), "Can't get Register model");
    end
    
    reg_model.get_registers(regs);
    
    foreach(regs[i])begin
      wr_data = 32'hFFFF_FFFF;
      //Write
      regs[i].write(status, wr_data, UVM_FRONTDOOR);
      //Read 
      regs[i].read(status, rd_data, UVM_FRONTDOOR);
      exp_data = regs[i].get();
      regname = regs[i].get_name();
      
      if(exp_data == rd_data)begin
        `uvm_info(get_type_name(), $sformatf("============ MATCH ============ Reg: %s Exp_val = %08h && Read_val = %08h",regname, exp_data, rd_data),UVM_LOW);
        match++;
      end else begin
        `uvm_error(get_type_name(), $sformatf("XXXXXXXXXXXX MISMATCH XXXXXXXXXXX Reg: %s Exp_val = %08h && Read_val = %08h",regname, exp_data, rd_data));
        mismatch++;
      end
    end
    
    `uvm_info(get_type_name(),$sformatf("\n------------------------------------------\n  MATCHES = %0d   MISMATCHES = %0d\n ------------------------------------------", match, mismatch), UVM_LOW);
    
    in_scb_evnt.trigger();
    
  endtask
  
endclass
      
      
      
    
    
    
  
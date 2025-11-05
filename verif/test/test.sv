class reg_test extends uvm_test;
  //=============================//
  //   UVM FACTORY REGISTRATION  //
  //=============================//
  `uvm_component_utils(reg_test)
  
  //======================
  // Constructor
  //======================
  function new(string name = "reg_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  reg_env rg_env;
  reg_seq register_seq;
  my_block reg_model;
  
  //======================
  // BUild Phase
  //======================
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    register_seq = reg_seq::type_id::create("register_seq");
    rg_env = reg_env::type_id::create("rg_env", this);
    reg_model = new("my_block");
    reg_model.build();
    reg_model.lock_model();
    uvm_config_db #(my_block)::set(null, "*", "reg_model", reg_model);
  endfunction
  
  //======================
  // Connect Phase
  //======================
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    reg_model.default_map.set_sequencer(rg_env.rg_agnt.seqr, rg_env.adapt_n);
    reg_model.default_map.set_auto_predict(0);  
  endfunction
  
  //======================
  // Main Phase
  //======================
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    super.main_phase(phase);
    
    `uvm_info(get_type_name(), "Main Phase Starting ....", UVM_LOW);
    register_seq.start(rg_env.rg_agnt.seqr);
    `uvm_info(get_type_name(), "Main Phase Ending ....", UVM_LOW);
    phase.drop_objection(this);
    
  endtask
  
endclass
    
  
  
  
class reg_env extends uvm_env;
  //==============================//
  //   UVM FACTORY REGISTRATION   //
  //==============================// 
  `uvm_component_utils(reg_env)
  
  //======================
  // Constructor
  //======================
  function new(string name = "reg_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  reg_agent rg_agnt;
  reg_adapter adapt_n;
  int WATCH_DOG;
  uvm_event in_scb_evnt;
  
  //======================
  // Build Phase
  //======================
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "----------------- BUILD_PHASE ----------------- ",UVM_LOW);
    rg_agnt = reg_agent::type_id::create("rg_agnt", this);
    adapt_n = reg_adapter::type_id::create("adapt_n"); 
    in_scb_evnt = uvm_event_pool::get_global("ingr_scb_evnt");
    
  endfunction
  
  //======================
  // Connect Phase
  //======================
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info(get_type_name(), "---------------- CONNECT_ PHASE ----------------",UVM_LOW);
  endfunction
  
  //======================
  // Main Phase
  //======================
  virtual task main_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_type_name(), "Main Phase Starting ......", UVM_LOW);
    super.main_phase(phase);
    
    WATCH_DOG = 0.5ms;
    
    fork
      begin
        `uvm_info(get_type_name(), "Starting WATCH_DOG started", UVM_MEDIUM);
        #WATCH_DOG;
        `uvm_info(get_type_name(), "WATCH DOG Expired", UVM_MEDIUM);
         `uvm_fatal(get_type_name(), "Error event didn't triggered");
      end
      
      begin
        `uvm_info(get_type_name(), "Wait for uvm_event", UVM_MEDIUM);
        in_scb_evnt.wait_trigger();
        `uvm_info(get_type_name(), "Scoreboard event triggered successfully", UVM_MEDIUM);
      end
    join_any
    
    phase.drop_objection(this);   
  endtask
  
endclass
    
  
    
  
  
  
class reg_agent extends uvm_agent;
  //==============================//
  //   UVM FACTORY REGISTRATION   //
  //==============================//
  `uvm_component_utils(reg_agent)
  
  //=====================
  // Constructor
  //=====================
  function new(string name = "reg_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  reg_driver rg_drv;
  reg_monitor rg_mon;
  uvm_sequencer #(reg_seq_item) seqr;
  
  //=====================
  // Build phase
  //=====================
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // ACTIVE AGENT
    if(get_is_active() == UVM_ACTIVE) begin
      rg_drv = reg_driver::type_id::create("rg_drv", this);
      rg_mon = reg_monitor::type_id::create("rg_mon", this);
    end
    seqr = uvm_sequencer #(reg_seq_item)::type_id::create("seqr", this);
  endfunction
  
  //=====================
  // Connect Phase
  //=====================
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //ACTIVE AGENT 
    if(get_is_active() == UVM_ACTIVE) begin
      rg_drv.seq_item_port.connect(seqr.seq_item_export);
    end
  endfunction
  
endclass
  
    
  
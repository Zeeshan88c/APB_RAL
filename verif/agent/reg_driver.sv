class reg_driver extends uvm_driver #(reg_seq_item);
  //==============================//
  //   UVM FACTORY REGISTRATION   //
  //==============================//  
  `uvm_component_utils(reg_driver)
  
  //===================
  // Constructor
  //===================
  function new(string name = "reg_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual reg_intf vif;
  
  //===================
  // Build Phase
  //===================
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    req = reg_seq_item::type_id::create("req");
    rsp = reg_seq_item::type_id::create("rsp");
    
    if(!(uvm_config_db #(virtual reg_intf)::get(this, "*", "vif", vif)))begin
      `uvm_fatal(get_type_name(), "Can't get interface");
    end
    
  endfunction
  
  //===================
  // Run Phase
  //===================
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    `uvm_info(get_type_name(), "Run Phase Starting ...", UVM_LOW);
    //Run phase staring
    forever begin
      seq_item_port.get_next_item(req);
      wait(vif.PRESETn);
      if(req.rd)begin
        reg_read(req);
      end else begin
        reg_write(req);
      end
      seq_item_port.item_done();
    end
    `uvm_info(get_type_name(), "Run Phase Ending ...", UVM_LOW);
    
  endtask
  
  //===================
  // Register Read
  //===================
  task reg_read(reg_seq_item req);

    // Setup phase
    @(posedge vif.PCLK);
    vif.PADDR   <= req.addr;
    vif.PSTRB   <= 4'b0;
    vif.PSELx   <= 1'b1;
    vif.PENABLE <= 1'b0;
    vif.PWRITE  <= 1'b0;

    // Enable phase
    @(posedge vif.PCLK);
    vif.PENABLE <= 1'b1;

    @(posedge vif.PCLK);
    req.rdata   = vif.PRDATA;
    req.slv_err = vif.PSLVERR;

    vif.PSELx   <= 1'b0;
    vif.PENABLE <= 1'b0;

    `uvm_info(get_type_name(), $sformatf("Read: addr=%h data=%h", req.addr, req.rdata), UVM_HIGH)

  endtask

  //===================
  // Register Write
  //===================
  task reg_write(reg_seq_item req);

    // Setup phase
    @(posedge vif.PCLK);
    vif.PADDR   <= req.addr;
    vif.PSTRB   <= req.strb;
    vif.PSELx   <= 1'b1;
    vif.PENABLE <= 1'b0;
    vif.PWRITE  <= 1'b1;
    vif.PWDATA  <= req.wdata;

    // Enable phase
    @(posedge vif.PCLK);
    vif.PENABLE <= 1'b1;

    // PREADY is always 1 (so take one cycle)
    @(posedge vif.PCLK);
    req.slv_err <= vif.PSLVERR;
    vif.PSELx   <= 1'b0;
    vif.PENABLE <= 1'b0;

    `uvm_info(get_type_name(), $sformatf("Write: addr=%h data=%h", req.addr, req.wdata), UVM_HIGH)

  endtask

  
endclass
  
  
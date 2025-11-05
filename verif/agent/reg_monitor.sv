class reg_monitor extends uvm_monitor;
  //==============================//
  //   UVM FACTORY REGISTRATION   //
  //==============================// 
  `uvm_component_utils(reg_monitor)

  //===================
  // Constructor
  //===================
  function new(string name = "reg_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Virtual interface
  virtual reg_intf vif;

  // Analysis ports
  uvm_analysis_port #(reg_seq_item) read_port;
  uvm_analysis_port #(reg_seq_item) write_port;

  //=======================
  // Build
  //=======================
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    read_port  = new("read_port", this);
    write_port = new("write_port", this);

    if (!uvm_config_db#(virtual reg_intf)::get(this, "*", "vif", vif)) begin
      `uvm_fatal(get_type_name(), "Can't get the interface (vif) from config DB")
    end
  endfunction

  //=======================
  // Run (monitoring loop)
  //=======================
  virtual task run_phase(uvm_phase phase);
    reg_seq_item send_packet;

    `uvm_info(get_type_name(), "Monitor run_phase started", UVM_LOW);

    forever begin
      @(posedge vif.PCLK iff (vif.PRESETn)); 

      if (vif.PSELx && vif.PENABLE && vif.PREADY) begin

        send_packet = reg_seq_item::type_id::create("send_packet", this);
        send_packet.addr    = vif.PADDR;
        send_packet.strb    = vif.PSTRB;
        send_packet.slv_err = vif.PSLVERR;
        if (vif.PWRITE) begin
          send_packet.wr    = 1'b1;
          send_packet.rd    = 1'b0;
          send_packet.wdata = vif.PWDATA;
          send_packet.rdata = vif.PRDATA;
          `uvm_info(get_type_name(), $sformatf("MON WRITE  addr=%0h data=%0h strb=%0b err=%0b",
                                             send_packet.addr, send_packet.wdata, send_packet.strb, send_packet.slv_err),
                    UVM_MEDIUM);
          write_port.write(send_packet);
        end
        else begin
          send_packet.wr    = 1'b0;
          send_packet.rd    = 1'b1;
          send_packet.rdata = vif.PRDATA;
          `uvm_info(get_type_name(), $sformatf("MON READ   addr=%0h rdata=%0h err=%0b",
                                             send_packet.addr, send_packet.rdata, send_packet.slv_err),
                    UVM_MEDIUM);
          read_port.write(send_packet);
        end
      end 
    end 
  endtask

endclass

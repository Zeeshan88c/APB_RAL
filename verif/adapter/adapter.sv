class reg_adapter extends uvm_reg_adapter;
  //===============================//
  //   UVM FACTORY REGISTRATION    //
  //===============================//
  `uvm_object_utils(reg_adapter)

  //===============================
  // Constructor
  //===============================
  function new(string name = "reg_adapter");
    super.new(name);
  endfunction

  //===================================================
  // Convert UVM register operation → bus sequence item
  //===================================================
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    reg_seq_item bus_item = reg_seq_item::type_id::create("bus_item");

    bus_item.addr  = rw.addr;
    bus_item.strb  = 4'b1111;     // full write enable
    if (rw.kind == UVM_WRITE) begin
      bus_item.rd   = 0;
      bus_item.wdata = rw.data;
    end
    else begin
      bus_item.rd   = 1;
    end

    return bus_item;
  endfunction

  //==============================================
  // Convert bus response → UVM register structure
  //==============================================
  virtual function void bus2reg(uvm_sequence_item b_item, ref uvm_reg_bus_op rw);
    reg_seq_item reg_item;

    if (!$cast(reg_item, b_item))begin
      `uvm_fatal("reg_adapter", "Failed to cast bus_item to reg_seq_item");
    end

    rw.kind = (reg_item.rd) ? UVM_READ : UVM_WRITE;
    rw.addr = reg_item.addr;
    rw.data = reg_item.rdata;   
    rw.byte_en = reg_item.strb; 
    rw.status = UVM_IS_OK;
  endfunction

endclass

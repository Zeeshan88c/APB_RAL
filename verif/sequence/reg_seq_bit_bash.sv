class reg_seq extends uvm_sequence;
  //=============================//
  //  UVM FACTORY REGISTRATION   //
  //=============================//
  `uvm_object_utils(reg_seq)
  
  //=============================
  // Constructor
  //=============================
  function new(string name="reg_seq");
    super.new(name);
  endfunction
  
  uvm_event in_scb_evnt;
  my_block reg_model;
  
  //=====================================
  // TASK BODY BIT BASH DEFAULT SEQUENCE
  //=====================================
  task body();
    uvm_reg_bit_bash_seq bitbash_seq;

    if(!(uvm_config_db #(my_block)::get(null, "*", "reg_model", reg_model))) begin
      `uvm_fatal(get_type_name(), "Unable to get register model from config_db");
    end
    
    in_scb_evnt = uvm_event_pool::get_global("ingr_scb_evnt");

    bitbash_seq = uvm_reg_bit_bash_seq::type_id::create("bitbash_seq");
    bitbash_seq.model = reg_model;

    `uvm_info(get_type_name(), "Starting UVM Bit Bash Sequence ...", UVM_LOW)
    bitbash_seq.start(null); 
    `uvm_info(get_type_name(), "UVM Bit Bash Sequence Completed.", UVM_LOW)
    
    in_scb_evnt.trigger();
  endtask
endclass

package reg_pkg;
  
  import uvm_pkg::*; 
  `include "uvm_macros.svh"

  //INterface
  `include "interface.sv"
  //Sequence item
  `include "sequence_item.sv"
  //Driver 
  `include "driver.sv"
  //Monitor 
  `include "monitor.sv"
  //Agent
  `include "agent.sv"
  // Regmodel
  `include "reg_model.sv"
  // Adapter
  `include "adapter.sv"
  //Environment
  `include "env.sv"
  import reg_top_reg_model::*;  
  //Sequence
  `include "sequence.sv"
   //Test
  `include "test.sv"
  
endpackage
 
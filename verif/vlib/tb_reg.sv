`timescale 1ns/1ns

module tb_apb;
  
import uvm_pkg::*;
 `include "uvm_macros.svh"
    import reg_pkg::*;
  
  bit PCLK, PRESETn;
  int ADDR_WIDTH, DATA_WIDTH;
  
  reg_intf apb_vif(PCLK, PRESETn);
  
  apb_slave_prac#(.ADDR_WIDTH(32), .DATA_WIDTH(32)) dut (
      .PCLK(apb_vif.PCLK),
      .PRESETn(apb_vif.PRESETn),
      .PADDR(apb_vif.PADDR),
      .PSELx(apb_vif.PSELx),
      .PENABLE(apb_vif.PENABLE),
      .PWRITE(apb_vif.PWRITE),
      .PWDATA(apb_vif.PWDATA),
      .PSTRB(apb_vif.PSTRB),
      .PREADY(apb_vif.PREADY),
      .PRDATA(apb_vif.PRDATA),
      .PSLVERR(apb_vif.PSLVERR)
  );
  
  //=========================
  // Clock Generation
  //=========================
  initial begin
    PCLK = 0;
    forever begin
      #5 PCLK = ~PCLK;	
    end
  end
  
  //=========================
  // Reset 
  //=========================
  initial begin
    PRESETn = 0;
    #10;
    PRESETn = 1;
  end
  
  
  //--------------------------------------------------------
  //Generate Waveforms
  //--------------------------------------------------------
  initial begin
   $dumpfile("d.vcd");
   $dumpvars();
  end

  
  //===============================
  // Setting interface in config db
  //===============================
  initial begin
    uvm_config_db #(virtual reg_intf)::set(null,"*", "vif", tb_apb.apb_vif);
    uvm_config_int::set(null, "*", "recording_detail", 1);
    // run test specified in coomand line
    run_test("reg_test");
  end
  
endmodule
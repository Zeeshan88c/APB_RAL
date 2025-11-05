//===============================================
// INTERFACE 
//===============================================
interface reg_intf (input PCLK, input PRESETn);
  
  logic [31:0] PADDR;      
  logic        PSELx;       
  logic        PENABLE;
  logic [3:0]  PSTRB;    
  logic        PWRITE;     
  logic [31:0] PWDATA;     
  logic [31:0] PRDATA;     
  logic        PREADY;     
  logic        PSLVERR;    

endinterface

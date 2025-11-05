//=========================================================//
//  APB Slave RTL : Practice CSR Block
//=========================================================//
//  Register Map
//    0x00 : CTRL    -> [0] enable (rw), [2:1] mode (rw)
//    0x04 : STATUS  -> [0] ready (ro), [1] error (ro)
//    0x08 : CONFIG  -> [7:0] cfg0 (rw), [15:8] cfg1 (rw)
//    0x0C : DATA    -> [31:0] data (rw)
//=========================================================//

module apb_slave_prac #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
)(
  input  logic                 PCLK,
  input  logic                 PRESETn,
  input  logic [ADDR_WIDTH-1:0] PADDR,
  input  logic                 PSELx,
  input  logic                 PENABLE,
  input  logic                 PWRITE,
  input  logic [DATA_WIDTH-1:0] PWDATA,
  input  logic [3:0]           PSTRB,
  output logic [DATA_WIDTH-1:0] PRDATA,
  output logic                 PREADY,
  output logic                 PSLVERR
);

  //===========================================
  // Internal Registers
  //===========================================
  logic [31:0] ctrl_reg;
  logic [31:0] status_reg;   // RO
  logic [31:0] config_reg;
  logic [31:0] data_reg;

  logic wr_en, rd_en;
  logic [31:0] wdata_masked;

  //===========================================
  // APB Handshake always ready (no wait)
  //===========================================
  assign PREADY  = 1'b1;
  assign PSLVERR = 1'b0;

  //===========================================
  // Write / Read Enables
  //===========================================
  assign wr_en = PSELx && PENABLE && PWRITE;
  assign rd_en = PSELx && !PWRITE;

  //===========================================
  // Write Data Masking using PSTRB
  //===========================================
  always_comb begin
    wdata_masked = PWDATA;
    if (!PSTRB[0]) wdata_masked[7:0]   = ctrl_reg[7:0];
    if (!PSTRB[1]) wdata_masked[15:8]  = ctrl_reg[15:8];
    if (!PSTRB[2]) wdata_masked[23:16] = ctrl_reg[23:16];
    if (!PSTRB[3]) wdata_masked[31:24] = ctrl_reg[31:24];
  end

  //===========================================
  // Write Logic (Only RW Registers Are Updated Here)
  //===========================================
  always_ff @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
      ctrl_reg   <= 32'h0000_0000;
      config_reg <= 32'h0000_0000;
      data_reg   <= 32'h0000_0000;
    end else if (wr_en) begin
      case (PADDR[7:2]) // word aligned decode
        6'h00: begin
          ctrl_reg[0]   <= wdata_masked[0];
          ctrl_reg[2:1] <= wdata_masked[2:1];
        end

        6'h02: begin
          config_reg[7:0]   <= wdata_masked[7:0];
          config_reg[15:8]  <= wdata_masked[15:8];
        end

        6'h03: begin
          data_reg <= wdata_masked;
        end
        
        default: ; // ignore writes to undefined addresses
      endcase
    end
  end

  //===========================================
  // Read Logic
  //===========================================
  always_comb begin
    PRDATA = 32'h0000_0000;
    case (PADDR[7:2])
      6'h00: PRDATA = ctrl_reg;
      6'h01: PRDATA = status_reg;   // RO
      6'h02: PRDATA = config_reg;
      6'h03: PRDATA = data_reg;
      default: PRDATA = 32'hDEAD_BEEF;
    endcase
  end

  //===========================================
  // Hardware Behavior - Controls STATUS Register
  //===========================================
  always_ff @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
      status_reg[0] <= 1'b0; // ready
      status_reg[1] <= 1'b0; // error
    end else begin
      status_reg[0] <= '0;                 // ready follows enable
      status_reg[1] <= (ctrl_reg[2:1] == 2'b00);    // error when mode==3
    end
  end

endmodule

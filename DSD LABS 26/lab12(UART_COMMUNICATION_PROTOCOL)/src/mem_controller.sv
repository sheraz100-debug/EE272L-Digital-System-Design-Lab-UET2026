
module mem_controller #(
  parameter FIFO_WIDTH = 8
) (
  input clk,
  input rst,
  input rx_fifo_empty,
  input tx_fifo_full,
  input [FIFO_WIDTH-1:0] din,

  output rx_fifo_rd_en,
  output tx_fifo_wr_en,
  output [FIFO_WIDTH-1:0] dout,
  output [5:0] state_leds
);

  localparam MEM_WIDTH = 8;
  localparam MEM_DEPTH = 256;
  localparam NUM_BYTES_PER_WORD = MEM_WIDTH/8;
  localparam MEM_ADDR_WIDTH = $clog2(MEM_DEPTH);

  //------------------------------------------------------
  // MEMORY
  //------------------------------------------------------

  reg mem_we_r;
  reg [MEM_ADDR_WIDTH-1:0] mem_addr_r;
  reg [MEM_WIDTH-1:0] mem_din_r;

  wire [NUM_BYTES_PER_WORD-1:0] mem_we;
  assign mem_we = mem_we_r ? 1'b1 : 1'b0;

  wire [MEM_WIDTH-1:0] mem_dout;

  SYNC_RAM_WBE #(
    .DWIDTH(MEM_WIDTH),
    .AWIDTH(MEM_ADDR_WIDTH)
  ) mem (
    .clk(clk),
    .en(1'b1),
    .wbe(mem_we),
    .addr(mem_addr_r),
    .d(mem_din_r),
    .q(mem_dout)
  );

  //------------------------------------------------------
  // STATES
  //------------------------------------------------------

  localparam
    IDLE          = 3'd0,
    READ_CMD      = 3'd1,
    READ_ADDR     = 3'd2,
    READ_DATA     = 3'd3,
    READ_MEM_VAL  = 3'd4,
    ECHO_VAL      = 3'd5,
    WRITE_MEM_VAL = 3'd6;

  wire [2:0] curr_state;
  reg  [2:0] next_state;

  REGISTER_R #(.N(3), .INIT(IDLE)) state_reg (
    .q(curr_state),
    .d(next_state),
    .rst(rst),
    .clk(clk)
  );

  //------------------------------------------------------
  // COMMAND / ADDRESS / DATA REGISTERS
  //------------------------------------------------------

  wire [7:0] cmd;
  wire [7:0] addr;
  wire [7:0] data;

  wire [7:0] cmd_next;
  wire [7:0] addr_next;
  wire [7:0] data_next;

  wire cmd_ld;
  wire addr_ld;
  wire data_ld;

  REGISTER_R #(.N(8)) cmd_reg (
    .q(cmd),
    .d(cmd_next),
    .rst(rst),
    .clk(clk)
  );

  REGISTER_R #(.N(8)) addr_reg (
    .q(addr),
    .d(addr_next),
    .rst(rst),
    .clk(clk)
  );

  REGISTER_R #(.N(8)) data_reg (
    .q(data),
    .d(data_next),
    .rst(rst),
    .clk(clk)
  );

  assign cmd_ld  = (curr_state == READ_CMD);
  assign addr_ld = (curr_state == READ_ADDR);
  assign data_ld = (curr_state == READ_DATA);

  assign cmd_next  = cmd_ld  ? din : cmd;
  assign addr_next = addr_ld ? din : addr;
  assign data_next = data_ld ? din : data;

  //------------------------------------------------------
  // OUTPUT REGISTERS
  //------------------------------------------------------

  reg rx_fifo_rd_en_r;
  reg tx_fifo_wr_en_r;
  reg [7:0] dout_r;

  assign rx_fifo_rd_en = rx_fifo_rd_en_r;
  assign tx_fifo_wr_en = tx_fifo_wr_en_r;
  assign dout          = dout_r;

  //------------------------------------------------------
  // NEXT STATE LOGIC
  //------------------------------------------------------

  always @(*) begin

    next_state = curr_state;

    case (curr_state)

      //--------------------------------------------------
      // WAIT FOR COMMAND
      //--------------------------------------------------
      IDLE: begin
        if (!rx_fifo_empty)
          next_state = READ_CMD;
      end

      //--------------------------------------------------
      // COMMAND CAPTURED
      //--------------------------------------------------
      READ_CMD: begin
        if (!rx_fifo_empty)
          next_state = READ_ADDR;
      end

      //--------------------------------------------------
      // ADDRESS CAPTURED
      //--------------------------------------------------
      READ_ADDR: begin

        if (cmd == 8'd48)
          next_state = READ_MEM_VAL;

        else if (cmd == 8'd49) begin
          if (!rx_fifo_empty)
            next_state = READ_DATA;
        end

        else
          next_state = IDLE;

      end

      //--------------------------------------------------
      // DATA BYTE CAPTURED
      //--------------------------------------------------
      READ_DATA: begin
        next_state = WRITE_MEM_VAL;
      end

      //--------------------------------------------------
      // WRITE MEMORY
      //--------------------------------------------------
      WRITE_MEM_VAL: begin
        next_state = IDLE;
      end

      //--------------------------------------------------
      // RAM READ LATENCY
      //--------------------------------------------------
      READ_MEM_VAL: begin
        next_state = ECHO_VAL;
      end

      //--------------------------------------------------
      // PUSH TO TX FIFO
      //--------------------------------------------------
      ECHO_VAL: begin
        if (!tx_fifo_full)
          next_state = IDLE;
      end

      default:
        next_state = IDLE;

    endcase
  end

  //------------------------------------------------------
  // OUTPUT LOGIC
  //------------------------------------------------------

  always @(*) begin

    rx_fifo_rd_en_r = 1'b0;
    tx_fifo_wr_en_r = 1'b0;

    dout_r = 8'd0;

    mem_we_r   = 1'b0;
    mem_addr_r = addr;
    mem_din_r  = data;

    case (curr_state)

      //--------------------------------------------------
      // READ COMMAND BYTE
      //--------------------------------------------------
      IDLE: begin
        if (!rx_fifo_empty)
          rx_fifo_rd_en_r = 1'b1;
      end

      //--------------------------------------------------
      // READ ADDRESS BYTE
      //--------------------------------------------------
      READ_CMD: begin
        if (!rx_fifo_empty)
          rx_fifo_rd_en_r = 1'b1;
      end

      //--------------------------------------------------
      // REQUEST DATA BYTE FOR WRITE COMMAND
      //--------------------------------------------------
      READ_ADDR: begin

        if ((cmd == 8'd49) && !rx_fifo_empty)
          rx_fifo_rd_en_r = 1'b1;

      end

      //--------------------------------------------------
      // WRITE MEMORY
      //--------------------------------------------------
      WRITE_MEM_VAL: begin

        mem_we_r   = 1'b1;
        mem_addr_r = addr;
        mem_din_r  = data;

      end

      //--------------------------------------------------
      // START MEMORY READ
      //--------------------------------------------------
      READ_MEM_VAL: begin

        mem_addr_r = addr;

      end

      //--------------------------------------------------
      // SEND TO TX FIFO
      //--------------------------------------------------
      ECHO_VAL: begin

        if (!tx_fifo_full) begin
          tx_fifo_wr_en_r = 1'b1;
          dout_r = mem_dout;
        end

      end

    endcase
  end

  //------------------------------------------------------
  // LEDS
  //------------------------------------------------------

  assign state_leds = {3'b000,curr_state};

endmodule

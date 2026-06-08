module fifo
#(
    parameter WIDTH         = 8,
    parameter DEPTH         = 32,
    parameter POINTER_WIDTH = $clog2(DEPTH)
)
(
    input  logic clk,
    input  logic rst,

    input  logic wr_en,
    input  logic rd_en,

    input  logic [WIDTH-1:0] din,

    output logic [WIDTH-1:0] dout,

    output logic full,
    output logic empty
);

    // =====================================================
    // MEMORY
    // =====================================================

    logic [WIDTH-1:0] mem [0:DEPTH-1];

    logic [POINTER_WIDTH-1:0] wr_ptr;
    logic [POINTER_WIDTH-1:0] rd_ptr;

    logic [POINTER_WIDTH:0] count;

    // =====================================================
    // FIFO LOGIC
    // =====================================================

    always_ff @(posedge clk) begin

        if (rst) begin

            wr_ptr <= 0;
            rd_ptr <= 0;

            count <= 0;

            dout <= 0;

        end
        else begin

            // =============================================
            // WRITE
            // =============================================

            if (wr_en && !full) begin

                mem[wr_ptr] <= din;

                wr_ptr <= wr_ptr + 1;

            end

            // =============================================
            // READ
            // =============================================

            if (rd_en && !empty) begin

                dout <= mem[rd_ptr];

                rd_ptr <= rd_ptr + 1;

            end

            // =============================================
            // COUNT UPDATE
            // =============================================

            case ({wr_en && !full, rd_en && !empty})

                2'b10: count <= count + 1;

                2'b01: count <= count - 1;

                default: count <= count;

            endcase

        end

    end

    // =====================================================
    // STATUS FLAGS
    // =====================================================

    assign full  = (count == DEPTH);

    assign empty = (count == 0);

endmodule
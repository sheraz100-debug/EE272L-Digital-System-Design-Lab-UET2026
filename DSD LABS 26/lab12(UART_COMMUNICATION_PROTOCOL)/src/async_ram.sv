module async_ram
#(
    parameter dwidth = 8,
    parameter depth  = 32,
    parameter awidth = $clog2(depth)
)
(
    input  logic              clk,

    input  logic              w_en,
    input  logic              r_en,

    input  logic [dwidth-1:0] data_in,

    input  logic [awidth-1:0] addr_read,
    input  logic [awidth-1:0] addr_write,

    output logic [dwidth-1:0] data_out
);

    logic [dwidth-1:0] mem [0:depth-1];

    always_ff @(posedge clk) begin

        if (w_en) begin
            mem[addr_write] <= data_in;
        end

        if (r_en) begin
            data_out <= mem[addr_read];
        end

    end

endmodule
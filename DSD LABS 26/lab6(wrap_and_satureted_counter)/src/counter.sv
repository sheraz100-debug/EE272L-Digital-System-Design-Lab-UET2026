module counter #(parameter N = 4)(
    input  logic clk,
    input  logic reset,
    input  logic mode,        // 0 = wrap, 1 = saturated
    output logic [N-1:0] count
);

    logic [N-1:0] next;
    logic [N-1:0] max_val;
    logic equal;

    assign max_val = {N{1'b1}};

    // Adder
    adder #(N) add1 (
        .a(count),
        .b({{(N-1){1'b0}}, 1'b1}),   // proper N-bit 1
        .sum(next)
    );

    // Comparator
    comparator #(N) comp1 (
        .a(count),
        .b(max_val),
        .equal(equal),
        .greater(),
        .less()
    );

    // Sequential logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            count <= 0;
        else begin
            if (mode == 0) begin
                // WRAP
                count <= next;
            end else begin
                // SATURATED
                if (equal)
                    count <= count;
                else
                    count <= next;
            end
        end
    end

endmodule
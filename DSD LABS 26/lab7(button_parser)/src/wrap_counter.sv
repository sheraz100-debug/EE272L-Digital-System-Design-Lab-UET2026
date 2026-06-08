module wrap_counter (
    input  logic clk, rst,
    output logic [1:0] count_wrap
);
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            count_wrap <= 0;
        else
            count_wrap <= count_wrap + 1;
    end
endmodule
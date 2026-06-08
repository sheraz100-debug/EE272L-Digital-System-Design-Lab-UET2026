module counter(
    input logic clk,counter_rst,
    output logic [1:0] down_count
);
always_ff @(posedge clk or posedge counter_rst) begin
    if(counter_rst)
        down_count <= 2'd3;
    else begin
        down_count <= down_count - 1;
    end
end
endmodule
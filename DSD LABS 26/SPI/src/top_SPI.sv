module top_SPI(
    input logic clk,rst,serial_input,
    output logic [3:0] parallel_output, 
    output logic data_ready
);
logic shift_enable;
logic counter_enable;
logic [1:0]down_count;

counter my_counter(
    .clk(clk),

    .counter_rst(counter_enable),
    .down_count(down_count)
);

shift_register my_register(
    .clk(clk),
    .rst(rst),
    .shift_enable(shift_enable),
    .serial_input(serial_input),
    .parallel_out(parallel_output)
);

controller_SPI my_controller(
    .clk(clk),
    .rst(rst),
    .shift_enable(shift_enable),
    .serial_in(serial_input),
    .down_count(down_count),
    .data_ready(data_ready),
    .counter_enable(counter_enable)
);
endmodule
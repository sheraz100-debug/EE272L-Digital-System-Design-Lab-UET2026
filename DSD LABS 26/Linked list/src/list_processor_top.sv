module list_processor_top(
    input logic clk,rst,start,
    output logic Done, [15:0]Result
);
logic load_next;
logic load_sum;
logic next_select;
logic sum_select;
logic Address_select;
logic Next_Zero;
logic [7:0]memory_data;
logic [7:0]memory_address;
 //memory
 memory my_mem (
    .address(memory_address),
    .data(memory_data)
 );
 //datapath
 datapath my_datapath(
    .load_next(load_next),
    .load_sum(load_sum),
    .next_select(next_select),
    .sum_select(sum_select),
    .Address_select(Address_select),
    .Next_Zero(Next_Zero),
    .clk(clk),
    .rst(rst),
    .result(Result),
    .memory_address(memory_address),
    .memory_data(memory_data)
 );
 //FSM
 controller my_controller(
    .clk(clk),
    .rst(rst),
    .Start(start),
    .Next_Zero(Next_Zero),
    .ld_next(load_next),
    .ld_sum(load_sum),
    .next_select(next_select),
    .sum_select(sum_select),
    .Address_select(Address_select),
    .Finish(Done)
 );
endmodule
module list_processor_tb;
logic clk;
    logic rst;
    logic start;
    logic Done;
    logic [15:0]Result;

list_processor_top DUT(
    .clk(clk),
    .rst(rst),
    .start(start),
    .Done(Done),
    .Result(Result)
);
initial begin
    clk = 0;
   forever #5 clk = ~clk;
end
initial begin
    rst = 1;
    start=1;
    #20;
    rst = 0;
    #20;
    start = 0;
    wait(Done);
$display("--------------------------------------------------------");
$display("Sum = %0d",Result);

$display("--------------------------------------------------------");
#10000000;
$finish;
end
endmodule
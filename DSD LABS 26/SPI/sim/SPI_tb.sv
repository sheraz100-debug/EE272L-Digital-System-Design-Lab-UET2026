module SPI;

logic clk;
logic rst;
logic serial_input;

logic [3:0] parallel_output;
logic data_ready;

// DUT
top_SPI DUT(
.clk(clk),
.rst(rst),
.serial_input(serial_input),
.parallel_output(parallel_output),
.data_ready(data_ready)
);

/////////////////////////////////////////////////
// Clock Generation (10ns period)
/////////////////////////////////////////////////

initial
begin
clk = 0;
forever #5 clk = ~clk;
end

/////////////////////////////////////////////////
// Stimulus
/////////////////////////////////////////////////

initial
begin


//-----------------------------------------
// Reset
//-----------------------------------------
rst = 1;
serial_input = 1;     // idle line

#20;
rst = 0;

//-----------------------------------------
// Start Bit
//-----------------------------------------
@(posedge clk);
serial_input = 0;

//-----------------------------------------
// 4 Data Bits
// Example: 1 0 0 1
//-----------------------------------------

@(posedge clk);
serial_input = 1;

@(posedge clk);
serial_input = 1;

@(posedge clk);
serial_input = 1;

@(posedge clk);
serial_input = 0;
@(posedge clk);
serial_input = 1;
@(posedge clk);
serial_input = 1;
@(posedge clk);
serial_input = 0;
@(posedge clk);
serial_input = 0;
@(posedge clk);
serial_input = 1;
@(posedge clk);
serial_input = 0;
@(posedge clk);
serial_input = 1;

@(posedge clk);
serial_input = 0;
//-----------------------------------------
// Return to Idle
//-----------------------------------------

@(posedge clk);
serial_input = 1;

//-----------------------------------------
// Wait until receiver is done
//-----------------------------------------

wait(data_ready);

$display("-----------------------------------");
$display("Time            = %0t", $time);
$display("Parallel Output = %b", parallel_output);
$display("Data Ready      = %b", data_ready);
$display("-----------------------------------");

#20;
$finish;

end

endmodule

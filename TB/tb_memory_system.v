`timescale 1ns/1ps

module tb_memory_system;

parameter N = 3;
parameter DATA_WIDTH = 32;
parameter ADDR_WIDTH = 4;

reg clk;
reg rst;

reg  [N-1:0] valid;
reg  [N-1:0] write;
reg  [N*ADDR_WIDTH-1:0] addr;
reg  [N*DATA_WIDTH-1:0] wdata;

wire [N-1:0] ready;
wire [DATA_WIDTH-1:0] rdata;

// Reference memory model
reg [DATA_WIDTH-1:0] ref_mem [0:(1<<ADDR_WIDTH)-1];

// Pipeline registers for verification
reg [ADDR_WIDTH-1:0] read_addr_d;
reg read_valid_d;

integer i;
integer k;

// DUT
memory_system_top #(N, DATA_WIDTH, ADDR_WIDTH) dut (
    .clk(clk),
    .rst(rst),
    .valid(valid),
    .write(write),
    .addr(addr),
    .wdata(wdata),
    .ready(ready),
    .rdata(rdata)
);

// Clock
always #5 clk = ~clk;

// --------------------------------------------------
// Initial block
// --------------------------------------------------
initial begin
    clk = 0;
    rst = 1;
    valid = 0;
    write = 0;
    addr = 0;
    wdata = 0;

    // Initialize reference memory
    for (k = 0; k < (1<<ADDR_WIDTH); k = k + 1)
        ref_mem[k] = 0;

    #20 rst = 0;

    // Continuous contention phase
    valid = 3'b111;
    write = 3'b111;

    for (i = 0; i < 10; i = i + 1)
        @(posedge clk);

    // Random traffic phase
    repeat (40) begin
        @(posedge clk);
        valid = $urandom % 8;
        write = $urandom % 8;
        addr  = $urandom;
        wdata = $urandom;
    end

    #50;

    // Performance summary
    $display("---- Performance Summary ----");
    for (k = 0; k < N; k = k + 1) begin
        $display("Master %0d Grants      = %0d", k, dut.grant_count[k]);
        $display("Master %0d Wait Cycles = %0d", k, dut.wait_count[k]);
    end

    $finish;
end

// --------------------------------------------------
// Correct Scoreboard (Aligned with DUT internals)
// --------------------------------------------------
always @(posedge clk) begin
    read_valid_d <= 0;

    // If a grant happened
    if (|dut.grant) begin

        // WRITE operation
        if (dut.we_mux) begin
            ref_mem[dut.addr_mux] <= dut.wdata_mux;
        end

        // READ operation
        else begin
            read_addr_d  <= dut.addr_mux;
            read_valid_d <= 1;
        end
    end
end

// --------------------------------------------------
// Compare 1 cycle later (due to synchronous RAM)
// --------------------------------------------------
always @(posedge clk) begin
    if (read_valid_d) begin
        if (rdata !== ref_mem[read_addr_d]) begin
            $display("ERROR: Data mismatch at time %t", $time);
            $display("Expected = %h, Got = %h",
                      ref_mem[read_addr_d], rdata);
            $finish;
        end
    end
end

// Waveform dump
initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0);

    // Explicitly dump performance counters
    $dumpvars(0, dut.grant_count[0]);
    $dumpvars(0, dut.grant_count[1]);
    $dumpvars(0, dut.grant_count[2]);

    $dumpvars(0, dut.wait_count[0]);
    $dumpvars(0, dut.wait_count[1]);
    $dumpvars(0, dut.wait_count[2]);
end

endmodule
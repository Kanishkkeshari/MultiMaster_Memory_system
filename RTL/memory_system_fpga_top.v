module memory_system_fpga_top (
    input  wire        clk,        // 100 MHz clock
    input  wire [15:0] sw,         // 16 switches
    output wire [15:0] led         // 16 LEDs
);

    parameter N = 3;
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;

    wire [N-1:0] valid;
    wire [N-1:0] write;
    wire [N*ADDR_WIDTH-1:0] addr;
    wire [N*DATA_WIDTH-1:0] wdata;

    wire [N-1:0] ready;
    wire [DATA_WIDTH-1:0] rdata;

    // Switch Mapping
    assign valid = sw[2:0];
    assign write = sw[5:3];

    assign addr  = {3{sw[9:6]}};    // same address for all masters (demo)
    assign wdata = {3{sw[15:8]}};   // same write data for all masters (demo)

    memory_system_top #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .clk(clk),
        .rst(1'b0),
        .valid(valid),
        .write(write),
        .addr(addr),
        .wdata(wdata),
        .ready(ready),
        .rdata(rdata)
    );

    // LED Mapping
    assign led[2:0]   = ready;
    assign led[15:8]  = rdata;
    assign led[7:3]   = 5'b0;

endmodule
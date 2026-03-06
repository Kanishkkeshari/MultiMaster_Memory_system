module sync_ram #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 4
)(
    input  wire                     clk,
    input  wire                     we,
    input  wire [ADDR_WIDTH-1:0]    addr,
    input  wire [DATA_WIDTH-1:0]    wdata,
    output reg  [DATA_WIDTH-1:0]    rdata
);

    // Memory declaration
    reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

    // ------------------------------------------
    // Simulation-only initialization
    // (Prevents X values during read)
    // ------------------------------------------
    integer init_i;
    initial begin
        for (init_i = 0; init_i < (1<<ADDR_WIDTH); init_i = init_i + 1)
            mem[init_i] = 0;
    end

    // ------------------------------------------
    // Synchronous read + write
    // ------------------------------------------
    always @(posedge clk) begin
        if (we)
            mem[addr] <= wdata;

        rdata <= mem[addr];   // 1-cycle read latency
    end

endmodule
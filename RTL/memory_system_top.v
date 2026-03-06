module memory_system_top #(
    parameter N = 3,
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 4
)(
    input  wire                         clk,
    input  wire                         rst,

    input  wire [N-1:0]                 valid,
    input  wire [N-1:0]                 write,
    input  wire [N*ADDR_WIDTH-1:0]      addr,
    input  wire [N*DATA_WIDTH-1:0]      wdata,

    output wire [N-1:0]                 ready,
    output wire [DATA_WIDTH-1:0]        rdata
);

    wire [N-1:0] grant;

    // ----------------------------
    // Performance Counters
    // ----------------------------
    reg [31:0] grant_count [0:N-1];
    reg [31:0] wait_count  [0:N-1];

    integer j;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (j = 0; j < N; j = j + 1) begin
                grant_count[j] <= 0;
                wait_count[j]  <= 0;
            end
        end else begin
            for (j = 0; j < N; j = j + 1) begin
                if (grant[j])
                    grant_count[j] <= grant_count[j] + 1;

                if (valid[j] && !grant[j])
                    wait_count[j] <= wait_count[j] + 1;
            end
        end
    end

    // Arbiter
    rr_arbiter #(N) arbiter (
        .clk(clk),
        .rst(rst),
        .req(valid),
        .grant(grant)
    );

    assign ready = grant;

    // ----------------------------
    // MUX Logic
    // ----------------------------
    reg [ADDR_WIDTH-1:0]  addr_mux;
    reg [DATA_WIDTH-1:0]  wdata_mux;
    reg                   we_mux;

    integer i;

    always @(*) begin
        addr_mux  = 0;
        wdata_mux = 0;
        we_mux    = 0;

        for (i = 0; i < N; i = i + 1) begin
            if (grant[i]) begin
                addr_mux  = addr[i*ADDR_WIDTH +: ADDR_WIDTH];
                wdata_mux = wdata[i*DATA_WIDTH +: DATA_WIDTH];
                we_mux    = write[i];
            end
        end
    end

    // RAM
    sync_ram #(DATA_WIDTH, ADDR_WIDTH) ram (
        .clk(clk),
        .we(we_mux),
        .addr(addr_mux),
        .wdata(wdata_mux),
        .rdata(rdata)
    );

    // ----------------------------
    // One-Hot Safety Check
    // ----------------------------


endmodule
module rr_arbiter #(
    parameter N = 3
)(
    input  wire            clk,
    input  wire            rst,
    input  wire [N-1:0]    req,
    output reg  [N-1:0]    grant
);

    reg [$clog2(N)-1:0] pointer;
    integer i;

    // Pointer update
    always @(posedge clk or posedge rst) begin
        if (rst)
            pointer <= 0;
        else if (|grant)
            pointer <= (pointer + 1) % N;
    end

    // Grant logic
    always @(*) begin
        grant = 0;
        for (i = 0; i < N; i = i + 1)
            if (req[(pointer+i)%N] && grant == 0)
                grant[(pointer+i)%N] = 1'b1;
    end

endmodule
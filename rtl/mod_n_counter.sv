`timescale 1ns / 1ps

// Modulo-N counter with synchronous reset and enable.
// rst takes priority over enable.
// Counts from 0 to N-1, then wraps back to 0.

module mod_n_counter #(
    parameter int N = 4,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic rst,
    input logic enable,
    output logic [WIDTH-1:0] count
);

    localparam logic [WIDTH-1:0] MaxCount = WIDTH'(N - 1);

    logic [WIDTH-1:0] next_count;

    initial count = '0;

    always_ff @(posedge clk)
        if (rst) count <= '0;
        else if (enable) count <= next_count;

    always_comb begin
        if (count == MaxCount) next_count = '0;
        else next_count = count + WIDTH'(1);
    end
endmodule

`timescale 1ns / 1ps

// Three-stage cascade counter built from mod_n_counter instances

module cascade_counter #(
    parameter int N2 = 3,
    parameter int N1 = 4,
    parameter int N0 = 5,
    parameter int W2 = 2,
    parameter int W1 = 2,
    parameter int W0 = 3
) (
    input  logic          clk,
    input  logic          rst,
    input  logic          enable,
    output logic [W2-1:0] count2,
    output logic [W1-1:0] count1,
    output logic [W0-1:0] count0
);

  logic wrap0, wrap1;

  assign wrap0 = enable && (count0 == W0'(N0 - 1));
  assign wrap1 = wrap0   && (count1 == W1'(N1 - 1));

  mod_n_counter #(.N(N0), .WIDTH(W0)) u_count0 (
    .clk   (clk),
    .rst   (rst),
    .enable(enable),
    .count (count0)
  );

  mod_n_counter #(.N(N1), .WIDTH(W1)) u_count1 (
    .clk   (clk),
    .rst   (rst),
    .enable(wrap0),
    .count (count1)
  );

  mod_n_counter #(.N(N2), .WIDTH(W2)) u_count2 (
    .clk   (clk),
    .rst   (rst),
    .enable(wrap1),
    .count (count2)
  );

endmodule

`timescale 1ns / 1ps

// Editable counter.
// In normal mode, count increments on each tick pulse.
// In edit mode, inc increments and dec decrements the count.
// If both inc and dec are asserted simultaneously, count does not change.

module editable_counter #(
    parameter int N     = 60,
    parameter int WIDTH = 6
) (
    input  logic             clk,
    input  logic             tick,
    input  logic             edit_mode,
    input  logic             inc,
    input  logic             dec,
    output logic [WIDTH-1:0] count
);

  logic enable;
  logic up;

  up_down_counter #(
      .MAX  (N - 1),
      .WIDTH(WIDTH)
  ) u_counter (
      .clk   (clk),
      .enable(enable),
      .up    (up),
      .count (count)
  );

  wire inc_event  = edit_mode && inc && !dec;
  wire dec_event  = edit_mode && dec && !inc;
  wire tick_event = !edit_mode && tick;

  assign up     = inc_event || tick_event;
  assign enable = inc_event || dec_event || tick_event;

endmodule

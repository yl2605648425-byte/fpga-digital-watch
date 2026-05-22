`timescale 1ns / 1ps

// Stopwatch FSM: controls counter reset, enable, and lap hold

module stopwatch_control (
    input  logic clk,
    input  logic rise_start_stop,
    input  logic rise_lap,
    output logic counter_rst,
    output logic counter_enable,
    output logic lap_hold
);

  logic running    = 1'b0;
  logic lap_hold_r = 1'b0;
  logic rst_r      = 1'b0;

  assign counter_enable = running;
  assign lap_hold       = lap_hold_r;
  assign counter_rst    = rst_r;

  always_ff @(posedge clk) begin
    rst_r <= rise_lap && !rise_start_stop && !running && !lap_hold_r;
  end

  always_ff @(posedge clk) begin
    if (rise_start_stop && !rise_lap)
      running <= !running;
  end

  always_ff @(posedge clk) begin
    if (rise_lap && !rise_start_stop) begin
      if (running)
        lap_hold_r <= !lap_hold_r;
      else if (lap_hold_r)
        lap_hold_r <= 1'b0;
    end
  end

endmodule


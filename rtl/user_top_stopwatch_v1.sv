`timescale 1ns / 1ps

// Stopwatch integration: minutes, seconds, centiseconds display

module user_top_stopwatch_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input  logic        clk,
    /* verilator lint_off UNUSEDSIGNAL */
    input  logic [3:0]  button,
    input  logic [9:0]  sw,
    /* verilator lint_on UNUSEDSIGNAL */
    output logic [9:0]  led,
    output logic [6:0]  hours_disp,
    output logic [6:0]  minutes_disp,
    output logic [6:0]  seconds_disp,
    output logic        blank_hours,
    output logic        blank_minutes,
    output logic        blank_seconds
);

  assign led         = '0;
  assign blank_hours = 1'b0;

  logic rise_start_stop, rise_lap;

  rising_edge_detector u_red0 (
    .clk   (clk),
    .sig_in(button[0]),
    .rise  (rise_start_stop)
  );

  rising_edge_detector u_red1 (
    .clk   (clk),
    .sig_in(button[1]),
    .rise  (rise_lap)
  );

  logic counter_rst, counter_enable, lap_hold;

  stopwatch_control u_ctrl (
    .clk            (clk),
    .rise_start_stop(rise_start_stop),
    .rise_lap       (rise_lap),
    .counter_rst    (counter_rst),
    .counter_enable (counter_enable),
    .lap_hold       (lap_hold)
  );

  logic [6:0] minutes_live, centiseconds_live;
  logic [5:0] seconds_live;

  stopwatch_counter #(
    .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_counter (
    .clk         (clk),
    .rst         (counter_rst),
    .enable      (counter_enable),
    .minutes     (minutes_live),
    .seconds     (seconds_live),
    .centiseconds(centiseconds_live)
  );

  logic [6:0] minutes_disp_raw, centiseconds_disp;
  logic [5:0] seconds_disp_raw;

  snapshot_mux #(.WIDTH(7)) u_snap_min (
    .clk (clk),
    .hold(lap_hold),
    .d   (minutes_live),
    .q   (minutes_disp_raw)
  );

  snapshot_mux #(.WIDTH(6)) u_snap_sec (
    .clk (clk),
    .hold(lap_hold),
    .d   (seconds_live),
    .q   (seconds_disp_raw)
  );

  snapshot_mux #(.WIDTH(7)) u_snap_cs (
    .clk (clk),
    .hold(lap_hold),
    .d   (centiseconds_live),
    .q   (centiseconds_disp)
  );

  assign hours_disp    = minutes_disp_raw;
  assign minutes_disp  = 7'(seconds_disp_raw);
  assign seconds_disp  = centiseconds_disp;
  assign blank_minutes = 1'b0;
  assign blank_seconds = 1'b0;

endmodule


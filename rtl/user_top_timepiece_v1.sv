`timescale 1ns / 1ps

// Timepiece: integrates watch, stopwatch, timer; sw[1:0] selects active app

module user_top_timepiece_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input  logic        clk,
    input  logic  [3:0] button,
    input  logic  [9:0] sw,
    output logic  [9:0] led,
    output logic  [6:0] hours_disp,
    output logic  [6:0] minutes_disp,
    output logic  [6:0] seconds_disp,
    output logic        blank_hours,
    output logic        blank_minutes,
    output logic        blank_seconds
);

  typedef struct packed {
    logic [3:0] button;
    logic [9:0] sw;
  } ui_in_t;

  typedef struct packed {
    logic  [9:0] led;
    logic  [6:0] hours_disp;
    logic  [6:0] minutes_disp;
    logic  [6:0] seconds_disp;
    logic        blank_hours;
    logic        blank_minutes;
    logic        blank_seconds;
  } ui_out_t;

  ui_in_t  in_watch,     in_timer,     in_sw;
  ui_out_t out_watch,    out_timer,    out_sw;

  user_top_watch_v4 #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_watch (
      .clk          (clk),
      .button       (in_watch.button),
      .sw           (in_watch.sw),
      .led          (out_watch.led),
      .hours_disp   (out_watch.hours_disp),
      .minutes_disp (out_watch.minutes_disp),
      .seconds_disp (out_watch.seconds_disp),
      .blank_hours  (out_watch.blank_hours),
      .blank_minutes(out_watch.blank_minutes),
      .blank_seconds(out_watch.blank_seconds)
  );

  user_top_timer_v1 #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_timer (
      .clk          (clk),
      .button       (in_timer.button),
      .sw           (in_timer.sw),
      .led          (out_timer.led),
      .hours_disp   (out_timer.hours_disp),
      .minutes_disp (out_timer.minutes_disp),
      .seconds_disp (out_timer.seconds_disp),
      .blank_hours  (out_timer.blank_hours),
      .blank_minutes(out_timer.blank_minutes),
      .blank_seconds(out_timer.blank_seconds)
  );

  user_top_stopwatch_v1 #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_stopwatch (
      .clk          (clk),
      .button       (in_sw.button),
      .sw           (in_sw.sw),
      .led          (out_sw.led),
      .hours_disp   (out_sw.hours_disp),
      .minutes_disp (out_sw.minutes_disp),
      .seconds_disp (out_sw.seconds_disp),
      .blank_hours  (out_sw.blank_hours),
      .blank_minutes(out_sw.blank_minutes),
      .blank_seconds(out_sw.blank_seconds)
  );

  ui_in_t  active_in, silent_in;
  assign active_in.sw     = sw;
  assign active_in.button = button;
  assign silent_in.sw     = sw;
  assign silent_in.button = '0;

  ui_out_t active_out;
  assign led           = active_out.led;
  assign hours_disp    = active_out.hours_disp;
  assign minutes_disp  = active_out.minutes_disp;
  assign seconds_disp  = active_out.seconds_disp;
  assign blank_hours   = active_out.blank_hours;
  assign blank_minutes = active_out.blank_minutes;
  assign blank_seconds = active_out.blank_seconds;

  always @(*) begin
    in_watch   = silent_in;
    in_timer   = silent_in;
    in_sw      = silent_in;
    active_out = out_watch;
    if (sw[1:0] == 2'b01) begin
      in_sw      = active_in;
      active_out = out_sw;
    end else if (sw[1:0] == 2'b11) begin
      in_timer   = active_in;
      active_out = out_timer;
    end else begin
      in_watch   = active_in;
      active_out = out_watch;
    end
  end

endmodule

`timescale 1ns / 1ps

module user_top_watch_v3 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
   input  logic        clk,
    /* verilator lint_off UNUSED */
    input  logic [ 3:0] button,
    input  logic [ 9:0] sw,
    /* verilator lint_on UNUSED */
    output logic [ 9:0] led,
    output logic [ 6:0] hours_disp,
    output logic [ 6:0] minutes_disp,
    output logic [ 6:0] seconds_disp,
    output logic        blank_hours,
    output logic        blank_minutes,
    output logic        blank_seconds
);

  // ------------------
  // Core Functionality
  // ------------------

  logic seconds_tick;
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_divider_1_Hz (
      .clk (clk),
      .run (1'b1),
      .tick(seconds_tick)
  );

  logic [5:0] seconds;
  logic seconds_edit;
  logic seconds_inc;
  logic seconds_dec;
  editable_counter #(
      .N    (60),
      .WIDTH(6)
  ) u_seconds (
      .clk      (clk),
      .tick     (seconds_tick),
      .edit_mode(seconds_edit),
      .inc      (seconds_inc),
      .dec      (seconds_dec),
      .count    (seconds)
  );

  logic [5:0] minutes;
  logic minutes_tick;
  logic minutes_edit;
  logic minutes_inc;
  logic minutes_dec;
  editable_counter #(
      .N    (60),
      .WIDTH(6)
  ) u_minutes (
      .clk      (clk),
      .tick     (minutes_tick),
      .edit_mode(minutes_edit),
      .inc      (minutes_inc),
      .dec      (minutes_dec),
      .count    (minutes)
  );

  logic [4:0] hours;
  logic hours_tick;
  logic hours_edit;
  logic hours_inc;
  logic hours_dec;
  editable_counter #(
      .N    (24),
      .WIDTH(5)
  ) u_hours (
      .clk      (clk),
      .tick     (hours_tick),
      .edit_mode(hours_edit),
      .inc      (hours_inc),
      .dec      (hours_dec),
      .count    (hours)
  );

  assign minutes_tick = (seconds == 6'd59) && seconds_tick;
  assign hours_tick   = (minutes == 6'd59) && minutes_tick;

  assign hours_disp   = {2'b0, hours};
  assign minutes_disp = {1'b0, minutes};
  assign seconds_disp = {1'b0, seconds};

  // --------------
  // Mode Selection
  // --------------

  logic [2:0] mode_enable;
  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) u_mode_selector (
      .clk        (clk),
      .button     (button[3]),
      .mode_enable(mode_enable)
  );

  logic pwm_out;
  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),
      .DUTY_CYCLES  (CYCLES_PER_SECOND / 2 * 4 / 5)
  ) u_pwm (
      .clk    (clk),
      .rst    (1'b0),
      .pwm_out(pwm_out)
  );

  assign blank_seconds = mode_enable[0] & ~pwm_out;
  assign blank_minutes = mode_enable[1] & ~pwm_out;
  assign blank_hours   = mode_enable[2] & ~pwm_out;

  // -----------
  // Edit Logic
  // -----------

  logic inc_pulse;
  logic dec_pulse;

  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2 + 1),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_inc (
      .clk   (clk),
      .button(button[1]),
      .pulse (inc_pulse)
  );

  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2 + 1),
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_dec (
      .clk   (clk),
      .button(button[0]),
      .pulse (dec_pulse)
  );

  assign seconds_edit = mode_enable[0];
  assign seconds_inc  = mode_enable[0] & inc_pulse;
  assign seconds_dec  = mode_enable[0] & dec_pulse;

  assign minutes_edit = mode_enable[1];
  assign minutes_inc  = mode_enable[1] & inc_pulse;
  assign minutes_dec  = mode_enable[1] & dec_pulse;

  assign hours_edit = mode_enable[2];
  assign hours_inc  = mode_enable[2] & inc_pulse;
  assign hours_dec  = mode_enable[2] & dec_pulse;

  assign led = 10'b0;

endmodule

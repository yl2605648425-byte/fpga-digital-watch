`timescale 1ns / 1ps

// Timer with set/stop/run modes and countdown display

module user_top_timer_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
`ifdef FORMAL
    output logic        probe_running,
    output logic [2:0]  probe_mode_enable,
`endif
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

  // Edit mode
  logic [2:0] mode_enable;
  logic edit_mode;
  assign edit_mode = (mode_enable != 3'b000);

  // All-zero detection
  logic [4:0] hours;
  logic [5:0] minutes, seconds;
  logic time_zero;
  assign time_zero = (hours == '0) && (minutes == '0) && (seconds == '0);

  // Running flag
  logic running = 1'b0;
  logic button0_rise;

  rising_edge_detector u_red0 (
    .clk   (clk),
    .sig_in(button[0]),
    .rise  (button0_rise)
  );

  always_ff @(posedge clk) begin
    if (edit_mode)
      running <= 1'b0;
    else if (running && time_zero)
      running <= 1'b0;
    else if (button0_rise && !time_zero)
      running <= !running;
  end

  // 1 Hz tick
  logic tick_1s;
  restartable_rate_generator #(
    .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_rate_gen (
    .clk (clk),
    .run (running),
    .tick(tick_1s)
  );

  // Borrow chain
  logic sec_borrow, min_borrow;
  /* verilator lint_off UNUSEDSIGNAL */
  logic hour_borrow;
  /* verilator lint_on UNUSEDSIGNAL */

  logic sec_tick, min_tick, hour_tick;
  assign sec_tick  = running && !edit_mode && !time_zero && tick_1s;
  assign min_tick  = sec_borrow;
  assign hour_tick = min_borrow;

  // Inc/dec pulses
  logic inc_pulse, dec_pulse;

  button_auto_repeat #(
    .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
    .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_inc (
    .clk   (clk),
    .button(button[1]),
    .pulse (inc_pulse)
  );

  button_auto_repeat #(
    .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),
    .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)
  ) u_dec (
    .clk   (clk),
    .button(button[0]),
    .pulse (dec_pulse)
  );

  // Editable countdown counters
  editable_countdown #(.MAX(59), .WIDTH(6)) u_sec (
    .clk      (clk),
    .clr      (1'b0),
    .tick     (sec_tick),
    .edit_mode(mode_enable[0]),
    .inc      (mode_enable[0] && inc_pulse),
    .dec      (mode_enable[0] && dec_pulse),
    .count    (seconds),
    .borrow_out(sec_borrow)
  );

  editable_countdown #(.MAX(59), .WIDTH(6)) u_min (
    .clk      (clk),
    .clr      (1'b0),
    .tick     (min_tick),
    .edit_mode(mode_enable[1]),
    .inc      (mode_enable[1] && inc_pulse),
    .dec      (mode_enable[1] && dec_pulse),
    .count    (minutes),
    .borrow_out(min_borrow)
  );

  editable_countdown #(.MAX(23), .WIDTH(5)) u_hour (
    .clk      (clk),
    .clr      (1'b0),
    .tick     (hour_tick),
    .edit_mode(mode_enable[2]),
    .inc      (mode_enable[2] && inc_pulse),
    .dec      (mode_enable[2] && dec_pulse),
    .count    (hours),
    .borrow_out(hour_borrow)
  );

  // Edit mode selector — blocked while running
  logic edit_button;
  assign edit_button = running ? 1'b0 : button[3];

  edit_mode_selector #(
    .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) u_ems (
    .clk        (clk),
    .button     (edit_button),
    .mode_enable(mode_enable)
  );

  // PWM for flashing (2 Hz, 80% duty cycle)
  logic pwm_out;
  pwm_generator #(
    .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),
    .DUTY_CYCLES  (CYCLES_PER_SECOND / 2 * 4 / 5)
  ) u_pwm (
    .clk    (clk),
    .rst    (1'b0),
    .pwm_out(pwm_out)
  );

  assign blank_seconds = mode_enable[0] && !pwm_out;
  assign blank_minutes = mode_enable[1] && !pwm_out;
  assign blank_hours   = mode_enable[2] && !pwm_out;

  assign seconds_disp = 7'(seconds);
  assign minutes_disp = 7'(minutes);
  assign hours_disp   = 7'(hours);
  assign led          = '0;

`ifdef FORMAL
  assign probe_running     = running;
  assign probe_mode_enable = mode_enable;
`endif

endmodule

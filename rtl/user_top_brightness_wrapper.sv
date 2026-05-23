`timescale 1ns / 1ps

// Brightness wrapper: PWM dimming via sw[9:8] grey-code brightness levels

module user_top_brightness_wrapper #(
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

  logic raw_blank_hours;
  logic raw_blank_minutes;
  logic raw_blank_seconds;

  user_top #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_watch (
      .clk          (clk),
      .button       (button),
      .sw           (sw),
      .led          (led),
      .hours_disp   (hours_disp),
      .minutes_disp (minutes_disp),
      .seconds_disp (seconds_disp),
      .blank_hours  (raw_blank_hours),
      .blank_minutes(raw_blank_minutes),
      .blank_seconds(raw_blank_seconds)
  );

  localparam int PWM_PERIOD = CYCLES_PER_SECOND / 1000;
  localparam int DIM_THRESH = PWM_PERIOD / 8;
  localparam int LOW_THRESH = PWM_PERIOD / 4;
  localparam int MED_THRESH = PWM_PERIOD / 2;

  logic [31:0] pwm_cnt;

  mod_n_counter #(
      .N    (PWM_PERIOD),
      .WIDTH(32)
  ) u_pwm (
      .clk   (clk),
      .rst   (1'b0),
      .enable(1'b1),
      .count (pwm_cnt)
  );

  logic display_on;

  always @(*) begin
    case (sw[9:8])
      2'b00:   display_on = (pwm_cnt < DIM_THRESH);
      2'b01:   display_on = (pwm_cnt < LOW_THRESH);
      2'b11:   display_on = (pwm_cnt < MED_THRESH);
      2'b10:   display_on = 1'b1;
      default: display_on = 1'b1;
    endcase
  end

  assign blank_hours   = raw_blank_hours   || !display_on;
  assign blank_minutes = raw_blank_minutes || !display_on;
  assign blank_seconds = raw_blank_seconds || !display_on;

endmodule

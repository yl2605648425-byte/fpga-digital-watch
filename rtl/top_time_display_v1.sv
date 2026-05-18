`timescale 1ns / 1ps

// Variable-speed time display for DE1-SoC board.
// SW[1:0] controls tick rate:
//   2'b00 = 1 Hz, 2'b01 = 25 Hz, 2'b10 = 1 kHz, 2'b11 = 50 MHz

module top_time_display_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input  logic        CLOCK_50,
    input  logic [1:0]  SW,
    output logic [6:0]  HEX5,
    output logic [6:0]  HEX4,
    output logic [6:0]  HEX3,
    output logic [6:0]  HEX2,
    output logic [6:0]  HEX1,
    output logic [6:0]  HEX0
);

  logic [4:0] hours;
  logic [5:0] minutes;
  logic [5:0] seconds;

  logic tick_1hz;
  logic tick_25hz;
  logic tick_1khz;
  logic tick_selected;

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_1hz (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_1hz)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 25)
  ) u_25hz (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_25hz)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND / 1000)
  ) u_1khz (
      .clk (CLOCK_50),
      .run (1'b1),
      .tick(tick_1khz)
  );

  always_comb begin
    unique case (SW)
      2'b00:   tick_selected = tick_1hz;
      2'b01:   tick_selected = tick_25hz;
      2'b10:   tick_selected = tick_1khz;
      2'b11:   tick_selected = 1'b1;
    endcase
  end

  hms_counter u_hms (
      .clk    (CLOCK_50),
      .enable (tick_selected),
      .hours  (hours),
      .minutes(minutes),
      .seconds(seconds)
  );

  logic [3:0] hours_tens,   hours_ones;
  logic [3:0] minutes_tens, minutes_ones;
  logic [3:0] seconds_tens, seconds_ones;

  binary_to_bcd u_bcd_hours (
      .bin ({2'b0, hours}),
      .tens(hours_tens),
      .ones(hours_ones)
  );

  binary_to_bcd u_bcd_minutes (
      .bin ({1'b0, minutes}),
      .tens(minutes_tens),
      .ones(minutes_ones)
  );

  binary_to_bcd u_bcd_seconds (
      .bin ({1'b0, seconds}),
      .tens(seconds_tens),
      .ones(seconds_ones)
  );

  seven_segment u_HEX5 (.digit(hours_tens),   .blank(1'b0), .segments(HEX5));
  seven_segment u_HEX4 (.digit(hours_ones),   .blank(1'b0), .segments(HEX4));
  seven_segment u_HEX3 (.digit(minutes_tens), .blank(1'b0), .segments(HEX3));
  seven_segment u_HEX2 (.digit(minutes_ones), .blank(1'b0), .segments(HEX2));
  seven_segment u_HEX1 (.digit(seconds_tens), .blank(1'b0), .segments(HEX1));
  seven_segment u_HEX0 (.digit(seconds_ones), .blank(1'b0), .segments(HEX0));

endmodule

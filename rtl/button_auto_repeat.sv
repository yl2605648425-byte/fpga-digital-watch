`timescale 1ns / 1ps

// Button auto-repeat module.
// A brief press produces one immediate pulse.
// Holding the button produces a pulse train after HOLD_CYCLES,
// repeating every REPEAT_CYCLES clock edges.

module button_auto_repeat #(
    parameter int HOLD_CYCLES   = 50_000_000,
    parameter int REPEAT_CYCLES = 5_000_000
) (
    input  logic clk,
    input  logic button,
    output logic pulse
);

  logic rise;
  logic held;
  logic pulse_train;

  assign pulse = rise | (held & pulse_train);

  rising_edge_detector u_detector (
      .clk   (clk),
      .sig_in(button),
      .rise  (rise)
  );

  button_hold_detect #(
      .HOLD_CYCLES(HOLD_CYCLES - 1)
  ) u_hold_detect (
      .clk   (clk),
      .button(button),
      .held  (held)
  );

  restartable_rate_generator #(
      .CYCLE_COUNT(REPEAT_CYCLES)
  ) u_rate_gen (
      .clk (clk),
      .run (button),
      .tick(pulse_train)
  );

endmodule

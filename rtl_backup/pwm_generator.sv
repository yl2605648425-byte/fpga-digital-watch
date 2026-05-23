`timescale 1ns / 1ps

// PWM generator with fixed frequency and duty cycle.
// Output is high for DUTY_CYCLES out of every PERIOD_CYCLES clock cycles.
// rst restarts the period from the next rising edge.

module pwm_generator #(
    parameter int PERIOD_CYCLES = 50_000_000,
    parameter int DUTY_CYCLES   = 25_000_000
) (
    input  logic clk,
    input  logic rst,
    output logic pwm_out
);

  localparam int CountWidth = $clog2(PERIOD_CYCLES) + 1;
localparam logic [CountWidth-1:0] DutyCycles = CountWidth'(DUTY_CYCLES);

  logic [CountWidth-1:0] count;

  mod_n_counter #(
      .N    (PERIOD_CYCLES),
      .WIDTH(CountWidth)
  ) u_counter (
      .clk   (clk),
      .rst   (rst),
      .enable(1'b1),
      .count (count)
  );

  assign pwm_out = (count < DutyCycles);

endmodule

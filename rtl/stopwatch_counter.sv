`timescale 1ns / 1ps

// Stopwatch counter: minutes, seconds, centiseconds at 1cs resolution

module stopwatch_counter #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input  logic       clk,
    input  logic       rst,
    input  logic       enable,
    output logic [6:0] minutes,
    output logic [5:0] seconds,
    output logic [6:0] centiseconds
);

  localparam int CYCLES_PER_CS = CYCLES_PER_SECOND / 100;

  logic tick_raw;
  logic tick;

  restartable_rate_generator #(
    .CYCLE_COUNT(CYCLES_PER_CS)
  ) u_rate_gen (
    .clk (clk),
    .run (enable && !rst),
    .tick(tick_raw)
  );

  assign tick = tick_raw && enable && !rst;

  cascade_counter #(
    .N2(100), .W2(7),
    .N1(60),  .W1(6),
    .N0(100), .W0(7)
  ) u_cascade (
    .clk   (clk),
    .rst   (rst),
    .enable(tick),
    .count2(minutes),
    .count1(seconds),
    .count0(centiseconds)
  );

endmodule

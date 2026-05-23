// Rising-edge detector implemented as a Mealy FSM.
//
// Detects a low-to-high transition on sig_in.
// rise is asserted immediately (combinationally) when sig_in goes high
// while the stored previous value is low.
// rise is deasserted as soon as sig_in returns low, or on the next
// rising clock edge after the high was captured.
//
// Ports:
//   clk    - clock input
//   sig_in - signal to monitor for rising edges
//   rise   - high for one combinational instant on each rising edge
`timescale 1ns / 1ps

module rising_edge_detector (
    input  logic clk,
    input  logic sig_in,
    output logic rise
);

  // State: stores the value of sig_in captured at the last rising clock edge
  logic prev;

  always_ff @(posedge clk) prev <= sig_in;

  // Mealy output: depends on both state (prev) and current input (sig_in)
  assign rise = sig_in & ~prev;

endmodule

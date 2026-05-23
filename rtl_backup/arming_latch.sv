`timescale 1ns / 1ps

// Arming latch: a flip-flop with synchronous set and clear.
// disarm (clear) takes priority over arm (set).

module arming_latch (
    input  logic clk,
    input  logic arm,
    input  logic disarm,
    output logic armed
);

  logic armed_reg = 1'b0;
  assign armed = armed_reg;

  always_ff @(posedge clk) begin
    if (disarm) armed_reg <= 1'b0;
    else if (arm) armed_reg <= 1'b1;
  end

endmodule

`timescale 1ns / 1ps

// Up-down counter with synchronous reset, wraps between 0 and MAX

module up_down_counter_rst #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input  logic             clk,
    input  logic             rst,
    input  logic             enable,
    input  logic             up,
    output logic [WIDTH-1:0] count = '0
);

  always_ff @(posedge clk) begin
    if (rst) begin
      count <= '0;
    end else if (enable) begin
      if (up) begin
        count <= (count == WIDTH'(MAX)) ? '0 : count + WIDTH'(1);
      end else begin
        count <= (count == '0) ? WIDTH'(MAX) : count - WIDTH'(1);
      end
    end
  end

endmodule

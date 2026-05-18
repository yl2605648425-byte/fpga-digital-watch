`timescale 1ns / 1ps
module wave_restartable_rate_generator_cycle1;
  reg  clk = 0;
  reg  run = 0;
  wire tick;

  restartable_rate_generator #(
      .CYCLE_COUNT(1)
  ) dut (
      .clk (clk),
      .run (run),
      .tick(tick)
  );

  always #5 clk = ~clk;

  initial begin
    $dumpfile("wave_restartable_rate_generator_cycle1.vcd");
    $dumpvars(0, wave_restartable_rate_generator_cycle1);

    // Test 1: run low, tick should stay low
    #30;

    // Test 2: run goes high, tick should follow run directly (same cycle)
    run = 1;
    #50;

    // Test 3: run goes low, tick should go low immediately
    run = 0;
    #30;

    // Test 4: run goes high again, tick should follow again
    run = 1;
    #30;

    $finish;
  end
endmodule

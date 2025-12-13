module vga_check #(
  parameter H_FRONT_PORCH       = 16,
  parameter HSYNC_PULSE_CYCLES  = 96,
  parameter H_BACK_PORCH        = 48,

  parameter V_FRONT_PORCH       = 8000,
  parameter VSYNC_PULSE_CYCLES  = 1600,
  parameter V_BACK_PORCH        = 26400,

  parameter CLK_GOOD_BITS       = 24
)(
  input  logic clk,
  input  logic hsync,
  input  logic vsync,
  input  logic data,
  output logic clk_good,
  output logic hsync_duration_good,
  output logic h_front_porch_good,
  output logic h_blanking_good,
  output logic vsync_duration_good
);

  logic [CLK_GOOD_BITS-1:0] clk_counter;

  logic hsync_last;
  logic vsync_last;
  logic data_last;

  logic [16:0] blanking_counter;
  logic [6:0]  hsync_counter;   // enough to count up to 96
  logic [10:0] vsync_counter;   // enough to count up to 1600

  assign clk_good = clk_counter[CLK_GOOD_BITS-1];

  // Simple free-running clock counter
  always_ff @(posedge clk) begin
    clk_counter <= clk_counter + 1'b1;
  end

  always_ff @(posedge clk) begin
    // Register previous values
    hsync_last <= hsync;
    vsync_last <= vsync;
    data_last  <= data;

    // Blanking counter: counts while data == 0
    if (data == 1'b0)
      blanking_counter <= blanking_counter + 17'd1;
    else
      blanking_counter <= 17'd0;

    // HSYNC pulse width counter
    if (hsync == 1'b0)
      hsync_counter <= hsync_counter + 7'd1;
    else
      hsync_counter <= 7'd0;

    // VSYNC pulse width counter
    if (vsync == 1'b0)
      vsync_counter <= vsync_counter + 11'd1;
    else
      vsync_counter <= 11'd0;

    // Check horizontal front porch: rising edge of hsync going low->high blanking before it
    if (hsync_last == 1'b1 && hsync == 1'b0) begin
      h_front_porch_good <= (blanking_counter == H_FRONT_PORCH);
    end

    // Check HSYNC duration: rising edge of hsync (0->1)
    if (hsync_last == 1'b0 && hsync == 1'b1) begin
      hsync_duration_good <= (hsync_counter == HSYNC_PULSE_CYCLES);
    end

    // Check total horizontal blanking: data 0->1
    if (data_last == 1'b0 && data == 1'b1) begin
      h_blanking_good <= (blanking_counter ==
                          (H_FRONT_PORCH + HSYNC_PULSE_CYCLES + H_BACK_PORCH));
    end

    // Check VSYNC duration: vsync 0->1
    if (vsync_last == 1'b0 && vsync == 1'b1) begin
      vsync_duration_good <= (vsync_counter == VSYNC_PULSE_CYCLES);
    end
  end

endmodule

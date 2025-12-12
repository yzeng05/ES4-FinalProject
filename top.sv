module top(
  input  wire ref_clk_i,
  input  wire kick_hit_i,
  input  wire snare_hit_i,
  input  wire hat_hit_i,
  output wire hsync_o,
  output wire vsync_o,
  output wire [5:0] rgb_o,
  output wire pll
);

  // PLL
  wire pllclk;

  mypll mypll_inst(
    .ref_clk_i(ref_clk_i),
    .rst_n_i(1'b1),
    .outglobal_o(pllclk)
  );

  assign pll = pllclk;

  // VGA timing
  wire [9:0] col, row;
  wire vis;

  vga u_vga(
    .clk(pllclk),
    .hsync(hsync_o),
    .vsync(vsync_o),
    .col(col),
    .row(row),
    .visible(vis)
  );

  // Timer display
  logic [5:0] timer_seconds;
  logic timer_enable;

  assign timer_enable = 1'b1;

  timer u_timer(
    .clk(pllclk),
    .reset(1'b0),
    .enable(timer_enable),
    .seconds(timer_seconds)
  );

  // Pattern generator
  pattern_gen u_pat(
    .clk(pllclk),
    .row(row),
    .col(col),
    .visible(vis),
    .kick_hit(kick_hit_i),
    .snare_hit(snare_hit_i),
    .hat_hit(hat_hit_i),
    .timer_seconds(timer_seconds),
    .rgb(rgb_o)
  );

endmodule

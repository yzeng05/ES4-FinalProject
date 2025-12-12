module vga #(
  parameter H_VISIBLE = 640,
  parameter H_FP      = 16,
  parameter H_SYNC    = 96,
  parameter H_BP      = 48,
  parameter H_TOTAL   = 640 + 16 + 96 + 48,

  parameter V_VISIBLE = 480,
  parameter V_FP      = 10,
  parameter V_SYNC    = 2,
  parameter V_BP      = 33,
  parameter V_TOTAL   = 480 + 10 + 2 + 33
)(
  input  wire        clk,
  output logic       hsync,
  output logic       vsync,
  output logic [9:0] col,
  output logic [9:0] row,
  output logic       visible
);

  // Horizontal and vertical counters
  logic [9:0] hcnt = 10'd0;
  logic [9:0] vcnt = 10'd0;

  // Timing counters
  always_ff @(posedge clk) begin
    if (hcnt == H_TOTAL - 1) begin
      hcnt <= 10'd0;
      if (vcnt == V_TOTAL - 1)
        vcnt <= 10'd0;
      else
        vcnt <= vcnt + 10'd1;
    end else begin
      hcnt <= hcnt + 10'd1;
    end
  end

  // Visible area
  assign visible = (hcnt < H_VISIBLE) && (vcnt < V_VISIBLE);

  // Current pixel coordinates
  assign col = hcnt;
  assign row = vcnt;

  // Active-low syncs
  assign hsync = ((hcnt >= H_VISIBLE + H_FP) &&
                  (hcnt <  H_VISIBLE + H_FP + H_SYNC)) ? 1'b0 : 1'b1;

  assign vsync = ((vcnt >= V_VISIBLE + V_FP) &&
                  (vcnt <  V_VISIBLE + V_FP + V_SYNC)) ? 1'b0 : 1'b1;

endmodule

module pattern_gen(
  input  logic        clk,
  input  logic [9:0]  row,
  input  logic [9:0]  col,
  input  logic        visible,
  input  logic        kick_hit,
  input  logic        snare_hit,
  input  logic        hat_hit,
  input  logic [5:0]  timer_seconds,  //NEW CODE
  output logic [5:0]  rgb
);

  // Drum positions and radii
  localparam KICK_X = 10'd220;
  localparam KICK_Y = 10'd320;
  localparam KICK_R = 10'd50;

  localparam SNARE_X = 10'd360;
  localparam SNARE_Y = 10'd300;
  localparam SNARE_R = 10'd40;

  localparam HAT_X = 10'd320;
  localparam HAT_Y = 10'd200;
  localparam HAT_R = 10'd30;

  // Flash timers (count down after a hit) to brighten and nudge shapes
  logic [4:0] kick_flash, snare_flash, hat_flash;

  always_ff @(posedge clk) begin
    if (kick_hit)       kick_flash  <= 5'd24;
    else if (kick_flash) kick_flash <= kick_flash - 5'd1;

    if (snare_hit)        snare_flash <= 5'd24;
    else if (snare_flash) snare_flash <= snare_flash - 5'd1;

    if (hat_hit)        hat_flash <= 5'd24;
    else if (hat_flash) hat_flash <= hat_flash - 5'd1;
  end

  // Simple circle check for drum shapes
  function automatic logic in_circle(
    input [9:0] x,
    input [9:0] y,
    input int   cx,
    input int   cy,
    input int   r
  );
    in_circle = ((x - cx)*(x - cx) + (y - cy)*(y - cy)) <= (r*r);
  endfunction


  // Draw numbers for timer
  //NEW CODE
  function automatic logic draw_digit(
    input [9:0] x,
    input [9:0] y,
    input int   digit_x,
    input int   digit_y,
    input [3:0] digit
  );
    int dx, dy;
    logic [34:0] digit_bitmap;

    dx = x - digit_x;
    dy = y - digit_y;

    case (digit)
      4'd0: digit_bitmap = 35'b01110_10001_10011_10101_11001_10001_01110;
      4'd1: digit_bitmap = 35'b00100_01100_00100_00100_00100_00100_01110;
      4'd2: digit_bitmap = 35'b01110_10001_00001_00010_00100_01000_11111;
      4'd3: digit_bitmap = 35'b11111_00010_00100_00010_00001_10001_01110;
      4'd4: digit_bitmap = 35'b00010_00110_01010_10010_11111_00010_00010;
      4'd5: digit_bitmap = 35'b11111_10000_11110_00001_00001_10001_01110;
      4'd6: digit_bitmap = 35'b00110_01000_10000_11110_10001_10001_01110;
      4'd7: digit_bitmap = 35'b11111_00001_00010_00100_01000_01000_01000;
      4'd8: digit_bitmap = 35'b01110_10001_10001_01110_10001_10001_01110;
      4'd9: digit_bitmap = 35'b01110_10001_10001_01111_00001_00010_01100;
      default: digit_bitmap = 35'b0;
    endcase

    if (dx >= 0 && dx < 5 && dy >= 0 && dy < 7) begin
      draw_digit = digit_bitmap[dy * 5 + dx];
    end else begin
      draw_digit = 0;
    end
  endfunction


  //Display timer logic
  //NEW CODE

  logic timer_pixel;
  logic [3:0] tens_digit, ones_digit;
  
  assign tens_digit = (timer_seconds / 10) % 10;
  assign ones_digit = timer_seconds % 10;

  always_comb begin
    timer_pixel = 0;
    
    // Timer at top right: "00:SS"
    if (draw_digit(col, row, 580, 10, 4'd0)) timer_pixel = 1;
    if (draw_digit(col, row, 586, 10, 4'd0)) timer_pixel = 1;
    if ((col == 593 || col == 594) && (row == 13 || row == 16)) timer_pixel = 1;
    if (draw_digit(col, row, 597, 10, tens_digit)) timer_pixel = 1;
    if (draw_digit(col, row, 603, 10, ones_digit)) timer_pixel = 1;
  end





  always_comb begin
    // white background by default
    rgb = 6'b111111;

    if (visible) begin
      rgb = 6'b111111; // white background

      // Kick: orange, jumps slightly up when flashing
      if (in_circle(col, row, KICK_X, KICK_Y - (kick_flash ? 3 : 0), KICK_R)) begin
        rgb = kick_flash ? 6'b111100 : 6'b011100;

      // Snare: white, nudges up when flashing
      end else if (in_circle(col, row, SNARE_X, SNARE_Y - (snare_flash ? 2 : 0), SNARE_R)) begin
        rgb = snare_flash ? 6'b111111 : 6'b011111;

      // Hi-hat: yellow-green, hops when flashing
      end else if (in_circle(col, row, HAT_X, HAT_Y - (hat_flash ? 4 : 0), HAT_R)) begin
        rgb = hat_flash ? 6'b110110 : 6'b010110;
      end

      // Draw timer in black
      //NEW CODE
      if (timer_pixel) begin
        rgb = 6'b000000;
      end
    end
  end
endmodule

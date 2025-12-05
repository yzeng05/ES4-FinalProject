module top (
    input  logic btn_rec,
    input  logic btn_play,
    output logic led_rec,
    output logic led_play
);

    logic clk;
    
    // Instantiate the internal oscillator
    SB_HFOSC #(.CLKHF_DIV("0b10")) osc_inst (
        .CLKHFPU(1'b1),
        .CLKHFEN(1'b1),
        .CLKHF(clk)
    );
    
    // Reset generation
    logic [3:0] rst_counter = 4'b0;
    logic rst;
    
    always_ff @(posedge clk) begin
        if (rst_counter != 4'hF)
            rst_counter <= rst_counter + 1;
    end
    
    assign rst = (rst_counter != 4'hF);
    
    // Edge detection
    logic rec_prev = 1'b0, play_prev = 1'b0;
    logic rec_mode, play_mode;
    
    always_ff @(posedge clk) begin
        if (rst) begin
            rec_prev  <= 1'b0;
            play_prev <= 1'b0;
        end else begin
            rec_prev  <= btn_rec;
            play_prev <= btn_play;
        end
    end
    
    assign rec_mode  = btn_rec  & ~rec_prev;
    assign play_mode = btn_play & ~play_prev;
    
    logic rec_en, play_en;
    
    loop_fsm fsm_inst (
        .clk       (clk),
        .rst       (rst),
        .rec_mode  (rec_mode),
        .play_mode (play_mode),
        .rec_en    (rec_en),
        .play_en   (play_en),
        .led_rec   (led_rec),
        .led_play  (led_play)
    );

endmodule

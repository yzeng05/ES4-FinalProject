module top (
    output logic out1, 
    input  logic btn_rec,    // raw record button
    input  logic btn_play,   // raw play/pause button
    output logic led_rec,    // turn on when in RECORDING state
    output logic led_play    // turn on when in PLAYING state
);

    logic clk;


    logic rec_prev = 1'b0, play_prev = 1'b0;     // previous values
    logic rec_mode, play_mode;   // rising edges

    always_ff @(posedge clk) begin
        rec_prev  <= btn_rec;
        play_prev <= btn_play;
    end

    assign rec_mode  =  btn_rec  & ~rec_prev;   // rising edge
    assign play_mode =  btn_play & ~play_prev;  // rising edge



    logic rec_en, play_en; // not used yet, but FSM outputs them

    loop_fsm fsm_inst (
        .clk        (clk),
        .rec_mode  (rec_mode),
        .play_mode (play_mode),
        .rec_en     (rec_en),
        .play_en    (play_en),
        .led_rec    (led_rec),
        .led_play   (led_play)
    );


endmodule

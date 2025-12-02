module loop_fsm (
    input  logic clk,
    input  logic rec_mode,    // 1-cycle when RECORD button is pressed
    input  logic play_mode,   // 1-cycle when PLAY/PAUSE button is pressed

    output logic rec_en,       // high while in RECORD state
    output logic play_en,      // high while in PLAY state
    // for testing on LEDs:
    output logic led_rec,      // light when recording
    output logic led_play      // light when playing
);

typedef enum logic [1:0] {
    S_IDLE = 2'b00,
    S_REC = 2'b01,
    S_PLAY = 2'b10
} state_t;

state_t state, next_state;

always_ff@(posedge clk) begin
    state <= next_state;
end

always_comb begin
    next_state = state;

    case(state)
        S_IDLE: begin
            if(rec_mode)
                next_state = S_REC;
        end

        S_REC: begin
            if(rec_mode)
                next_state = S_REC;
            else if (play_mode)
                next_state = S_PLAY;
        end

        S_PLAY: begin
            if(play_mode)
                next_state = S_IDLE; //pause
            else if (rec_mode)
                next_state = S_REC;
        end

        default: next_state = S_IDLE;
    endcase
end

always_comb begin
    rec_en  = (state == S_REC);
    play_en = (state == S_PLAY);

    led_rec  = (state == S_REC);
    led_play = (state == S_PLAY);
end

endmodule




        


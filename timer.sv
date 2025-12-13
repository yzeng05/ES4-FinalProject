module timer(
    input  logic       clk,
    input  logic       reset,
    input  logic       enable,
    output logic [5:0] seconds
);

    // Adjust to your actual clock frequency
    localparam int CYCLES_PER_SECOND = 25_000_000;

    // 25 bits is enough for values up to 33,554,431 (> 25,000,000)
    logic [24:0] cycle_counter;

    always_ff @(posedge clk) begin
        if (reset) begin
            cycle_counter <= 25'd0;
            seconds       <= 6'd0;
        end else if (enable) begin
            if (cycle_counter == CYCLES_PER_SECOND - 1) begin
                cycle_counter <= 25'd0;
                seconds       <= seconds + 6'd1;  // will roll over after 63
            end else begin
                cycle_counter <= cycle_counter + 25'd1;
            end
        end
    end

endmodule







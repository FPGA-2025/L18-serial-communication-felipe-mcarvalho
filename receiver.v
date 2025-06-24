module receiver (
    input        clk,
    input        rstn,
    output reg   ready,
    output reg [6:0] data_out,
    output reg   parity_ok_n,  
    input        serial_in
);
    reg [6:0] shift_reg;
    reg [3:0] bit_cnt;
    reg       parity_calc;
    reg       serial_d;        

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            serial_d    <= 1'b1;
            bit_cnt     <= 4'd0;
            shift_reg   <= 7'd0;
            parity_calc <= 1'b0;
            ready       <= 1'b0;
            data_out    <= 7'd0;
            parity_ok_n <= 1'b1;
        end else begin
            serial_d <= serial_in;

            if (bit_cnt == 4'd0) begin
                ready <= 1'b0;
                if (serial_d == 1'b1 && serial_in == 1'b0) begin
                    bit_cnt     <= 4'd1;
                    parity_calc <= 1'b0;
                end
            end
            else begin
                if (bit_cnt <= 4'd7) begin
                    shift_reg[bit_cnt-1] <= serial_in;
                    parity_calc <= (bit_cnt == 4'd1)
                                  ? serial_in
                                  : parity_calc ^ serial_in;
                    bit_cnt <= bit_cnt + 4'd1;
                end
                else if (bit_cnt == 4'd8) begin
                    parity_ok_n <= parity_calc ^ serial_in;
                    data_out    <= shift_reg;
                    ready       <= 1'b1;
                    bit_cnt     <= 4'd0;  
                end
            end
        end
    end

endmodule

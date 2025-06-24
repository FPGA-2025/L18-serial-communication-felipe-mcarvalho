module transmitter (
    input clk,
    input rstn,
    input start,
    input [6:0] data_in,
    output reg serial_out
);

localparam STATE_IDLE       = 3'b000; 
localparam STATE_START_BIT  = 3'b001; 
localparam STATE_DATA_BITS  = 3'b010; 
localparam STATE_PARITY_BIT = 3'b011; 
localparam STATE_STOP_BIT   = 3'b100; 

reg [2:0] state = STATE_IDLE;       
reg [6:0] data_reg;                 
reg [2:0] bit_count;                
reg parity_bit;                     


always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        state <= STATE_IDLE;
        serial_out <= 1'b1;
        bit_count <= 3'b0;
    end else begin
        case (state)
            STATE_IDLE: begin
                serial_out <= 1'b1; 
                if (start) begin
                    data_reg <= data_in; 
                    parity_bit <= ^data_in; 
                    state <= STATE_START_BIT;
                end
            end
            
            STATE_START_BIT: begin
                serial_out <= 1'b0; 
                bit_count <= 3'b0; 
                state <= STATE_DATA_BITS;
            end
            
            STATE_DATA_BITS: begin
                serial_out <= data_reg[bit_count];
                if (bit_count == 3'd6) begin 
                    state <= STATE_PARITY_BIT;
                end else begin
                    bit_count <= bit_count + 1;
                end
            end
            
            STATE_PARITY_BIT: begin
                serial_out <= parity_bit; 
                state <= STATE_STOP_BIT;
            end
            
            STATE_STOP_BIT: begin
                serial_out <= 1'b1; 
                state <= STATE_IDLE; 
            end
            
            default: begin
                state <= STATE_IDLE;
                serial_out <= 1'b1;
            end
        endcase
    end
end

endmodule
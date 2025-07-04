`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Krishna Gupta
// Module Name: spi_state
// Project Name: SPI Protocol & Interfacing
//////////////////////////////////////////////////////////////////////////////////

module spi_state(
    input wire clk,             // Clock input
    input wire rst,             // Asynchronous Reset
    input wire [15:0] datain,   // 16-bit input data to transmit over SPI
    output wire spi_cs_l,       // SPI Chip Select (active low)
    output wire spi_sclk,       // SPI Clock output
    output wire spi_data,       // SPI Data output (MOSI)
    output [4:0] counter        // Output current bit counter value
    );

    reg [15:0] MOSI;            // Shift register for outputting bits
    reg [4:0] count;            // 5-bit counter to track transmission progress
    reg cs_l;                   // Internal Chip Select signal
    reg sclk;                   // Internal SPI Clock signal
    reg [2:0] state;            // State variable for FSM

    // State Machine - triggered on rising edge of clock or asynchronous reset
    always @(posedge clk or posedge rst)
        if (rst) begin
            MOSI <= 16'b0;      // Clear shift register
            count <= 5'd16;     // Set counter to 16 (for 16-bit transmission)
            cs_l <= 1'b1;       // Deactivate chip select
            sclk <= 1'b0;       // Set SPI clock low
            state <= 3'd0;      // Go to initial state
        end
        else begin
            case(state)
                0: begin
                    // Idle/Setup state
                    sclk <= 1'b0;   // Keep clock low
                    cs_l <= 1'b1;   // Chip select inactive
                    state <= 1;     // Move to data preparation state
                end
                
                1: begin
                    // Load the next bit and assert CS
                    sclk <= 1'b0;       // Keep clock low before rising
                    cs_l <= 1'b0;       // Activate chip select
                    MOSI <= datain;     // Load the full 16-bit input data
                    count <= 5'd15;     // Start from MSB (bit 15)
                    state <= 2;         // Move to transmission state
                end
                
                2: begin
                    sclk <= 1'b1;       // Generate clock pulse high

                    if (count > 0) begin
                        // Shift left and continue
                        MOSI <= {MOSI[14:0], 1'b0};  // Shift MOSI left
                        count <= count - 1;          // Decrease count
                        state <= 2;                  // Continue transmitting
                        sclk <= 1'b0;                // Toggle clock
                    end
                    else begin
                        // Transmission complete
                        count <= 5'd16;  // Reset count for next transmission
                        cs_l <= 1'b1;    // Deactivate chip select
                        state <= 0;      // Go back to idle
                        sclk <= 1'b0;    // Reset clock
                    end
                end

                default: state <= 0;    // Default to idle state
            endcase
        end

    // Output assignments
    assign spi_cs_l = cs_l;         // Chip select output
    assign spi_sclk = sclk;         // SPI clock output
    assign spi_data = MOSI[15];     // Send the MSB first (bit 15 of shift register)
    assign counter = count;         // Output current bit count

endmodule

// -------------------- Testbench ------------------------

module spi_state_tb;

    reg clk, rst;
    reg [15:0] datain;

    wire spi_cs_l, spi_sclk, spi_data;
    wire [4:0] counter;

    // Instantiate the SPI module
    spi_state uut(
        .clk(clk),
        .rst(rst),
        .datain(datain),
        .spi_cs_l(spi_cs_l),
        .spi_sclk(spi_sclk),
        .spi_data(spi_data),
        .counter(counter)
    );

    // Clock generation: toggles every 5ns -> 10ns clock period
    always #5 clk = ~clk;

    initial begin
        // Initialize values
        clk = 0;
        rst = 1;
        datain = 0;

        // Apply reset
        #10 rst = 0;

        // Provide different input data
        #10 datain = 16'hA569;
        #335 datain = 16'h2563;
        #335 datain = 16'h9B63;
        #335 datain = 16'h6A61;  // Fixed syntax error: 16h6A61 -> 16'h6A61

        #500 $finish;
    end

endmodule
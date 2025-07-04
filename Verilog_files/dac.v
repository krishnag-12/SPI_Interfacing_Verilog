`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Krishna Gupta
// Module Name: DAC
// Project Name: SPI Protocol & Interfacing
//////////////////////////////////////////////////////////////////////////////////


module DAC(
    input clk,                // System clock input
    input rst,                // Asynchronous reset
    input spi_miso,           // SPI MISO (not used here for DAC, but included for compatibility)
    input [11:0] data,        // 12-bit data to be sent to DAC
    input [3:0] address,      // 4-bit DAC channel address (A, B, C, D)

    output reg send,          // Signal to indicate data send completion
    output reg dac_cs,        // Chip select for DAC (active-low)
    output reg spi_sck,       // SPI clock output
    output reg spi_mosi,      // SPI data output
    output reg dac_clr,       // DAC clear signal (active-low)

    output reg [3:0] command, // DAC command (typically 4'b0011 for write and update)

    // Disable these peripherals to free SPI bus for DAC
    output SPI_SS_B,          // SPI Flash select (disable = 1)
    output AMP_CS,            // Amplifier chip select (disable = 1)
    output AD_CONV,           // ADC conversion trigger (not used here)
    output SF_CE0,            // StrataFlash enable (disable = 1)
    output FPGA_INIT_B        // Platform Flash (keep initialized = 1)
);

    // State register for DAC communication FSM
    reg [2:0] dac_state;

    // SPI data register: 32 bits total (includes padding, command, address, data)
    reg [31:0] dac_out;

    // Bit counter for shifting out 32 bits
    reg [5:0] count = 32;

    // Disable unused SPI peripherals
    assign SPI_SS_B = 1;
    assign AMP_CS = 1;
    assign AD_CONV = 0;
    assign SF_CE0 = 1;
    assign FPGA_INIT_B = 1;

    // FSM to control SPI data transmission to DAC
    always @(posedge clk or posedge rst) begin
        if (rst == 1) begin
            // Reset all outputs and FSM
            dac_cs     <= 1;
            spi_sck    <= 0;
            spi_mosi   <= 0;
            dac_clr    <= 1;
            send       <= 0;
            dac_state  <= 0;
            count      <= 32;
        end
        else begin
            case (dac_state)
                0: begin
                    // Initialization state
                    dac_cs     <= 1;
                    spi_sck    <= 0;
                    spi_mosi   <= 0;
                    dac_clr    <= 1;
                    send       <= 0;
                    dac_state  <= 1;
                end

                1: begin
                    // Load the 32-bit DAC input format:
                    // [8'b0 (don't care), 4-bit command, 4-bit address, 12-bit data, 4'b0 (padding)]
                    dac_out <= {8'b00000000, 4'b0011, address, data, 4'b0000};
                    command <= 4'b0011; // set command output too
                    dac_state <= 2;
                end

                2: begin
                    // Start SPI transmission
                    dac_cs     <= 0;                          // Enable DAC
                    spi_sck    <= 0;                          // Set SPI clock low
                    spi_mosi   <= dac_out[count - 1];         // Send MSB first
                    count      <= count - 1;
                    dac_state  <= 3;
                end

                3: begin
                    if (count > 0) begin
                        // Toggle clock and continue shifting
                        spi_sck   <= 1;
                        dac_state <= 2;  // Go back to send next bit
                    end
                    else begin
                        // Transmission complete
                        spi_sck   <= 1;
                        dac_state <= 4;
                    end
                end

                4: begin
                    // Post-transmission cleanup
                    spi_sck   <= 0;
                    dac_state <= 5;
                end

                5: begin
                    dac_cs    <= 1;  // Deactivate DAC chip select
                    dac_state <= 6;
                end

                6: begin
                    send      <= 1;  // Indicate successful transmission
                    dac_state <= 7;
                end

                7: begin
                    send      <= 0;
                    count     <= 32; // Reset bit counter
                    dac_state <= 1;  // Ready for next transmission
                end

                default: begin
                    // Failsafe reset
                    dac_cs     <= 1;
                    spi_mosi   <= 0;
                    dac_clr    <= 1;
                    send       <= 0;
                    dac_state  <= 0;
                    count      <= 32;
                end
            endcase
        end
    end
endmodule
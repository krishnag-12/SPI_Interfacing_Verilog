`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Krishna Gupta
// Module Name: adc
// Project Name: SPI Protocol & Interfacing
//////////////////////////////////////////////////////////////////////////////////


module adc(
    input clk,               // System clock (50 MHz)
    input enable,            // Active-high enable signal to reset/start process
    input spi_miso,          // SPI Master In Slave Out (data from ADC)

    output clkout,           // Divided clock output (~2 MHz)
    output a1, a2,           // Output signals to observe amp_cs and adc_conv
    output spi_ss_b,         // SPI Flash disable (active-low)
    output sf_ce0,           // Disable parallel flash
    output fpga_init_b,      // Platform flash init signal
    output dac_cs,           // DAC chip select disable
    output reg spi_sck,      // SPI clock output
    output reg amp_cs,       // Amplifier chip select
    output reg adc_conv,     // ADC conversion start signal
    output reg spi_mosi,     // SPI Master Out Slave In (gain config)
    output reg amp_shdn,     // Amplifier shutdown control

    output reg [13:0] adc_data1,  // First ADC channel data (14-bit)
    output reg [13:0] adc_data2,  // Second ADC channel data (14-bit)
    output [15:0] adc_data        // Combined output (for observation)
);

    reg adc_sent = 0;

    reg [2:0] cnt = 0;               // Delay counter for wait states
    reg [3:0] clk_10_count = 0;      // Placeholder (not used in this code)
    reg [6:0] adc_clk_count = 0;     // Counts total SPI clock edges for ADC read
    reg [5:0] adc_bit_count = 17;    // Bit counter for SPI data shift
    reg [3:0] gain_count = 8;        // Counter for 8-bit gain config
    reg [4:0] pos_count, neg_count;  // Clock division counters

    reg [7:0] data_gain = 8'b00010001;  // Initial gain setting for amplifier
    reg [5:0] state = 6'b000000;        // FSM state

    // Disable other peripherals on shared SPI bus
    assign spi_ss_b = 0;       // Disable serial flash
    assign sf_ce0 = 1;         // Disable parallel flash
    assign fpga_init_b = 1;    // Normal operation
    assign dac_cs = 1;         // Disable DAC

    // Generate clkout by dividing 50MHz system clock by 25 => ~2 MHz
    always @(posedge clk or posedge enable) begin
        if (enable)
            pos_count <= 0;
        else if (pos_count == 24)
            pos_count <= 0;
        else
            pos_count <= pos_count + 1;
    end

    always @(negedge clk or posedge enable) begin
        if (enable)
            neg_count <= 0;
        else if (neg_count == 24)
            neg_count <= 0;
        else
            neg_count <= neg_count + 1;
    end

    // Clock output toggled when counter is over half of 25
    assign clkout = ((pos_count > (25 >> 1)) | (neg_count > (25 >> 1)));

    // Export internal signals for debug
    assign a1 = amp_cs;
    assign a2 = adc_conv;
    assign adc_data = {2'b00, adc_data1};  // Exporting only one ADC channel

    // Main FSM that runs on divided clkout
    always @(posedge clkout or posedge enable) begin
        if (enable) begin
            // Reset and initialize all outputs
            spi_sck <= 0;
            amp_shdn <= 0;
            adc_conv <= 0;
            amp_cs <= 1;
            spi_mosi <= 0;
            state <= 1;
        end else begin
            case (state)
                1: state <= 2;

                2: begin
                    spi_sck <= 0;
                    amp_cs <= 0;       // Enable amplifier
                    state <= 3;
                end

                3: begin
                    spi_sck <= 0;
                    state <= 4;
                end

                // Gain setting using SPI to amplifier
                4: begin
                    spi_sck <= 0;
                    amp_shdn <= 0;
                    amp_cs <= 0;
                    spi_mosi <= data_gain[gain_count - 1];
                    gain_count <= gain_count - 1;
                    state <= 5;
                end

                5: begin
                    amp_cs <= 0;
                    spi_sck <= 1;
                    if (gain_count > 0)
                        state <= 6;
                    else begin
                        spi_sck <= 1;
                        amp_shdn <= 0;
                        amp_cs <= 0;
                        gain_count <= 8;
                        state <= 7;
                    end
                end

                6: begin
                    spi_sck <= 1;
                    state <= 3;   // Loop back for next bit
                end

                // Short delay after gain setting
                7: begin spi_sck <= 1; state <= 8; end
                8: begin spi_sck <= 0; state <= 9; end
                9: begin spi_sck <= 0; state <= 10; end

                10: begin
                    if (cnt > 5) begin
                        spi_sck <= 0;
                        cnt <= 0;
                        state <= 11;
                    end else begin
                        cnt <= cnt + 1;
                        spi_sck <= 0;
                    end
                end

                // Gain setup done, begin ADC conversion
                11: begin amp_cs <= 1; spi_sck <= 0; state <= 12; end
                12: begin spi_sck <= 0; state <= 13; end
                13: begin spi_sck <= 1; state <= 14; end
                14: begin spi_sck <= 1; state <= 15; end
                15: begin spi_sck <= 0; state <= 30; end

                30: begin spi_sck <= 0; state <= 16; end

                // ADC conversion control
                16: begin adc_conv <= 1; spi_sck <= 0; state <= 17; end
                17: begin spi_sck <= 0; state <= 18; end
                18: begin adc_conv <= 0; spi_sck <= 0; state <= 19; end

                // Wait for ADC to complete conversion
                19: begin
                    if (cnt > 3) begin
                        spi_sck <= 0;
                        cnt <= 0;
                        state <= 20;
                    end else begin
                        cnt <= cnt + 1;
                        state <= 19;
                    end
                end

                // SPI read from ADC
                20: begin spi_sck <= 0; state <= 21; end
                21: begin
                    spi_sck <= 0;
                    adc_conv <= 0;
                    adc_clk_count <= adc_clk_count + 1;
                    adc_bit_count <= adc_bit_count - 1;
                    state <= 22;
                end
                22: begin spi_sck <= 1; state <= 23; end

                // Read data bits from ADC using SPI
                23: begin
                    spi_sck <= 1;
                    if (adc_clk_count == 34) begin
                        adc_sent <= 1;
                        state <= 24;
                    end else if (adc_clk_count <= 2) begin
                        state <= 20;
                    end else if ((adc_clk_count > 2) && (adc_clk_count <= 16)) begin
                        adc_data1[adc_bit_count - 1] <= spi_miso;
                        state <= 20;
                    end else if ((adc_clk_count > 16) && (adc_clk_count <= 18)) begin
                        adc_bit_count <= 15;
                        state <= 20;
                    end else if ((adc_clk_count > 18) && (adc_clk_count <= 32)) begin
                        adc_data2[adc_bit_count - 1] <= spi_miso;
                        state <= 20;
                    end else if (adc_clk_count == 33) begin
                        state <= 20;
                    end
                end

                // Reset after data reception
                24: begin
                    adc_clk_count <= 0;
                    adc_bit_count <= 17;
                    spi_sck <= 0;
                    state <= 25;
                end
                25: begin spi_sck <= 0; adc_sent <= 0; state <= 26; end
                26: begin spi_sck <= 1; amp_shdn <= 0; state <= 27; end
                27: begin spi_sck <= 1; state <= 28; end

                // Delay before restarting
                28: begin
                    if (cnt > 4) begin
                        spi_sck <= 0;
                        state <= 16;
                        cnt <= 0;
                    end else begin
                        cnt <= cnt + 1;
                        spi_sck <= 0;
                        state <= 18;
                    end
                end
            endcase
        end
    end
endmodule
module top_vga (
    input  wire CLOCK_50,
    input  wire [0:0] KEY,
    output wire VGA_HS,
    output wire VGA_VS,
    output wire VGA_CLK,
    output wire VGA_BLANK_N,
    output wire VGA_SYNC_N,
    output reg  [7:0] VGA_R,
    output reg  [7:0] VGA_G,
    output reg  [7:0] VGA_B
);

    wire clk_25mhz;
    wire video_on;
    wire [9:0] pixel_x;
    wire [9:0] pixel_y;
    wire reset = ~KEY[0]; 

    assign VGA_CLK = clk_25mhz;
    assign VGA_BLANK_N = video_on;
    assign VGA_SYNC_N = 1'b0;

    vga_pll meu_pll (
        .inclk0(CLOCK_50),
        .c0(clk_25mhz)
    );

    vga_sync controlador_de_varredura (
        .clk(clk_25mhz),
        .rst(reset),       // <-- Atualizado: Conectando o reset virtual ao reset do controlador
        .hsync(VGA_HS),
        .vsync(VGA_VS),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .video_on(video_on)
    );
		
		// Quadrado verde com fundo cinza
    always @(*) begin
        if (video_on == 1'b0) begin
            VGA_R = 8'd0; VGA_G = 8'd0; VGA_B = 8'd0;
        end
        else begin
            if (pixel_x >= 305 && pixel_x <= 335 && pixel_y >= 225 && pixel_y <= 255) begin
                VGA_R = 8'd0; VGA_G = 8'd255; VGA_B = 8'd0;
            end
            else begin
                VGA_R = 8'd128; VGA_G = 8'd128; VGA_B = 8'd128;
            end
        end
    end

endmodule
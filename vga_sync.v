module vga_sync (
    input wire clk,
    input wire rst,           // O reset está aqui!
    output reg hsync,
    output reg vsync,
    output reg [9:0] pixel_x,
    output reg [9:0] pixel_y,
    output reg video_on
);

    parameter H_ACTIVE = 640, H_FRONT = 16, H_SYNC = 96, H_BACK = 48, H_TOTAL = 800;
    parameter V_ACTIVE = 480, V_FRONT = 10, V_SYNC = 2,  V_BACK = 33, V_TOTAL = 525;

    reg [9:0] h_count, v_count;

    always @(posedge clk or posedge rst) begin
        if (rst) h_count <= 0;
        else if (h_count == H_TOTAL - 1) h_count <= 0;
        else h_count <= h_count + 1;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) v_count <= 0;
        else if (h_count == H_TOTAL - 1) begin
            if (v_count == V_TOTAL - 1) v_count <= 0;
            else v_count <= v_count + 1;
        end
    end

    always @(*) begin
        hsync = (h_count >= (H_ACTIVE + H_FRONT) && h_count < (H_ACTIVE + H_FRONT + H_SYNC)) ? 0 : 1;
        vsync = (v_count >= (V_ACTIVE + V_FRONT) && v_count < (V_ACTIVE + V_FRONT + V_SYNC)) ? 0 : 1;
        video_on = (h_count < H_ACTIVE && v_count < V_ACTIVE);
        pixel_x = h_count;
        pixel_y = v_count;
    end

endmodule
const std = @import("std");

const raylib = @cImport({
    @cInclude("raylib.h");
});

const WINDOW_WIDTH = 800;
const WIDTH_PADDING = 50;
const WINDOW_HEIGHT = 600;
const HEIGHT_PADDING = 50;
const FPS = 144;
const SPEED = 1;
const NUM_TARGETS = 20;
const TARGET_WIDTH = 100;
const TARGET_HEIGHT = 20;
const TARGET_WIDTH_PADDING = 10;
const TARGET_HEIGHT_PADDING = 10;

const Target = struct {
    x: f32,
    y: f32,
    destroyed: bool,

    pub fn make_targets() [NUM_TARGETS]Target {
        var targets: [NUM_TARGETS]Target = undefined;

        const targets_per_row: u32 = (WINDOW_WIDTH - 2 * WIDTH_PADDING) / (TARGET_WIDTH + TARGET_WIDTH_PADDING);

        const num_cols = std.math.divCeil(comptime_int, NUM_TARGETS, targets_per_row);

        var drawn_targets: u32 = 0;

        for (targets_per_row) |i| {
            for (num_cols) |j| {
                targets[drawn_targets] = Target{
                    .x = WIDTH_PADDING + i * (TARGET_WIDTH + TARGET_WIDTH_PADDING),
                    .y = HEIGHT_PADDING + j * (TARGET_HEIGHT + TARGET_HEIGHT_PADDING),
                    .destroyed = false,
                };
            }
        }
    }
};

pub fn main() !void {
    raylib.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "raylib [core] example - basic window");
    raylib.SetTargetFPS(FPS);

    var targets = Target.make_targets();

    // var circle_x: c_int = 0;

    while (!raylib.WindowShouldClose()) {
        raylib.BeginDrawing();
        raylib.ClearBackground(raylib.RAYWHITE);

        for (targets) |target| {
            if (!target.destroyed) {
                raylib.DrawRectangle(target.x, target.y, TARGET_WIDTH, TARGET_HEIGHT, raylib.GRAY);
            }
        }

        // raylib.DrawCircle(circle_x, 450, 24, raylib.RED);
        //
        // if (raylib.IsKeyDown(raylib.KEY_LEFT)) circle_x -= 4;
        // if (raylib.IsKeyDown(raylib.KEY_RIGHT)) circle_x += 4;

        raylib.EndDrawing();
    }

    raylib.CloseWindow();
}

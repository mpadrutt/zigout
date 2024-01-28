const std = @import("std");

const raylib = @cImport({
    @cInclude("raylib.h");
});

const WINDOW_WIDTH = 800;
const WIDTH_PADDING = 30;
const WINDOW_HEIGHT = 600;
const HEIGHT_PADDING = 30;
const FPS = 144;
const SPEED = 1;
const NUM_TARGETS = 18;
const TARGET_WIDTH = 100;
const TARGET_HEIGHT = 20;
const TARGET_WIDTH_PADDING = 10;
const TARGET_HEIGHT_PADDING = 10;
const BALL_RADIUS = 16;

const Target = struct {
    x: c_int,
    y: c_int,
    destroyed: bool,

    pub fn init() ![NUM_TARGETS]Target {
        var targets: [NUM_TARGETS]Target = undefined;

        const targets_per_row: u32 = (WINDOW_WIDTH - 2 * WIDTH_PADDING) / (TARGET_WIDTH + TARGET_WIDTH_PADDING);
        const extra_padding: u32 = (WINDOW_WIDTH - 2 * WIDTH_PADDING - targets_per_row * (TARGET_WIDTH + TARGET_WIDTH_PADDING)) / targets_per_row;
        const num_cols = try std.math.divCeil(u32, NUM_TARGETS, targets_per_row);

        var drawn_targets: u32 = 0;

        for (0..num_cols) |j| {
            for (0..targets_per_row) |i| {
                if (drawn_targets >= NUM_TARGETS) break;
                targets[drawn_targets] = Target{
                    .x = @intCast(WIDTH_PADDING + i * (TARGET_WIDTH + TARGET_WIDTH_PADDING + extra_padding)),
                    .y = @intCast(HEIGHT_PADDING + j * (TARGET_HEIGHT + TARGET_HEIGHT_PADDING)),
                    .destroyed = false,
                };

                drawn_targets += 1;
            }
        }

        return targets;
    }
};

const Paddle = struct {
    x: c_int,
    y: c_int,

    pub fn init() Paddle {
        return Paddle{ .x = (WINDOW_WIDTH - TARGET_WIDTH) / 2, .y = WINDOW_HEIGHT - TARGET_HEIGHT - TARGET_HEIGHT_PADDING };
    }

    pub fn update(self: *Paddle) void {
        if (raylib.IsKeyDown(raylib.KEY_LEFT)) self.x = @max(0, self.x - 4);
        if (raylib.IsKeyDown(raylib.KEY_RIGHT)) self.x = @min(WINDOW_WIDTH - TARGET_WIDTH, self.x + 4);
    }
};

const Ball = struct {
    x: c_int,
    y: c_int,
    dx: c_int,
    dy: c_int,
    paused: bool,

    pub fn init() Ball {
        return Ball{ .x = WINDOW_WIDTH / 2, .y = WINDOW_HEIGHT - TARGET_HEIGHT - TARGET_HEIGHT_PADDING - BALL_RADIUS, .dx = 0, .dy = 0, .paused = true };
    }

    pub fn update(self: *Ball, targets: [NUM_TARGETS]Target, paddle: Paddle) void {
        _ = paddle;
        _ = targets;
        if (raylib.IsKeyDown(raylib.KEY_SPACE)) {
            self.dx = 1;
            self.dy = 1;
        }

        self.x -= self.dx;
        self.y -= self.dy;
    }
};

pub fn game_step() void {}

pub fn main() !void {
    raylib.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "raylib [core] example - basic window");
    raylib.SetTargetFPS(FPS);

    var targets = try Target.init();
    var paddle = Paddle.init();
    var ball = Ball.init();

    // var circle_x: c_int = 0;

    while (!raylib.WindowShouldClose()) {
        raylib.BeginDrawing();
        raylib.ClearBackground(raylib.RAYWHITE);

        for (targets) |target| {
            if (!target.destroyed) {
                raylib.DrawRectangle(target.x, target.y, TARGET_WIDTH, TARGET_HEIGHT, raylib.GRAY);
            }
        }

        raylib.DrawRectangle(paddle.x, paddle.y, TARGET_WIDTH, TARGET_HEIGHT, raylib.BLACK);
        raylib.DrawCircle(ball.x, ball.y, BALL_RADIUS, raylib.RED);

        paddle.update();
        ball.update(targets, paddle);

        raylib.EndDrawing();
    }

    raylib.CloseWindow();
}

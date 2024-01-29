const std = @import("std");

const raylib = @cImport({
    @cInclude("raylib.h");
});

const WINDOW_WIDTH = 800;
const WIDTH_PADDING = 30;
const WINDOW_HEIGHT = 600;
const HEIGHT_PADDING = 50;
const FPS = 144;
const SPEED = 2;
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

    pub fn init(allocator: std.mem.Allocator) ![]*Target {
        var targets = try allocator.alloc(*Target, NUM_TARGETS);

        const targets_per_row: u32 = (WINDOW_WIDTH - 2 * WIDTH_PADDING) / (TARGET_WIDTH + TARGET_WIDTH_PADDING);
        const extra_padding: u32 = (WINDOW_WIDTH - 2 * WIDTH_PADDING - targets_per_row * (TARGET_WIDTH + TARGET_WIDTH_PADDING)) / targets_per_row;
        const num_cols = try std.math.divCeil(u32, NUM_TARGETS, targets_per_row);

        var drawn_targets: u32 = 0;

        for (0..num_cols) |j| {
            for (0..targets_per_row) |i| {
                if (drawn_targets >= NUM_TARGETS) break;

                targets[drawn_targets] = try allocator.create(Target);
                targets[drawn_targets].*.x = @intCast(WIDTH_PADDING + i * (TARGET_WIDTH + TARGET_WIDTH_PADDING + extra_padding));
                targets[drawn_targets].*.y = @intCast(HEIGHT_PADDING + j * (TARGET_HEIGHT + TARGET_HEIGHT_PADDING));
                targets[drawn_targets].*.destroyed = false;

                drawn_targets += 1;
            }
        }

        return targets;
    }

    pub fn destroy(self: *Target) void {
        self.destroyed = true;
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

    pub fn update(self: *Ball, targets: []*Target, paddle: Paddle) bool {
        if (self.paused) {
            self.x = paddle.x + TARGET_WIDTH / 2;
        }

        if (raylib.IsKeyDown(raylib.KEY_SPACE) and self.paused) {
            self.dx = SPEED;
            self.dy = SPEED;
            self.paused = false;
        }

        if (self.x - BALL_RADIUS / 2 <= 0) self.dx *= -1;
        if (self.x + BALL_RADIUS / 2 >= WINDOW_WIDTH) self.dx *= -1;
        if (self.y - BALL_RADIUS / 2 <= 0) self.dy *= -1;
        if (self.y + BALL_RADIUS / 2 >= WINDOW_HEIGHT) return false;

        if (self.y + BALL_RADIUS / 2 >= paddle.y and
            self.x >= paddle.x and
            self.x <= paddle.x + TARGET_WIDTH)
            self.dy *= -1;

        for (targets) |target| {
            if (!target.*.destroyed and
                self.x >= target.*.x and
                self.x <= target.*.x + TARGET_WIDTH and
                self.y <= target.y + TARGET_HEIGHT)
            {
                self.dy *= -1;
                target.*.destroyed = true;
            }
        }

        self.x -= self.dx;
        self.y -= self.dy;

        return true;
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    raylib.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "raylib [core] example - basic window");
    raylib.SetTargetFPS(FPS);

    var targets = try Target.init(allocator);
    var paddle = Paddle.init();
    var ball = Ball.init();

    while (!raylib.WindowShouldClose()) {
        raylib.BeginDrawing();
        raylib.ClearBackground(raylib.RAYWHITE);

        for (targets) |target| {
            if (!target.*.destroyed) {
                raylib.DrawRectangle(target.*.x, target.*.y, TARGET_WIDTH, TARGET_HEIGHT, raylib.GRAY);
            }
        }

        raylib.DrawRectangle(paddle.x, paddle.y, TARGET_WIDTH, TARGET_HEIGHT, raylib.BLACK);
        raylib.DrawCircle(ball.x, ball.y, BALL_RADIUS, raylib.RED);

        paddle.update();

        if (!ball.update(targets, paddle)) {
            targets = try Target.init(allocator);
            paddle = Paddle.init();
            ball = Ball.init();
        }

        raylib.EndDrawing();
    }

    raylib.CloseWindow();
}

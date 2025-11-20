// Configuração base do jogo
wire_meters_max = 12;
pixels_per_meter = 80;
max_wire_length_px = wire_meters_max * pixels_per_meter;
wire_length_used = 0;
wire_points = [];
ball_radius = 10;
ball_vx = 0;
ball_vy = 0;
ball_x = 0;
ball_y = 0;
gravity = 0.35;
launch_speed = 8;
launch_boost_y = -2.5;
bounce_restitution = 0.2;
friction = 0.99;
goal_radius = 18;
state = "drawing";
start_pos = { x: 128, y: room_height - 160 };
goal_pos = { x: room_width - 160, y: 160 };

function reset_round() {
    wire_length_used = 0;
    wire_points = [ start_pos ];
    ball_x = start_pos.x;
    ball_y = start_pos.y;
    ball_vx = 0;
    ball_vy = 0;
    state = "drawing";
}

function add_wire_point(px, py) {
    var max_remaining = max_wire_length_px - wire_length_used;
    if (max_remaining <= 0) return;

    var last_point = wire_points[array_length(wire_points) - 1];
    var dist = point_distance(last_point.x, last_point.y, px, py);
    if (dist <= 0) return;

    if (dist > max_remaining) {
        var ratio = max_remaining / dist;
        px = last_point.x + (px - last_point.x) * ratio;
        py = last_point.y + (py - last_point.y) * ratio;
        dist = max_remaining;
    }

    if (dist < 1) return;

    wire_length_used += dist;
    array_push(wire_points, { x: px, y: py });
}

reset_round();

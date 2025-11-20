/// Initialize wire-drawing state and spawn gameplay pieces
global.wire_controller = id;

wire_points = [];
wire_length_pixels = 0;
meters_available = 4;
meter_in_pixels = 120;
max_wire_length = meters_available * meter_in_pixels;
drawing = false;
launched = false;
level_complete = false;
restart_requested = false;

ball_spawn = { x: 96, y: room_height - 120 };
goal_spawn = { x: room_width - 180, y: room_height - 180 };

if (!instance_exists(obj_goal)) {
    goal_id = instance_create_layer(goal_spawn.x, goal_spawn.y, "Instances", obj_goal);
} else {
    goal_id = instance_find(obj_goal, 0);
    goal_id.x = goal_spawn.x;
    goal_id.y = goal_spawn.y;
}

ball_id = instance_create_layer(ball_spawn.x, ball_spawn.y, "Instances", obj_ball);
ball_id.controller = id;
ball_id.spawn_x = ball_spawn.x;
ball_id.spawn_y = ball_spawn.y;

function reset_round() {
    drawing = false;
    launched = false;
    level_complete = false;
    restart_requested = false;
    wire_points = [];
    wire_length_pixels = 0;

    if (instance_exists(ball_id)) {
        with (ball_id) instance_destroy();
    }

    ball_id = instance_create_layer(ball_spawn.x, ball_spawn.y, "Instances", obj_ball);
    ball_id.controller = id;
    ball_id.spawn_x = ball_spawn.x;
    ball_id.spawn_y = ball_spawn.y;
}

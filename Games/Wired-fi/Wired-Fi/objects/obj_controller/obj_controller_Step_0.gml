/// Handle drawing logic, launching, and resets
global.wire_controller = id;

if (!instance_exists(ball_id)) {
    ball_id = instance_create_layer(ball_spawn.x, ball_spawn.y, "Instances", obj_ball);
}
if (instance_exists(ball_id)) {
    ball_id.controller = id;
    ball_id.spawn_x = ball_spawn.x;
    ball_id.spawn_y = ball_spawn.y;
}

if (restart_requested || keyboard_check_pressed(ord("R"))) {
    reset_round();
}

if (!launched && !level_complete) {
    if (mouse_check_button_pressed(mb_left)) {
        drawing = true;
        wire_points = [ { x: mouse_x, y: mouse_y } ];
        wire_length_pixels = 0;
    }

    if (drawing && mouse_check_button(mb_left)) {
        var last = wire_points[array_length(wire_points) - 1];
        var nx = mouse_x;
        var ny = mouse_y;
        var segment_length = point_distance(last.x, last.y, nx, ny);
        if (segment_length > 3) {
            var remaining = max(0, max_wire_length - wire_length_pixels);
            if (remaining <= 0) {
                drawing = false;
            } else {
                if (segment_length > remaining) {
                    var dirx = (nx - last.x) / segment_length;
                    var diry = (ny - last.y) / segment_length;
                    nx = last.x + dirx * remaining;
                    ny = last.y + diry * remaining;
                    segment_length = remaining;
                    drawing = false;
                }
                array_push(wire_points, { x: nx, y: ny });
                wire_length_pixels += segment_length;
            }
        }
    }

    if (mouse_check_button_released(mb_left)) {
        drawing = false;
    }

    if (mouse_check_button_pressed(mb_right) || keyboard_check_pressed(vk_space)) {
        launched = true;
        if (instance_exists(ball_id)) {
            with (ball_id) {
                controller = other.id;
                launched = true;
                vx = 8;
                vy = -9;
            }
        }
    }
}

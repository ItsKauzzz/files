// Reinicia a fase rapidamente
if (keyboard_check_pressed(ord("R"))) {
    reset_round();
}

switch (state) {
    case "drawing": {
        if (mouse_check_button(mb_left)) {
            var mx = device_mouse_x(0);
            var my = device_mouse_y(0);
            add_wire_point(mx, my);
        }

        if (keyboard_check_pressed(vk_space)) {
            state = "flying";
            ball_vx = launch_speed;
            ball_vy = launch_boost_y;
        }
    } break;

    case "flying": {
        ball_vy += gravity;
        ball_vx *= friction;
        ball_vy *= friction;

        ball_x += ball_vx;
        ball_y += ball_vy;

        // Colisão com o fio desenhado
        var segment_count = array_length(wire_points) - 1;
        for (var i = 0; i < segment_count; ++i) {
            var p1 = wire_points[i];
            var p2 = wire_points[i + 1];

            var seg_x = p2.x - p1.x;
            var seg_y = p2.y - p1.y;
            var seg_len_sq = seg_x * seg_x + seg_y * seg_y;
            if (seg_len_sq <= 0) continue;

            var t = clamp(((ball_x - p1.x) * seg_x + (ball_y - p1.y) * seg_y) / seg_len_sq, 0, 1);
            var closest_x = p1.x + seg_x * t;
            var closest_y = p1.y + seg_y * t;

            var offset_x = ball_x - closest_x;
            var offset_y = ball_y - closest_y;
            var dist_sq = offset_x * offset_x + offset_y * offset_y;
            var radius_sq = sqr(ball_radius);

            if (dist_sq < radius_sq) {
                var dist = sqrt(dist_sq);
                var nx, ny;
                if (dist > 0) {
                    nx = offset_x / dist;
                    ny = offset_y / dist;
                } else {
                    var seg_len = sqrt(seg_len_sq);
                    nx = -seg_y / seg_len;
                    ny = seg_x / seg_len;
                    dist = ball_radius;
                }

                // Corrige a penetração
                var push = ball_radius - dist;
                ball_x += nx * push;
                ball_y += ny * push;

                // Reflete a velocidade
                var vn = ball_vx * nx + ball_vy * ny;
                if (vn < 0) {
                    ball_vx -= (1 + bounce_restitution) * vn * nx;
                    ball_vy -= (1 + bounce_restitution) * vn * ny;
                }
            }
        }

        // Checagens de derrota/limites
        if (ball_y > room_height + 200 || ball_x < -200 || ball_x > room_width + 200) {
            reset_round();
        }

        // Vitória
        if (point_distance(ball_x, ball_y, goal_pos.x, goal_pos.y) <= goal_radius) {
            state = "complete";
        }
    } break;

    case "complete": {
        if (keyboard_check_pressed(vk_space)) {
            reset_round();
        }
    } break;
}


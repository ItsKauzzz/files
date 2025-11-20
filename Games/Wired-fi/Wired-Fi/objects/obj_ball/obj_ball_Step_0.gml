/// Simple physics + custom wire collisions
if (!instance_exists(controller)) {
    controller = global.wire_controller;
}

if (!launched) {
    x = spawn_x;
    y = spawn_y;
    return;
}

vy += grav;
x += vx;
y += vy;

vx *= friction;
vy *= friction;

if (instance_exists(controller)) {
    var points = controller.wire_points;
    if (is_array(points) && array_length(points) > 1) {
        for (var i = 1; i < array_length(points); i++) {
            var p0 = points[i - 1];
            var p1 = points[i];
            var hit = wire_check_segment(x, y, vx, vy, radius, p0.x, p0.y, p1.x, p1.y);
            if (hit.hit) {
                x += hit.nx * hit.overlap;
                y += hit.ny * hit.overlap;
                var d = vx * hit.nx + vy * hit.ny;
                vx -= 2 * d * hit.nx;
                vy -= 2 * d * hit.ny;
                vx *= bounce;
                vy *= bounce;
            }
        }
    }

    if (instance_exists(controller.goal_id)) {
        var g = controller.goal_id;
        if (point_distance(x, y, g.x, g.y) <= (g.radius + radius * 0.25)) {
            launched = false;
            vx = 0;
            vy = 0;
            x = g.x;
            y = g.y;
            controller.level_complete = true;
        }
    }
}

// Room edges
if (x < radius) { x = radius; vx = abs(vx) * bounce; }
if (x > room_width - radius) { x = room_width - radius; vx = -abs(vx) * bounce; }
if (y < radius) { y = radius; vy = abs(vy) * bounce; }

if (y > room_height + 200) {
    launched = false;
    if (instance_exists(controller)) {
        controller.restart_requested = true;
    }
}

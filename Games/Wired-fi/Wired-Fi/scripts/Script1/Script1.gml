/// Helper math functions for the Wired-Fi prototype
/// Returns a struct describing a potential collision between a moving circle and a segment
function wire_check_segment(px, py, vx, vy, radius, x1, y1, x2, y2) {
    var dx = x2 - x1;
    var dy = y2 - y1;
    var seg_len_sq = dx * dx + dy * dy;
    if (seg_len_sq <= 0) {
        return { hit: false };
    }

    // Closest point on the segment to the circle center
    var t = ((px - x1) * dx + (py - y1) * dy) / seg_len_sq;
    t = clamp(t, 0, 1);
    var cx = x1 + dx * t;
    var cy = y1 + dy * t;

    var diff_x = px - cx;
    var diff_y = py - cy;
    var dist_sq = diff_x * diff_x + diff_y * diff_y;
    if (dist_sq > radius * radius) {
        return { hit: false };
    }

    var dist = max(0.0001, sqrt(dist_sq));
    var nx = diff_x / dist;
    var ny = diff_y / dist;

    // Only reflect if the ball is moving toward the wire
    var approaching = vx * nx + vy * ny < 0;
    if (!approaching) {
        return { hit: false };
    }

    return {
        hit: true,
        nx: nx,
        ny: ny,
        px: cx,
        py: cy,
        overlap: max(0, radius - dist)
    };
}

/// Calculates the total length for a polyline
function wire_length(points) {
    var length_accum = 0;
    for (var i = 1; i < array_length(points); i++) {
        var p0 = points[i - 1];
        var p1 = points[i];
        length_accum += point_distance(p0.x, p0.y, p1.x, p1.y);
    }
    return length_accum;
}

/// Draws the wire with the given style
function wire_draw(points, col, thickness) {
    draw_set_color(col);
    draw_set_line_width(thickness);
    for (var i = 1; i < array_length(points); i++) {
        var p0 = points[i - 1];
        var p1 = points[i];
        draw_line(p0.x, p0.y, p1.x, p1.y);
    }
    draw_set_line_width(1);
}

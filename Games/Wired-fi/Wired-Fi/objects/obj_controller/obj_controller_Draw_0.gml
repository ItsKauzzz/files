/// Render the wire and UI overlay
if (array_length(wire_points) > 1) {
    var wire_col = c_aqua;
    if (wire_length_pixels >= max_wire_length * 0.95) {
        wire_col = c_orange;
    }
    wire_draw(wire_points, wire_col, 6);

    draw_set_color(c_white);
    for (var i = 0; i < array_length(wire_points); i++) {
        var p = wire_points[i];
        draw_circle(p.x, p.y, 4, false);
    }
}

// Spawn and goal markers
if (is_undefined(ball_spawn) == false) {
    draw_set_color(merge_color(c_blue, c_white, 0.5));
    draw_circle(ball_spawn.x, ball_spawn.y, 14, false);
}

if (instance_exists(goal_id)) {
    draw_set_color(c_lime);
    draw_circle(goal_id.x, goal_id.y, goal_id.radius + 4, false);
}

draw_set_color(c_white);
draw_text(24, 24, "Clique ESQUERDO: desenha o fio (wire)");
draw_text(24, 48, "ESPACO ou BOTAO DIREITO: lancar a bolinha");
draw_text(24, 72, "R: reiniciar a fase");

var meters_left = max(0, (max_wire_length - wire_length_pixels) / meter_in_pixels);
draw_set_color(c_aqua);
draw_text(24, 104, "Metros restantes: " + string_format(meters_left, 1, 2) + " m");

draw_set_color(c_yellow);
draw_text(24, 136, "Objetivo: bata no fio e leve a bolinha ate a area verde");

if (level_complete) {
    draw_set_color(c_lime);
    draw_set_alpha(0.8);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(1);
    draw_set_color(c_black);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(room_width * 0.5, room_height * 0.5, "Parabens! Chegou ao final. Pressione R para tentar de novo.");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

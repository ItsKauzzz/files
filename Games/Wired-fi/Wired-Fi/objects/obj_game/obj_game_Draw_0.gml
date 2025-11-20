// Fundo
var bg_col = make_color_rgb(18, 18, 28);
draw_clear(bg_col);

// Desenho do fio
if (array_length(wire_points) > 1) {
    draw_set_color(c_lime);
    draw_set_line_width(4);
    for (var i = 0; i < array_length(wire_points) - 1; ++i) {
        var p1 = wire_points[i];
        var p2 = wire_points[i + 1];
        draw_line(p1.x, p1.y, p2.x, p2.y);
    }
}

draw_set_color(c_white);
draw_set_line_width(1);

// Ponto inicial e final
var start_col = make_color_rgb(120, 200, 255);
var goal_col = make_color_rgb(255, 200, 80);
draw_set_color(start_col);
draw_circle(start_pos.x, start_pos.y, 14, false);
draw_set_color(goal_col);
draw_circle(goal_pos.x, goal_pos.y, goal_radius, false);

// Bola
var ball_col = make_color_rgb(120, 255, 200);
draw_set_color(ball_col);
draw_circle(ball_x, ball_y, ball_radius, false);
draw_set_color(c_white);
draw_circle(ball_x, ball_y, ball_radius - 2, false);

// HUD
var meters_left = max(0, (max_wire_length_px - wire_length_used) / pixels_per_meter);
var top_text = "Metros restantes: " + string_format(meters_left, 2, 2);
draw_text(24, 24, top_text);

var helper = "Botão esquerdo: desenhar fio | Espaço: lançar/reiniciar vitória | R: reiniciar";
draw_text(24, 48, helper);

if (state == "drawing") {
    draw_text(24, 72, "Desenhe um caminho até o objetivo e aperte Espaço para lançar a bolinha!");
} else if (state == "complete") {
    draw_text(24, 72, "Chegou ao objetivo! Aperte Espaço para jogar novamente.");
}

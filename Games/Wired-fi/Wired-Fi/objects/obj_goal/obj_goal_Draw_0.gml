/// Draw the target ring for the finish
var outer_radius = radius;
draw_set_color(color_outer);
draw_circle(x, y, outer_radius, false);

draw_set_color(color_inner);
draw_circle(x, y, outer_radius * 0.55, false);
draw_circle_color(x, y, outer_radius * 0.3, c_white, c_lime, false);

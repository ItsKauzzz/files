/// Draw the ball with a small speed indicator
draw_self();

draw_set_color(c_white);
var speed_dir = point_direction(0, 0, vx, vy);
draw_line(x, y, x + lengthdir_x(20, speed_dir), y + lengthdir_y(20, speed_dir));

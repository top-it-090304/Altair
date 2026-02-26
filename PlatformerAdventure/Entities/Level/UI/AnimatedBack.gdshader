shader_type canvas_item;

uniform float scroll_speed : hint_range(0.0, 200.0) = 30;
uniform vec2 tile_size = vec2(64.0, 64.0);

void vertex() {
	
}

void fragment() {
	vec2 uv = FRAGCOORD.xy / tile_size;
	uv.y -= TIME * (scroll_speed / tile_size.y);
	COLOR = texture(TEXTURE, fract(uv));
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}

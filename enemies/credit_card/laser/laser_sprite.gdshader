shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

uniform float green_point = 0.25;

void fragment()
{
	//vec2 grid_uv = round(UV * float(amount)) / float(amount);
	//
	//vec4 col = texture(TEXTURE, grid_uv);
	
	float pixel_intensity = 64.0;
	
	float pixel_UV_x = round(UV.x * pixel_intensity) / pixel_intensity;
	float pixel_UV_y = round(UV.y * pixel_intensity) / pixel_intensity;
	
	float offset = (sin(pixel_UV_y * 5.0 * 2.0 * PI) + 1.0)/2.0;
	
	float red = max(0.0, pow((pixel_UV_x + offset/50.0),4));
	
	
	COLOR = vec4(red,1.0,red,1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}

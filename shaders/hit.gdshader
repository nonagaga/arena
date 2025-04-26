shader_type spatial;
//when fade 0, use base_color. When fade 1, use hit_color
uniform float fade : hint_range(0.0, 1.0) = 0.0f;
uniform vec4 base_color : source_color = vec4(1);
uniform vec4 hit_color : source_color = vec4(1);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = base_color.rgb*(1.0f-fade) + hit_color.rgb*fade;

}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}

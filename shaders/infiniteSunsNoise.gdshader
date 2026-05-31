//if you want custom suns past this, you will need to have to create a uniform array for each sun, then dynamically use this.
//I suggest since the only real dynamic data type is sampler to use sets of pixels color values to match to the dir_light
//it would go something like this:
shader_type sky;


struct dir_light{
	bool enabled;//this is whether or not the light is visible and in the scene
	float energy;//this is the energy float on the directional light
	float size;//this is angular distance float on the directional light
	vec3 color;//this is the color vec3 on the directional light
	vec3 direction;//this is the -global_transform.basis.z.normalized() of the directional light
};

//update this dynamically through gd script.
uniform sampler2D suns_tex;
void sky(){
	ivec2 size = textureSize(suns_tex,0);

//separate suns by their row, so each new sun is a new row
	for(int row = 0;row<size.y;row++){
		dir_light new_light;
		//check first three pixels
		vec4 col0 = texture(suns_tex, vec2(0.125, (float(row) + 0.5) / float(size.y)));
		vec4 col1 = texture(suns_tex, vec2(0.375, (float(row) + 0.5) / float(size.y)));
		vec4 col2 = texture(suns_tex, vec2(0.625, (float(row) + 0.5) / float(size.y)));

		new_light.enabled = col0.r > 0.5;
		new_light.energy = col0.g;
		new_light.size = col0.b;
		new_light.color = col1.rgb;
		new_light.direction = col2.rgb;
		
		if(sign(new_light.energy)==0.0){
			continue;
		}

		float light_angle = acos(dot(EYEDIR,new_light.direction));
		float light_disc = smoothstep(new_light.size,new_light.size-1.0,light_angle);

		vec3 light = new_light.color * new_light.energy;

		COLOR += mix(COLOR,light,light_disc);
	}
}

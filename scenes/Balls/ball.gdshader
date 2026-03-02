shader_type canvas_item;

void fragment() {
	// 获取当前像素的原始颜色
	vec4 tex_color = texture(TEXTURE, UV);
	
	// UV 坐标是从 (0,0) 到 (1,1) 的，所以图片的中心点是 (0.5, 0.5)
	// 计算当前像素点到中心点的距离
	float dist = distance(UV, vec2(0.5, 0.5));
	
	// 使用 smoothstep 做一个平滑过渡，实现边缘抗锯齿（消除毛边）
	// 当距离小于 0.48 时，alpha 为 1（完全不透明）
	// 当距离大于 0.50 时，alpha 为 0（完全透明）
	float alpha = 1.0 - smoothstep(0.48, 0.50, dist);
	
	// 将计算出的透明度应用到最终颜色上
	COLOR = vec4(tex_color.rgb, tex_color.a * alpha);
}
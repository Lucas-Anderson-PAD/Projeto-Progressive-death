shader_type canvas_item;

// Agua animada: ondulacao + reflexos (caustics) que escorrem + faixa de
// superficie brilhante. A cor base vem do ColorRect (via water.gd), entao
// cada agua mantem seu tom e sua transparencia.

uniform vec4 cor_base : source_color = vec4(0.05, 0.10, 0.35, 0.55);
uniform float velocidade = 1.0;   // velocidade da animacao
uniform float escala_onda = 9.0;  // quantidade de ondas na horizontal
uniform float forca_onda = 0.02;  // amplitude da ondulacao
uniform float brilho = 0.5;       // intensidade dos reflexos

void fragment() {
	vec2 uv = UV;
	float t = TIME * velocidade;

	// Ondulacao: desloca verticalmente conforme x e tempo.
	float onda = sin(uv.x * escala_onda + t * 1.6) * 0.5
	           + sin(uv.x * escala_onda * 0.5 - t * 1.1) * 0.5;
	uv.y += onda * forca_onda;

	vec3 deep   = cor_base.rgb * 0.5;
	vec3 bright = mix(cor_base.rgb, vec3(0.8, 0.95, 1.0), 0.75);

	// Gradiente: mais claro na superficie, escuro no fundo.
	vec3 col = mix(cor_base.rgb, deep, clamp(uv.y, 0.0, 1.0));

	// Linhas de luz que escorrem (refracao da agua).
	float linhas = sin(uv.y * 26.0 + sin(uv.x * 8.0 + t * 1.5) * 2.5 - t * 2.5);
	linhas = smoothstep(0.75, 1.0, linhas);
	col += bright * linhas * (brilho * 0.4);

	// Cintilacoes que se movem (reflexos pontuais).
	float cint = sin((uv.x * 20.0 + uv.y * 8.0) + t * 2.2)
	           * sin((uv.x * 13.0 - uv.y * 11.0) - t * 1.6);
	cint = smoothstep(0.65, 1.0, cint);
	col += bright * cint * (brilho * 0.5);

	// Faixa de superficie ondulada e brilhante no topo.
	float sy = 0.06 + 0.03 * sin(uv.x * escala_onda * 1.4 + t * 2.6);
	float s = smoothstep(sy + 0.03, sy, uv.y);
	col = mix(col, bright, s * 0.7);

	COLOR = vec4(col, cor_base.a);
}

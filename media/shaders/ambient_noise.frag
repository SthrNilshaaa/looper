// Ambient noise-blur background shader.
//
// Renders a slow, organic flow field of color (built from the current song's
// artwork palette) with a very fine animated film-grain layer on top — the
// same visual language as Apple Music's lyrics background: soft blurred
// color blobs that breathe and drift, dusted with subtle moving grain
// instead of a flat gradient.
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform float uGrain;

uniform vec3 uColor0;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;
uniform vec3 uColor4;
uniform vec3 uColor5;

out vec4 fragColor;

float hash(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * 0.1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}

float valueNoise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  float a = hash(i);
  float b = hash(i + vec2(1.0, 0.0));
  float c = hash(i + vec2(0.0, 1.0));
  float d = hash(i + vec2(1.0, 1.0));
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float fbm(vec2 p) {
  float value = 0.0;
  float amp = 0.5;
  for (int i = 0; i < 4; i++) {
    value += amp * valueNoise(p);
    p *= 2.02;
    amp *= 0.55;
  }
  return value;
}

// Sequential lerp chain across 6 stops — avoids dynamic array indexing so
// this stays compatible across GPUs.
vec3 ramp(float t) {
  float s = clamp(t, 0.0, 1.0) * 5.0;
  vec3 c = uColor0;
  c = mix(c, uColor1, smoothstep(0.0, 1.0, clamp(s - 0.0, 0.0, 1.0)));
  c = mix(c, uColor2, smoothstep(0.0, 1.0, clamp(s - 1.0, 0.0, 1.0)));
  c = mix(c, uColor3, smoothstep(0.0, 1.0, clamp(s - 2.0, 0.0, 1.0)));
  c = mix(c, uColor4, smoothstep(0.0, 1.0, clamp(s - 3.0, 0.0, 1.0)));
  c = mix(c, uColor5, smoothstep(0.0, 1.0, clamp(s - 4.0, 0.0, 1.0)));
  return c;
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / uSize;
  float aspect = uSize.x / max(uSize.y, 1.0);
  vec2 p = vec2((uv.x - 0.5) * aspect, uv.y - 0.5) * 1.7;

  // Very slow drift — a full cycle takes minutes, so motion reads as a
  // gentle breathing tide rather than a loop.
  float t = uTime * 0.028;

  // Rotate and move both domains diagonally. Axis-aligned translation made
  // coherent noise boundaries look like a vertical band sweeping the screen.
  mat2 domainRotation = mat2(0.866, -0.5, 0.5, 0.866);
  vec2 q = domainRotation * p;
  vec2 flow = vec2(
    fbm(q * 0.85 + vec2(t * 0.73, -t * 0.61)),
    fbm(q.yx * 0.85 + vec2(-t * 0.47, t * 0.83))
  );

  float n1 = fbm(q * 1.05 + flow * 1.35 + vec2(t * 0.31, t * 0.23));
  float n2 = fbm(domainRotation * (p * 0.5 + flow.yx * 0.2) -
      vec2(t * 0.17, t * 0.11) + 47.0);

  float mixT = clamp(n1 * 0.65 + n2 * 0.35, 0.0, 1.0);
  vec3 color = ramp(mixT);

  // Fine animated grain, stepped to ~14fps so it reads as soft filmic
  // texture rather than a shimmering per-frame flicker.
  float grainStep = floor(uTime * 14.0);
  float g = hash(fragCoord * 0.6 + grainStep * 91.37) - 0.5;
  color += g * uGrain;

  fragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
}

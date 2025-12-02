uniform sampler2D envMap;
uniform samplerCube skybox;

varying vec2 refractedPosition[3];
varying vec3 reflected;
varying float reflectionFactor;

void main() {
  // Color coming from the sky reflection
  vec3 reflectedColor = textureCube(skybox, reflected).rgb;

  // Color coming from the environment refraction, applying chromatic aberration
  vec3 refractedColor;
  refractedColor.r = texture2D(envMap, refractedPosition[0] * 0.5 + 0.5).r;
  refractedColor.g = texture2D(envMap, refractedPosition[1] * 0.5 + 0.5).g;
  refractedColor.b = texture2D(envMap, refractedPosition[2] * 0.5 + 0.5).b;

  // Tone down refraction a bit (it was blowing out to pure white)
  refractedColor *= 0.6;

  // Fresnel-style factor (already provided by the vertex shader)
  float fresnel = clamp(reflectionFactor, 0.0, 1.0);

  // Give reflection a minimum contribution so the underside looks mirror-like
  float reflectionWeight  = mix(0.3, 1.0, fresnel);   // never less than 30% reflection
  float refractionWeight  = 1.0 - reflectionWeight;

  vec3 finalColor = refractedColor * refractionWeight + reflectedColor * reflectionWeight;

  gl_FragColor = vec4(finalColor, 1.0);
}

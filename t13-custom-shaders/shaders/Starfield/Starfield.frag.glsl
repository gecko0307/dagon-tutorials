#version 400 core

#define PI 3.14159265359
const float PI2 = PI * 2.0;

uniform mat4 invViewMatrix;

in vec3 eyePosition;
in vec3 worldNormal;

in vec4 currPosition;
in vec4 prevPosition;

layout(location = 0) out vec4 fragColor;
layout(location = 3) out vec4 fragRadiance;
layout(location = 4) out vec4 fragVelocity;

vec3 toLinear(vec3 v)
{
    return pow(v, vec3(2.2));
}

float hash(float n)
{
    return fract((1.0 + sin(n)) * 415.92653);
}

float noise3d(vec3 x)
{
    float xhash = hash(round(400 * x.x) * 37.0);
    float yhash = hash(round(400 * x.y) * 57.0);
    float zhash = hash(round(400 * x.z) * 67.0);
    return fract(xhash + yhash + zhash);
}

uniform vec3 spaceColor;
uniform float starsThreshold;
uniform float starsBrightness;

uniform vec3 sunDirection;
uniform vec3 sunColor;

const float sunEnergy = 100.0;
const float sunAngularDiameterCos = 0.9999;

void main()
{
    vec3 radiance = toLinear(spaceColor);
    
    float stars = noise3d(normalize(worldNormal));
    float starsRadiance = (stars >= starsThreshold)? pow((stars - starsThreshold) / (1.0 - starsThreshold), starsBrightness) : 0.0;
    vec3 starsColor = mix(vec3(1.0, 0.98, 0.9), vec3(1.0, 0.627, 0.01), starsRadiance);
    radiance += toLinear(starsColor) * starsRadiance;
    
    float cosTheta = clamp(dot(normalize(worldNormal), sunDirection), 0.0, 1.0);
    float sunDisk = smoothstep(sunAngularDiameterCos, sunAngularDiameterCos + 0.00002, cosTheta);
    radiance += sunColor * sunDisk * sunEnergy;
    
    vec2 posScreen = (currPosition.xy / currPosition.w) * 0.5 + 0.5;
    vec2 prevPosScreen = (prevPosition.xy / prevPosition.w) * 0.5 + 0.5;
    vec2 velocity = posScreen - prevPosScreen;
    const float blurMask = 1.0; 
    
    fragColor = vec4(radiance, 0.0);
    fragRadiance = vec4(radiance, 0.0);
    fragVelocity = vec4(velocity, blurMask, 0.0);
}

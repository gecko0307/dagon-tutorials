#version 400 core

in vec3 eyePosition;
in vec3 eyeNormal;
in vec2 texCoord;

in vec4 currPosition;
in vec4 prevPosition;

layout(location = 0) out vec4 fragColor;
layout(location = 1) out vec4 fragNormal;
layout(location = 2) out vec4 fragPBR;
layout(location = 3) out vec4 fragRadiance;
layout(location = 4) out vec4 fragVelocity;

vec3 toLinear(vec3 v)
{
    return pow(v, vec3(2.2));
}

/*
 * Diffuse color
 */
subroutine vec4 srtColor(in vec2 uv);

uniform vec4 diffuseVector;
subroutine(srtColor) vec4 diffuseColorValue(in vec2 uv)
{
    return diffuseVector;
}

uniform sampler2D diffuseTexture;
subroutine(srtColor) vec4 diffuseColorTexture(in vec2 uv)
{
    return textureLod(diffuseTexture, uv, 0.0);
}

subroutine uniform srtColor diffuse;

uniform vec3 ambientColor;
uniform vec3 sunDirection;
uniform vec3 sunColor;

uniform mat4 viewMatrix;

uniform vec3 planetPosition;
uniform float planetRadius;

bool rayVsSphere(in vec3 origin, in vec3 dir, in vec3 center, in float radius)
{
    vec3 dist = center - origin;
    float B = dot(dist, dir);
    float D = radius * radius - dot(dist, dist) + B * B;
    if (D < 0.0)
        return false;
    float t0 = B - sqrt(D);
    float t1 = B + sqrt(D);
    return (t0 > 0.0) || (t1 > 0.0);
}

void main()
{
    vec3 E = normalize(-eyePosition);
    vec3 N = normalize(eyeNormal);
    float NE = max(dot(N, E), 0.0);
    float fresnel = pow(clamp(1.0 - NE, 0.0, 1.0), 8.0);
    
    vec3 sun = toLinear(sunColor);
    
    vec4 diff = diffuse(texCoord);
    
    vec3 planetCenter = (viewMatrix * vec4(planetPosition, 1.0)).xyz;
    bool pointInShadow = rayVsSphere(eyePosition, sunDirection, planetCenter, planetRadius);
    float shadow = 1.0 - float(pointInShadow);
    
    float sunDiffuse = max(dot(N, sunDirection), 0.0);
    vec3 radiance = toLinear(diff.rgb) * (toLinear(ambientColor) + sun * sunDiffuse * shadow);
    
    vec2 posScreen = (currPosition.xy / currPosition.w) * 0.5 + 0.5;
    vec2 prevPosScreen = (prevPosition.xy / prevPosition.w) * 0.5 + 0.5;
    vec2 velocity = posScreen - prevPosScreen;
    
    const float blurMask = 1.0; 
    
    fragColor = vec4(radiance, 0.0);
    fragNormal = vec4(0.0);
    fragPBR = vec4(0.0);
    fragRadiance = vec4(radiance, diff.a);
    fragVelocity = vec4(velocity, blurMask, 0.0);
}

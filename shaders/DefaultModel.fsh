//
//  DefaultModel.fsh
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#version 410


struct material_t {
    //
    // TODO: remove ambient and replace diffuse and specular with mapped values, for objects that
    //       don't have one or the other will need to generate one
    //
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;

    // diffuse and specular will be color scalars, i.e. how much of each channel to pass through from
    // the respective maps, this is primarily for debugging visualization
    //vec3 diffuseScalar;
    //float specularScalar;


    // strength of the specular reflection
    float shininess;

    // sampler2D is an opaque type, they can be decalred as members of a struct, but if so, then the struct
    // can only be used to declare a uniform variable (they cannot be part of a buffer-backed interface block
    // or an input/output variable)
    sampler2D diffuseMap;
    sampler2D specularMap;
};

//
// TODO: this is a point light, it should be named such after new light types are added
//
struct light_t {
    vec3 position;

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;

    float constant;
    float linear;
    float quadratic;
};


uniform vec3 viewPos;
uniform material_t material;
uniform light_t light;

in vec3 f_position;
in vec3 f_normal;
in vec2 f_texcoord;

out vec4 color;

//
// TODO: add layout qualifiers to subroutine definition and uniform
//


//
// NOTE: if passing the material struct sampler2D to a function must use in qualifer
//
//vec4 add(in sampler2D tex) {
//    return vec4(texture(tex, texcoords));
//}


//
// lighting subroutines
//
subroutine vec4 lightingFunc();
subroutine uniform lightingFunc LightingFunction;

subroutine(lightingFunc)
vec4 light_subroutine() {
    return vec4(1.0f); // set all 4 vector values to 1.0f
}

subroutine(lightingFunc)
vec4 phong_subroutine() {
    // ambient
    vec3 ambient = light.ambient * material.ambient * texture(material.diffuseMap, f_texcoord).xyz;

    // diffuse
    vec3 norm = normalize(f_normal);
    vec3 lightDir = normalize(light.position - f_position);
    float diff = max(dot(norm, lightDir), 0.0f);
    vec3 diffuse = light.diffuse * (diff * material.diffuse * texture(material.diffuseMap, f_texcoord).xyz);

    // specular
    vec3 viewDir = normalize(viewPos - f_position);

    //
    // TODO: make the useBlinn boolean a uniform and allow it to be set with a key press so
    //       can switch back and forth between Phong specular and Blinn-Phong specular claculation
    //
    bool useBlinn = true;

    float spec = 0.0f;
    if (useBlinn) {
        vec3 halfwayDir = normalize(lightDir + viewDir);
        spec = pow(max(dot(norm, halfwayDir), 0.0f), 2.0f * material.shininess);
    }
    else {
        vec3 reflectDir = reflect(-lightDir, norm);
        spec = pow(max(dot(viewDir, reflectDir), 0.0f), material.shininess);
    }

    vec3 specular = light.specular * (spec * material.specular);

    // attenuation
    float distance = length(light.position - f_position);
    float attenuation = 1.0f / (light.constant - light.linear * distance + light.quadratic * (distance * distance));

    ambient  *= attenuation;
    diffuse  *= attenuation;
    specular *= attenuation;

    vec3 result = ambient + diffuse + specular;

    //
    // TODO: add gamma correction
    //
    //float gamma = 2.2f;
    //result = pow(result, vec3(1.0f/gamma));

    return vec4(result, 1.0f);
}

void main() {
    color = LightingFunction();
}

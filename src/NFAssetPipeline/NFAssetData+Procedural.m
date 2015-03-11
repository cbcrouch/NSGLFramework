//
//  NFAssetData+Procedural.m
//  NSGLFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFAssetData+Procedural.h"
#import "NFAssetUtils.h"

static const char *g_faceType = @encode(NFFace_t);


@implementation NFAssetData (Procedural)

-(void) createGridOfSize:(NSInteger)size {
    NFSubset *pSubset = [[[NFSubset alloc] init] autorelease];

    // (size * 2) + 1 == number of lines
    // numLines * 2 == number of vertices per grid direction
    // gridDirVertices * 2 == total number of vertices (2 grid directions)
    const NSInteger numVertices = ((size * 8) + 4);
    NFVertex_t vertices[numVertices];

    // set all texture coordinates and normals to 0
    memset(vertices, 0x00, numVertices * sizeof(NFVertex_t));

    int vertexIndex = 0;
    for (NSInteger i=-size; i<=size; ++i) {
        vertices[vertexIndex].pos[0] = (float)size;
        vertices[vertexIndex].pos[1] = 0.0f;
        vertices[vertexIndex].pos[2] = (float)i;
        vertices[vertexIndex].pos[3] = 1.0f;

        vertices[vertexIndex+1].pos[0] = (float)-size;
        vertices[vertexIndex+1].pos[1] = 0.0f;
        vertices[vertexIndex+1].pos[2] = (float)i;
        vertices[vertexIndex+1].pos[3] = 1.0f;

        vertexIndex += 2;
    }

    for (NSInteger i=-size; i<=size; ++i) {
        vertices[vertexIndex].pos[0] = (float)i;
        vertices[vertexIndex].pos[1] = 0.0f;
        vertices[vertexIndex].pos[2] = (float)size;
        vertices[vertexIndex].pos[3] = 1.0f;

        vertices[vertexIndex+1].pos[0] = (float)i;
        vertices[vertexIndex+1].pos[1] = 0.0f;
        vertices[vertexIndex+1].pos[2] = (float)-size;
        vertices[vertexIndex+1].pos[3] = 1.0f;

        vertexIndex += 2;
    }

    GLushort indices[numVertices];
    for (int i=0; i<numVertices; ++i) {
        indices[i] = i;
    }

    [pSubset allocateVerticesWithNumElts:numVertices];
    [pSubset allocateIndicesWithNumElts:numVertices];

    [pSubset loadVertexData:vertices ofSize:(numVertices * sizeof(NFVertex_t))];
    [pSubset loadIndexData:indices ofSize:(numVertices * sizeof(GLushort))];

    self.subsetArray = [[[NSArray alloc] initWithObjects:(id)pSubset, nil] autorelease];
}

-(void) createAxisOfSize:(NSInteger)size {
    NFSubset *pSubset = [[[NFSubset alloc] init] autorelease];

    const NSInteger numVertices = 12;
    NFVertex_t vertices[numVertices];

    // memset will zero out the normal vectors
    memset(vertices, 0x00, numVertices * sizeof(NFVertex_t));

    //
    // TODO: there are much simpler ways of doing this other than encoding integer values in a float
    //       to be used decoded the shader, such as declaring an alternate struct with integer texture
    //       coordinates (current method was done as a learning exercise, think twice before using
    //       it in production code)
    //

    // NOTE: this is for use with the GLSL floatBitsToInt function
    // as per GL_ARB_shader_precision which was made core in OpenGL 4.1:
    //"Any denormalized value input into a shader or potentially generated by an operation in a shader can be flushed to 0."
    float (^encodeIntBitsAsFloat)(int) = ^ float (int intValue) {
        // int values are only supported between 0 and 8388608 (value of 8388608 is hex 0x00800000)
        NSAssert(intValue < 0x00800000, @"ERROR: encodeIntBitsAsFloat int value exceeded max value of 8388608");

        intValue = 0x00800000 | intValue;
        float sign = (intValue & 0x80000000) ? -1.0f : 1.0f;
        int valueExp = ((intValue & 0x7f800000) >> 23) - 127;
        float valueMan = 1.0f;
        for (int i=9; i<32; ++i) {
            valueMan += (intValue & (0x80000000 >> i)) ? powf(2.0f, -1.0f * ((float)(i-8))) : 0.0f;
        }
        return (sign * powf(2.0f, (float)valueExp) * valueMan);
    };

    float f1 = encodeIntBitsAsFloat(1);
    float f2 = encodeIntBitsAsFloat(2);

    // x - red   (s,t): [0, 0] [1, 0]
    // y - green (s,t): [0, 1] [1, 1]
    // z - blue  (s,t): [0, 2] [1, 2]

    // x-axis

    // pos x
    vertices[0].pos[0] = 0.0f;
    vertices[0].pos[3] = 1.0f;

    vertices[1].pos[0] = (float)size;
    vertices[1].pos[3] = 1.0f;

    // neg x
    vertices[2].pos[0] = (float)-size;
    vertices[2].pos[3] = 1.0f;
    vertices[2].texCoord[0] = f1;
    vertices[2].texCoord[1] = 0.0f;

    vertices[3].pos[0] = 0.0f;
    vertices[3].pos[3] = 1.0f;
    vertices[3].texCoord[0] = f1;
    vertices[3].texCoord[1] = 0.0f;

    // y-axis

    // pos y
    vertices[4].pos[1] = 0.0f;
    vertices[4].pos[3] = 1.0f;
    vertices[4].texCoord[0] = 0.0f;
    vertices[4].texCoord[1] = f1;

    vertices[5].pos[1] = (float)size;
    vertices[5].pos[3] = 1.0f;
    vertices[5].texCoord[0] = 0.0f;
    vertices[5].texCoord[1] = f1;

    // neg y
    vertices[6].pos[1] = (float)-size;
    vertices[6].pos[3] = 1.0f;
    vertices[6].texCoord[0] = f1;
    vertices[6].texCoord[1] = f1;

    vertices[7].pos[1] = 0.0f;
    vertices[7].pos[3] = 1.0f;
    vertices[7].texCoord[0] = f1;
    vertices[7].texCoord[1] = f1;

    // z-axis

    // pos z
    vertices[8].pos[2] = 0.0f;
    vertices[8].pos[3] = 1.0f;
    vertices[8].texCoord[0] = 0.0f;
    vertices[8].texCoord[1] = f2;

    vertices[9].pos[2] = (float)size;
    vertices[9].pos[3] = 1.0f;
    vertices[9].texCoord[0] = 0.0f;
    vertices[9].texCoord[1] = f2;

    // neg z
    vertices[10].pos[2] = (float)-size;
    vertices[10].pos[3] = 1.0f;
    vertices[10].texCoord[0] = f1;
    vertices[10].texCoord[1] = f2;

    vertices[11].pos[2] = 0.0f;
    vertices[11].pos[3] = 1.0f;
    vertices[11].texCoord[0] = f1;
    vertices[11].texCoord[1] = f2;

    const NSInteger numIndices = 12;
    GLushort indices[numIndices];

    for (int i=0; i<numIndices; ++i) {
        indices[i] = i;
    }

    [pSubset allocateVerticesWithNumElts:numVertices];
    [pSubset allocateIndicesWithNumElts:numIndices];

    [pSubset loadVertexData:vertices ofSize:(numVertices * sizeof(NFVertex_t))];
    [pSubset loadIndexData:indices ofSize:(numIndices * sizeof(GLushort))];

    self.subsetArray = [[[NSArray alloc] initWithObjects:(id)pSubset, nil] autorelease];
}

- (void) loadAxisSurface:(NFSurfaceModel *)surface {
    static unsigned char texture2d[] = {
        255, 0,   0, 255,   64,  0,  0, 255,  // red and light red
        0, 255,   0, 255,    0, 64,  0, 255,  // green and light green
        0,   0, 255, 255,    0,  0, 64, 255,  // blue and light blue
        255,255,255, 255,   255,255,255,255   // padding to make texture 2x4
    };

    [[surface map_Kd] setWidth:2];
    [[surface map_Kd] setHeight:4];

    CGRect size = CGRectMake(0.0, 0.0, surface.map_Kd.width, surface.map_Kd.height);
    [surface.map_Kd loadWithData:texture2d ofSize:size ofType:surface.map_Kd.type withFormat:surface.map_Kd.format];
}

- (void) createPlaneOfSize:(NSInteger)size {
    NFSubset *pSubset = [[[NFSubset alloc] init] autorelease];

    const NSInteger numVertices = 4;
    NFVertex_t vertices[numVertices];

    // bottom left
    vertices[0].pos[0] = (float)-size;
    vertices[0].pos[1] = 0.0f;
    vertices[0].pos[2] = (float)-size;
    vertices[0].pos[3] = 1.0f;
    vertices[0].texCoord[0] = 0.0f;
    vertices[0].texCoord[1] = 0.0f;
    vertices[0].texCoord[2] = 0.0f;

    // bottom right
    vertices[1].pos[0] = (float)size;
    vertices[1].pos[1] = 0.0f;
    vertices[1].pos[2] = (float)-size;
    vertices[1].pos[3] = 1.0f;
    vertices[1].texCoord[0] = 1.0f * size;
    vertices[1].texCoord[1] = 0.0f;
    vertices[1].texCoord[2] = 0.0f;

    // top right
    vertices[2].pos[0] = (float)size;
    vertices[2].pos[1] = 0.0f;
    vertices[2].pos[2] = (float)size;
    vertices[2].pos[3] = 1.0f;
    vertices[2].texCoord[0] = 1.0f * size;
    vertices[2].texCoord[1] = 1.0f * size;
    vertices[2].texCoord[2] = 0.0f;

    // top left
    vertices[3].pos[0] = (float)-size;
    vertices[3].pos[1] = 0.0f;
    vertices[3].pos[2] = (float)size;
    vertices[3].pos[3] = 1.0f;
    vertices[3].texCoord[0] = 0.0f;
    vertices[3].texCoord[1] = 1.0f * size;
    vertices[3].texCoord[2] = 0.0f;

    const NSInteger numIndices = 6;
    GLushort indices[numIndices];

    //
    // TODO: should be able to handle either CCW or CW mode
    //
/*
    GLint frontFace;
    glGetIntegerv(GL_FRONT_FACE, &frontFace);
    if (frontFace == GL_CCW) {
        NSLog(@"glFrontFace currently set to CCW");
    }
    else if (frontFace == GL_CW) {
        NSLog(@"glFrontFace currently set to CW");
    }
    else {
        NSLog(@"unknown value returned");
    }
*/
    //
    // 0 1 2   2 3 0    CW
    // 2 1 0   0 3 2   CCW
    //

    indices[0] = 2;
    indices[1] = 1;
    indices[2] = 0;

    indices[3] = 0;
    indices[4] = 3;
    indices[5] = 2;

    NFFace_t face1 = [NFAssetUtils calculateFaceWithPoints:vertices withIndices:indices];

    GLushort *indexPtr = indices;
    indexPtr += 3;

    NFFace_t face2 = [NFAssetUtils calculateFaceWithPoints:vertices withIndices:indexPtr];

    // encode the faces into an array
    NSValue *value1 = [NSValue value:&face1 withObjCType:g_faceType];
    NSValue *value2 = [NSValue value:&face2 withObjCType:g_faceType];
    NSArray *array = [[[NSArray alloc] initWithObjects:value1, value2, nil] autorelease];

    for (int i=0; i<4; ++i) {
        GLKVector4 vertexNormal = [NFAssetUtils calculateAreaWeightedNormalOfIndex:i withFaces:array];
        vertices[i].norm[0] = vertexNormal.x;
        vertices[i].norm[1] = vertexNormal.y;
        vertices[i].norm[2] = vertexNormal.z;
        vertices[i].norm[3] = vertexNormal.w;
    }

    [pSubset allocateVerticesWithNumElts:numVertices];
    [pSubset allocateIndicesWithNumElts:numIndices];

    [pSubset loadVertexData:vertices ofSize:(numVertices * sizeof(NFVertex_t))];
    [pSubset loadIndexData:indices ofSize:(numIndices * sizeof(GLushort))];

    self.subsetArray = [[[NSArray alloc] initWithObjects:(id)pSubset, nil] autorelease];
}

- (void) createSolidSphereWithRadius:(float)radius {
    const NSInteger verticalSlices = 4;
    const NSInteger horizontalSlices = 8;

    NFSubset *pSubset = [[[NFSubset alloc] init] autorelease];

    // adding two vertices for the top and bottom points
    const NSInteger numVertices = 2 + ((verticalSlices-1) * horizontalSlices);

    // top and bottom horizontal slices will consist of only triangles and the remaing slices form quads
    // from two triangles (3 indices per triangle, 6 per quad)
    const NSInteger numIndices = (2 * horizontalSlices * 3) + ((verticalSlices - 2) * horizontalSlices * 6);

    NFVertex_t vertices[numVertices];
    GLushort indices[numIndices];

    //
    // TODO: remove memset after normals and texture coordinates have been calculated
    //
    memset(vertices, 0, sizeof(vertices));


    // spherical coordinates as mapped to perspective coordiantes (x to the right, y up, +z towards the camera)
    //x = r * sin(phi) * sin(theta);
    //y = r * cos(phi);
    //z = r * sin(phi) * cos(theta);

    // phi => [0, M_PI]
    // theta => [0, 2*M_PI]

    // phi is vertical angle (inclination angle)
    // theta is horizontal angle (azimuthal angle)


    float phi = 0.0f;
    float theta = 0.0f;
    float verticalAngleDelta = M_PI / (float)verticalSlices;
    float horizontalAngleDelta = (2 * M_PI) / (float)horizontalSlices;

    // top point of sphere
    vertices[0].pos[0] = radius * sin(phi) * sin(theta);
    vertices[0].pos[1] = radius * cos(phi);
    vertices[0].pos[2] = radius * sin(phi) * cos(theta);
    vertices[0].pos[3] = 1.0f;

    // generate all side vertices
    int index = 1;
    for (NSInteger i=0; i<(verticalSlices-1); ++i) {
        phi += verticalAngleDelta;
        theta = 0.0f;
        for (NSInteger j=0; j<horizontalSlices; ++j) {
            vertices[index].pos[0] = radius * sin(phi) * sin(theta);
            vertices[index].pos[1] = radius * cos(phi);
            vertices[index].pos[2] = radius * sin(phi) * cos(theta);
            vertices[index].pos[3] = 1.0f;
            theta += horizontalAngleDelta;
            ++index;
        }
    }

    // bottom point of the sphere
    phi += verticalAngleDelta;
    theta = 0.0f;
    vertices[index].pos[0] = radius * sin(phi) * sin(theta);
    vertices[index].pos[1] = radius * cos(phi);
    vertices[index].pos[2] = radius * sin(phi) * cos(theta);
    vertices[index].pos[3] = 1.0f;


    // index to cap of the sphere
    GLushort idx = 1;
    for (NSInteger i=0; i < 3*horizontalSlices; i+=3) {
        indices[i]   = 0;
        indices[i+1] = idx;

        if (idx != horizontalSlices) {
            indices[i+2] = idx+1;
        }
        else {
            indices[i+2] = 1;
        }

        ++idx;
    }

    // index sides
    NSInteger baseIdx = 3*horizontalSlices;
    for (NSInteger i=0; i<verticalSlices-2; ++i) {
        GLushort first = 1 + i*horizontalSlices;
        GLushort second = 2 + i*horizontalSlices;
        for (NSInteger j=0; j<horizontalSlices; ++j) {
            if (j != horizontalSlices-1) {
                indices[baseIdx] = first;
                indices[baseIdx+1] = idx;
                indices[baseIdx+2] = idx+1;

                indices[baseIdx+3] = idx+1;
                indices[baseIdx+4] = second;
                indices[baseIdx+5] = first;
            }
            else {
                // final/closing indexing of the horizontal slice
                indices[baseIdx] = first;
                indices[baseIdx+1] = idx;
                indices[baseIdx+2] = 1 + i*horizontalSlices;

                indices[baseIdx+3] = idx;
                indices[baseIdx+4] = second;
                indices[baseIdx+5] = 1 + i*horizontalSlices;
            }
            ++first;
            ++second;
            ++idx;
            baseIdx += 6;
        }
    }

    // index bottom cap of the sphere
    GLushort first = ((verticalSlices-2) * horizontalSlices) + 1;
    GLushort second = first+1;
    for (NSInteger i=baseIdx; i < 3*horizontalSlices + baseIdx; i+=3) {
        indices[i]   = first;
        indices[i+1] = index;

        if (second != index) {
            indices[i+2] = second;
        }
        else {
            indices[i+2] = ((verticalSlices-2) * horizontalSlices) + 1;
        }

        ++first;
        ++second;
    }


    //
    // TODO: create a faces array and then calculate all the vertex normals (verify that vertex normals
    //       are simply unit vectors from the origin to the vertex, if this is the case use it over
    //       the constructed faces method)
    //
/*
    NFFace_t face = [NFAssetUtils calculateFaceWithPoints:vertices withIndices:indices];
    NSValue *value = [NSValue value:&face withObjCType:g_faceType];

    NSArray *array = [[[NSArray alloc] initWithObjects:value, value, nil] autorelease];

    for (int i=0; i<numVertices; ++i) {
        GLKVector4 vertexNormal = [NFAssetUtils calculateAreaWeightedNormalOfIndex:i withFaces:array];
        vertices[i].norm[0] = vertexNormal.x;
        vertices[i].norm[1] = vertexNormal.y;
        vertices[i].norm[2] = vertexNormal.z;
        vertices[i].norm[3] = vertexNormal.w;
    }
*/

    [pSubset allocateVerticesWithNumElts:numVertices];
    [pSubset allocateIndicesWithNumElts:numIndices];
    [pSubset loadVertexData:vertices ofSize:(numVertices * sizeof(NFVertex_t))];
    [pSubset loadIndexData:indices ofSize:(numIndices * sizeof(GLushort))];
    self.subsetArray = [[[NSArray alloc] initWithObjects:(id)pSubset, nil] autorelease];
}

@end

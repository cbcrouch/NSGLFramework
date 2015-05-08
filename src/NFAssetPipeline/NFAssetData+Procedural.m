//
//  NFAssetData+Procedural.m
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFAssetData+Procedural.h"
#import "NFAssetUtils.h"

static const char *g_faceType = @encode(NFFace_t);


@implementation NFAssetData (Procedural)

-(void) createGridOfSize:(NSInteger)size {
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

    NFSubset *pSubset = [[[NFSubset alloc] init] autorelease];
    [pSubset allocateVerticesWithNumElts:numVertices];
    [pSubset allocateIndicesWithNumElts:numVertices];
    [pSubset loadVertexData:vertices ofSize:(numVertices * sizeof(NFVertex_t))];
    [pSubset loadIndexData:indices ofSize:(numVertices * sizeof(GLushort))];
    self.subsetArray = [[[NSArray alloc] initWithObjects:(id)pSubset, nil] autorelease];
}

-(void) createAxisOfSize:(NSInteger)size {
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

    NFSubset *pSubset = [[[NFSubset alloc] init] autorelease];
    [pSubset allocateVerticesWithNumElts:numVertices];
    [pSubset allocateIndicesWithNumElts:numIndices];
    [pSubset loadVertexData:vertices ofSize:(numVertices * sizeof(NFVertex_t))];
    [pSubset loadIndexData:indices ofSize:(numIndices * sizeof(GLushort))];
    self.subsetArray = [[[NSArray alloc] initWithObjects:(id)pSubset, nil] autorelease];
}

- (void) loadAxisSurface:(NFSurfaceModel *)surface {
    static unsigned char texture2d[] = {
        255, 0,   0, 255,   65,  0,  0, 255,  // red and light red
        0, 255,   0, 255,    0,105,  0, 255,  // green and light green
        0,   0, 255, 255,    0,  0, 70, 255,  // blue and light blue
        255,255,255, 255,  255,255,255, 255   // padding to make texture 2x4
    };

    [[surface map_Kd] setWidth:2];
    [[surface map_Kd] setHeight:4];

    CGRect size = CGRectMake(0.0, 0.0, surface.map_Kd.width, surface.map_Kd.height);
    [surface.map_Kd loadWithData:texture2d ofSize:size ofType:surface.map_Kd.type withFormat:surface.map_Kd.format];
}

- (void) createPlaneOfSize:(NSInteger)size {
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

    NFSubset *pSubset = [[[NFSubset alloc] init] autorelease];
    [pSubset allocateVerticesWithNumElts:numVertices];
    [pSubset allocateIndicesWithNumElts:numIndices];
    [pSubset loadVertexData:vertices ofSize:(numVertices * sizeof(NFVertex_t))];
    [pSubset loadIndexData:indices ofSize:(numIndices * sizeof(GLushort))];
    self.subsetArray = [[[NSArray alloc] initWithObjects:(id)pSubset, nil] autorelease];
}

- (void) createUVSphereWithRadius:(float)radius withStacks:(int)stacks withSlices:(int)slices {
    const NSInteger numVertices = (stacks+1) * (slices+1) + 1;
    const NSInteger numIndices = stacks * slices * 3 * 2;
    NFVertex_t vertices[numVertices];
    GLushort indices[numIndices];

    // spherical coordinates as mapped to perspective coordiantes (x to the right, y up, +z towards the camera)
    // x = r * sin(phi) * sin(theta);
    // y = r * cos(phi);
    // z = r * sin(phi) * cos(theta);
    // phi   => [0, M_PI]    inclination (vertical angle)
    // theta => [0, 2*M_PI]  azimuth (horizontal angle)

    float phi = 0.0f;
    float theta = 0.0f;
    float phiDelta = M_PI / (float)stacks;
    float thetaDelta = (2 * M_PI) / (float)slices;

    // NOTE: need to add an extra slice to get a coincident vertex with both tex coord S = 0.0 and 1.0, and
    //       and adding an extra stack to get the bottom point i.e. would take five vertical vertices to
    //       make four stacks
    int index=0;
    for (NSInteger i=0; i<stacks+1; ++i) {
        for (NSInteger j=0; j<slices+1; ++j) {
            vertices[index].pos[0] = radius * sin(phi) * sin(theta);
            vertices[index].pos[1] = radius * cos(phi);
            vertices[index].pos[2] = radius * sin(phi) * cos(theta);
            vertices[index].pos[3] = 1.0f;

            //
            // TODO: second to last vertex on the top and bottom cap won't get used
            //       should ideally generate one less top and bottom vertex and evenly
            //       distribute the texture coordinates
            //

            vertices[index].texCoord[0] = phi / M_PI;
            vertices[index].texCoord[1] = theta / (2.0f*M_PI);
            vertices[index].texCoord[2] = 0.0f;

            GLKVector3 normal = GLKVector3Make(vertices[index].pos[0], vertices[index].pos[1], vertices[index].pos[2]);
            normal = GLKVector3Normalize(normal);

            vertices[index].norm[0] = normal.x;
            vertices[index].norm[1] = normal.y;
            vertices[index].norm[2] = normal.z;
            vertices[index].norm[3] = 0.0f;

            theta += thetaDelta;
            ++index;
        }

        phi += phiDelta;
        theta = 0.0f;
    }

    // index the first stack
    index = 0;
    for (int i=0; i<slices-1; ++i) {
        indices[index] = i;
        indices[index+1] = i + slices + 1;
        indices[index+2] = i + slices + 2;
        index += 3;
    }
    indices[index] = slices;
    indices[index+1] = 2*slices;
    indices[index+2] = 2*slices + 1;
    index += 3;

    // index all stacks up to the bottom one
    GLushort p0 = slices+1;
    GLushort p1 = p0 + slices+1;
    GLushort p2 = p1 + 1;
    GLushort p3 = p0 + 1;
    for (int i=0; i<stacks-2; ++i) {
        for (int j=0; j<slices; ++j) {
            indices[index] = p0;
            indices[index+1] = p1;
            indices[index+2] = p2;
            index += 3;

            indices[index] = p0;
            indices[index+1] = p2;
            indices[index+2] = p3;
            index += 3;

            ++p0;
            ++p1;
            ++p2;
            ++p3;
        }

        GLushort sliceInc = (i+2) * (slices+1);
        p0 = sliceInc;
        p1 = p0 + slices+1;
        p2 = p1 + 1;
        p3 = p0 + 1;
    }

    // index bottom stack
    p0 = (slices+1) * (stacks-1);
    p1 = (slices+1) * stacks;
    p2 = p0 + 1;
    for (int i=0; i<slices-1; ++i) {
        indices[index] = p0;
        indices[index+1] = p1;
        indices[index+2] = p2;

        ++p0;
        ++p1;
        ++p2;
        index += 3;
    }
    indices[index] = p0;
    indices[index+1] = p1+1;
    indices[index+2] = p2;

    NFSubset *pSubset = [[[NFSubset alloc] init] autorelease];
    [pSubset allocateVerticesWithNumElts:numVertices];
    [pSubset allocateIndicesWithNumElts:numIndices];
    [pSubset loadVertexData:vertices ofSize:(numVertices * sizeof(NFVertex_t))];
    [pSubset loadIndexData:indices ofSize:(numIndices * sizeof(GLushort))];
    self.subsetArray = [[[NSArray alloc] initWithObjects:(id)pSubset, nil] autorelease];
}

@end

//
//  NFAssetData+Procedural.m
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//

#import "NFAssetData+Procedural.h"

#import "NFUtils.h"


@interface NFAssetData()

// helper methods for generating procedural geometry

@end


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
    for (NSInteger i=-size; i<=size; i++) {
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

    for (NSInteger i=-size; i<=size; i++) {
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
    for (int i=0; i<numVertices; i++) {
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

    const NSInteger numVertices = 6;
    NFVertex_t vertices[numVertices];

    // memset will zero out the normal vectors
    memset(vertices, 0x00, numVertices * sizeof(NFVertex_t));

    // NOTE: this is for use with the GLSL floatBitsToInt function
    float (^encodeIntBitsAsFloat)(int) = ^ float (int intValue) {
        //
        // TODO: currently only looking at the mantissa bits in order to avoid a denormal float
        //       (need to confirm this is true)
        //

        // int values are only supported between 0 and 8388608

        // as per GL_ARB_shader_precision which was made core in OpenGL 4.1:
        //"Any denormalized value input into a shader or potentially generated by an operation in a shader can be flushed to 0."

        // max value of 8388608 is hex 0x00800000
        NSAssert(intValue < 0x00800000, @"ERROR: encodeIntBitsAsFloat int value exceeded max value of 8388608");

        intValue = 0x00800000 | intValue;
        float sign = (intValue & 0x80000000) ? -1.0f : 1.0f;
        int valueExp = ((intValue & 0x7f800000) >> 23) - 127;
        float valueMan = 1.0f;
        for (int i=9; i<32; i++) {
            valueMan += (intValue & (0x80000000 >> i)) ? powf(2.0f, -1.0f * ((float)(i-8))) : 0.0f;
        }
        return (sign * powf(2.0f, (float)valueExp) * valueMan);
    };

    float value = encodeIntBitsAsFloat(1);

    // x-axis
    vertices[0].pos[0] = (float)-size;
    vertices[0].pos[1] = 0.0f;
    vertices[0].pos[2] = 0.0f;
    vertices[0].pos[3] = 1.0f;
    vertices[0].texCoord[0] = 0.0f;
    vertices[0].texCoord[1] = 0.0f;
    vertices[0].texCoord[2] = 0.0f;

    vertices[1].pos[0] = (float)size;
    vertices[1].pos[1] = 0.0f;
    vertices[1].pos[2] = 0.0f;
    vertices[1].pos[3] = 1.0f;
    vertices[1].texCoord[0] = 0.0f;
    vertices[1].texCoord[1] = 0.0f;
    vertices[1].texCoord[2] = 0.0f;

    // y-axis
    vertices[2].pos[0] = 0.0f;
    vertices[2].pos[1] = (float)-size;
    vertices[2].pos[2] = 0.0f;
    vertices[2].pos[3] = 1.0f;

    vertices[2].texCoord[0] = value;
    vertices[2].texCoord[1] = 0.0f;

    vertices[2].texCoord[2] = 0.0f;

    vertices[3].pos[0] = 0.0f;
    vertices[3].pos[1] = (float)size;
    vertices[3].pos[2] = 0.0f;
    vertices[3].pos[3] = 1.0f;

    vertices[3].texCoord[0] = value;
    vertices[3].texCoord[1] = 0.0f;

    vertices[3].texCoord[2] = 0.0f;

    // z-axis
    vertices[4].pos[0] = 0.0f;
    vertices[4].pos[1] = 0.0f;
    vertices[4].pos[2] = (float)-size;
    vertices[4].pos[3] = 1.0f;

    vertices[4].texCoord[0] = 0.0f;
    vertices[4].texCoord[1] = value;
    vertices[4].texCoord[2] = 0.0f;

    vertices[5].pos[0] = 0.0f;
    vertices[5].pos[1] = 0.0f;
    vertices[5].pos[2] = (float)size;
    vertices[5].pos[3] = 1.0f;

    vertices[5].texCoord[0] = 0.0f;
    vertices[5].texCoord[1] = value;
    vertices[5].texCoord[2] = 0.0f;


/*
    for (int i=0; i<8; i++) {
        float x = i & 1 ? -1.0f : 1.0f;
        float y = i & 2 ? -1.0f : 1.0f;
        float z = i & 4 ? -1.0f : 1.0f;

        // will start with x == 1 then -1
        // then will repeat with y == 1 then -1
        // ...

        NSLog(@"%f %f %f", x, y, z);
    }
*/


    const NSInteger numIndices = 6;
    GLushort indices[numIndices];

    indices[0] = 0;
    indices[1] = 1;
    indices[2] = 2;
    indices[3] = 3;
    indices[4] = 4;
    indices[5] = 5;

    [pSubset allocateVerticesWithNumElts:numVertices];
    [pSubset allocateIndicesWithNumElts:numIndices];

    [pSubset loadVertexData:vertices ofSize:(numVertices * sizeof(NFVertex_t))];
    [pSubset loadIndexData:indices ofSize:(numIndices * sizeof(GLushort))];

    self.subsetArray = [[[NSArray alloc] initWithObjects:(id)pSubset, nil] autorelease];
}

- (void) loadAxisSurface:(NFSurfaceModel *)surface {

    // x - red
    // y - green
    // z - blue
    static unsigned char texture2d[] = {
        255,  0,  0,255,   128,  0,  0,255,  // red and light red
        0,255,  0,255,     0,128,  0,255,    // green and light green
        0,  0,255,255,     0,  0,128,255,    // blue and light blue
        255,255,255,255,   255,255,255,255   // padding to make texture 2x4
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

    NFFace_t face1 = [NFUtils calculateFaceWithPoints:vertices withIndices:indices];

    GLushort *indexPtr = indices;
    indexPtr += 3;

    NFFace_t face2 = [NFUtils calculateFaceWithPoints:vertices withIndices:indexPtr];

    // encode the faces into an array
    NSValue *value1 = [NSValue value:&face1 withObjCType:g_faceType];
    NSValue *value2 = [NSValue value:&face2 withObjCType:g_faceType];
    NSArray *array = [[[NSArray alloc] initWithObjects:value1, value2, nil] autorelease];

    for (int i=0; i<4; i++) {
        GLKVector4 vertexNormal = [NFUtils calculateAreaWeightedNormalOfIndex:i withFaces:array];
        vertices[i].norm[0] = vertexNormal.v[0];
        vertices[i].norm[1] = vertexNormal.v[1];
        vertices[i].norm[2] = vertexNormal.v[2];
        vertices[i].norm[3] = vertexNormal.v[3];
    }

    [pSubset allocateVerticesWithNumElts:numVertices];
    [pSubset allocateIndicesWithNumElts:numIndices];

    [pSubset loadVertexData:vertices ofSize:(numVertices * sizeof(NFVertex_t))];
    [pSubset loadIndexData:indices ofSize:(numIndices * sizeof(GLushort))];

    self.subsetArray = [[[NSArray alloc] initWithObjects:(id)pSubset, nil] autorelease];
}

@end

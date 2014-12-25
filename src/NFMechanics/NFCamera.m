//
//  NFCamera.m
//  NSGLFramework
//
//  Copyright (c) 2014 Casey Crouch. All rights reserved.
//

#import "NFCamera.h"

#define FORWARD_BIT 0x01
#define BACK_BIT    0x02
#define LEFT_BIT    0x04
#define RIGHT_BIT   0x08

#define X_IDX 0
#define Y_IDX 1
#define Z_IDX 2


@implementation NFMotionVector
@synthesize currentValue = _currentValue;
@synthesize modifier = _modifier;
@synthesize updateRate = _updateRate;
@end


@interface NFCamera()

@property (nonatomic, assign) GLKVector3 initialPosition;
@property (nonatomic, assign) GLKVector3 initialTarget;
@property (nonatomic, assign) GLKVector3 initialUp;


@property (nonatomic, assign) GLKVector3 U;
@property (nonatomic, assign) GLKVector3 V;
@property (nonatomic, assign) GLKVector3 N;


@property (nonatomic, retain) NFViewVolume* viewVolume;


//
// TODO: make a stack of motionVectors
//
//@property (nonatomic, assign) NFMotionVector motionVector;

@property (nonatomic, assign) NSUInteger currentFlags;

@property (nonatomic, assign) float aspectRatio;


- (void) updateViewVolume;


- (void) calculatePositionTargetUp;
- (void) updateModelViewMatrix;

@end


@implementation NFCamera

@synthesize initialTarget = _initialTarget;
@synthesize initialPosition = _initialPosition;
@synthesize initialUp = _initialUp;


@synthesize U = _U;
@synthesize V = _V;
@synthesize N = _N;


//@synthesize motionVector = _motionVector;


//
// TODO: override setters so that any observers are notified of a change
//
@synthesize position = _position;
@synthesize target = _target;
@synthesize up = _up;

@synthesize viewVolume = _viewVolume;

@synthesize translationSpeed = _translationSpeed;

//@synthesize hFOV = _hFOV;
@synthesize vFOV = _vFOV;
@synthesize width = _width;
@synthesize height = _height;
@synthesize aspectRatio = _aspectRatio;

@synthesize currentFlags = _currentFlags;

- (void) setPosition:(GLKVector3)position {
    _position = position;
    [self updateViewVolume];
}

- (void) setTarget:(GLKVector3)target {
    _target = target;
    [self updateViewVolume];
}

- (void) setUp:(GLKVector3)up {
    _up = GLKVector3Normalize(up);
    [self updateViewVolume];
}

- (void) setWidth:(NSUInteger)width {
    _width = width;
    self.aspectRatio = width / (float) self.height;
}

- (void) setHeight:(NSUInteger)height {
    _height = height;
    self.aspectRatio = self.width / (float) height;
}


- (GLKMatrix4) getViewMatrix {
    return self.viewVolume.view;
}
- (GLKMatrix4) getProjectionMatrix {
    return self.viewVolume.projection;
}


//
// TODO: build out camera class enough so that these methods can be replaced
//
- (void) setViewMatrix:(GLKMatrix4)view {
    self.viewVolume.view = view;
}

- (void) setProjectionMatrix:(GLKMatrix4)projection {
    self.viewVolume.projection = projection;
}


- (void) updateViewVolume {
    self.viewVolume.view = GLKMatrix4MakeLookAt(self.position.v[0], self.position.v[1], self.position.v[2],
                                                self.target.v[0], self.target.v[1], self.target.v[2],
                                                self.up.v[0], self.up.v[1], self.up.v[2]);
}

- (instancetype) init {
    self = [super init];
    if (self != nil) {
        //
        // TODO: allow default values to be configured or set them to same defaults
        //       as either Maya, Blender, 3DS Max, Unreal, etc. based on whichever
        //       makes the most sense (try Maya first, would be a nice nod towards
        //       Alias Wavefront which also where the obj file format comes from)
        //
        GLKVector3 position = GLKVector3Make(0.0f, 2.0f, 4.0f);
        GLKVector3 target = GLKVector3Make(0.0f, 0.0f, 0.0f);
        GLKVector3 up = GLKVector3Make(0.0f, 1.0f, 0.0f);


        //
        // TODO: transition to UVN camera implementation
        //


        [self setPosition:position];
        [self setTarget:target];
        [self setUp:up];

        // set initial vectors so that the camera can be reset if the user becomes lost
        [self setInitialPosition:[self position]];
        [self setInitialTarget:[self target]];
        [self setInitialUp:[self up]];

        NFViewVolume *viewVolume = [[[NFViewVolume alloc] init] autorelease];

        viewVolume.view = GLKMatrix4MakeLookAt(position.v[0], position.v[1], position.v[2],
                                               target.v[0], target.v[1], target.v[2],
                                               up.v[0], up.v[1], up.v[2]);

        //
        // TODO: need to set the projection matrix
        //
/*
        float nearPlane = 1.0f;
        float farPlane = 100.0f;

        CGFloat width = self.frame.size.width;
        CGFloat height = self.frame.size.height;

        GLKMatrix4 projection = GLKMatrix4MakePerspective(M_PI_4, width / height, nearPlane, farPlane);
        [self.viewVolume pushProjectionMatrix:projection];

        self.viewVolume.nearPlane = 1.0f;
        self.viewVolume.farPlane = 100.0f;
*/


        [self setViewVolume:viewVolume];


        [self setCurrentFlags:0x00];

        //[self setMotionVector:GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f)];

        [self setTranslationSpeed:GLKVector4Make(0.025f, 0.0f, 0.025f, 0.0f)];
    }
    return self;
}

- (instancetype) initWithPosition:(GLKVector3)position withTarget:(GLKVector3)target withUp:(GLKVector3)up {
    self = [super init];
    if (self != nil) {
        [self setPosition:position];
        [self setTarget:target];
        [self setUp:up];

        // set initial vectors so that the camera can be reset if the user becomes lost
        [self setInitialPosition:position];
        [self setInitialTarget:target];
        [self setInitialUp:up];

        [self setCurrentFlags:0x00];

        //[self setMotionVector:GLKVector4Make(0.0f, 0.0f, 0.0f, 0.0f)];

        [self setTranslationSpeed:GLKVector4Make(0.025f, 0.0f, 0.025f, 0.0f)];
    }
    return self;
}

- (void) step:(NSUInteger)delta {
    //
    // TODO: update camera position based on motion vector
    //

    BOOL positionChanged = NO;

    GLKVector3 newPosition = self.position;
    GLKVector3 newTarget = self.target;

    // NOTE: delta is measured in microseconds

    //
    // TODO: increment position by multiple of time delta and use
    //       slide based logic to update UVN based camera
    //

/*
    void Camera::slide(float delU, float delV, float delN)
    {
        eye.x += delU * u.x + delV * v.x + delN * n.x;
        eye.y += delU * u.y + delV * v.y + delN * n.y;
        eye.z += delU * u.z + delV * v.z + delN * n.z;
        setModelViewMatrix();
    }

    void Camera::slideXZ(float delU, float delN)
    {
        eye.x += delU * u.x + delN * n.x;
        eye.z += delU * u.z + delN * n.z;
        setModelViewMatrix();
    }
*/

    if (self.currentFlags & FORWARD_BIT) {
        newPosition.v[Z_IDX] -= self.translationSpeed.v[Z_IDX];
        newTarget.v[Z_IDX] -= self.translationSpeed.v[Z_IDX];
        positionChanged = YES;
    }

    if (self.currentFlags & BACK_BIT) {
        newPosition.v[Z_IDX] += self.translationSpeed.v[Z_IDX];
        newTarget.v[Z_IDX] += self.translationSpeed.v[Z_IDX];
        positionChanged = YES;
    }

    if (self.currentFlags & LEFT_BIT) {
        newPosition.v[X_IDX] += self.translationSpeed.v[X_IDX];
        newTarget.v[X_IDX] += self.translationSpeed.v[X_IDX];
        positionChanged = YES;
    }

    if (self.currentFlags & RIGHT_BIT) {
        newPosition.v[X_IDX] -= self.translationSpeed.v[X_IDX];
        newTarget.v[X_IDX] -= self.translationSpeed.v[X_IDX];
        positionChanged = YES;
    }

    if (positionChanged) {
        self.position = newPosition;
        self.target = newTarget;
    }
}

- (void) pushMotionVector:(NFMotionVector *)motionVector {
    //
}

- (void) clearMotionVectors {
    //
}

- (void) setState:(CAMERA_STATE)state {

    //
    // TODO: this should be checking against the bit flags
    //       not the enum state
    //

    if (state == kCameraStateActFwd && self.currentFlags & FORWARD_BIT) {
        return;
    }
    else if (state == kCameraStateActBack && self.currentFlags & BACK_BIT) {
        return;
    }

    switch (state) {

        // set direction bit and update position

        case kCameraStateActFwd:
            self.currentFlags = self.currentFlags | FORWARD_BIT;
            break;

        case kCameraStateActBack:
            self.currentFlags = self.currentFlags | BACK_BIT;
            break;

        case kCameraStateActLeft:
            self.currentFlags = self.currentFlags | LEFT_BIT;
            break;

        case kCameraStateActRight:
            self.currentFlags = self.currentFlags | RIGHT_BIT;
            break;

        // unset direction bit

        case kCameraStateNilFwd:
            self.currentFlags = self.currentFlags & ~FORWARD_BIT;
            break;

        case kCameraStateNilBack:
            self.currentFlags = self.currentFlags & ~BACK_BIT;
            break;

        case kCameraStateNilLeft:
            self.currentFlags = self.currentFlags & ~LEFT_BIT;
            break;

        case kCameraStateNilRight:
            self.currentFlags = self.currentFlags & ~RIGHT_BIT;
            break;
    }
}

- (void) resetTarget {
    self.target = self.initialTarget;
}

- (void) resetPosition {
    self.up = self.initialUp;
    self.position = self.initialPosition;
}

- (void) setPosition:(GLKVector3)position withTarget:(GLKVector3)target withUp:(GLKVector3)up {
    self.position = position;
    self.target = target;
    self.up = up;

    self.N = GLKVector3Subtract(position, target);
    self.U = GLKVector3CrossProduct(up, self.N);

    self.N = GLKVector3Normalize(self.N);
    self.U = GLKVector3Normalize(self.U);

    self.V = GLKVector3CrossProduct(self.N, self.U);

    [self updateModelViewMatrix];
}

- (void) roll:(float)angle {
    float cs = cosf(angle);
    float sn = cosf(angle);

    GLKVector3 t = self.U;

    //
    // TODO: use X_IDX, Y_IDX, Z_IDX
    //

    self.U.v[0] = cs * t.v[0] - sn * self.V.v[0];
    self.U.v[1] = cs * t.v[1] - sn * self.V.v[1];
    self.U.v[2] = cs * t.v[2] - sn * self.V.v[2];

    self.V.v[0] = sn * t.v[0] + cs * self.V.v[0];
    self.V.v[1] = sn * t.v[1] + cs * self.V.v[1];
    self.V.v[2] = sn * t.v[2] + cs * self.V.v[2];

    [self updateModelViewMatrix];
}

- (void) pitch:(float)angle {
    float cs = cosf(angle);
    float sn = sinf(angle);

    GLKVector3 t = self.N;

    self.N.v[0] = cs * t.v[0] - sn * self.V.v[0];
    self.N.v[1] = cs * t.v[1] - sn * self.V.v[1];
    self.N.v[2] = cs * t.v[2] - sn * self.V.v[2];

    self.V.v[0] = sn * t.v[0] + cs * self.V.v[0];
    self.V.v[1] = sn * t.v[1] + cs * self.V.v[1];
    self.V.v[2] = sn * t.v[2] + cs * self.V.v[2];

    [self updateModelViewMatrix];
}

- (void) yaw:(float)angle {
    float cs = cosf(angle);
    float sn = sinf(angle);

    GLKVector3 t = self.U;

    self.U.v[0] = cs * t.v[0] - sn * self.N.v[0];
    self.U.v[1] = cs * t.v[1] - sn * self.N.v[1];
    self.U.v[2] = cs * t.v[2] - sn * self.N.v[2];

    self.N.v[0] = sn * t.v[0] + cs * self.N.v[0];
    self.N.v[1] = sn * t.v[1] + cs * self.N.v[1];
    self.N.v[2] = sn * t.v[2] + cs * self.N.v[2];

    [self updateModelViewMatrix];
}

- (void) calculatePositionTargetUp {
    //
    // TODO: calculate position, target, and up vectors from UVN
    //
}

- (void) updateModelViewMatrix {
    GLKMatrix4 viewMat;

    viewMat.m[0] = self.U.v[0];
    viewMat.m[1] = self.V.v[0];
    viewMat.m[2] = self.N.v[0];
    viewMat.m[3] = 0.0f;

    viewMat.m[4] = self.U.v[1];
    viewMat.m[5] = self.V.v[1];
    viewMat.m[6] = self.N.v[1];
    viewMat.m[7] = 0.0f;

    viewMat.m[8]  = self.U.v[2];
    viewMat.m[9]  = self.V.v[2];
    viewMat.m[10] = self.N.v[2];
    viewMat.m[11] = 0.0f;

    viewMat.m[12] = -1.0f * GLKVector3DotProduct(self.position, self.U);
    viewMat.m[13] = -1.0f * GLKVector3DotProduct(self.position, self.V);
    viewMat.m[14] = -1.0f * GLKVector3DotProduct(self.position, self.N);
    viewMat.m[15] = 1.0f;

    self.viewVolume.view = viewMat;
}

@end

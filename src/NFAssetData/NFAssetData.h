//
//  NSAssetData.h
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "NFCommonTypes.h"
#import "NFAssetSubset.h"

#import "NFRResources.h"
#import "NFSurfaceModel.h"


//
// TODO: this definition out into NFUtils, will eventually need to turn it into
//       an actual (though primitives at first) animation system
//
typedef GLKMatrix4 (^transformBlock_f)(GLKMatrix4, float);


@interface NFAssetData : NSObject

@property (nonatomic, assign) GLKMatrix4 modelMatrix;

@property (nonatomic, retain) NSArray* subsetArray;
@property (nonatomic, retain) NSArray* surfaceModelArray;

@property (nonatomic, retain) NFRGeometry* geometry;

@property (nonatomic, assign) transformBlock_f transformBlock;



- (instancetype) init;
- (void) dealloc;

- (void) stepTransforms:(float)secsElapsed;

- (void) generateRenderables;


//
// TODO: remove these terrible debug/test calls
//
- (void) applyUnitScalarMatrix;
- (void) applyOriginCenterMatrix;

@end

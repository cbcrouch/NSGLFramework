//
//  NSAssetData.h
//  NSFramework
//
//  Copyright (c) 2016 Casey Crouch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "NFCommonTypes.h"
#import "NFAssetSubset.h"

#import "NFRResources.h"
#import "NFSurfaceModel.h"


//
// TODO: move this definition out into NFUtils, will eventually need to turn it into
//       an actual (though primitive at first) animation system
//
typedef GLKMatrix4 (^transformBlock_f)(GLKMatrix4, float);


@interface NFAssetData : NSObject

@property (nonatomic, assign) GLKMatrix4 modelMatrix;

@property (nonatomic, strong) NSArray* subsetArray;
@property (nonatomic, strong) NSArray* surfaceModelArray;
@property (nonatomic, strong) NFRGeometry* geometry;

@property (nonatomic, weak) transformBlock_f transformBlock;


- (void) stepTransforms:(float)secsElapsed;
- (void) generateRenderables;


//
// TODO: cleanup these debug/test calls and keep them around for handy editing/visualizing
//
- (void) applyUnitScalarMatrix;
- (void) applyOriginCenterMatrix;

@end

//
//  ADTransformTransition.h
//  Transition
//
//  Created by Patrick Nollet on 08/03/11.
//  Copyright 2011 Applidium. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADTransition.h"

@interface ADTransformTransition : ADTransition {
    CATransform3D _inLayerTransform;
    CATransform3D _outLayerTransform;
    CAAnimation * _animation;
}

@property (readonly) CAAnimation * animation;
@property (readonly) CATransform3D inLayerTransform;
@property (readonly) CATransform3D outLayerTransform;

- (id)initWithAnimation:(CAAnimation *)animation inLayerTransform:(CATransform3D)inTransform outLayerTransform:(CATransform3D)outTransform;
- (id)initWithAnimation:(CAAnimation *)animation inLayerTransform:(CATransform3D)inTransform outLayerTransform:(CATransform3D)outTransform reversed:(BOOL)reversed;
- (id)initWithAnimation:(CAAnimation *)animation reversed:(BOOL)reversed;
- (id)initWithAnimation:(CAAnimation *)animation orientation:(ADTransitionOrientation)orientation reversed:(BOOL)reversed;
- (id)initWithAnimation:(CAAnimation *)animation orientation:(ADTransitionOrientation)orientation inLayerTransform:(CATransform3D)inTransform outLayerTransform:(CATransform3D)outTransform reversed:(BOOL)reversed;

@end

//
//  ADModernPushTransition.m
//  AppLibrary
//
//  Created by Martin Guillon on 23/09/13.
//
//

#import "ADModernPushTransition.h"
#import "CAMediaTimingFunction+AdditionalEquations.h"

@interface ADModernPushTransition()
{
    CABasicAnimation * fadeAnimation;
    UIView* fadeView;
}
@end

@implementation ADModernPushTransition

-(void) dealloc
{
    [super dealloc];
    if (fadeView) {
        [fadeView release];
        fadeView = nil;
    }
}

- (id)initWithDuration:(CFTimeInterval)duration orientation:(ADTransitionOrientation)orientation sourceRect:(CGRect)sourceRect {

    const CGFloat viewWidth = sourceRect.size.width;
    const CGFloat viewHeight = sourceRect.size.height;

    CABasicAnimation * inSwipeAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    inSwipeAnimation.timingFunction = [CAMediaTimingFunction easeInOutCirc];
    inSwipeAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    switch (orientation) {
        case ADTransitionRightToLeft:
        {
            inSwipeAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(viewWidth, 0.0f, 0.0f)];
        }
            break;
        case ADTransitionLeftToRight:
        {
            inSwipeAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(- viewWidth, 0.0f, 0.0f)];
        }
            break;
        case ADTransitionTopToBottom:
        {
            inSwipeAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0.0f, - viewHeight, 0.0f)];
        }
            break;
        case ADTransitionBottomToTop:
        {
            inSwipeAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(0.0f, viewHeight, 0.0f)];
        }
            break;
        default:
            NSAssert(FALSE, @"Unhandled ADTransitionOrientation");
            break;
    }
    inSwipeAnimation.duration = duration;

    CABasicAnimation * outOpacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    outOpacityAnimation.fromValue = @1.0f;
    outOpacityAnimation.toValue = @0.5f;

    CABasicAnimation * outPositionAnimation = [CABasicAnimation animationWithKeyPath:@"zPosition"];
    outPositionAnimation.fromValue = @-0.001;
    outPositionAnimation.toValue = @-0.001;
    outPositionAnimation.duration = duration;

    CAAnimationGroup * outAnimation = [CAAnimationGroup animation];
    [outAnimation setAnimations:@[outOpacityAnimation, outPositionAnimation]];
    outAnimation.duration = duration;
    
    fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnimation.fromValue = @0.0f;
    fadeAnimation.toValue = @0.2f;
    fadeAnimation.duration = duration;
    
    fadeView = [[UIView alloc] initWithFrame:CGRectZero];
    fadeView.backgroundColor = [UIColor blackColor];

    self = [super initWithInAnimation:inSwipeAnimation andOutAnimation:outAnimation];
    return self;
}


-(void)prepareTransitionFromView:(UIView *)viewOut toView:(UIView *)viewIn inside:(UIView *)viewContainer
{
    [super prepareTransitionFromView:viewOut toView:viewIn inside:viewContainer];
    fadeView.frame = viewOut.bounds;
    [viewOut addSubview:fadeView];
}

-(void)finishedTransitionFromView:(UIView *)viewOut toView:(UIView *)viewIn inside:(UIView *)viewContainer
{
    [fadeView removeFromSuperview];
    [super finishedTransitionFromView:viewOut toView:viewIn inside:viewContainer];
}

-(void)startTransitionFromView:(UIView *)viewOut toView:(UIView *)viewIn inside:(UIView *)viewContainer {
    [super startTransitionFromView:viewOut toView:viewIn inside:viewContainer];
    [fadeView.layer addAnimation:fadeAnimation forKey:@"opacity"];
}

@end

//
//  ADNavigationControllerDelegate.m
//  ADTransitionController
//
//  Created by Patrick Nollet on 09/10/13.
//  Copyright (c) 2013 Applidium. All rights reserved.
//

#import "ADNavigationControllerDelegate.h"
#import "ADTransitioningDelegate.h"
#import "UIGestureRecognizer+ADNavTransition.h"

@interface ADNavigationControllerDelegate() <UINavigationControllerDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) ADTransitioningDelegate* currentTransition;
@property (nonatomic, assign) BOOL shouldCompleteCurrentInteractiveTransition;
@end


@implementation ADNavigationControllerDelegate

- (void)dealloc
{
    [_delegate release];
    [super dealloc];
}

- (void)manageNavigationController:(UINavigationController *)navigationController
{
    navigationController.delegate = self;
    _isInteractive = YES;
    _isInteracting = NO;
    // This part is *risky*.  Based on http://stackoverflow.com/a/20923477/860000
    [navigationController view]; // interactivePopGestureRecognizer is initialized in -viewDidLoad
    navigationController.interactivePopGestureRecognizer.delegate = self;
    navigationController.interactivePopGestureRecognizer.AD_viewController = navigationController;
    [navigationController.interactivePopGestureRecognizer addTarget:self action:@selector(handlePanGesture:)];
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (_delegate) {
        id result = [_delegate navigationController:navigationController animationControllerForOperation:operation fromViewController:fromVC toViewController:toVC];
        if (result) {
          return result;
        }
    }
  
    BOOL shouldAddGestureRecognizers = NO;
  id<UIViewControllerAnimatedTransitioning> result = self.currentTransition;
    
    switch (operation) {
        case UINavigationControllerOperationPush:
            shouldAddGestureRecognizers = _isInteractive;
            if ([toVC.transitioningDelegate isKindOfClass:[ADTransitioningDelegate class]]) {
                result = self.currentTransition = (ADTransitioningDelegate *)toVC.transitioningDelegate;
                self.currentTransition.transition.type = ADTransitionTypePush;
                if (self.currentTransition.transition.onlyForPop) {
                  result = nil;
                }
            }
            else {
                result = self.currentTransition = nil;
            }
            break;
        case UINavigationControllerOperationPop:
            if ([fromVC.transitioningDelegate isKindOfClass:[ADTransitioningDelegate class]]){
                result = self.currentTransition = (ADTransitioningDelegate *)fromVC.transitioningDelegate;
                self.currentTransition.transition.type = ADTransitionTypePop;
                if (self.currentTransition.transition.onlyForPush) {
                  result = nil;
                }
            }
            else {
              result = self.currentTransition = nil;
            }
            break;
        case UINavigationControllerOperationNone:
        default:
          result = self.currentTransition = nil;
    }
    if (shouldAddGestureRecognizers) {
        [toVC.view addGestureRecognizer:[self panGestureRecognizerForLeftEdgeOfViewController:toVC]];
    }

    return result;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    if (_isInteracting && animationController == self.currentTransition) {
        return self.currentTransition;
    }
    
    return nil;
}

- (UIScreenEdgePanGestureRecognizer *)panGestureRecognizerForLeftEdgeOfViewController:(UIViewController *)viewController
{
    UIScreenEdgePanGestureRecognizer *panGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGestureRecognizer.AD_viewController = viewController;
    panGestureRecognizer.edges = UIRectEdgeLeft;
    panGestureRecognizer.delegate = self;
    return panGestureRecognizer;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)sender
{
    CGPoint point = [sender translationInView:[sender.view window]];
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            self.isInteracting = YES;
            [sender.AD_viewController.navigationController popViewControllerAnimated:YES];
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            CGFloat percentComplete = point.x / CGRectGetWidth([sender.view window].bounds);
            self.shouldCompleteCurrentInteractiveTransition = percentComplete > 0.5;
            [self.currentTransition updateInteractiveTransition:fmaxf(0, percentComplete)];
            break;
        }
            
        case UIGestureRecognizerStateEnded:
            if (self.shouldCompleteCurrentInteractiveTransition) {
                [self.currentTransition finishInteractiveTransition];
            } else {
                [self.currentTransition cancelInteractiveTransition];
//                [self performSelector:@selector(resetIsInteractive)
//                           withObject: nil
//                           afterDelay:0.01];

            }
            break;
            
        case UIGestureRecognizerStateCancelled:
            [self.currentTransition cancelInteractiveTransition];
            break;
            
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStatePossible:
            break;
    }
}

-(void)resetIsInteractive {
    self.isInteracting = NO;
}

#pragma mark - UINavigationController swipe configuration

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (!_isInteractive) return NO;
    UIViewController *viewController = gestureRecognizer.AD_viewController;
    UINavigationController *navigationController = [viewController isKindOfClass:[UINavigationController class]] ? (id)viewController : viewController.navigationController;
    
    if ([navigationController.transitionCoordinator isAnimated]) {
        return NO;
    }
//    int count = navigationController.viewControllers.count;
    if (navigationController.viewControllers.count < 2) {
        return NO;
    }
    
    if (gestureRecognizer == navigationController.interactivePopGestureRecognizer) {
        return self.currentTransition == nil || self.currentTransition.transition.onlyForPush;
    }
    
    return self.currentTransition != nil && !self.currentTransition.transition.onlyForPush;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (_delegate) {
        [_delegate navigationController:navigationController willShowViewController:viewController animated:animated];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.isInteracting = NO;
    if (_delegate) {
        [_delegate navigationController:navigationController didShowViewController:viewController animated:animated];
    }
}

@end

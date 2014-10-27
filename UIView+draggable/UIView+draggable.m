//
//  UIView+draggable.m
//  UIView+draggable
//
//  Created by Andrea on 13/03/14.
//  Copyright (c) 2014 Fancy Pixel. All rights reserved.
//

#import "UIView+draggable.h"
#import <objc/runtime.h>

@implementation UIView (draggable)

- (void)setPanGesture:(UIPanGestureRecognizer*)panGesture
{
	objc_setAssociatedObject(self, @selector(panGesture), panGesture, OBJC_ASSOCIATION_RETAIN);
}

- (UIPanGestureRecognizer*)panGesture
{
	return objc_getAssociatedObject(self, @selector(panGesture));
}

- (void)setCagingArea:(CGRect)cagingArea
{
    if (CGRectContainsRect(cagingArea, self.frame)) {
        NSValue *cagingAreaValue = [NSValue valueWithCGRect:cagingArea];
        objc_setAssociatedObject(self,
                                 @selector(cagingArea),
                                 cagingAreaValue,
                                 OBJC_ASSOCIATION_RETAIN);
    }
}

- (CGRect)cagingArea
{
    NSValue *cagingAreaValue = objc_getAssociatedObject(self,
                                                        @selector(cagingArea));
    
    return [cagingAreaValue CGRectValue];
}

- (void)handlePan:(UIPanGestureRecognizer*)sender
{
	[self adjustAnchorPointForGestureRecognizer:sender];
	
	CGPoint translation = [sender translationInView:[self superview]];
    
    CGFloat newXOrigin = CGRectGetMinX(self.frame) + translation.x;
    CGFloat newYOrigin = CGRectGetMinY(self.frame) + translation.y;
    
    CGRect cagingArea = self.cagingArea;

    CGFloat cagingAreaOriginX = CGRectGetMinX(cagingArea);
    CGFloat cagingAreaOriginY = CGRectGetMinY(cagingArea);
    
    CGFloat cagingAreaRightSide = cagingAreaOriginX + CGRectGetWidth(cagingArea);
    CGFloat cagingAreaBottomSide = cagingAreaOriginY + CGRectGetHeight(cagingArea);
    
    if (!CGRectEqualToRect(cagingArea, CGRectZero)) {
        
        // Check to make sure the view is still within the caging area
        if (newXOrigin <= cagingAreaOriginX ||
            newYOrigin <= cagingAreaOriginY ||
            newXOrigin + CGRectGetWidth(self.frame) >= cagingAreaRightSide ||
            newYOrigin + CGRectGetHeight(self.frame) >= cagingAreaBottomSide) {
            
            // Don't move
            newXOrigin = CGRectGetMinX(self.frame);
            newYOrigin = CGRectGetMinY(self.frame);
        }
    }
    
    [self setFrame:CGRectMake(newXOrigin,
                              newYOrigin,
                              CGRectGetWidth(self.frame),
                              CGRectGetHeight(self.frame))];
    
    [sender setTranslation:(CGPoint){0, 0} inView:[self superview]];
}

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = self;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}

- (void)setDraggable:(BOOL)draggable
{
	[self.panGesture setEnabled:draggable];
}

- (void)enableDragging
{
	self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
	[self.panGesture setMaximumNumberOfTouches:1];
	[self.panGesture setMinimumNumberOfTouches:1];
	[self.panGesture setCancelsTouchesInView:NO];
	[self addGestureRecognizer:self.panGesture];
}

@end

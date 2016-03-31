//
//  UIView+draggable.m
//  UIView+draggable
//
//  Created by Andrea on 13/03/14.
//  Copyright (c) 2016 Andrea Mazzini. All rights reserved.
//

#import "UIView+draggable.h"
#import <objc/runtime.h>

@implementation UIView (draggable)

#pragma mark - Associated properties

- (void)setPanGesture:(UIPanGestureRecognizer*)panGesture {
    objc_setAssociatedObject(self, @selector(panGesture), panGesture, OBJC_ASSOCIATION_RETAIN);
}

- (UIPanGestureRecognizer*)panGesture {
    return objc_getAssociatedObject(self, @selector(panGesture));
}

- (void)setCagingArea:(CGRect)cagingArea {
    if (CGRectEqualToRect(cagingArea, CGRectZero) ||
        CGRectContainsRect(cagingArea, self.frame)) {
        NSValue *cagingAreaValue = [NSValue valueWithCGRect:cagingArea];
        objc_setAssociatedObject(self, @selector(cagingArea), cagingAreaValue, OBJC_ASSOCIATION_RETAIN);
    }
}

- (CGRect)cagingArea {
    NSValue *cagingAreaValue = objc_getAssociatedObject(self, @selector(cagingArea));
    return [cagingAreaValue CGRectValue];
}

- (void)setHandle:(CGRect)handle {
    CGRect relativeFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if (CGRectContainsRect(relativeFrame, handle)) {
        NSValue *handleValue = [NSValue valueWithCGRect:handle];
        objc_setAssociatedObject(self, @selector(handle), handleValue, OBJC_ASSOCIATION_RETAIN);
    }
}

- (CGRect)handle {
    NSValue *handleValue = objc_getAssociatedObject(self, @selector(handle));
    return [handleValue CGRectValue];
}

- (void)setShouldMoveAlongY:(BOOL)newShould {
    NSNumber *shouldMoveAlongYBool = [NSNumber numberWithBool:newShould];
    objc_setAssociatedObject(self, @selector(shouldMoveAlongY), shouldMoveAlongYBool, OBJC_ASSOCIATION_RETAIN );
}

- (BOOL)shouldMoveAlongY {
    NSNumber *moveAlongY = objc_getAssociatedObject(self, @selector(shouldMoveAlongY));
    return (moveAlongY) ? [moveAlongY boolValue] : YES;
}

- (void)setShouldMoveAlongX:(BOOL)newShould {
    NSNumber *shouldMoveAlongXBool = [NSNumber numberWithBool:newShould];
    objc_setAssociatedObject(self, @selector(shouldMoveAlongX), shouldMoveAlongXBool, OBJC_ASSOCIATION_RETAIN );
}

- (BOOL)shouldMoveAlongX {
    NSNumber *moveAlongX = objc_getAssociatedObject(self, @selector(shouldMoveAlongX));
    return (moveAlongX) ? [moveAlongX boolValue] : YES;
}

- (void)setDraggingStartedBlock:(void (^)(UIView *))draggingStartedBlock {
    objc_setAssociatedObject(self, @selector(draggingStartedBlock), draggingStartedBlock, OBJC_ASSOCIATION_RETAIN);
}

- (void (^)(UIView *))draggingStartedBlock {
    return objc_getAssociatedObject(self, @selector(draggingStartedBlock));
}

- (void)setDraggingMovedBlock:(void (^)(UIView *))draggingMovedBlock {
    objc_setAssociatedObject(self, @selector(draggingMovedBlock), draggingMovedBlock, OBJC_ASSOCIATION_RETAIN);
}

- (void (^)(UIView *))draggingMovedBlock {
    return objc_getAssociatedObject(self, @selector(draggingMovedBlock));
}

- (void)setDraggingEndedBlock:(void (^)(UIView *))draggingEndedBlock {
    objc_setAssociatedObject(self, @selector(draggingEndedBlock), draggingEndedBlock, OBJC_ASSOCIATION_RETAIN);
}

- (void (^)(UIView *))draggingEndedBlock {
    return objc_getAssociatedObject(self, @selector(draggingEndedBlock));
}

#pragma mark - Gesture recognizer

- (void)handlePan:(UIPanGestureRecognizer*)sender {
    // Check to make you drag from dragging area
    CGPoint locationInView = [sender locationInView:self];
    if (!CGRectContainsPoint(self.handle, locationInView)
        && sender.state == UIGestureRecognizerStateBegan) {
        return;
    }

    [self adjustAnchorPointForGestureRecognizer:sender];

    if (sender.state == UIGestureRecognizerStateBegan && self.draggingStartedBlock) {
        self.draggingStartedBlock(self);
    }

    if (sender.state == UIGestureRecognizerStateChanged && self.draggingMovedBlock) {
        self.draggingMovedBlock(self);
    }

    if (sender.state == UIGestureRecognizerStateEnded && self.draggingEndedBlock) {
        self.layer.anchorPoint = CGPointMake(0.5, 0.5);
        self.draggingEndedBlock(self);
    }

    CGPoint translation = [sender translationInView:[self superview]];

    CGFloat newXOrigin = CGRectGetMinX(self.frame) + (([self shouldMoveAlongX]) ? translation.x : 0);
    CGFloat newYOrigin = CGRectGetMinY(self.frame) + (([self shouldMoveAlongY]) ? translation.y : 0);

    CGRect cagingArea = self.cagingArea;

    CGFloat cagingAreaOriginX = CGRectGetMinX(cagingArea);
    CGFloat cagingAreaOriginY = CGRectGetMinY(cagingArea);

    CGFloat cagingAreaRightSide = cagingAreaOriginX + CGRectGetWidth(cagingArea);
    CGFloat cagingAreaBottomSide = cagingAreaOriginY + CGRectGetHeight(cagingArea);

    if (!CGRectEqualToRect(cagingArea, CGRectZero)) {
        // Check to make sure the view is still horizontaly within the caging area
        if (newXOrigin <= cagingAreaOriginX ||
            newXOrigin + CGRectGetWidth(self.frame) >= cagingAreaRightSide) {
            // Don't move
            newXOrigin = CGRectGetMinX(self.frame);
        }

        // Check to make sure the view is still vertically within the caging area
        if(newYOrigin <= cagingAreaOriginY ||
           newYOrigin + CGRectGetHeight(self.frame) >= cagingAreaBottomSide) {
            // Don't move
            newYOrigin = CGRectGetMinY(self.frame);
        }
    }

    self.frame = CGRectMake(newXOrigin,
                            newYOrigin,
                            CGRectGetWidth(self.frame),
                            CGRectGetHeight(self.frame));

    [sender setTranslation:(CGPoint){0, 0} inView:[self superview]];
}

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint locationInView = [gestureRecognizer locationInView:self];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:self.superview];

        self.layer.anchorPoint = CGPointMake(locationInView.x / self.bounds.size.width, locationInView.y / self.bounds.size.height);
        self.center = locationInSuperview;
    }
}

#pragma mark - Drag state handling

- (void)setDraggable:(BOOL)draggable {
    self.panGesture.enabled = draggable;
}

- (void)enableDragging {
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.panGesture.maximumNumberOfTouches = 1;
    self.panGesture.minimumNumberOfTouches = 1;
    self.panGesture.cancelsTouchesInView = NO;
    self.handle = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addGestureRecognizer:self.panGesture];
}

@end

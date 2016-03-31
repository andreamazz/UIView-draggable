#import <objc/runtime.h>

#define EXP_SHORTHAND
#import <Specta/Specta.h>
#import <Expecta/Expecta.h>
#import <Expecta+Snapshots/EXPMatchers+FBSnapshotTest.h>
#import <OCMock/OCMock.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import "UIView+draggable.h"

#define P(x, y) [NSValue valueWithCGPoint:CGPointMake(x, y)]

@implementation UIPanGestureRecognizer(Mocking)

+ (void)setupMockRecognizer:(UIPanGestureRecognizer *)mockRecognizer
        toReturnTranslation:(CGPoint)translation {
    [given([mockRecognizer translationInView:anything()]) willReturnStruct:&translation
                                                                  objCType:@encode(CGPoint)];
}

+ (void)setupMockRecognizer:(UIPanGestureRecognizer *)mockRecognizer
                toBeInState:(UIGestureRecognizerState)state {
    [given([mockRecognizer state]) willReturnInteger:state];
}

@end

@implementation UIView(PanGestureRecognizerMockingTools)

- (void)performAction:(SEL)action withRecognizer:(UIPanGestureRecognizer *)recognizer {
    ((void (*)(id, SEL, UIPanGestureRecognizer*))[self methodForSelector:action])(self, action, recognizer);
}

- (void)setupMockRecognizer:(UIPanGestureRecognizer *)mockRecognizer
           toReturnLocation:(CGPoint)location {
    CGPoint locationInSuperview = [self convertPoint:location toView:self.superview];
    
    [given([mockRecognizer locationInView:self]) willReturnStruct:&location
                                                         objCType:@encode(CGPoint)];
    [given([mockRecognizer locationInView:self.superview]) willReturnStruct:&locationInSuperview
                                                                   objCType:@encode(CGPoint)];
}

- (void)simulatePanGestureWithCheckPoints:(NSArray *)points action:(SEL)action {
    CGPoint firstPoint = [points[0] CGPointValue];
    __block CGPoint prevPoint = firstPoint;
    [points enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGPoint point = [obj CGPointValue];
        UIPanGestureRecognizer *mockRecognizer = mock([UIPanGestureRecognizer class]);
        UIGestureRecognizerState state = UIGestureRecognizerStateChanged;
        if (idx == 0) {
            state = UIGestureRecognizerStateBegan;
        } else if (idx == points.count - 1) {
            state = UIGestureRecognizerStateEnded;
        }
        [self setupMockRecognizer:mockRecognizer toReturnLocation:firstPoint];
        [UIPanGestureRecognizer setupMockRecognizer:mockRecognizer toBeInState:state];
        [UIPanGestureRecognizer setupMockRecognizer:mockRecognizer
                                toReturnTranslation:CGPointMake(point.x - prevPoint.x,
                                                                point.y - prevPoint.y)];
        prevPoint = point;
        
        [self performAction:action withRecognizer:mockRecognizer];
    }];
}

@end

SpecBegin(UIView_draggable)

describe(@"draggable view", ^{
    __block UIView *view = nil;
    __block UIView *container = nil;
    
    beforeEach(^{
        view = [[UIView alloc] initWithFrame:(CGRect){80.0, 50.0, 100.0, 50.0}];
        [view setBackgroundColor:[UIColor lightGrayColor]];
        
        container = [[UIView alloc] initWithFrame:(CGRect){0.0, 0.0, 300.0, 300.0}];
        [container setBackgroundColor:[UIColor whiteColor]];
        
        [container addSubview:view];
    });
    
    context(@"when dragging is enabled", ^{
        __block id recognizerTarget = nil;
        __block SEL recognizerSelector;
        __block UIPanGestureRecognizer *mockRecognizer = nil;
        
        beforeEach(^{
            [view enableDragging];
            
            mockRecognizer = mock([UIPanGestureRecognizer class]);
            
            // assuming that dragging feature is implemented using UIPanGestureRecognizer and
            // relying on private internals of UIGestureRecognizer so that we can simulate pan gestures
            id targetsContainer = [view.panGesture valueForKey:@"targets"][0];
            recognizerTarget = [targetsContainer valueForKey:@"target"];
            recognizerSelector = ((SEL (*)(id, const char*))object_getIvar)
            (targetsContainer, (const char*)class_getInstanceVariable([targetsContainer class], "_action"));
        });
        
        describe(@"pan gesture recognizer", ^{
            it(@"should be set", ^{
                expect(view.panGesture).to.beAKindOf([UIPanGestureRecognizer class]);
            });
            
            it(@"should have subject view as target", ^{
                expect(recognizerTarget).to.equal(view);
            });
            
            it(@"should have an action supported by the subject view", ^{
                expect(view).to.respondTo(recognizerSelector);
            });
        });
        
        describe(@"default state", ^{
            it(@"should have zero caging area by default", ^{
                expect(view.cagingArea).to.equal(CGRectZero);
            });
            
            it(@"should have handle rect size equal to its frame size by default", ^{
                expect(view.handle).to.equal((CGRect){0.0, 0.0, 100.0, 50.0});
            });
            
            it(@"should not restrict movement along X axis by default", ^{
                expect(view.shouldMoveAlongX).to.beTruthy();
            });
            
            it(@"should not restrict movement along Y axis by default", ^{
                expect(view.shouldMoveAlongY).to.beTruthy();
            });
            
            it(@"should reset handle rect when dragging is enabled again", ^{
                [view setHandle:(CGRect){40.0, 80.0, 10.0, 20.0}];
                [view enableDragging];
                expect(view.handle).to.equal((CGRect){0.0, 0.0, 100.0, 50.0});
            });
        });
        
        describe(@"dragging", ^{
            it(@"should change view origin according to pan gesture recognizer translation", ^{
                [view simulatePanGestureWithCheckPoints:@[P(30.0, 22.0),
                                                          P(40.0, 25.0),
                                                          P(48.0, 14.0),
                                                          P(53.0, 7.0),
                                                          P(53.0, 7.0)]
                                                 action:recognizerSelector];
                expect(view.frame).to.equal((CGRect){103.0, 35.0, 100.0, 50.0});
            });
            
            it(@"should call dragging started block", ^{
                __block BOOL draggingStartedCalled = NO;
                __weak UIView * weakView = view;
                view.draggingStartedBlock = ^(UIView * draggingView){
                    if([draggingView isEqual:weakView]){
                        draggingStartedCalled = YES;
                    }
                };
                
                [view simulatePanGestureWithCheckPoints:@[P(30.0, 20.0)]
                                                 action:recognizerSelector];
                expect(draggingStartedCalled).to.beTruthy();
            });
            it(@"should call dragging moved block", ^{
                __block BOOL draggingMovedCalled = NO;
                __weak UIView * weakView = view;
                view.draggingMovedBlock = ^(UIView * draggingView){
                    if([draggingView isEqual:weakView]){
                        draggingMovedCalled = YES;
                    }
                };
                
                [view simulatePanGestureWithCheckPoints:@[P(30.0, 20.0),
                                                          P(40.0, 20.0),
                                                          P(40.0, 20.0)]
                                                 action:recognizerSelector];
                expect(draggingMovedCalled).to.beTruthy();
            });
            it(@"should call dragging ended block", ^{
                __block BOOL draggingEndedCalled = NO;
                __weak UIView * weakView = view;
                view.draggingEndedBlock = ^(UIView * draggingView){
                    if([draggingView isEqual:weakView]){
                        draggingEndedCalled = YES;
                    }
                };
                
                [view simulatePanGestureWithCheckPoints:@[P(30.0, 20.0),
                                                          P(40.0, 20.0),
                                                          P(40.0, 20.0)]
                                                 action:recognizerSelector];
                expect(draggingEndedCalled).to.beTruthy();
            });
            
            // assuming this behaviour so that provided pan gesture simulation approach works
            it(@"should reset translation of the pan gesture recognizer", ^{
                [view setupMockRecognizer:mockRecognizer toReturnLocation:CGPointMake(30.0, 20.0)];
                [UIPanGestureRecognizer setupMockRecognizer:mockRecognizer
                                        toReturnTranslation:CGPointMake(100.0, 200.0)];
                [UIPanGestureRecognizer setupMockRecognizer:mockRecognizer
                                                toBeInState:UIGestureRecognizerStateChanged];
                [view performAction:recognizerSelector withRecognizer:mockRecognizer];
                
                [MKTVerify(mockRecognizer) setTranslation:(CGPoint){0.0, 0.0} inView:anything()];
            });
            
            it(@"should look right", ^{
                [view simulatePanGestureWithCheckPoints:@[P(30.0, 22.0),
                                                          P(40.0, 25.0),
                                                          P(48.0, 14.0),
                                                          P(90.0, 50.0),
                                                          P(180.0, 95.0),
                                                          P(260.0, 95.0),
                                                          P(140.0, 95.0)]
                                                 action:recognizerSelector];
                expect(container).to.haveValidSnapshot();
            });
        });
        
        describe(@"caging area", ^{
            it(@"should not move outside its caging area", ^{
                view.cagingArea = CGRectMake(60.0, 30.0, 200.0, 130.0);
                
                [view simulatePanGestureWithCheckPoints:@[P(30.0, 22.0),
                                                          P(20.0, 22.0),
                                                          P(15.0, 22.0),
                                                          P(0.0, 22.0),
                                                          P(0.0, 22.0)]
                                                 action:recognizerSelector];
                expect(view.frame).to.equal((CGRect){65.0, 50.0, 100.0, 50.0});
            });
            
            it(@"should move freely if the view is not contained in the caging area", ^{
                view.cagingArea = CGRectMake(60.0, 30.0, 100.0, 130.0);
                
                [view simulatePanGestureWithCheckPoints:@[P(30.0, 22.0),
                                                          P(20.0, 22.0),
                                                          P(15.0, 22.0),
                                                          P(0.0, 22.0),
                                                          P(0.0, 22.0)]
                                                 action:recognizerSelector];
                expect(view.frame).to.equal((CGRect){50.0, 50.0, 100.0, 50.0});
            });
        });
        
        describe(@"handle restriction", ^{
            it(@"should not start dragging if first touch is outside the handle rect", ^{
                __block BOOL draggingStartedCalled = NO;
                __weak UIView * weakView = view;
                view.draggingStartedBlock = ^(UIView * draggingView){
                    if([draggingView isEqual:weakView]){
                        draggingStartedCalled = YES;
                    }
                };
                view.handle = CGRectMake(10.0, 10.0, 10.0, 30.0);
                
                [view simulatePanGestureWithCheckPoints:@[P(30.0, 20.0)]
                                                 action:recognizerSelector];
                expect(draggingStartedCalled).notTo.beTruthy();
            });
        });
        
        describe(@"axis restrictions", ^{
            it(@"should move along X axis only if Y axis is restricted", ^{
                view.shouldMoveAlongX = YES;
                view.shouldMoveAlongY = NO;
                [view simulatePanGestureWithCheckPoints:@[P(30.0, 22.0),
                                                          P(40.0, 25.0),
                                                          P(48.0, 14.0),
                                                          P(90.0, 50.0)]
                                                 action:recognizerSelector];
                expect(view.frame).to.equal(CGRectMake(140.0, 50.0, 100.0, 50.0));
            });
            
            it(@"should move along Y axis only if X axis is restricted", ^{
                view.shouldMoveAlongX = NO;
                view.shouldMoveAlongY = YES;
                [view simulatePanGestureWithCheckPoints:@[P(30.0, 22.0),
                                                          P(40.0, 25.0),
                                                          P(48.0, 14.0),
                                                          P(90.0, 50.0)]
                                                 action:recognizerSelector];
                expect(view.frame).to.equal(CGRectMake(80.0, 78.0, 100.0, 50.0));
            });
            
            it(@"should not move if both axes are restricted", ^{
                view.shouldMoveAlongX = NO;
                view.shouldMoveAlongY = NO;
                [view simulatePanGestureWithCheckPoints:@[P(30.0, 22.0),
                                                          P(40.0, 25.0),
                                                          P(48.0, 14.0),
                                                          P(90.0, 50.0)]
                                                 action:recognizerSelector];
                expect(view.frame).to.equal(CGRectMake(80.0, 50.0, 100.0, 50.0));
            });
        });
        
        describe(@"setDraggable:", ^{
            it(@"should disable pan gesture recognizer when set to NO", ^{
                [view setDraggable:YES];
                [view setDraggable:NO];
                expect(view.panGesture.enabled).notTo.beTruthy();
            });
            
            it(@"should disable pan gesture recognizer when set to YES", ^{
                [view setDraggable:NO];
                [view setDraggable:YES];
                expect(view.panGesture.enabled).to.beTruthy();
            });
        });
    });
    
    context(@"when dragging wasn't enabled", ^{
        describe(@"setDraggable:", ^{
            it(@"should not enable dragging when set to YES", ^{
                [view setDraggable:YES];
                expect(view.panGesture).to.beNil();
            });
        });
    });
});

SpecEnd
//
//  FPViewController.m
//  UIViewDraggableDemo
//
//  Created by Andrea on 13/03/14.
//  Copyright (c) 2014 Fancy Pixel. All rights reserved.
//

#import "FPViewController.h"

#import "UIView+draggable.h"

@interface FPViewController ()

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *draggableViews;

@end

@implementation FPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	[self.draggableViews enumerateObjectsUsingBlock:^(UIView* obj, NSUInteger idx, BOOL *stop) {
		[obj enableDragging];
		[obj.layer setCornerRadius:4];
        //[obj setDraggingArea:CGRectMake(0, 0, 100, 100)];
	}];
}

- (IBAction)actionSwitch:(UISwitch*)sender
{
	[self.draggableViews enumerateObjectsUsingBlock:^(UIView* obj, NSUInteger idx, BOOL *stop) {
		[obj setDraggable:sender.isOn];
	}];
}
- (IBAction)didToggleCagingAreaSwitch:(UISwitch *)sender
{
    CGRect cagingArea = CGRectZero;
    
    if ([sender isOn]) {
        cagingArea = self.view.frame;
    }
    
    [self.draggableViews enumerateObjectsUsingBlock:^(UIView* obj, NSUInteger idx, BOOL *stop) {
        obj.cagingArea = cagingArea;
    }];
}

@end

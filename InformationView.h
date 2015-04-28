//
//  InformationView.h
//  Project CloudPlay
//
//  Created by Kevin Wang on 2015-04-21.
//  Copyright (c) 2015 Kevin Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InformationView;
typedef void(^ActionHandler)(InformationView *view);
@interface InformationView : UIView

@property (nonatomic, copy) ActionHandler dismissHandler;
@property (nonatomic, copy) ActionHandler exitHandler;

+ (InformationView *)viewWithChoice:(NSInteger)choice;
@end
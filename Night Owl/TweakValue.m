//
//  TweakValue.m
//  Night Owl
//
//  Created by Brian Vallelunga on 6/26/15.
//  Copyright (c) 2015 Brian Vallelunga. All rights reserved.
//

#import "TweakValue.h"

@implementation TweakValue

+ (BOOL)questionShareModal {
    return MPTweakValue(@"Question Answer Refer Modal", false);
}

@end

//
//  Sonic.m
//  ;
//
//  Created by Yunus Eren Guzel on 11/16/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "Sonic.h"
#import "SonicData.h"
#import "TypeDefs.h"

@implementation Sonic

- (void)updateWithSonic:(Sonic *)sonic
{
    if([[self sonicId] isEqualToString:sonic.sonicId]){
        self.resonicCount = sonic.resonicCount;
        self.likeCount = sonic.likeCount;
        self.commentCount = sonic.commentCount;
        self.isLikedByMe = sonic.isLikedByMe;
        self.isResonicedByMe = sonic.isResonicedByMe;
    }
}

- (SonicData *)sonicData
{
    if(_sonicData == nil){
        self.sonicData = [SonicData sonicDataWithSonic:self];
    }
    return _sonicData;
}

- (void)setSonic:(SonicData *)sonicData
{
    _sonicData = sonicData;
    sonicData.sonic = self;
}

- (UIImage *)getImage
{
    return [[self sonicData] image];
}

- (NSData *)getSound
{
    return [[self sonicData] sound];
}



@end

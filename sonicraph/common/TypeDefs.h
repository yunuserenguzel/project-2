//
//  TypeDefs.h
//  sonicraph
//
//  Created by Yunus Eren Guzel on 10/26/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#ifndef sonicraph_TypeDefs_h
#define sonicraph_TypeDefs_h

#define EditSonicSegue @"EditSonicSegue"
#define ShareSonicSegue @"ShareSonicSegue"
#define ProfileToPreviewSegue @"ProfileToPreviewSegue"
#define ViewSonicSegue @"ViewSonicSegue"

#define NotificationSonicsAreLoaded @"NotificationSonicsAreLoaded"
#define NotificationLikeSonic @"NotificationLikeSonic"
#define NotificationDislikeSonic @"NotificationDislikeSonic"
#define NotificationOpenCommentsOfSonic @"NotificationOpenCommentsOfSonic"
#define NotificationSonicDeleted @"NotificationSonicDeleted"
#define NotificationCommentWrittenToSonic @"NotificationCommentWrittenToSonic"

UIColor* rgb(CGFloat red, CGFloat green, CGFloat blue);

CGRect CGRectByRatio(CGRect maxRect, CGRect minRect, CGFloat ratio);


#endif

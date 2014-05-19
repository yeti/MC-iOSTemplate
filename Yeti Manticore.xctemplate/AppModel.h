//
//  AppModel.h
//  Fora
//
//  Created by Floyd on 2/19/14.
//  Copyright (c) 2014 Yeti LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ManticoreViewFactory.h"
#import "AuthUserResponse.h"

@class RKObjectRequestOperation;
@class RKMappingResult;
@class AFImageRequestOperation;

/* The output from iOS View Generator goes here */

#define FA_SECTION_FIRST  /* FIRST SECTION */
#define FA_VIEW_FIRST /* FIRST VIEW */

#define PROD_URL @""
#define STAGING_URL @""
#define DEVELOPMENT_URL @""

#define BASE_URL PROD_URL

#define API_PREFIX @"/api/v1" // these two lines should match each other, this one with the trailing slash
#define API_URL @"api/v1" // these two lines should match each other, this one without the trailing slash
#define TOS_URL @"terms-of-service/"
#define RESET_URL @"password_reset/"
#define DATABASE_FILE @"Fora.sqlite"

#define kForaAppStoreLink @"http://apple.com"
#define kForaWebsiteLink @"http://fora.is"

@interface AppModel : NSObject

+ (AppModel*)sharedModel;

@property(readonly) NSString* apikey;
@property(nonatomic, retain) AuthUserResponse* user;
@property(nonatomic, retain) NSArray* socialAuthentication; // array of UserSocialAuthResponse
@property (nonatomic) BOOL defaultShareToTwitter;
@property (nonatomic) BOOL defaultShareToFacebook;

-(void) loginOrWelcome:(MCIntent*)passThroughIntent;
-(void) loadUserWithUsername:(NSString*)username apikey:(NSString*)apikey success:(void (^)())success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;
-(void) loadAll;
-(void) logout;
-(NSArray*) socialAuthNames; // array of strings that contain facebook, twitter, or foursquare
-(BOOL) authenticated;

@property() BOOL bottomTabsVisible;



// in memory caches
@property (nonatomic, retain) NSCache* imageCache;

// cache to disk and/or memory and shows a placeholder image. Does not report failure.
-(void) fetchImageFromCachesOrURL:(NSString*)urlString toImageView:(UIImageView*)imageView;

// cache to disk and/or memory. Automatic retry. Does not report failure.
-(void) fetchImageFromCachesOrURL:(NSString*)urlString
                          network:(void(^)(AFImageRequestOperation* operation))networkBlock
                          success:(void (^)(NSString* urlString, UIImage* image))imageBlock
                          failure:(void (^)(NSString* urlString))failureBlock;

@end

//
//  AppModel.m
//  Fora
//
//  Created by Floyd on 2/19/14.
//  Copyright (c) 2014 Yeti LLC. All rights reserved.
//

#import "AppModel.h"
//#import "FollowingModel.h"
//#import "UserSocialAuthResponse.h"
//#import "DataModel.h"
//#import "UserResponse.h"
#import "MCPagination.h"
#import <SDWebImage/UIImageView+WebCache.h>
//#import <FacebookSDK/FacebookSDK.h>

@implementation AppModel

@synthesize socialAuthentication;
@synthesize user;
@synthesize imageCache;
@synthesize defaultShareToFacebook;
@synthesize defaultShareToTwitter;
@synthesize bottomTabsVisible;

// http://www.galloway.me.uk/tutorials/singleton-classes/
+ (AppModel*)sharedModel {
  static AppModel *sharedModel = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedModel = [[self alloc] init];
  });
  return sharedModel;
}

-(id)init {
	self = [super init];
	if (self != nil) {
    imageCache = [NSCache new];
    bottomTabsVisible = YES;
  }
  return self;
}

#pragma mark authentication

-(NSString *)apikey{
  if (user)
    return user.token;
  else
    return nil;
}

-(BOOL) authenticated {
  //probably need to be a little more robust
  if ([[NSUserDefaults standardUserDefaults] objectForKey:@"apikey"]){
    return YES;
  } else {
    return NO;
  }
}

-(void) loginOrWelcome:(MCIntent*)passThroughIntent {
  if (!passThroughIntent){
    passThroughIntent = [MCIntent intentWithSectionName:SECTION_FEED andViewName:VIEW_FEEDMAIN andAnimation:ANIMATION_PUSH];
  }
  
  if ([AppModel sharedModel].apikey) {
    [[MCViewModel sharedModel] setCurrentSection:passThroughIntent];
  }
  else if ([[NSUserDefaults standardUserDefaults] objectForKey:@"apikey"]) {
    [[AppModel sharedModel] loadUserWithUsername:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"] apikey:[[NSUserDefaults standardUserDefaults] objectForKey:@"apikey"] success:^() {
      // deferred loading of the social authentication credentials
      [[AppModel sharedModel] loadAll];
      [[MCViewModel sharedModel] setCurrentSection:passThroughIntent];
      
      
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
      MCIntent* intent = [MCIntent intentWithSectionName:SECTION_INTRO andViewName:VIEW_INTROWELCOME andAnimation:ANIMATION_PUSH];
      [[MCViewModel sharedModel] setCurrentSection:intent];
    }];
  } else {
    MCIntent* intent = [MCIntent intentWithSectionName:SECTION_INTRO andViewName:VIEW_INTROWELCOME andAnimation:ANIMATION_PUSH];
    [[MCViewModel sharedModel] setCurrentSection:intent];
    
  }
  
}

-(void) loadUserWithUsername:(NSString*)username apikey:(NSString*)apikey success:(void (^)())success failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure {
  [[DataModel sharedModel] getAllUserWithUsername:username apikey:apikey success:^(AuthUserResponse* retProfile) {
    // this is ugly because the token isn't send down
    [AppModel sharedModel].user = [AuthUserResponse new];
    [AppModel sharedModel].user.token = apikey;
    [AppModel sharedModel].user.username = retProfile.username;
    [AppModel sharedModel].user.email = retProfile.email;
    [AppModel sharedModel].user.location = retProfile.location;
    [AppModel sharedModel].user.website = retProfile.website;
    [AppModel sharedModel].user.info = retProfile.info;
    [AppModel sharedModel].user.thumbnail = retProfile.thumbnail;
    [AppModel sharedModel].user.small_photo = retProfile.small_photo;
    [AppModel sharedModel].user.large_photo = retProfile.large_photo;
    [AppModel sharedModel].user.theID = retProfile.theID;
    [AppModel sharedModel].user.full_name = retProfile.full_name;
    
    [AppModel sharedModel].user.user_followers_count = retProfile.user_followers_count;
    [AppModel sharedModel].user.total_score = retProfile.total_score;
    [AppModel sharedModel].user.post_count = retProfile.post_count;
    [AppModel sharedModel].user.user_following_count = retProfile.user_following_count;
    [AppModel sharedModel].user.favorites_count = retProfile.favorites_count;
    
    success();
  }failure:^(RKObjectRequestOperation *operation, NSError *error) {
    failure(operation, error);
  }];
  
}

// called after the user has authenticated
-(void) loadAll {
  //[self loadClientSettings];
  [self loadUserSocialAuthentication];
  //[[FollowingModel sharedModel] loadFollowedUsers];
}

-(void) loadUserSocialAuthentication {
  // deferred loading of the social authentication credentials
  [[DataModel sharedModel] getAllUserSocialAuthWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    self.socialAuthentication = [MCPaginationHelper helperWithUsername:[AppModel sharedModel].user.username apikey:[AppModel sharedModel].apikey urlPrefix:API_PREFIX restKit:mappingResult].objects;
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    self.socialAuthentication = nil;
  }];
}
/*
-(void) loadClientSettings {
  [[DataModel sharedModel] getAllUserSettingWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    UserSettingResponse* settings = [MCPaginationHelper firstObjectFromRestKit:mappingResult];
    // 6 settings are loaded into AppModel
    
    defaultShareToFacebook = providerContains(settings.default_social_providers, @"facebook");
    defaultShareToTwitter = providerContains(settings.default_social_providers, @"twitter");
    
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    
  }];
}
*/
-(NSArray*) socialAuthNames {
  NSMutableArray* arrProviders = [NSMutableArray arrayWithCapacity:socialAuthentication.count];
  
  for(UserSocialAuthResponse* sauth in self.socialAuthentication){
    
    [arrProviders addObject:sauth.provider];
    
  }
  
  return arrProviders;
}

-(void) logout {
  self.user = nil;
  self.socialAuthentication = nil;
  
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"apikey"];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"username"];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"full_name"];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"loginDate"];
  
  [[NSUserDefaults standardUserDefaults] synchronize];
  if (FBSession.activeSession){
    [FBSession.activeSession closeAndClearTokenInformation];
  }
  
  // logout from the server
  [[DataModel sharedModel] getAllLogoutWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    
  } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    
  }];
  
}


#pragma mark image cache

-(void) fetchImageFromCachesOrURL:(NSString*)urlString toImageView:(UIImageView*)imageView {
  
  imageView.image = [UIImage imageNamed: @"loadingImage"];
  [self fetchImageFromCachesOrURL:urlString network:^(AFImageRequestOperation *operation) {
    
  } success:^(NSString *urlString, UIImage *image) {
    imageView.image = image;
  } failure:^(NSString *urlString) {
    
  }];
  
}

// does not report failure
-(AFImageRequestOperation*) fetchImageFromNetwork:(NSString*)urlString success:(void (^)(UIImage* image))imageBlock failure:(void (^)(NSError* error))failureBlock retryCount:(int)retries{
  // do not retry loading an image indefinitely
  if (retries > 2){
    failureBlock(nil);
    return nil;
  }
  
  SDImageCache* cache = [SDImageCache sharedImageCache];
  
  NSURL* url = [NSURL URLWithString:urlString relativeToURL:[NSURL URLWithString:BASE_URL]];
  NSURLRequest* request = [NSURLRequest requestWithURL:url];
  
  AFImageRequestOperation *op = [AFImageRequestOperation imageRequestOperationWithRequest:request
                                                                     imageProcessingBlock:nil
                                                                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
                                 {
                                   [cache storeImage:image forKey:urlString];
                                   imageBlock(image);
                                 } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
                                 {
                                   if (error.domain == NSURLErrorDomain && (error.code == NSURLErrorNotConnectedToInternet || error.code == NSURLErrorTimedOut)){
                                     [self fetchImageFromNetwork:urlString success:imageBlock failure:failureBlock retryCount:retries + 1];
                                   }else{
                                     failureBlock(error);
                                   }
                                 }];
  [op start];
  return op;
}

// TODO: possibly this should be using SDWebImageManager
-(void) fetchImageFromCachesOrURL:(NSString*)urlString
                          network:(void(^)(AFImageRequestOperation* operation))networkBlock
                          success:(void (^)(NSString* urlString, UIImage* image))imageBlock
                          failure:(void (^)(NSString* urlString))failureBlock{
  SDImageCache* cache = [SDImageCache sharedImageCache];
  
  [cache queryDiskCacheForKey:urlString done:^(UIImage *image, SDImageCacheType cacheType) {
    if (image){
      imageBlock(urlString, image);
    }else{
      AFImageRequestOperation* op = [self fetchImageFromNetwork:urlString success:^(UIImage *image) {
        if (imageBlock)
          imageBlock(urlString, image);
      } failure:^(NSError *error) {
        if (failureBlock)
          failureBlock(urlString);
      } retryCount:0];
      
      if (networkBlock)
        networkBlock(op);
    }
  }];
  
}

#pragma mark For Observers

-(void) setBottomTabsVisible: (BOOL) newBool {
	bottomTabsVisible = newBool;
}

-(BOOL) bottomTabsVisible {
	return bottomTabsVisible;
}

@end

//
//  admob.cpp
//  BannerExample
//
//  Created by YI ZHENG on 23/09/2017.
//  Copyright © 2017 Google. All rights reserved.
//



//#include "core/globals.h"
#include "core/variant.h"
#include "core/message_queue.h"

#import <GoogleMobileAds/GoogleMobileAds.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AdSupport/ASIdentifierManager.h>
#include "admob.h"

#import "app_delegate.h"

#if VERSION_MAJOR == 3
#define CLASS_DB ClassDB
#define _MD D_METHOD
#else
#define CLASS_DB ObjectTypeDB
#endif



Admob* instance = NULL;

@interface AdmobAdsDelegate:NSObject<GADBannerViewDelegate, GADInterstitialDelegate, GADRewardBasedVideoAdDelegate>
-(id)initWithAd:(Admob *)ad;
@property (nonatomic, assign) Admob *admob;
@end


//static AdmobAdsDelegate* delegate = nil;
//static GADInterstitial* interstitial = nil;
//static GADBannerView* bannerView = nil;

Admob::Admob(){
    ERR_FAIL_COND(instance != NULL);
    instance = this;
    delegate = [[AdmobAdsDelegate alloc] initWithAd:this];
    [GADRewardBasedVideoAd sharedInstance].delegate = delegate;
    bannerView = nil;
    interstitial = nil;
}

Admob::~Admob(){
   instance = NULL;

   if (bannerView != nil){
      [bannerView release];
   }

   if (interstitial != nil){
      [interstitial release];
   }

   [delegate release];
};


void Admob::_bind_methods()
{
    CLASS_DB::bind_method(_MD("init"),                  &Admob::init);
    CLASS_DB::bind_method(_MD("loadBanner"),    &Admob::loadBanner);
    
    CLASS_DB::bind_method(_MD("showBanner"),      &Admob::showBanner);
    CLASS_DB::bind_method(_MD("hideBanner"),     &Admob::hideBanner);
    CLASS_DB::bind_method(_MD("loadInterstitial"),       &Admob::loadInterstitial);
    CLASS_DB::bind_method(_MD("showInterstitial"),         &Admob::showInterstitial);
    CLASS_DB::bind_method(_MD("loadRewardedVideo"),        &Admob::loadRewardedVideo);
    CLASS_DB::bind_method(_MD("showRewardedVideo"),    &Admob::showRewardedVideo);
    CLASS_DB::bind_method(_MD("setTest"),    &Admob::setTest);
    CLASS_DB::bind_method(_MD("setTop"),    &Admob::setTop);
    CLASS_DB::bind_method(_MD("isInterstitialReady"),    &Admob::isInterstitialReady);
    CLASS_DB::bind_method(_MD("isRewardedVideoAdReady"),    &Admob::isRewardedVideoAdReady);
    CLASS_DB::bind_method(_MD("vibrate"),    &Admob::vibrate);
    
};

void Admob::vibrate(){
  AudioServicesPlaySystemSound(kSystemSoundID_Vibrate); 
}


void Admob::init(bool isReal, int inst_id, const String& app_id){
    //[GADMobileAds configureWithApplicationID:[NSString stringWithUTF8String:app_id]];
    isTest = !isReal;
    instance_id = inst_id;
    [GADMobileAds configureWithApplicationID:[NSString stringWithCString:app_id.utf8().get_data() encoding:NSUTF8StringEncoding]];
    
}


void Admob::loadBanner(const String& banner_id, bool isTop){
     NSLog(@"loadBanner Running on %@ thread", [NSThread currentThread]);

     bool isPortrait = [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown;

     GADAdSize adSize = kGADAdSizeSmartBannerLandscape;

     if (isPortrait)
        adSize = kGADAdSizeSmartBannerPortrait;

    bannerView = [[GADBannerView alloc] initWithAdSize:adSize]; //kGADAdSizeBanner];
    //bannerView.adUnitID = [NSString stringWithUTF8String:banner_id];
    bannerView.adUnitID = [NSString stringWithCString:banner_id.utf8().get_data() encoding:NSUTF8StringEncoding];
    bannerView.delegate = delegate;
    
    UIViewController *rootViewController = (ViewController *)((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
   
    //UIViewController *rootViewController = [AppDelegate getViewController];
    bannerView.rootViewController = rootViewController;
    
    GADRequest *request = [GADRequest request];
    
    //request.testDevices = @[ @"879b0065e9d7fc5df8f3398bb3c68066" ];
    if (isTest){
        request.testDevices = @[[NSString stringWithCString:getTestId().utf8().get_data() encoding:NSUTF8StringEncoding]];
        //NSLog([NSString stringWithCString:getTestId().utf8().get_data() encoding:NSUTF8StringEncoding]);
    }
    
    [bannerView loadRequest:request];
    [rootViewController.view addSubview:bannerView];
    
    setTop(isTop);
    set_position(isTop);
}


void Admob::showBanner(){
   
    if (bannerView != NULL) {
        UIViewController *rootViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        //UIViewController *rootViewController = [AppDelegate getViewController];
        [rootViewController.view addSubview:bannerView];
        set_position();
    }
    
}
void Admob::hideBanner(){
    
    if (bannerView != NULL) {
        [bannerView removeFromSuperview];
    }
    
}


void Admob::loadInterstitial(const String& adUnitID){
    
    NSLog(@"loadInterstitial Running on %@ thread %i", [NSThread currentThread], [[UIDevice currentDevice] orientation]);
    //if (adUnitID != "")
        //interstitial_id = [NSString stringWithUTF8String:id];
        //interstitial_id = [NSString stringWithCString:adUnitID.utf8().get_data() encoding:NSUTF8StringEncoding];
        //interstitial_id = adUnitID;

    if (interstitial != nil)
    {
        interstitial.delegate = nil;
        [interstitial release];
        interstitial = nil;
    }
    
    //if (interstitial_id != ""){
    interstitial = [[GADInterstitial alloc] initWithAdUnitID:[NSString stringWithCString:adUnitID.utf8().get_data() encoding:NSUTF8StringEncoding]];
    interstitial.delegate = delegate;
    
    GADRequest *request = [GADRequest request];
    
    if (isTest){

        request.testDevices = @[[NSString stringWithCString:getTestId().utf8().get_data() encoding:NSUTF8StringEncoding]];
    }
    [interstitial loadRequest:request];
    //}
    
}

bool Admob::isInterstitialReady(){
    if (interstitial != nil){
        if (interstitial.isReady) {
            return true;
        }
    }
    return false;
}

bool Admob::showInterstitial(){
    
    NSLog(@"showInterstitial Running on %@ thread", [NSThread currentThread]);
    if (interstitial != nil){
        if (interstitial.isReady) {
             //UIViewController *rootViewController = (ViewController *)((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
            UIViewController *rootViewController = [AppDelegate getViewController];
            [interstitial presentFromRootViewController:rootViewController];
            NSLog(@"rootViewController %@", rootViewController);
            NSLog(@"interstitial %@", interstitial);
            return true;
        }
    }
    return false;
}


void Admob::loadRewardedVideo(const String& rewardedvideo_id){
    if (![[GADRewardBasedVideoAd sharedInstance] isReady]) {
        GADRequest *request = [GADRequest request];
        if (isTest){

            request.testDevices = @[[NSString stringWithCString:getTestId().utf8().get_data() encoding:NSUTF8StringEncoding]];
        }
        [[GADRewardBasedVideoAd sharedInstance] loadRequest:request
                                         withAdUnitID:[NSString stringWithCString:rewardedvideo_id.utf8().get_data() encoding:NSUTF8StringEncoding]];
    }
}

bool Admob::isRewardedVideoAdReady(){
    if ([[GADRewardBasedVideoAd sharedInstance] isReady]){
        return true;
    }
    return false;
}

bool Admob::showRewardedVideo(){
    if ([[GADRewardBasedVideoAd sharedInstance] isReady]) {
        UIViewController *rootViewController = (ViewController *)((AppDelegate *)[[UIApplication sharedApplication] delegate]).window.rootViewController;
        [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:rootViewController];

        return true;
    }
    return false;
}


void Admob::setTest(bool test){
    isTest = test;
}

void Admob::setTop(bool top){
    isOnTop = top;
}


 String Admob::getTestId(){
    if (NSClassFromString(@"ASIdentifierManager")) {

        NSString *test = [[[ASIdentifierManager sharedManager]
                           advertisingIdentifier] UUIDString];
        // Create pointer to the string as UTF8
        String ptr = [test UTF8String];
        
        return ptr.md5_text();
    }
    return "";
}


void Admob::set_position(bool isTop){
    UIViewController *rootViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    //UIViewController *rootViewController = [AppDelegate getViewController];
    bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutAttribute attribute = NSLayoutAttributeBottom;
    
    bool isSmart = false;
    
    /*
    if (isTop)
        attribute = NSLayoutAttributeTop;
    
    
    // Layout constraints that align the banner view to the bottom center of the screen.
    [rootViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:bannerView
                                                                        attribute:attribute
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:rootViewController.view
                                                                        attribute:attribute
                                                                       multiplier:1
                                                                         constant:0]];
    [rootViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:bannerView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:rootViewController.view
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1
                                                                         constant:0]];
      */
     if (@available(ios 11.0, *)) {
        UILayoutGuide *guide = rootViewController.view.safeAreaLayoutGuide; 
        if (isSmart)
            [NSLayoutConstraint activateConstraints:@[
                                              [guide.leftAnchor constraintEqualToAnchor:bannerView.leftAnchor],
                                              [guide.rightAnchor constraintEqualToAnchor:bannerView.rightAnchor],
                                              [guide.bottomAnchor constraintEqualToAnchor:bannerView.bottomAnchor]
                                              ]];
        else
            [NSLayoutConstraint activateConstraints:@[
                                              [bannerView.centerXAnchor constraintEqualToAnchor:guide.centerXAnchor],
                                              [bannerView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor]
                                              ]];
    } else {
        if (isSmart){
            [rootViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:bannerView
                                                                        attribute:NSLayoutAttributeLeading
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:rootViewController.view
                                                                        attribute:NSLayoutAttributeLeading
                                                                       multiplier:1
                                                                         constant:0]];
            [rootViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:bannerView
                                                                                attribute:NSLayoutAttributeTrailing
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:rootViewController.view
                                                                                attribute:NSLayoutAttributeTrailing
                                                                               multiplier:1
                                                                                 constant:0]];
            [rootViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:bannerView
                                                                                attribute:NSLayoutAttributeBottom
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:rootViewController.bottomLayoutGuide
                                                                                attribute:NSLayoutAttributeTop
                                                                               multiplier:1
                                                                         constant:0]];
        }
        else{
            [rootViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:bannerView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:rootViewController.view
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1
                                                                         constant:0]];
            [rootViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:bannerView
                                                                                attribute:NSLayoutAttributeBottom
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:rootViewController.bottomLayoutGuide
                                                                                attribute:NSLayoutAttributeTop
                                                                               multiplier:1
                                                                                 constant:0]];
        }
    }
}




void Admob::call_multilevel(const StringName &p_method, const Variant **p_args, int p_argcount){
    Object *obj = ObjectDB::get_instance(getInstanceID());
    if (obj){
        obj->call_multilevel(p_method, p_args, p_argcount);
    }

}




@implementation AdmobAdsDelegate


-(id)initWithAd:(Admob *)ad{
    if (self = [super init])
    {
        _admob = ad;
    }
    return self;
}




#pragma mark GADBannerViewDelegate implementation

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
     NSLog(@"adViewDidReceiveAd");
     _admob->call_multilevel("_on_admob_ad_loaded", NULL, 0);
}
- (void)adView:(GADBannerView *)bannerView
didFailToReceiveAdWithError:(GADRequestError *)error;
{
   NSLog(@"adView didFailToReceiveAdWithError");
   Variant err =  Variant([[error localizedDescription] UTF8String]);
   const Variant *args[1] = {&err};
  _admob->call_multilevel("_on_admob_ad_failed_to_load", args, 1);
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView
{
    
}

- (void)adViewDidDismissScreen:(GADBannerView *)bannerView
{
    
}

- (void)adViewWillDismissScreen:(GADBannerView *)bannerView
{
}

- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView
{
    
}



#pragma mark GADInterstitialDelegate implementation

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial
{
    NSLog(@"interstitialDidReceiveAd Running on %@ thread", [NSThread currentThread]);

    _admob->call_multilevel("_on_interstitial_loaded", NULL, 0);

    //_admob->showInterstitial();

}
- (void)interstitial:(GADInterstitial *)interstitial
didFailToReceiveAdWithError:(GADRequestError *)error;
{
    NSLog(@"interstitial didFailToReceiveAdWithError");
    Variant err =  Variant([[error localizedDescription] UTF8String]);
    const Variant *args[1] = {&err};
    _admob->call_multilevel("_on_interstitial_failed_to_load", args, 1);
}
- (void)interstitialWillPresentScreen:(GADInterstitial *)interstitial
{
    NSLog(@"interstitialWillPresentScreen");
    _admob->call_multilevel("_on_interstitia_will_present_screen", NULL, 0);
    
}


- (void)interstitialDidFailToPresentScreen:(GADInterstitial *)ad
{
    
}
- (void)interstitialWillDismissScreen:(GADInterstitial *)interstitial
{
    NSLog(@"interstitialWillDismissScreen Running on %@ thread", [NSThread currentThread]);
     _admob->call_multilevel("_on_interstitial_will_dismiss", NULL, 0);
}
- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial
{
    NSLog(@"interstitialDidDismissScreen Running on %@ thread", [NSThread currentThread]);
    
     _admob->call_multilevel("_on_interstitial_closed", NULL, 0);
}
- (void)interstitialWillLeaveApplication:(GADInterstitial *)interstitial
{
    
}



#pragma mark GADRewardBasedVideoAdDelegate implementation

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
  NSLog(@"Reward based video ad is received.");
  _admob->call_multilevel("_on_rewarded_video_ad_loaded", NULL, 0);
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
  NSLog(@"Opened reward based video ad.");
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
  NSLog(@"Reward based video ad started playing.");
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
  NSLog(@"Reward based video ad is closed.");
  _admob->call_multilevel("_on_rewarded_video_ad_closed", NULL, 0);
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
    didRewardUserWithReward:(GADAdReward *)reward {
  NSString *rewardMessage =
      [NSString stringWithFormat:@"Reward received with currency %@ , amount %lf", reward.type,
                                 [reward.amount doubleValue]];
  NSLog(@"%@", rewardMessage);

  Variant type = Variant([reward.type UTF8String]);
  Variant amount = Variant([reward.amount doubleValue]);

  const Variant *args[2] = {&type, &amount};
  _admob->call_multilevel("_on_rewarded", args, 2);
  
}

- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
  NSLog(@"Reward based video ad will leave application.");
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd
    didFailToLoadWithError:(NSError *)error {
   NSLog(@"Reward based video ad failed to load.");
   Variant err =  Variant([[error localizedDescription] UTF8String]);
   const Variant *args[1] = {&err};
   _admob->call_multilevel("_on_rewarded_video_ad_failed_to_load", args, 1);
}



@end



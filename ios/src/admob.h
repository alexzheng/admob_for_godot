//
//  admob.hpp
//  BannerExample
//
//  Created by YI ZHENG on 23/09/2017.
//  Copyright © 2017 Google. All rights reserved.
//

#ifndef admob_h
#define admob_h


#include "reference.h"
#include <objc/objc.h>

#ifdef __OBJC__
@class GADBannerView;
typedef GADBannerView * BannerViewPtr;
@class GADInterstitial;
typedef GADInterstitial * InterstitialPtr;
@class AdmobAdsDelegate;
typedef AdmobAdsDelegate * AdmobAdsDelegatePtr;
#else
typedef void * BannerViewPtr;
typedef void * InterstitialPtr;
typedef void * AdmobAdsDelegatePtr;
#endif


//class Admob;


class Admob : public Reference {
    OBJ_TYPE(Admob, Reference);
    
    static void _bind_methods();
    
    
    bool isTest = false;
    int instance_id = 0;
    bool isOnTop = false;
    
    BannerViewPtr bannerView;
    InterstitialPtr interstitial;
    AdmobAdsDelegatePtr delegate;
    //id bannerView;
    //GADBannerView *bannerView = NULL;
    //GADInterstitial *interstitial= NULL;
    //String interstitial_id;
    
    //AdmobAdsDelegate *delegate = NULL;
    
public:
    ~Admob();
    Admob();
    
    void init(int inst_id, const String& app_id);
    void loadBanner(const String& banner_id, bool isTop = false);
    void showBanner();
    void hideBanner();
    void loadInterstitial(const String& adUnitID);
    bool showInterstitial();
    void loadRewardedVideo(const String& rewardedvideo_id);
    bool showRewardedVideo();
    void setTest(bool test);
    void setTop(bool top);
    void set_position(bool isTop = false);
    String  getTestId();
    int getInstanceID(){return instance_id;}
    void call_multilevel(const StringName &p_method, const Variant **p_args, int p_argcount);   
    bool isInterstitialReady();
    bool isRewardedVideoAdReady();
    void vibrate();
};




#endif /* admob_hpp */

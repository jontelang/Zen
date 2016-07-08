//
// Just some headers
//

@interface SBApplication
  -(NSString*)bundleIdentifier;
@end 

@interface SpringBoard
  +(id)sharedInstance;
  -(SBApplication*)_accessibilityFrontMostApplication;
  -(void)clearMenuButtonTimer;
@end

@interface SBLockScreenManager
  +(id)sharedInstance;
  -(BOOL)isUILocked;
@end

@interface UIStatusBar
  -(void)setForegroundColor:(UIColor *)arg1;
@end

@interface SBLockScreenView
  -(UIView*)cameraGrabberView;
@end

@interface SBIconListPageControl : UIView
  // Just so we can use self.hidden further down
@end



%hook UIStatusBar 

-(void)layoutSubviews{
	// Do what you need
	%orig();

	// Make sure we're running inside SpringBoard (not in some app).
	// Could use -- IS_SPRINGBOARD or BUNDLE CHECKS -- as well
    SpringBoard *c = (SpringBoard*)[objc_getClass("SpringBoard") sharedApplication];
    if( c != nil ){
    	// Check if we're in an app or on springboard
	    NSString *identifier = [[c _accessibilityFrontMostApplication] bundleIdentifier];
	    BOOL springboardIsTopMostApp = identifier == nil ? YES : NO;

	    // Check if we're locked or not. Because if we locked while in an app, the status bar
	    // from that app is still showing on the lock screen since lockscreen is only like
	    // and SBAlert on top of the .... ios ... maybe?
		SBLockScreenManager *lsm = [objc_getClass("SBLockScreenManager") sharedInstance];

		// Debug
	    // NSLog(@"---");
	    // NSLog(@"In Springboard process - %@", c?@"YES":@"NO" );
	    // NSLog(@"Inside app             - %@", springboardIsTopMostApp?@"NO":@"YES");
	    // NSLog(@"Inside home screen     - %@", springboardIsTopMostApp?@"YES":@"NO");
	    // NSLog(@"Locked                 - %@", [lsm isUILocked]?@"YES":@"NO");
	    // NSLog(@"---");

		// Do them checks
	    if( springboardIsTopMostApp || [lsm isUILocked] ){
			[self setForegroundColor:[UIColor clearColor]];
	    }else{
	    	// Does orig. I.e. shows the status bar.
	    }
	}

	else{
		// If we're in some app, make the status bar its default state (does orig).
	}
}

%end


%hook SBIconView

// Gone.
+(BOOL)canShowLabelAccessoryView{
	return NO;
}

// Move the badge to the bottom center of the icon.
// This affects the "beta" and "new" accesoryviews as well. But it's ok. Since above we disabled them.
-(CGRect)_frameForAccessoryView{
	CGRect orig = %orig();
	orig.size.width = 6;
	orig.size.height = 6;
	orig.origin.y = orig.origin.x - 1.5f;
	orig.origin.x = (orig.origin.x / 2.0f) - (orig.size.width / 2.0f) - 2.0f;
	return orig;
}

%end


%hook SBIconBadgeView

// Makes the badge content empty
+(id)_createImageForText:(id)arg1 highlighted:(_Bool)arg2{
  return %orig(@" ",arg2);
}

%end


%hook SBIconLabelView

// Removes the label
+(id)newIconLabelViewWithSettings:(id)arg1 imageParameters:(id)arg2{
	return nil;
}

%end


%hook SBDockView

// Removes the dock background
-(void)setBackgroundAlpha:(double)arg1{
	%orig(0.0);
}

%end


%hook SBFStaticWallpaperView

// Makes the background black.
-(id)_displayedImage{
	return nil;
}

%end


%hook SBLockScreenView

-(id)_defaultSlideToUnlockText{
	return nil;
}

-(void)_layoutSlideToUnlockView{
	// Do nothing
}

-(void)_addGrabberViews{
	// Do nothing. This doesn't seem to work.
}

-(void)_layoutCameraGrabberView{
	%orig();
	UIView *grabber = [self cameraGrabberView];
	grabber.alpha = 0.011f;
}

-(UIView*)cameraGrabberView{
	%log;
	UIView *grabber = %orig();
	grabber.alpha = 0.011f; // Almost invisible, but over 0.01 will still render
	return grabber;
}

%end


%hook SBFLockScreenDateView

// Moves the time area down to center it
-(double)timeBaselineOffsetFromOrigin{
	return -80.0;
}

%end


%hook SBLockScreenViewController

-(void)_addBatteryChargingViewAndShowBattery:(BOOL)arg1{
	// Do nothing to prevent the battery charge level on the LS
	// when you unlock the device. I want to move it but.. meh
}

// Uncomment this to disable the timer on the LS. Good for dev.
// -(BOOL)_disableIdleTimer:(BOOL)arg1{
// 	return %orig(YES);
// }

%end


%hook SBIconListPageControl

// Removes the dots
-(void)layoutSubviews {
	self.hidden = YES;
}

%end


%hook SBSearchBlurEffectView

-(void)layoutSubviews{
	// Removes some background on the spotligh thing.
}

%end


%hook SBRootIconListView

//
// The following methods tightens up the spacing between icons on home screen
//

-(double)bottomIconInset{
	return 60.0f;
}

-(double)topIconInset{
	return 0.0f;
}

-(CGFloat)sideIconInset{
	return 20.0f;
}

%end


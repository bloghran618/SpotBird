


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum iToastGravity {
	iToastGravityTop = 1000001,
	iToastGravityBottom,
	iToastGravityCenter
}iToastGravity;

typedef enum iToastDuration {
	iToastDurationLong = 10000,
	iToastDurationShort = 1000,
	iToastDurationNormal = 3000
}iToastDuration;

typedef enum iToastType {
	iToastTypeInfo = -100000,
	iToastTypeNotice,
	iToastTypeWarning,
	iToastTypeError,
	iToastTypeNone // For internal use only (to force no image)
}iToastType;

typedef enum {
    iToastImageLocationTop,
    iToastImageLocationLeft
} iToastImageLocation;


@class iToastSettings;

@interface iToast : NSObject {
	iToastSettings *_settings;
	
	NSTimer *timer;
	
	UIView *view;
	NSString *text;
}

- (void) show;
- (void) show:(iToastType) type;
- (iToast *) setDuration:(NSInteger ) duration;
- (iToast *) setGravity:(iToastGravity) gravity 
			 offsetLeft:(NSInteger) left
			 offsetTop:(NSInteger) top;
- (iToast *) setGravity:(iToastGravity) gravity;
- (iToast *) setPostion:(CGPoint) position;
- (iToast *) setFontSize:(CGFloat) fontSize;
- (iToast *) setUseShadow:(BOOL) useShadow;
- (iToast *) setCornerRadius:(CGFloat) cornerRadius;
- (iToast *) setBgRed:(CGFloat) bgRed;
- (iToast *) setBgGreen:(CGFloat) bgGreen;
- (iToast *) setBgBlue:(CGFloat) bgBlue;
- (iToast *) setBgAlpha:(CGFloat) bgAlpha;

+ (iToast *) makeText:(NSString *) text;

-(iToastSettings *) theSettings;

@end



@interface iToastSettings : NSObject<NSCopying>{
	NSInteger duration;
	iToastGravity gravity;
	CGPoint postition;
	iToastType toastType;
	CGFloat fontSize;
	BOOL useShadow;
	CGFloat cornerRadius;
	CGFloat bgRed;
	CGFloat bgGreen;
	CGFloat bgBlue;
	CGFloat bgAlpha;
	NSInteger offsetLeft;
	NSInteger offsetTop;

	NSDictionary *images;
	
	BOOL positionIsSet;
}


@property(assign) NSInteger duration;
@property(assign) iToastGravity gravity;
@property(assign) CGPoint postition;
@property(assign) CGFloat fontSize;
@property(assign) BOOL useShadow;
@property(assign) CGFloat cornerRadius;
@property(assign) CGFloat bgRed;
@property(assign) CGFloat bgGreen;
@property(assign) CGFloat bgBlue;
@property(assign) CGFloat bgAlpha;
@property(assign) NSInteger offsetLeft;
@property(assign) NSInteger offsetTop;
@property(readonly) NSDictionary *images;
@property(assign) iToastImageLocation imageLocation;


- (void) setImage:(UIImage *)img forType:(iToastType) type;
- (void) setImage:(UIImage *)img withLocation:(iToastImageLocation)location forType:(iToastType)type;
+ (iToastSettings *) getSharedSettings;
						  
@end
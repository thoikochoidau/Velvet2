#import "../headers/HeadersTweak.h"

Velvet2PrefsManager *prefsManager;

%hook NCNotificationShortLookViewController
%property (nonatomic,retain) UIView *velvetView;

-(void)viewDidLoad {
    %orig;

    NCNotificationShortLookView *view = (NCNotificationShortLookView *)self.viewForPreview;

    UIView *velvetView = [UIView new];
    [velvetView.layer insertSublayer:[CALayer layer] atIndex:0];
    [velvetView.layer insertSublayer:[CALayer layer] atIndex:0];
    [view.backgroundMaterialView.superview insertSubview:velvetView atIndex:1];

    self.velvetView = velvetView;
    self.velvetView.clipsToBounds = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(velvetUpdateStyle) name:@"com.noisyflake.velvet2/updateStyle" object:nil];
}

-(void)viewDidLayoutSubviews {
    %orig;

    if (self.viewForPreview.frame.size.width == 0) return;

    [self velvetUpdateStyle];
}

-(void)viewDidAppear:(BOOL)arg1 {
    %orig;
    
    Velvet2Colorizer *colorizer = [[Velvet2Colorizer alloc] initWithIdentifier:self.notificationRequest.sectionIdentifier];
    NCNotificationShortLookView *view                       = (NCNotificationShortLookView *)self.viewForPreview;
    NCNotificationSeamlessContentView *contentView          = [view valueForKey:@"notificationContentView"];
    UIImage *appIcon                                        = contentView.prominentIcon ?: contentView.subordinateIcon;
    NCBadgedIconView *badgedIconView                        = [contentView valueForKey:@"badgedIconView"];
    UIView *appIconView                                     = badgedIconView.iconView;

    colorizer.appIcon = appIcon;

    // For some reason, dateLabel and appIconView isn't fully initialized yet after viewDidLayoutSubviews
    [colorizer colorDate:[contentView valueForKey:@"dateLabel"]];
    [colorizer setAppIconCornerRadius:appIconView];
}

%new
-(void)velvetUpdateStyle {
    NSString *identifier = self.notificationRequest.sectionIdentifier;

    // Initialize content variables
    NCNotificationShortLookView *view                       = (NCNotificationShortLookView *)self.viewForPreview;
    MTMaterialView *materialView                            = view.backgroundMaterialView;
    NCNotificationViewControllerView *controllerView        = [self valueForKey:@"contentSizeManagingView"];
    UIView *stackDimmingView                                = SYSTEM_VERSION_LESS_THAN(@"16.0") ? [controllerView valueForKey:@"stackDimmingView"] : [view valueForKey:@"stackDimmingOverlayView"];
    NCNotificationSeamlessContentView *contentView          = [view valueForKey:@"notificationContentView"];
    UILabel *title                                          = [contentView valueForKey:@"primaryTextLabel"];
    UILabel *message                                        = [contentView valueForKey:@"secondaryTextElement"];
    UILabel *dateLabel                                      = [contentView valueForKey:@"dateLabel"];
    NCBadgedIconView *badgedIconView                        = [contentView valueForKey:@"badgedIconView"];
    UIView *appIconView                                     = badgedIconView.iconView;
    UIImage *appIcon                                        = contentView.prominentIcon ?: contentView.subordinateIcon;

    self.velvetView.frame = materialView.frame;

    Velvet2Colorizer *colorizer = [[Velvet2Colorizer alloc] initWithIdentifier:identifier];
    colorizer.appIcon = appIcon;

    CGFloat defaultCornerRadius = SYSTEM_VERSION_LESS_THAN(@"16.0") ? 19 : 23.5;
    CGFloat cornerRadius = [[prefsManager settingForKey:@"cornerRadiusEnabled" withIdentifier:identifier] boolValue] ? [[prefsManager settingForKey:@"cornerRadiusCustom" withIdentifier:identifier] floatValue] : defaultCornerRadius;
	materialView.layer.continuousCorners = cornerRadius < materialView.frame.size.height / 2;
	materialView.layer.cornerRadius = MIN(cornerRadius, materialView.frame.size.height / 2);
    self.velvetView.layer.continuousCorners = cornerRadius < self.velvetView.frame.size.height / 2;
	self.velvetView.layer.cornerRadius = MIN(cornerRadius, self.velvetView.frame.size.height / 2);

    view.layer.cornerRadius = MIN(cornerRadius, materialView.frame.size.height / 2);
    materialView.superview.layer.cornerRadius = MIN(cornerRadius, materialView.frame.size.height / 2);
    stackDimmingView.layer.cornerRadius = MIN(cornerRadius, materialView.frame.size.height / 2);

    stackDimmingView.hidden = [[prefsManager settingForKey:@"stackDimmingViewHidden" withIdentifier:identifier] boolValue];
    
    [colorizer setAppIconCornerRadius:appIconView];
    [colorizer colorBackground:self.velvetView];
    [colorizer setBackgroundBlur:materialView];
    [colorizer colorBorder:self.velvetView];
    [colorizer colorShadow:materialView];
    [colorizer colorLine:self.velvetView inFrame:materialView.frame];
    [colorizer colorTitle:title];
    [colorizer colorMessage:message];
    [colorizer colorDate:dateLabel];
    [colorizer setAppearance:self.view];
}
%end

%hook NCNotificationSummaryPlatterView
%property (nonatomic,retain) UIView *velvetView;

-(void)didMoveToWindow {
    
    if (!self.velvetView) {
        UIView *velvetView = [UIView new];
        [velvetView.layer insertSublayer:[CALayer layer] atIndex:0];
        [velvetView.layer insertSublayer:[CALayer layer] atIndex:0];
        [self insertSubview:velvetView atIndex:1];

        self.velvetView = velvetView;
        self.velvetView.clipsToBounds = YES;
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(velvetUpdateStyle) name:@"com.noisyflake.velvet2/updateStyle" object:nil];
}
-(void)layoutSubviews {
    %orig;

    [self velvetUpdateStyle];
}

%new
-(void)velvetUpdateStyle {
    MTMaterialView *materialView                            = (MTMaterialView*)self.subviews[0];
    NCNotificationSummaryContentView *contentView           = [self valueForKey:@"summaryContentView"];
    UILabel *title                                          = [contentView valueForKey:@"summaryTitleLabel"];
    UILabel *message                                        = [contentView valueForKey:@"summaryLabel"];

    Velvet2Colorizer *colorizer = [[Velvet2Colorizer alloc] initWithIdentifier:@"com.noisyflake.velvetFocus"];

    CGFloat defaultCornerRadius = SYSTEM_VERSION_LESS_THAN(@"16.0") ? 19 : 23.5;
    CGFloat cornerRadius = [[prefsManager settingForKey:@"cornerRadiusEnabled" withIdentifier:@"com.noisyflake.velvetFocus"] boolValue] ? [[prefsManager settingForKey:@"cornerRadiusCustom" withIdentifier:@"com.noisyflake.velvetFocus"] floatValue] : defaultCornerRadius;
    
    if (materialView) {
        self.velvetView.frame = materialView.frame;
        materialView.layer.continuousCorners = cornerRadius < self.frame.size.height / 2;
        materialView.layer.cornerRadius = MIN(cornerRadius, self.frame.size.height / 2);
        self.velvetView.layer.continuousCorners = cornerRadius < self.velvetView.frame.size.height / 2;
	    self.velvetView.layer.cornerRadius = MIN(cornerRadius, self.velvetView.frame.size.height / 2);
    
        [colorizer colorBackground:self.velvetView];
        [colorizer colorBorder:self.velvetView];
        [colorizer colorShadow:materialView];
        [colorizer colorLine:self.velvetView inFrame:materialView.frame];
        [colorizer colorTitle:title];
        [colorizer colorMessage:message];
        [colorizer setAppearance:self];
    }
}
%end

%hook NCNotificationSeamlessContentView
-(void)didMoveToWindow {
    %orig;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(velvetUpdateStyle) name:@"com.noisyflake.velvet2/updateStyle" object:nil];
}
-(void)layoutSubviews {
    %orig;

    [self velvetUpdateStyle];
}

%new
-(void)velvetUpdateStyle {
    NCNotificationShortLookViewController *controller = [self _viewControllerForAncestor];
    Velvet2Colorizer *colorizer = [[Velvet2Colorizer alloc] initWithIdentifier:controller.notificationRequest.sectionIdentifier];

    UILabel *title                                          = [self valueForKey:@"primaryTextLabel"];
    UILabel *message                                        = [self valueForKey:@"secondaryTextElement"];
    UILabel *footer                                         = [self valueForKey:@"footerTextLabel"];
    NCBadgedIconView *badgedIconView                        = [self valueForKey:@"badgedIconView"];

    [colorizer toggleAppIconVisibility:badgedIconView withTitle:title message:message footer:footer alwaysUpdate:YES];
}
%end

// Fix notifications in a stack having the wrong color because they were re-used

%hook NCNotificationListView
-(void)recycleVisibleViews{}
-(void)_recycleViewIfNecessary:(id)arg1{}
-(void)_recycleViewIfNecessary:(id)arg1 withDataSource:(id)arg2{}
%end

%ctor {
    prefsManager = [NSClassFromString(@"Velvet2PrefsManager") sharedInstance];

    if ([[prefsManager objectForKey:@"enabled"] boolValue]) {
        %init;
    }
}
#import <CoreImage/CoreImage.h>

// MARK: - Enhanced Music Player Support for Velvet 2
%hook CSMediaControlsViewController

- (void)viewDidLayoutSubviews {
    %orig;

    UIView *mediaControlsView = self.view;
    if (!mediaControlsView) return;

    // Artwork view (the big square album art)
    UIImageView *artworkView = [mediaControlsView valueForKey:@"_artworkView"];
    if (artworkView && artworkView.image) {
        // Remove any old glow layer
        artworkView.layer.shadowOpacity = 0;

        // Extract dominant/vibrant color from album art
        UIColor *dominant = [self dominantColorFromImage:artworkView.image] ?: [UIColor systemBlueColor];

        // Add glow
        artworkView.layer.shadowColor   = dominant.CGColor;
        artworkView.layer.shadowOpacity = 0.85;
        artworkView.layer.shadowRadius  = 14.0;
        artworkView.layer.shadowOffset  = CGSizeZero;
        artworkView.layer.masksToBounds = NO;
    }

    // Scrubber / progress bar
    UISlider *scrubber = [mediaControlsView valueForKey:@"_routeSlider"] ?: 
                         [mediaControlsView valueForKey:@"_timeSlider"];
    if (scrubber) {
        scrubber.minimumTrackTintColor = [UIColor whiteColor];
        scrubber.maximumTrackTintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
        scrubber.thumbTintColor       = [UIColor whiteColor];
    }
}

// Simple dominant color extractor (fast enough for real-time)
%new
- (UIColor *)dominantColorFromImage:(UIImage *)image {
    CGSize size = CGSizeMake(1, 1);
    UIGraphicsBeginImageContextWithOptions(size, YES, 1.0);
    [image drawInRect:CGRectMake(0, 0, 1, 1)];
    uint8_t rgba[4] = {0};
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGImageRef imgRef = CGBitmapContextCreateImage(ctx);
    CGContextDrawImage(ctx, CGRectMake(0, 0, 1, 1), imgRef);
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(rgba, 1, 1, 8, 4, space, kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(bitmapContext, CGRectMake(0, 0, 1, 1), imgRef);
    CGContextRelease(bitmapContext);
    CGColorSpaceRelease(space);
    CGImageRelease(imgRef);
    UIGraphicsEndImageContext();

    return [UIColor colorWithRed:rgba[0]/255.0 green:rgba[1]/255.0 blue:rgba[2]/255.0 alpha:1.0];
}
%end

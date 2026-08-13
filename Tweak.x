// =============================================================================
// Tweak.x — R6 Mobile iOS Injection
// =============================================================================
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import <dlfcn.h>

// Unity function pointers
typedef void (*UnitySetGraphicsDevice_t)(void*);
typedef void (*UnityRenderBeforeForward_t)(void*);

UnitySetGraphicsDevice_t orig_UnitySetGraphicsDevice = NULL;

// Mod Menu State
@interface ModMenu : NSObject
@property (nonatomic, strong) UIWindow *menuWindow;
@property (nonatomic, strong) UIViewController *menuVC;
@property (nonatomic, assign) BOOL menuVisible;
+ (instancetype)sharedInstance;
- (void)showMenu;
- (void)toggleMenu;
@end

@implementation ModMenu

+ (instancetype)sharedInstance {
    static ModMenu *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ModMenu alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _menuVisible = NO;
    }
    return self;
}

- (void)showMenu {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.menuWindow) {
            self.menuWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            self.menuWindow.windowLevel = UIWindowLevelAlert + 100;
            self.menuWindow.backgroundColor = [UIColor colorWithRed:0.03 green:0.03 blue:0.05 alpha:0.95];
            self.menuWindow.layer.cornerRadius = 12;
            self.menuWindow.layer.masksToBounds = YES;
            
            self.menuVC = [[UIViewController alloc] init];
            self.menuWindow.rootViewController = self.menuVC;
            
            // Title Label
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, 300, 30)];
            title.text = @"R6 MOBILE MOD";
            title.textColor = [UIColor colorWithRed:0.4 green:0.7 blue:1.0 alpha:1.0];
            title.font = [UIFont boldSystemFontOfSize:22];
            [self.menuVC.view addSubview:title];
            
            // ESP Toggle
            UISwitch *espSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(20, 100, 0, 0)];
            [espSwitch addTarget:self action:@selector(espToggled:) forControlEvents:UIControlEventValueChanged];
            [self.menuVC.view addSubview:espSwitch];
            
            UILabel *espLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 100, 200, 30)];
            espLabel.text = @"Enable ESP";
            espLabel.textColor = [UIColor whiteColor];
            [self.menuVC.view addSubview:espLabel];
        }
        self.menuWindow.hidden = !self.menuVisible;
    });
}

- (void)espToggled:(UISwitch*)sender {
    // Hook your ESP boolean here
    // espEnabled = sender.isOn;
}

- (void)toggleMenu {
    _menuVisible = !_menuVisible;
    [self showMenu];
}

@end

// Hook Unity's entry point to inject our menu
%hook UIApplication
- (void)sendEvent:(UIEvent *)event {
    %orig;
    
    // Detect 3-finger tap to toggle menu
    if (event.type == UIEventTypeTouches) {
        NSSet *touches = [event touchesForView:nil];
        if (touches.count >= 3) {
            [[ModMenu sharedInstance] toggleMenu];
        }
    }
}
%end

// Hook Unity's graphics device initialization
extern "C" void UnitySetGraphicsDevice(void* device) {
    if (!orig_UnitySetGraphicsDevice) {
        orig_UnitySetGraphicsDevice = (UnitySetGraphicsDevice_t)dlsym(RTLD_DEFAULT, "UnitySetGraphicsDevice");
    }
    if (orig_UnitySetGraphicsDevice) {
        orig_UnitySetGraphicsDevice(device);
    }
    // Mod is now fully loaded in the game's context
}

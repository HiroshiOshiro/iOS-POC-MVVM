#import "SceneDelegate.h"
#import "BreedListViewController.h"
#import "FavoritesListViewController.h"
#import "SettingsViewController.h"

@implementation SceneDelegate

- (void)scene:(UIScene *)scene
willConnectToSession:(UISceneSession *)session
      options:(UISceneConnectionOptions *)connectionOptions {
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window.rootViewController = [self makeTabBarController];
    [self.window makeKeyAndVisible];
}

- (UITabBarController *)makeTabBarController {
    // Dog tab
    BreedListViewController *dogVC = [[BreedListViewController alloc] init];
    UINavigationController *dogNav =
        [[UINavigationController alloc] initWithRootViewController:dogVC];
    dogNav.tabBarItem = [[UITabBarItem alloc]
        initWithTitle:NSLocalizedString(@"tab.dog", nil)
                image:[UIImage systemImageNamed:@"pawprint"]
                  tag:0];

    // Favorites tab
    FavoritesListViewController *favVC = [[FavoritesListViewController alloc] init];
    UINavigationController *favNav =
        [[UINavigationController alloc] initWithRootViewController:favVC];
    favNav.tabBarItem = [[UITabBarItem alloc]
        initWithTitle:NSLocalizedString(@"tab.favorites", nil)
                image:[UIImage systemImageNamed:@"heart"]
                  tag:1];

    // Settings tab
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    UINavigationController *settingsNav =
        [[UINavigationController alloc] initWithRootViewController:settingsVC];
    settingsNav.tabBarItem = [[UITabBarItem alloc]
        initWithTitle:NSLocalizedString(@"tab.settings", nil)
                image:[UIImage systemImageNamed:@"gearshape"]
                  tag:2];

    UITabBarController *tabBar = [[UITabBarController alloc] init];
    tabBar.viewControllers = @[dogNav, favNav, settingsNav];

    UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    tabBar.tabBar.standardAppearance = appearance;
    tabBar.tabBar.scrollEdgeAppearance = appearance;

    return tabBar;
}

@end

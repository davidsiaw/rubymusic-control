@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@import "ListWindowController.j"

@import "LoginView.j"
@import "Session.j"


@implementation AppController : CPObject
{
    LoginView loginView;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
        contentView = [theWindow contentView];

    loginView = [[LoginView alloc] initWithFrame:[contentView frame]];
    [loginView setDelegate:self];
    [loginView setLoading:YES];
    [contentView addSubview: loginView];

    [[Session instance] setDelegate:self];
    [[Session instance] checkToken];

    [theWindow orderFront:self];

    // removeAllItems doesnt seem to work on the main menu
    var menu = [[CPApplication sharedApplication] mainMenu];
    [menu removeItemAtIndex:0];
    [menu removeItemAtIndex:0];
    [menu removeItemAtIndex:0];
    [menu removeItemAtIndex:0];
    [menu removeItemAtIndex:0];

    var openMenuItem = [menu addItemWithTitle:"Library" action:nil keyEquivalent:""];

    var openMenu = [CPMenu new];
    [menu setSubmenu:openMenu forItem:openMenuItem];

    [openMenu addItemWithTitle:"View" action:@selector(openLibrary:) keyEquivalent:""];
}

- (void)openLibrary:(id)sender
{
    var window = [[CPWindow alloc] initWithContentRect:CGRectMake(50,50,700,500) styleMask:CPClosableWindowMask | CPResizableWindowMask | CPTitledWindowMask];
    var windowController = [[ListWindowController alloc] initWithWindow:window];
    [windowController showWindow:window];
}

- (void)userClickedLoginButton:(id)sender
{
    [[Session instance] loginWithUsername:[loginView username] andPassword:[loginView password]];
    [loginView setLoading:YES];
}

- (void)loginFailed:(id)sender
{
    [loginView setLoading:NO];
}

- (void)loginSucceeded:(id)sender
{
    [loginView removeFromSuperview];
    [CPMenu setMenuBarVisible:YES];
}

@end

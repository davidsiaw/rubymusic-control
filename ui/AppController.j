@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@import "extern.j"
@import "Session.j"
@import "ListWindowController.j"
@import "LoginView.j"


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

  var fileMenuItem = [menu addItemWithTitle:"Media" action:nil keyEquivalent:""];

  var fileMenu = [CPMenu new];
  [menu setSubmenu:fileMenu forItem:fileMenuItem];

  [fileMenu addItemWithTitle:"Library" action:@selector(openLibrary:) keyEquivalent:""];
  [fileMenu addItemWithTitle:"Default Playlist" action:@selector(openDefaultPlaylist:) keyEquivalent:""];
  [fileMenu addItemWithTitle:"Playlists" action:@selector(openPlaylists:) keyEquivalent:""];


  var botMenuItem = [menu addItemWithTitle:"Bots" action:nil keyEquivalent:""];

  var botMenu = [CPMenu new];
  [menu setSubmenu:botMenu forItem:botMenuItem];

  [botMenu addItemWithTitle:"List" action:@selector(showBots:) keyEquivalent:""];
}

- (void)openLibrary:(id)sender
{
        
  var window = [[CPWindow alloc] initWithContentRect:CGRectMake(50,50,700,300) styleMask:CPClosableWindowMask | CPResizableWindowMask | CPTitledWindowMask];
  var windowController = [[ListWindowController alloc] initWithWindow:window andModel:SONG_MODEL andTitle:"Library" withNature:"library"];
  [windowController showWindow:window];
}

- (void)openDefaultPlaylist:(id)sender
{       
  var window = [[CPWindow alloc] initWithContentRect:CGRectMake(50,400,700,300) styleMask:CPClosableWindowMask | CPResizableWindowMask | CPTitledWindowMask];
  var windowController = [[ListWindowController alloc] initWithWindow:window andModel:SONG_MODEL andTitle:"Default Playlist" withNature:"list"];
  [windowController showWindow:window];
}

- (void)showBots:(id)sender
{       
  var window = [[CPWindow alloc] initWithContentRect:CGRectMake(50,400,700,300) styleMask:CPClosableWindowMask | CPResizableWindowMask | CPTitledWindowMask];
  var windowController = [[ListWindowController alloc] initWithWindow:window andModel:BOT_MODEL andTitle:"Music Bots" withNature:"library"];
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

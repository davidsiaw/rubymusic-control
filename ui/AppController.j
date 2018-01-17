@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@import "extern.j"
@import "ListWindowController.j"

@import "LoginView.j"
@import "Session.j"

SONG_MODEL = {
  type: "Song",
  fields: {
    song_name: {},
    artist_name: {},
    url: {},
  }
}

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

  var openMenuItem = [menu addItemWithTitle:"File" action:nil keyEquivalent:""];

  var openMenu = [CPMenu new];
  [menu setSubmenu:openMenu forItem:openMenuItem];

  [openMenu addItemWithTitle:"Library" action:@selector(openLibrary:) keyEquivalent:""];
  [openMenu addItemWithTitle:"Default Playlist" action:@selector(openDefaultPlaylist:) keyEquivalent:""];
  [openMenu addItemWithTitle:"Playlists" action:@selector(openPlaylists:) keyEquivalent:""];
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

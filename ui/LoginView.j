@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation LoginView : CPView
{
    CPBox _box;

    CPTextField _username;
    CPTextField _password;

    CPButton _loginButton;

    id delegate @accessors;
}

- (id)initWithFrame:(CGRect)aRect
{
    self = [super initWithFrame:aRect];
    if (self)
    {
        _box = [[CPBox alloc] initWithFrame:CGRectMake(0,0,300,200)];
        [_box setCenter:[self center]];
        [self addSubview:_box];

        var usernameLabel = [CPTextField labelWithTitle:@"Username"];
        [usernameLabel setFrameOrigin:CGPointMake(20,50)];
        [_box addSubview: usernameLabel];

        _username = [CPTextField textFieldWithStringValue:"" placeholder:"" width:200];
        [_username setFrameOrigin:CGPointMake(80,40)];
        [_box addSubview: _username];

        var passwordLabel = [CPTextField labelWithTitle:@"Password"];
        [passwordLabel setFrameOrigin:CGPointMake(20,90)];
        [_box addSubview: passwordLabel];

        _password = [CPTextField textFieldWithStringValue:"" placeholder:"" width:200];
        [_password setSecure:YES];
        [_password setFrameOrigin:CGPointMake(80,80)];
        [_box addSubview: _password];

        _loginButton = [CPButton buttonWithTitle:"Login"];
        [_loginButton setCenter:CGPointMake(150, 150)];
        [_loginButton setKeyEquivalent:@"\r"];
        [_loginButton setTarget:self];
        [_loginButton setAction:@selector(buttonClicked:)];
        [_box addSubview: _loginButton];
    }
    return self;
}

-(CPString)username
{
    return [_username stringValue];
}

-(CPString)password
{
    return [_password stringValue];
}

-(void)setLoading:(BOOL)aFlag
{
    if (aFlag)
    {
        [_loginButton setEnabled: NO];
    }
    else
    {
        [_loginButton setEnabled: YES];
    }
}

-(BOOL)isLoading
{
    return ![_loginButton isEnabled];
}

-(void)buttonClicked:(id)sender
{
    if ( [[self delegate] respondsToSelector:@selector(userClickedLoginButton:)] )
    {
        [[self delegate] userClickedLoginButton:self];
    }
}

@end

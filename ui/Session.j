@import <Foundation/Foundation.j>

var _static_session = nil;
@implementation Session : CPObject
{
    id delegate @accessors;
    BOOL isLoggedIn @accessors;
    CPString apiToken;
}

- (CPString)apiToken
{
    return self.apiToken;
}

- (void)loginWithUsername:(CPString)username andPassword:(CPString)password
{
    var request = [CPURLRequest requestWithURL:[CPString stringWithFormat:"%@%@", API_URL, "/api/session"]];
    [request setHTTPMethod: "POST"];
    [request setHTTPBody: JSON.stringify({
                   email: username,
                password: password
    })];
    [request setValue:"application/json" forHTTPHeaderField:"Content-Type"];
    [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)checkToken
{
    var request = [CPURLRequest requestWithURL:[CPString stringWithFormat:"%@%@?api_token=%@", API_URL, "/api/session", apiToken]];
   [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(CPURLConnection)anURLConnection didReceiveData:(CPString)aData
{
    try {
        var data = JSON.parse(aData);
        if (data.api_token)
        {
            isLoggedIn = true;
            apiToken = data.api_token;

            if (typeof(Storage) !== "undefined")
            {
                window.localStorage.api_token = apiToken;
            }

            if ( [self.delegate respondsToSelector:@selector(loginSucceeded:)] )
            {
                [self.delegate loginSucceeded:self];
            }
        }
        else if (data.message)
        {
            isLoggedIn = true;
            if ( [self.delegate respondsToSelector:@selector(loginSucceeded:)] )
            {
                [self.delegate loginSucceeded:self];
            }
        }
        else
        {
            window.localStorage.api_token = nil;
            if ( [self.delegate respondsToSelector:@selector(loginFailed:)] )
            {
                [self.delegate loginFailed:self];
            }
        }
    }
    catch (e) {
        apiToken = nil;
        isLoggedIn = false;
        if ( [[self delegate] respondsToSelector:@selector(loginFailed:)] )
        {
            [[self delegate] loginFailed:self];
        }
    }
    //console.log(aData);
}

- (id)init
{
    self = [super init];
    if (self)
    {
        isLoggedIn = false;
        delegate = nil;
        apiToken = nil;
        if (typeof(Storage) !== "undefined")
        {
            apiToken = window.localStorage.getItem("api_token");
        }
    }
    return self;
}

+ (Session)instance
{
    if (!_static_session)
    {
        _static_session = [Session new];
    }
    return _static_session;
}

@end
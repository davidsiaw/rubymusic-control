@import <Foundation/Foundation.j>

@implementation CPDictionary (JavaScript)

+ (CPDictionary)fromJSObject:(id)anObject
{
  var dict = [[CPDictionary alloc] init];

  for (var key in anObject)
  {
    [dict setValue:anObject[key] forKey:key];
  }

  return dict;
}

@end

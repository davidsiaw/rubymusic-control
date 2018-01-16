@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@import "AppController.j"

API_URL = "http://localhost:5000"

function pad(num)
{
	var str = "" + num;
	var pad = "00";
	return pad.substring(0, pad.length - str.length) + str;
}

function main(args, namedArgs)
{
    CPApplicationMain(args, namedArgs);
}

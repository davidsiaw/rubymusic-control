@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@import "AppController.j"

API_URL = "http://localhost:5000"

DRAG_TYPES = {}

function pad(num)
{
	var str = "" + num;
	var pad = "00";
	return pad.substring(0, pad.length - str.length) + str;
}

function get_drag_type(type)
{
	if (!DRAG_TYPES[type])
	{
		DRAG_TYPES[type] = [CPString stringWithFormat: @"%@ItemDragType", type];
		console.log(DRAG_TYPES[type])
	}
	return DRAG_TYPES[type]
}

function main(args, namedArgs)
{
    CPApplicationMain(args, namedArgs);
}

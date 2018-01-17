
API_URL = "http://192.168.1.15:5000"

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
	}
	return DRAG_TYPES[type]
}

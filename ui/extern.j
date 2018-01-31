
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

SONG_MODEL = {
  type: "Song",
  slug: "songs",
  fields: {
           name: {editable: true},
    artist_name: {editable: true},
            url: {editable: true},
  }
}

BOT_MODEL = {
  type: "Bot",
  slug: "bots",
  fields: {
           name: {editable: true},
          token: {editable: true, type: "secure"},
       location: {editable: true},
       playlist: {},
        playing: {editable: true, type: "boolean"},
      reachable: {type: "boolean"},
  }
}

PLAYLIST_MODEL = {
  type: "Playlist",
  slug: "playlists",
  list_of: SONG_MODEL,
  fields: {
    open: {type: "method", selector:@selector(openPlaylist:)},
    name: {editable: true}
  }
}

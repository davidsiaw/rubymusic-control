@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation ListTableDataSource : CPObject
{
  ListTableView dataView @accessors;
  id delegate @accessors;

  id model;
  CPString nature;

  int dataLength;
  id data;

  CPString listId @accessors;

  CPArray _draggedItems;
}

- (CPArray)draggedItems
{
  return _draggedItems
}

- (BOOL)outlineView:(CPOutlineView)anOutlineView writeItems:(CPArray)theItems toPasteboard:(CPPasteBoard)thePasteBoard
{
  if ([dataView inEditMode])
  {
    return NO;
  }

  var dragtype = get_drag_type(self.model.type+self.nature)
  _draggedItems = theItems;
  [thePasteBoard declareTypes:[dragtype] owner:self];
  [thePasteBoard setData:[CPKeyedArchiver archivedDataWithRootObject:theItems] forType:dragtype];

  return YES;
}

- (CPDragOperation)outlineView:(CPOutlineView)outlineView validateDrop:(CPDraggingInfo)theInfo proposedItem:(id)theItem proposedChildIndex:(int)theIndex
{
    CPLog.debug(@"validate item: %@, from idx %@, at index: %i", theItem, [theInfo draggingSource], theIndex);

    if (theItem === nil && nature === "list")
    {
      [outlineView setDropItem:nil dropChildIndex:theIndex];
      if ([[theInfo draggingSource] UID] === [outlineView UID])
      {
        return CPDragOperationMove;
      }

      if (nature === "library")
      {
        return CPDragOperationMove;
      }
      else
      {
        return CPDragOperationCopy;
      }
    }

    return CPDragOperationNone;
}

- (BOOL)outlineView:(CPOutlineView)outlineView acceptDrop:(CPDraggingInfo)theInfo item:(id)theItem childIndex:(int)theIndex
{
  if(theItem)
  {
    return NO;
  }

  if ([[theInfo draggingSource] UID] === [outlineView UID] && self.nature === "list")
  {
    // Internal drop (move)
    var newArray = []
    var i=0;

    var count = [_draggedItems count];

    var draggedOrdinals = {}

    for (i=0; i<count; ++i)
    {
      // Record dragged items
      draggedOrdinals[ [[_draggedItems objectAtIndex:i] valueForKey:"ord"] ] = true;
    }

    // Insert items before
    for(i=0;i<theIndex;i++)
    {
      if (draggedOrdinals[i])
      {
        continue;
      }
      newArray.push(data[i])
    }

    // Insert dragged items
    for (i=0; i<count; ++i)
    {
      newArray.push([_draggedItems objectAtIndex:i])
    }

    for(i=theIndex;i<dataLength;i++)
    {
      if (draggedOrdinals[i])
      {
        continue;
      }
      newArray.push(data[i])
    }

    data = {}
    for (i=0;i<newArray.length;i++)
    {
      var obj = newArray[i];
      [obj setValue:i forKey:"ord"];
      data[i] = obj;
    }

    return YES;
  }

  if (self.nature === "list")
  {
    // External drop (copy)
    var newArray = []
    var i=0;

    var draggedData = [[theInfo draggingPasteboard] dataForType:get_drag_type(self.model.type+"list")];
    if (!draggedData)
    {
      draggedData = [[theInfo draggingPasteboard] dataForType:get_drag_type(self.model.type+"library")];
    }

    var toBeInserted = [CPKeyedUnarchiver unarchiveObjectWithData:draggedData];
    var count = [toBeInserted count];

    // Insert items before
    for(i=0;i<theIndex;i++)
    {
      newArray.push(data[i])
    }

    // Insert dragged items
    for (i=0; i<count; ++i)
    {
      newArray.push([toBeInserted objectAtIndex:i])
    }

    for(i=theIndex;i<dataLength;i++)
    {
      newArray.push(data[i])
    }

    data = {}
    for (i=0;i<newArray.length;i++)
    {
      var obj = newArray[i];
      [obj setValue:i forKey:"ord"];
      data[i] = obj;
    }
    dataLength = newArray.length

    return YES;
  }

  return NO;
}


- (id)initWithModel:(id)aModel andNature:(CPString)aNature
{
  self = [super init];
  if (self)
  {
    self.model = aModel
    self.nature = aNature

    self.dataLength = -1
    self.data = {}

    //self.data[0] = [CPDictionary fromJSObject: {ord: 0, id: "a", name: "7 Senses", artist_name: "Wake Up Girls!", url: "https://7senses.flac"}]
    //self.data[1] = [CPDictionary fromJSObject: {ord: 1, id: "b", name: "Change!", artist_name: "765 All Stars", url: "https://change.flac"}]
    //self.data[2] = [CPDictionary fromJSObject: {ord: 2, id: "c", name: "Taiyou wo Oikakero", artist_name: "Aqours", url: "https://tokotoko.flac"}]

  }
  return self;
}

- (void)resetData
{
  self.dataLength = -1;
  self.data = {};
}

- (void)refreshFromServer
{
  [self getItemFromServerAtIndex:0];
}

- (void)getItemFromServerAtIndex:(int)item
{
  var descriptors = [[dataView tableView] sortDescriptors];
  var sort = "id:a"

  if(descriptors)
  {
    var idx = 0;
    for (idx=descriptors.length-1; idx >= 0; idx--)
    {
      sort += "," + [descriptors[idx] key] + ":" + ([descriptors[idx] ascending] ? "a" : "d")
    }

  }

  [SessionRequest GET:[CPString stringWithFormat:"/%@/%@", self.model.slug, self.nature]
            forTarget:self
            withQuery:"item=" + item + "&sort=" + sort + (listId ? "&list=" + listId : "")
            andNotify:@selector(dataDidLoad:)
            otherwise:@selector(dataLoadDidError:)];
}

- (void)dataDidLoad:(id)loadedData
{
  if (loadedData.data_length !== Object.keys(loadedData.data).length)
  {
    console.log("invalid response: ", loadedData.dataLength, Object.keys(loadedData.data).length)
    console.log(loadedData)
    return;
  }
  self.dataLength = loadedData.data_length;
  for (var idx in loadedData.data)
  {
    var obj = loadedData.data[idx];
    obj.ord = idx;
    self.data[idx] = [CPDictionary fromJSObject:obj];
  }
  [[dataView tableView] reloadData];
}

- (void)dataLoadDidError:(id)error
{
  console.log("dataLoadDidError", error)
}

- (void)modifyDidComplete:(id)data
{
  [self refreshFromServer];
}

- (void)modifyError:(id)error
{
  console.log("modifyError", error)
}

- (void)setFilter:(id)aFilter
{
  [[dataView tableView] reloadData];
}

- (CPString)description
{
  // Return a string that describes the object for debugging purposes
  return [CPString stringWithFormat:@"<ListTableDataSource #%d>", 0];
}

- (id)outlineView:(CPOutlineView)outlineView child:(CPInteger)index ofItem:(id)item
{
  if (item === nil)
  {
    if (!self.data[index])
    {
      [self getItemFromServerAtIndex:index];
      return null;
    }

    return self.data[index];
  }

  return nil;
}

- (BOOL)outlineView:(CPOutlineView)outlineView isItemExpandable:(id)theItem
{
  return NO;
}

- (int)outlineView:(CPOutlineView)outlineView numberOfChildrenOfItem:(id)theItem
{
  if (theItem === nil)
  {
    if (self.dataLength === -1)
    {
      [self refreshFromServer]
      return 0;
    }
    return dataLength;
  }

  return 0;
}

- (id)outlineView:(CPOutlineView)outlineView objectValueForTableColumn:(CPTableColumn)aColumn byItem:(id)item
{
  if ([aColumn identifier] === "ord")
  {
    return [item valueForKey:"ord"];
  }

  if (item)
  {
    var identifier = [aColumn identifier];
    var obj = [item valueForKey:identifier];
    var fields = self.model.fields;

    if (fields[identifier].type === "time")
    {
      if (obj)
      {
        var date = new Date(obj);
        return pad(date.getHours()) + ":" + pad(date.getMinutes());
      }
      else
      {
        return "00:00";
      }
    }
    if (fields[identifier].type === "date")
    {
      if (obj == null)
      {
        return "";
      }
      var date = new Date(obj);
      return pad(date.getFullYear()) + "/" + pad(date.getMonth() + 1) + "/" + pad(date.getDate());
    }
    if (fields[identifier].type === "datetime")
    {
      if (obj == null)
      {
        return "";
      }
      var date = new Date(obj);
      return pad(date.getFullYear()) + "/" + pad(date.getMonth() + 1) + "/" + pad(date.getDate()) + " " + pad(date.getHours()) + ":" + pad(date.getMinutes());
    }
    if (fields[identifier].type === "choice")
    {
      var arr = fields[identifier].choices;
      return arr.indexOf(obj);
    }

    return obj;
  }
  return undefined;
}

- (void)outlineView:(CPOutlineView)outlineView setObjectValue:(id)object forTableColumn:(CPTableColumn)tableColumn byItem:(id)item
{
  if (self.model.fields[[tableColumn identifier]].type === "method")
  {
    if ([self.delegate respondsToSelector:@selector(methodButtonClicked:withItem:)])
    {
      [self.delegate methodButtonClicked:self.model.fields[[tableColumn identifier]].selector withItem:item];
    }
    return;
  }

  [SessionRequest POST:[CPString stringWithFormat:"/%@/%@/modify", self.model.slug, self.nature]
             forTarget:self
             withQuery:(listId ? "list=" + listId : "")
              withBody:{id: [item valueForKey:"id"], field: [tableColumn identifier], value: object}
             andNotify:@selector(modifyDidComplete:)
             otherwise:@selector(modifyError:)];


  [item setValue:object forKey:[tableColumn identifier]];
}

- (BOOL)outlineView:(CPOutlineView)outlineView shouldEditTableColumn:(CPTableColumn)tableColumn item:(id)item
{
  if (self.nature === "list")
  {
    return NO;
  }

  if ([tableColumn identifier] === "ord")
  {
    return NO;
  }
  return YES;
}

- (void)outlineView:(CPOutlineView)outlineView sortDescriptorsDidChange:(CPArray)oldDescriptors
{
  [self resetData];
  [outlineView reloadData];
  return;

  var descriptors = [outlineView sortDescriptors];
  var idx = 0;
  var newArray = [];

  for(idx=0; idx<self.dataLength; idx++)
  {
    newArray.push(self.data[idx])
  }

  for (idx=descriptors.length-1; idx >= 0; idx--)
  {
    newArray.sort(function(a,b)
    {
      return [descriptors[idx] compareObject:a withObject:b];
    })
  }

  self.data = {}
  
  for (idx=0; idx<newArray.length; idx++)
  {
    var obj = newArray[idx];
    [obj setValue:idx forKey:"ord"];
    self.data[idx] = obj;
  }

  [outlineView reloadData];
}

- (BOOL)canAdd
{
  if (self.nature === "library")
  {
    return YES;
  }
  return NO;
}

- (void)addClicked:(id)sender
{
  if (self.nature === "library")
  {

    [SessionRequest POST:[CPString stringWithFormat:"/%@/%@", self.model.slug, self.nature]
               forTarget:self
               withQuery:(listId ? "list=" + listId : "")
                withBody:{}
               andNotify:@selector(modifyDidComplete:)
               otherwise:@selector(modifyError:)];

  }
}


@end

@implementation SessionRequest : CPObject
{
  CPString path;
  SEL action @accessors;
  SEL errorAction @accessors;
  id target @accessors;
  CPString query @accessors;
  CPString method @accessors;
  id body @accessors;
}

+ (void)GET:(CPString)aPath forTarget:(id)target withQuery:(CPString)query andNotify:(SEL)action otherwise:(SEL)errorAction
{
  var req = [[SessionRequest alloc] initRequestWithPath:aPath];
  [req setQuery:query];
  [req setAction:action];
  [req setErrorAction:errorAction];
  [req setTarget:target];
  [req sendRequest];
}

+ (void)POST:(CPString)aPath forTarget:(id)target withBody:(id)body andNotify:(SEL)action otherwise:(SEL)errorAction
{
  var req = [[SessionRequest alloc] initRequestWithPath:aPath];
  [req setMethod:"POST"];
  [req setBody:body];
  [req setAction:action];
  [req setErrorAction:errorAction];
  [req setTarget:target];
  [req sendRequest];
}

+ (void)POST:(CPString)aPath forTarget:(id)target withQuery:(CPString)query withBody:(id)body andNotify:(SEL)action otherwise:(SEL)errorAction
{
  var req = [[SessionRequest alloc] initRequestWithPath:aPath];
  [req setMethod:"POST"];
  [req setQuery:query];
  [req setBody:body];
  [req setAction:action];
  [req setErrorAction:errorAction];
  [req setTarget:target];
  [req sendRequest];
}

- (id)initRequestWithPath:(CPString)aPath
{
  self = [super init];
  if (self)
  {
    self.path = aPath;
    self.target = null;
    self.action = null;
    self.body = null;
    self.query = null;
    self.method = "GET";
  }
  return self;
}

- (void)sendRequest
{
  var api_token = [[Session instance] apiToken];

  var added_query = "";
  if (self.query)
  {
    added_query = "&" + self.query;
  }

  var request = [CPURLRequest requestWithURL:[CPString stringWithFormat:"%@/api%@?api_token=%@%@", API_URL, self.path, api_token, added_query ]];
  [request setHTTPMethod:self.method];
  if (body)
  {  
    [request setHTTPBody: JSON.stringify(body)];
    [request setValue:"application/json" forHTTPHeaderField:"Content-Type"]; 
  }

  [CPURLConnection connectionWithRequest:request delegate:self]; 
}

- (void)connection:(CPURLConnection)anURLConnection didReceiveData:(CPString)aData
{
    try
    {
      var data = JSON.parse(aData);
      if ( [self.target respondsToSelector:self.action] )
      {
        [self.target performSelector:self.action withObject:data];
      }
    }
    catch (e)
    {
      if ( [self.target respondsToSelector:self.errorAction] )
      {
        [self.target performSelector:self.errorAction withObject:e];
      }
    }
    //console.log(aData);
}

@end

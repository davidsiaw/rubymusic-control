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
    self.dataLength = 3

    self.data = {}

    //self.data[0] = [CPDictionary fromJSObject: {ord: 0, id: "a", name: "7 Senses", artist_name: "Wake Up Girls!", url: "https://7senses.flac"}]
    //self.data[1] = [CPDictionary fromJSObject: {ord: 1, id: "b", name: "Change!", artist_name: "765 All Stars", url: "https://change.flac"}]
    //self.data[2] = [CPDictionary fromJSObject: {ord: 2, id: "c", name: "Taiyou wo Oikakero", artist_name: "Aqours", url: "https://tokotoko.flac"}]

  }
  return self;
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

- (CPInteger)numberOfRows
{
  return dataLength;
}

- (id)outlineView:(CPOutlineView)outlineView child:(CPInteger)index ofItem:(id)item
{
  if (item === nil)
  {
    return self.data[index];
  }

  return nil;
}

- (BOOL)outlineView:(CPOutlineView)outlineView isItemExpandable:(id)item
{
  return NO;
}

- (int)outlineView:(CPOutlineView)outlineView numberOfChildrenOfItem:(id)item
{
  if (item === nil)
  {
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
  console.log(object)
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
    var obj = {ord: dataLength}

    var fields = model.fields;

    for (var key in fields)
    {
      obj[key] = "<" + key + ">"
    }
    self.data[dataLength] = [CPDictionary fromJSObject: obj]
    dataLength += 1
    [[dataView tableView] reloadData];
  }
}

@end

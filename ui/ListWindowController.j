@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation ListTableView : CPView
{
  CPScrollView scrollView;
  CPOutlineView tableView @accessors;
}

- (id)initWithFrame:(CGRect)aFrame
{
  self = [super initWithFrame:aFrame];
  if (self)
  {
    scrollView = [[CPScrollView alloc] initWithFrame:[self bounds]];
    tableView = [[CPOutlineView alloc] initWithFrame:CGRectMakeZero()];
    [tableView setUsesAlternatingRowBackgroundColors:YES];
    [tableView setAutoresizingMask:  CPViewWidthSizable | CPViewHeightSizable];
    [scrollView setAutoresizingMask: CPViewWidthSizable | CPViewHeightSizable];
    [scrollView setHasHorizontalScroller: YES];


    [scrollView setDocumentView:tableView];

    [self addSubview:scrollView];

  }
  return self;
}

- (CPOutlineView)table
{
  return tableView;
}

- (id)dataSource
{
  return [tableView dataSource];
}

- (void)setDataSource:(id)aDataSource
{
  [tableView setDataSource:aDataSource];
}

- (id)delegate
{
  return [tableView delegate];
}

- (void)setDelegate:(id)aDelegate
{
  [tableView setDelegate:aDelegate];
  [aDelegate setDataView:self];
}

- (void)applyModel:(id)model
{
    var col = [[CPTableColumn alloc] initWithIdentifier:"ord"];
    [[col headerView] setStringValue:"ord"]
    [col setHidden: true];
    [tableView addTableColumn: col];


    var fields = model.fields;

    for (var key in fields)
    {
        col = [[CPTableColumn alloc] initWithIdentifier:key];
        [[col headerView] setStringValue:fields[key].name ? fields[key].name : key];
        [tableView addTableColumn: col];
        
        if (fields[key].tooltip)
        {
            //console.log(fields[key].tooltip);
            [[col headerView] setToolTip:fields[key].tooltip];
            [col setHeaderToolTip:fields[key].tooltip];
        }

        var sortDescriptor = [CPSortDescriptor sortDescriptorWithKey:key ascending:YES];
        [col setSortDescriptorPrototype:sortDescriptor];

        if (fields[key].type === "boolean")
        {
            var cbView = [CPCheckBox checkBoxWithTitle:@""];
            [cbView setEnabled: fields[key].editable];
            [col setDataView:cbView];
        }

        if (fields[key].type === "choice")
        {
            var cbv = [[CPPopUpButton alloc] initWithFrame:[self bounds]];
            [cbv addItemsWithTitles: fields[key].choices];
            [cbv setEnabled: fields[key].editable];
            [col setDataView:cbv];
        }

        //if (fields[key].type === "link")
        //{
        //    var cbv = [[HCLinkButtonView alloc] init];
        //    [cbv setTargetUrl:fields[key].href];
        //    if (fields[key].prefix) { [cbv setPrefix:fields[key].prefix]; }
        //    [col setDataView:cbv];
        //}

        if (fields[key].editable === true)
        {
            [col setEditable: YES];
        }

        if (fields[key].width)
        {
            [col setMinWidth: fields[key].width];
            [col setMaxWidth: fields[key].width];
        }
    }
}


@end

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


@implementation ListTableDataSource : CPObject
{
  CPView dataView @accessors;
  id delegate @accessors;

  id model;
  CPString nature;

  int dataLength;
  id data;

  CPArray _draggedItems;
}

- (CPArray)draggedItems
{
  return draggedItems
}

- (BOOL)outlineView:(CPOutlineView)anOutlineView writeItems:(CPArray)theItems toPasteboard:(CPPasteBoard)thePasteBoard
{
    var dragtype = get_drag_type(self.model.type+self.nature)
    _draggedItems = theItems;
    [thePasteBoard declareTypes:[dragtype] owner:self];
    [thePasteBoard setData:[CPKeyedArchiver archivedDataWithRootObject:theItems] forType:dragtype];

    return YES;
}

- (CPDragOperation)outlineView:(CPOutlineView)outlineView validateDrop:(CPDraggingInfo)theInfo proposedItem:(id)theItem proposedChildIndex:(int)theIndex
{
    CPLog.debug(@"validate item: %@, from idx %@, at index: %i", theItem, [theInfo draggingSource], theIndex);

    if (theItem === nil)
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

  if ([[theInfo draggingSource] UID] === [outlineView UID])
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

    console.log(newArray)
    console.log(data)

    return YES;
  }

  if (theIndex == dataLength)
  {
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

    self.data[0] = [CPDictionary fromJSObject: {ord: 0, id: "a", song_name: "7 Senses", artist_name: "Wake Up Girls!", url: "https://7senses.flac"}]
    self.data[1] = [CPDictionary fromJSObject: {ord: 1, id: "b", song_name: "Change!", artist_name: "765 All Stars", url: "https://change.flac"}]
    self.data[2] = [CPDictionary fromJSObject: {ord: 2, id: "c", song_name: "Taiyou wo Oikakero", artist_name: "Aqours", url: "https://tokotoko.flac"}]

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
    return aRowIndex;
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

- (BOOL)tableView:(CPTableView)aTableView shouldEditTableColumn:(CPTableColumn)aTableColumn row:(CPInteger)rowIndex
{
  return NO;
}

- (void)tableView:(CPTableView)tableView sortDescriptorsDidChange:(CPArray)oldDescriptors
{
  [tableView reloadData];
}

@end



@implementation ListTableViewController : CPObject
{
  ListTableView view;
  ListTableDataSource dataSource;
  id model;
  CPString nature;
  id delegate @accessors;
}

- (id)initWithModel:(id)aModel withNature:(CPString)aNature
{
  self = [super init];
  if (self)
  {
    self.model = aModel;
    self.nature = aNature;

    self.view = [[ListTableView alloc] initWithFrame:CGRectMakeZero()];
    self.dataSource = [[ListTableDataSource alloc] initWithModel:aModel andNature:aNature];
    [self.view setDataSource: self.dataSource];
    [self.view setDelegate: self.dataSource];

    [self.dataSource setDelegate: self];

    [self.view applyModel: aModel];

    var dragtypes = []
    dragtypes.push(get_drag_type(self.model.type+self.nature));

    if (self.nature == "list")
    {
      dragtypes.push(get_drag_type(self.model.type+"library"));
    }
    [[self.view table] registerForDraggedTypes:dragtypes];
  }
  return self;
}

- (ListTableView)view
{
  return self.view;
}

- (void)setFilter:(id)filter
{
  [self.dataSource setFilter:filter];
}

- (void)receivedData:(id)sender
{
    if ( [[self delegate] respondsToSelector:@selector(dataDidChange:)] )
    {
        [[self delegate] dataDidChange:self];
    }
}

- (CPInteger)numberOfRows
{
  return [self.dataSource numberOfRows];
}


@end


@implementation ListWindowController : CPWindowController
{
  ListTableViewController _tableController;
  ListTableView _tableView;
}

- (id)initWithWindow:(CPWindow)window andModel:(id)model andTitle:(CPString)title withNature:(CPString)nature
{
  self = [super initWithWindow:window];
  if(self)
  {
    [_window setTitle:title];

    _tableController = [[ListTableViewController alloc] initWithModel:model withNature:nature];
    [_tableController setDelegate:self];
    _tableView = [_tableController view];
    [_tableView setFrame:[[window contentView] bounds]];
    [_tableView setAutoresizingMask: CPViewWidthSizable | CPViewHeightSizable];

    [[window contentView] addSubview:_tableView];

  }
  return self
}

@end

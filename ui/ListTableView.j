@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@implementation ListTableView : CPView
{
  CPScrollView scrollView;
  CPOutlineView tableView @accessors;

  CPButton addButton;
  CPButton deleteButton;
  CPButton manageButton;
}

- (id)initWithFrame:(CGRect)aFrame
{
  self = [super initWithFrame:aFrame];
  if (self)
  {
    var scrollViewBounds = [self bounds];
    scrollViewBounds.size.height -= 40;
    scrollViewBounds.origin.y = 40;

    scrollView = [[CPScrollView alloc] initWithFrame:scrollViewBounds];
    tableView = [[CPOutlineView alloc] initWithFrame:CGRectMakeZero()];
    [tableView setUsesAlternatingRowBackgroundColors:YES];
    [tableView setAutoresizingMask:  CPViewWidthSizable | CPViewHeightSizable];
    [tableView setRowHeight:35]
    [scrollView setAutoresizingMask: CPViewWidthSizable | CPViewHeightSizable];
    [scrollView setHasHorizontalScroller: YES];

    [scrollView setDocumentView:tableView];

    [self addSubview:scrollView];

    addButton = [CPButton buttonWithTitle:"Add"];
    [addButton setFrameOrigin:CGPointMake(8,8)];
    [self addSubview:addButton];

    deleteButton = [CPButton buttonWithTitle:"Delete"];
    [deleteButton setFrameOrigin:CGPointMake([addButton bounds].size.width + 16,8)];
    [self addSubview:deleteButton];

    manageButton = [CPButton buttonWithTitle:"Manage Mode"];
    [manageButton setFrameOrigin:CGPointMake([deleteButton bounds].size.width + 8 + [addButton bounds].size.width + 16, 8)];
    [manageButton setButtonType:CPToggleButton];
    [manageButton setAlternateTitle:@"Edit Mode"];
    [self addSubview:manageButton];

  }
  return self;
}

- (void)setCanAdd:(BOOL)aValue
{
    [addButton setHidden:!aValue];
}

- (void)setCanDelete:(BOOL)aValue
{
    [deleteButton setHidden:!aValue];
}

- (void)setCanEdit:(BOOL)aValue
{
    [manageButton setHidden:!aValue];
}

- (BOOL)canAdd
{
    return ![addButton isHidden];
}

- (BOOL)canDelete
{
    return ![deleteButton isHidden];
}

- (BOOL)canEdit
{
    return ![manageButton isHidden];
}

- (BOOL)inEditMode
{
    return [manageButton state] === CPOnState;
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

  if ( [[self delegate] canAdd] )
  {
    [addButton setTarget: aDelegate];
    [addButton setAction: @selector(addClicked:)];
    [addButton setEnabled: YES];
  }
  else
  {
    [addButton setEnabled: NO];
  }

  if ( [[self delegate] canDelete] )
  {
    [deleteButton setTarget: aDelegate];
    [deleteButton setAction: @selector(deleteClicked:)];
    [deleteButton setEnabled: YES];
  }
  else
  {
    [deleteButton setEnabled: NO];
  }
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

            if (fields[key].choices)
            {
                [cbv addItemsWithTitles: fields[key].choices];
            }

            [cbv setEnabled: fields[key].editable];
            [col setDataView:cbv];
        }

        if (fields[key].type === "tags")
        {
            var cbv = [[CPTokenField alloc] initWithFrame:[self bounds]];
            [cbv setEnabled: fields[key].editable];
            [col setDataView:cbv];
        }

        if (fields[key].type === "secure")
        {
            var cbv = [[CPSecureTextField alloc] initWithFrame:[self bounds]];
            [cbv setEnabled: fields[key].editable];
            [col setDataView:cbv];
        }

        if (fields[key].type === "method")
        {
            var cbv = [CPButton buttonWithTitle:key];
            [col setDataView:cbv];
        }

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

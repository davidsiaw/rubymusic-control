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

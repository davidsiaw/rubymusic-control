@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@import "ListTableView.j"
@import "ListTableDataSource.j"

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
    if (self.nature === "list")
    {
      [[[self.view tableView] tableColumnWithIdentifier:"ord"] setHidden: false];
    }

    var dragtypes = []
    dragtypes.push(get_drag_type(self.model.type+self.nature));

    if (self.nature == "list")
    {
      dragtypes.push(get_drag_type(self.model.type+"library"));
      [self.view setCanAdd:YES];
      [self.view setCanDelete:YES];
      [self.view setCanEdit:NO];
    }
    else
    {
      [self.view setCanAdd:YES];
      [self.view setCanDelete:NO];
      [self.view setCanEdit:YES];
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

- (void)setListId:(CPString)anId;
{
  [self.dataSource setListId:anId];
}

- (void)listId
{
  return [self.dataSource listId];
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

- (void)methodButtonClicked:(SEL)selector withItem:(id)item
{
  if ( [[self delegate] respondsToSelector:@selector(methodButtonClicked:withItem:)] )
  {
      [[self delegate] methodButtonClicked:selector withItem:item];
  }
}

@end

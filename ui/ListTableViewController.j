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

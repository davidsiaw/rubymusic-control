@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@import "ListTableViewController.j"

@implementation ListWindowController : CPWindowController
{
  ListTableViewController _tableController;
  ListTableView _tableView;

  id delegate @accessors;
}

- (id)initLibraryWindow:(CPWindow)window andModel:(id)model andTitle:(CPString)title
{
  self = [super initWithWindow:window];
  if(self)
  {
    [_window setTitle:title];

    _tableController = [[ListTableViewController alloc] initWithModel:model withNature:"library"];
    [_tableController setDelegate:self];
    _tableView = [_tableController view];
    [_tableView setFrame:[[window contentView] bounds]];
    [_tableView setAutoresizingMask: CPViewWidthSizable | CPViewHeightSizable];

    [[window contentView] addSubview:_tableView];

  }
  return self
}

- (id)initListWindow:(CPWindow)window andModel:(id)model andTitle:(CPString)title withId:(CPString)anId
{
  self = [super initWithWindow:window];
  if(self)
  {
    [_window setTitle:title];

    _tableController = [[ListTableViewController alloc] initWithModel:model withNature:"list"];
    [_tableController setDelegate:self];
    [_tableController setListId:anId];
    _tableView = [_tableController view];
    [_tableView setFrame:[[window contentView] bounds]];
    [_tableView setAutoresizingMask: CPViewWidthSizable | CPViewHeightSizable];

    [[window contentView] addSubview:_tableView];

  }
  return self
}

- (void)methodButtonClicked:(SEL)selector withItem:(id)item
{
  if ( [self.delegate respondsToSelector:selector] )
  {
    [self.delegate performSelector:selector withObject:item];
  }
}

@end

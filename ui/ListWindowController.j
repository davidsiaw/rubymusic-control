@import <Foundation/Foundation.j>
@import <AppKit/AppKit.j>

@import "ListTableViewController.j"


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

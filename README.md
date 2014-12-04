TBAlertController
=================

`UIAlertController`, `UIAlertView`, and `UIActionSheet` unified for developers who want to support iOS 7 and 8.

Installation:
=============
Add `TBAlertController.h` and `TBAlertController.m` to your project and import `TBAlertController.h`. Cocoapods support coming soon!

About:
=============
`TBAlertController` tries to be as much of a drop-in replacement for the iOS 7 classes as possible, and adds a simpler interface for iOS 8 by allowing you to directly add buttons instead of first creating action objects. This feature is coming soon, however, to remain consistent with `UIAlertController`'s interface.

The only major difference for iOS 7 is that `TBAlertController` does away with delegates in favor of block and target-selector style actions. Delegate support will not be added, since this project is directed at developers who want to minimize code involving action sheets and alert views on iOS 7 and 8. It is possible to use the same code for both platforms; `TBAlertController` takes care of the rest for you.

Examples:

``` obj-c
TBAlertController *alert = [[TBAlertController alloc] initWithStyle:TBAlertControllerStyleActionSheet];
alert.title   = @"Alert";
alert.message = @"This is a message!";
[alert addOtherButtonWithTitle:@"OK" buttonAction:^{ [self pressedOK]; }];
[alert addOtherButtonWithTitle:@"Delete" target:self action:@selector(selfDestruct)];
[alert setCancelButtonWithTitle:@"Cancel"];
alert.destructiveButtonIndex = 1;
```

This will create an action sheet with the title `Alert` and a message, as well as three buttons: `OK` with a block style action, `Delete` with a target-selector style action (as well as being the "destructive" button), and a `Cancel` button which only dismisses the alert. The cancel button will always appear last in the list of buttons if set using one of the `setCancelButton...` methods.

Display an alert with `showFromViewController:` or `showFromViewController:animated:completion:`.

Actions can be added to any button, either block or target-selector style. Destructive buttons can only be added when using `TBAlertControllerStyleActionSheet` on iOS 7. Buttons can also be added with just a title.

The target-selector style actions also support passing a single parameter, like `performSelector:withObject:`.

``` obj-c
TBAlertController *alert = [[TBAlertController alloc] initWithTitle:@"Title"
                                                            message:@"Hello world"
                                                              style:TBAlertControllerStyleActionSheet];
[alert addOtherButtonWithTitle:@"Dismiss"];
[alert addOtherButtonWithTitle:@"Say hi" target:self action:@selector(say:) withObject:@"hi"];
```

The following will throw exceptions:
- setting the destructive button index when using the alert view style on iOS 7 (since iOS 7 doesn't support this)
- passing `nil` for any of the folliwing: title, target, action, or a block for `buttonAction:`. You may pass `nil` to the `object` parameter of `addOtherButtonWithTitle:target:action:withObject:`, as it will call just call the parent method which takes no `object` parameter.

TODO
- Add support for alert views with text boxes.
- Cocoapods support

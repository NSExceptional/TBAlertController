TBAlertController
=================

UIAlertController, UIAlertView, and UIActionSheet unified for develoeprs who want to support iOS 7 and 8.

TBAlertController tries to be as much of a drop-in replacement for all three classes as possible. TBAlertController objects will respond to `show`, `showInView:`, and implements it's own `showFromViewController:animated:completion:` (as well as a simpler `showFromViewController:`).

The only major difference for iOS 7 is that TBAlertController does away with delegates in favor of block and target-selector style actions. Delegate support will not be added, since this project is directed at developers who want to minimize code involving action sheets and alert views on iOS 7 and 8. It is possible to use the same code for both platforms; TBAlertController takes care of the rest for you.

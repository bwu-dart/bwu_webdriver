library bwu_webdriver.src.io;

import 'dart:math' show Point;
import 'dart:async' show Future, Stream;
import 'package:webdriver/io.dart' as wd;

part 'action_jquery_drag_and_drop.dart';

class Action {
  final wd.WebDriver driver;

  Action(this.driver);

  /// Set the [attribute] of [element] to [value].
  Future setAttribute(wd.WebElement element, String attribute, String value) {
    return driver.execute(
        'arguments[0].setAttribute(arguments[1], arguments[2])',
        [element, attribute, value]);
  }

  /// Drag the element found by [sourceSelector] or [sourceLocation] onto
  /// the element found by [targetSelector] or [targetLocation].
  /// [sourceSelector] is used as a CSS selector to find the source element.
  /// [sourceLocation] uses the element found at this position on the page as
  /// source element.
  /// [targetSelector] is used as a CSS selector to find the target element.
  /// [targetLocation] uses the element found at this position on the page as
  /// source element.
  /// [jQueryUrl] allows to pass an URL for a specific jQuery version or
  Future dragAndDrop(
      {String sourceSelector,
      Point sourceLocation,
      String targetSelector,
      Point targetLocation,
      String jQueryUrl}) async {
    await driver.executeAsync(_loadJQueryJs, [jQueryUrl]);
    await driver.execute(
        _simulateDragDropScript(
            sourceSelector: sourceSelector,
            sourceLocation: sourceLocation,
            targetSelector: targetSelector,
            targetLocation: targetLocation),
        []);
  }
}

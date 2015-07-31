library bwu_webdriver.src.io;

import 'dart:async' show Future, Stream;
import 'package:webdriver/io.dart' as wd;

part 'action_jquery_drag_and_drop.dart';

class Action {
  final wd.WebDriver driver;

  Action(this.driver);

  /// Set the [attribute] of [element] to [value].
  Future setAttribute(wd.WebElement element, String attribute, String value) {
    return driver.execute(
        'arguments[0].setAttribute(arguments[1], arguments[2])', [
      element,
      attribute,
      value
    ]);
  }

  /// Drag the element found by [sourceElementSelector] onto the element found
  /// by [targetElementSelector].
  /// [jQueryUrl] allows to pass an URL for a specific jQuery version or
  Future dragAndDrop(String sourceElementSelector, String targetElementSelector,
      {jQueryUrl: _jQueryUrl}) async {
    await driver.execute(_loadJQueryJs, [jQueryUrl]);
    String javaScriptString =
        "${_dragAndDropHelper}\$('${sourceElementSelector}').simulateDragDrop({ dropTarget: '${targetElementSelector}'});";
    print(javaScriptString);
    await driver.execute(javaScriptString, []);
  }
}

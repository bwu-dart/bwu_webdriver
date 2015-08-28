library bwu_webdriver.src.io;

import 'dart:math' show Point, Rectangle;
import 'dart:async' show Future, Stream, StreamController;
import 'package:webdriver/io.dart' as core;
import 'package:webdriver/src/stepper.dart';

part 'action_jquery_drag_and_drop.dart';
part 'action_drag_and_drop.dart';

class WebBrowser {
  static const android = const WebBrowser(core.Browser.android);
  static const chrome = const WebBrowser(core.Browser.chrome);
  static const edge = const WebBrowser('MicrosoftEdge');
  static const firefox = const WebBrowser(core.Browser.firefox);
  static const ie = const WebBrowser(core.Browser.ie);
  static const ipad = const WebBrowser(core.Browser.ipad);
  static const iphone = const WebBrowser(core.Browser.iphone);
  static const opera = const WebBrowser(core.Browser.opera);
  static const safari = const WebBrowser(core.Browser.safari);

  static const values = const [chrome, firefox];

  final String value;
  const WebBrowser(this.value);
}

// TODO(zoechi) doesn't work because '/actions' is nowhere supported
class DragAndDrop {
//  final core.WebDriver driver;
//  DragAndDrop(this.driver);
  final core.WebElement sourceElement;
  final int sourceXOffset;
  final int sourceYOffset;

  final core.WebElement targetElement;
  final int targetXOffset;
  final int targetYOffset;

  DragAndDrop(this.sourceElement,
      {this.sourceXOffset,
      this.sourceYOffset,
      this.targetElement,
      this.targetXOffset,
      this.targetYOffset});

  List toJson() {
    final actions = [];
    final source = {'name': 'pointerDown', 'ELEMENT': sourceElement.id};
    if (sourceXOffset != null) {
      source['x'] = sourceXOffset;
    }
    if (sourceYOffset != null) {
      source['y'] = sourceYOffset;
    }
    actions.add(source);
    actions.add({'name': 'pause', 'duration': 'CHAINED_EVENT'});

    final target = {'name': 'pointerMove'};
    if (targetElement != null) {
      target['ELEMENT'] = sourceElement.id;
    } else {
      target['ELEMENT'] = targetElement.id;
    }
    if (targetXOffset != null) {
      target['x'] = targetXOffset;
    }
    if (targetYOffset != null) {
      target['y'] = targetYOffset;
    }
    actions.add(target);
    actions.add({'name': 'pause', 'duration': 'CHAINED_EVENT'});

    actions.add({'name': 'pointerUp'});

    return [
      {'source': 'mouse', 'id': '1', 'actions': actions}
    ];
  }
}

class ExtendedWebDriver implements core.WebDriver {
  final core.WebDriver _webDriver;

  ExtendedWebDriver.fromDriver(this._webDriver);

  /// Create a new instance of [ExtendedWebDriver].
  static Future<ExtendedWebDriver> createNew(
      {Uri uri, Map<String, dynamic> desired}) async {
    return new ExtendedWebDriver.fromDriver(
        await core.createDriver(uri: uri, desired: desired));
  }

  /// Set the [attribute] of [element] to [value].
  /// See also http://stackoverflow.com/questions/8473024
  Future setAttribute(core.WebElement element, String attribute, String value) {
    return _webDriver.execute(
        'arguments[0].setAttribute(arguments[1], arguments[2])',
        [element, attribute, value]);
  }

  Future dragAndDrop2(DragAndDrop dnd) {
    return postRequest('actions', dnd);
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
    await _webDriver.executeAsync(_loadJQueryJs, [jQueryUrl]);
    await _webDriver.execute(
        _simulateDragDropScript(
            sourceSelector: sourceSelector,
            sourceLocation: sourceLocation,
            targetSelector: targetSelector,
            targetLocation: targetLocation),
        []);
  }

  @Deprecated('use WebElement.size instead')
  Future<Rectangle> getBoundingClientRect(core.WebElement element) async {
    Map<String, int> result = await _webDriver.execute(
        'return arguments[0].getBoundingClientRect()', [element]);
    return new Rectangle<int>(
        result['left'], result['top'], result['width'], result['height']);
  }

  // TODO(zoechi) move to WebElement
  Future scrollElementRelative(core.WebElement element, {int x, int y}) async {
    final scrollTop = 'arguments[0].scrollTop += ${y};\n';
    final scrollLeft = 'arguments[0].scrollLeft += ${x}\n;';

    String script = '';
    if (x != null) {
      script += scrollLeft;
    }

    if (y != null) {
      script += scrollTop;
    }

    return _webDriver.execute(script, [element]);
  }

  // TODO(zoechi) move to WebElement
  Future scrollElementAbsolute(core.WebElement element, {int x, int y}) {
    final scrollTop = 'arguments[0].scrollTop = ${y};\n';
    final scrollLeft = 'arguments[0].scrollLeft = ${x}\n;';

    String script = '';
    if (x != null) {
      script += scrollLeft;
    }

    if (y != null) {
      script += scrollTop;
    }

    return _webDriver.execute(script, [element]);
  }

  @override
  Map<String, dynamic> get capabilities => _webDriver.capabilities;

  /// Close the current window, quitting the browser if it is the last window.
  @override
  Future close() => _webDriver.close();

  /// Search for multiple elements within the entire current page.
  @override
  Stream<WebElement> findElements(core.By by) {
//    final streamController = new StreamController<WebElement>();
    return _webDriver
        .findElements(by)
        .map((e) => new WebElement._(e)); //.pipe(streamController);
//    return streamController.stream;

//    StreamController<core.WebElement> streamController =
//        new StreamController<core.WebElement>();
////    print(_webDriver.capabilities); // TODO(zoechi) make browser dependent
//    _webDriver.findElements(by).listen(streamController.add).onError((error) {
////          print('Error: $error');
//      if (error is core.InvalidSelectorException &&
//          by.toJson()['using'] == 'css selector') {
//        // TODO(zoechi) use search context (for element.querySelector())
//        final script = 'document.querySelectorAll("${by.toJson()['value']}")';
////        print(script);
//        execute(script, []).then((result) {
//          print(result);
//          streamController.close();
//        });
//      } else {
//        streamController.addError(error);
//        streamController.close();
//      }
//    });
//    return streamController.stream;
  }

  /// Search for an element within the entire current page.
  /// Throws [NoSuchElementException] if a matching element is not found.
  @override
  Future<core.WebElement> findElement(core.By by) async {
    try {
      return new WebElement._(await _webDriver.findElement(by));
    } catch (error) {
      if (error is core.InvalidSelectorException &&
          by.toJson()['using'] == 'css selector') {
        // TODO(zoechi) use search context (for element.querySelector())
        return execute('document.querySelector("${by.toJson()['value']}")', []);
      } else {
        rethrow;
      }
    }
  }

  Future<bool> elementExists(core.By by) async {
    try {
      var element = await _webDriver.findElement(by);
      return element != null;
    } on core.NoSuchElementException catch (_) {
      return false;
    }
  }

  Timeouts _timeouts;
  @override
  Timeouts get timeouts {
    _timeouts ??= new Timeouts(this);
    return _timeouts;
  }

  @override
  String get id => _webDriver.id;

  @override
  Future deleteRequest(String command) => _webDriver.deleteRequest(command);

  @override
  Future getRequest(String command) => _webDriver.getRequest(command);

  @override
  Future postRequest(String command, [params]) =>
      _webDriver.postRequest(command, params);

  @override
  Future execute(String script, List args) => _webDriver.execute(script, args);

  @override
  Future executeAsync(String script, List args) =>
      _webDriver.executeAsync(script, args);

  @override
  Stream<int> captureScreenshot() => _webDriver.captureScreenshot();

  @override
  core.Mouse get mouse => _webDriver.mouse;

  @override
  core.Keyboard get keyboard => _webDriver.keyboard;

  @override
  core.Logs get logs => _webDriver.logs;

  @override
  core.Cookies get cookies => _webDriver.cookies;

  @override
  core.Navigation get navigate => _webDriver.navigate;

  @override
  core.TargetLocator get switchTo => _webDriver.switchTo;

  @override
  Future<core.WebElement> get activeElement => _webDriver.activeElement;

  @override
  Future<core.Window> get window => _webDriver.window;

  @override
  Stream<core.Window> get windows => _webDriver.windows;

  @override
  Future quit({bool closeSession: true}) =>
      _webDriver.quit(closeSession: closeSession);

  @override
  Future<String> get pageSource => _webDriver.pageSource;

  @override
  Future<String> get title => _webDriver.title;

  @override
  Future get(url) async {
    if (driver.capabilities['browserName'] == WebBrowser.edge.value) {
      // TODO(zoechi) edge doesn't wait until the page is loaded
      // therefore we loop until `currentUrl` returns the requested url

      bool _isFinished = false;
      new Future.delayed(
          timeouts.pageLoadTimeout ?? const Duration(seconds: 90), () {
        if (!_isFinished) {
          throw new core.TimeoutException(-1, 'Loading page failed');
        }
      });

      await _webDriver.get(url);
      while (await _webDriver.currentUrl != url) {
        await new Future.delayed(const Duration(milliseconds: 1200));
      }
      _isFinished = true;
      return null;
    }
    return _webDriver.get(url);
  }

  @override
  Future<String> get currentUrl => _webDriver.currentUrl;

  @override
  Stream<core.WebDriverCommandEvent> get onCommand => _webDriver.onCommand;

  @override
  Stepper get stepper => _webDriver.stepper;
  set stepper(Stepper stepper) => _webDriver.stepper = stepper;

  @override
  bool get filterStackTraces => _webDriver.filterStackTraces;

  @override
  Uri get uri => _webDriver.uri;

  @override
  ExtendedWebDriver get driver =>
      new ExtendedWebDriver.fromDriver(_webDriver.driver);
}

class Timeouts implements core.Timeouts {
  final ExtendedWebDriver driver;
  final core.Timeouts _timeouts;

  Duration _implicitTimeout;
  Duration get implicitTimeout => _implicitTimeout;
  Duration _pageLoadTimeout;
  Duration get pageLoadTimeout => _pageLoadTimeout;
  Duration _scriptTimeout;
  Duration get scriptTimeout => _scriptTimeout;

  Timeouts(ExtendedWebDriver driver)
      : this.driver = driver,
        _timeouts = driver._webDriver.timeouts;

  @override
  Future setImplicitTimeout(Duration duration) async {
    await _timeouts.setImplicitTimeout(duration);
    _implicitTimeout = duration;
  }

  @override
  Future setPageLoadTimeout(Duration duration) async {
    await _timeouts.setPageLoadTimeout(duration);
    _pageLoadTimeout = duration;
  }

  @override
  Future setScriptTimeout(Duration duration) async {
    await _timeouts.setScriptTimeout(duration);
    _scriptTimeout = duration;
  }
}

class _ByUsing {
  static const id = const _ByUsing._('id');
  static const xPath = const _ByUsing._('xpath');
  static const linkText = const _ByUsing._('linkText', 'link text');
  static const partialLinkText =
      const _ByUsing._('partialLinkText', 'partial link text');
  static const name = const _ByUsing._('name', 'name');
  static const tagName = const _ByUsing._('tagName', 'tag name');
  static const className = const _ByUsing._('className', 'class name');
  static const cssSelector = const _ByUsing._('cssSelector', 'css selector');
  static const browserCssSelector =
      const _ByUsing._('browserCssSelector', 'browser specific css selector');

  final String value;
  final String text;

  const _ByUsing._(String value, [String text])
      : this.value = value,
        this.text = text != null ? text : value;
}

class By implements core.By {
  final _ByUsing _using;
  final String _value;
  final Map<WebBrowser, String> _browserValue;
  final core.WebDriver _driver;

  const By._(this._using, this._value)
      : _driver = null,
        _browserValue = null;

  /// Returns an element whose ID attribute matches the search value.
  const By.id(String id) : this._(_ByUsing.id, id);

  /// Returns an element matching an XPath expression.
  const By.xpath(String xpath) : this._(_ByUsing.xPath, xpath);

  /// Returns an anchor element whose visible text matches the search value.
  const By.linkText(String linkText) : this._(_ByUsing.linkText, linkText);

  /// Returns an anchor element whose visible text partially matches the search
  /// value.
  const By.partialLinkText(String partialLinkText)
      : this._(_ByUsing.partialLinkText, partialLinkText);

  /// Returns an element whose NAME attribute matches the search value.
  const By.name(String name) : this._(_ByUsing.name, name);

  /// Returns an element whose tag name matches the search value.
  const By.tagName(String tagName) : this._(_ByUsing.tagName, tagName);

  /**
   * Returns an element whose class name contains the search value; compound
   * class names are not permitted
   */
  const By.className(String className) : this._(_ByUsing.className, className);

  /// Returns an element matching a CSS selector.
  const By.cssSelector(String cssSelector)
      : this._(_ByUsing.cssSelector, cssSelector);

  const By._browser(this._using, this._driver, this._value, this._browserValue);

  /// Returns an element matching a CSS selector.
  const By.browserCssSelector(core.WebDriver driver, String cssSelector,
      Map<WebBrowser, String> browserCssSelector)
      : this._browser(_ByUsing.browserCssSelector, driver, cssSelector,
            browserCssSelector);

  @override
  Map<String, String> toJson() => {'using': _using.text, 'value': __value};

  String get __value => _browserValue != null
      ? _browserValue[_driver.capabilities['browserName']] ?? _value
      : _value;

  @override
  String toString() => 'By.${_using.value}(${__value})';

  @override
  int get hashCode => (_using.hashCode * 3 + _value.hashCode) * 7 +
      (__value == null ? 0 : __value.hashCode);

  @override
  bool operator ==(other) =>
      other is core.By && other.toString() == this.toString();
}

class WebElement implements core.WebElement {
  core.WebElement _element;

  WebElement._(this._element);

  @override
  core.Attributes get attributes => _element.attributes;

  @override
  Future clear() => _element.clear();

  @override
  Future click() => _element.click();

  @override
  core.SearchContext get context => _element.context;

  @override
  core.Attributes get cssProperties => _element.cssProperties;

  @override
  Future<bool> get displayed => _element.displayed;

  @override
  core.WebDriver get driver => _element.driver;

  @override
  Future<bool> get enabled => _element.enabled;

  @override
  Future<bool> equals(core.WebElement other) => _element.equals(other);

  @override
  Future<WebElement> findElement(core.By by) async =>
      new WebElement._(await _element.findElement(by));

  @override
  Stream<WebElement> findElements(core.By by) =>
      _element.findElements(by).map((e) => new WebElement._(e));

  Future<bool> elementExists(core.By by) async {
    try {
      var element = await _element.findElement(by);
      return element != null;
    } on core.NoSuchElementException catch (_) {
      return false;
    }
  }

  @override
  String get id => _element.id;

  @override
  int get index => _element.index;

  @override
  Future<Point> get location => _element.location;

  @override
  get locator => _element.locator;

  @override
  Future<String> get name => _element.name;

  @override
  Future<bool> get selected => _element.selected;

  @override
  Future sendKeys(String keysToSend) => _element.sendKeys(keysToSend);

  @override
  Future<Rectangle<int>> get size => _element.size;

  @override
  Future submit() => _element.submit();

  @override
  Future<String> get text => _element.text;

  @override
  Map<String, String> toJson() => _element.toJson();
}

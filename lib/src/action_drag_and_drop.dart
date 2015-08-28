// See also https://www.testautomatisierung.org/drag-drop-fuer-html-5-elemente-mit-selenium/

part of bwu_webdriver.src.io;

class Html5DragDropHelper {
  static const _javaScriptEventSimulator = '''
/* Creates a drag event */
function createDragEvent(eventName, options) {
  var event = document.createEvent('HTMLEvents');
  event.initEvent('DragEvent', true, true);
  // var event = document.createEvent("DragEvent");
  var screenX = window.screenX + options.clientX;
  var screenY = window.screenY + options.clientY;
  var clientX = options.clientX;
  var clientY = options.clientY;
  var dataTransfer = {
    data: options.dragData == null ? {} : options.dragData,
    setData: function(eventName, val) {
      if (typeof val === 'string') {
        this.data[eventName] = val;
      }
    },
    getData: function(eventName) {
      return this.data[eventName];
    },
    clearData: function() {
      return this.data = {};
    },
    setDragImage: function(dragElement, x, y) {}
  };
  var eventInitialized=false;
  if (event != null && event.initDragEvent) {
    try {
      event.initDragEvent(eventName, true, true, window, 0, screenX, screenY,
          clientX, clientY, false, false, false, false, 0, null, dataTransfer);
      event.initialized=true;
    } catch(err) {
      // no-op
    }
  }
  if (!eventInitialized) {
    event = document.createEvent("CustomEvent");
    event.initCustomEvent(eventName, true, true, null);
    event.view = window;
    event.detail = 0;
    event.screenX = screenX;
    event.screenY = screenY;
    event.clientX = clientX;
    event.clientY = clientY;
    event.ctrlKey = false;
    event.altKey = false;
    event.shiftKey = false;
    event.metaKey = false;
    event.button = 0;
    event.relatedTarget = null;
    event.dataTransfer = dataTransfer;
  }
  return event;
}

/* Creates a mouse event */
function createMouseEvent(eventName, options) {
  var event = document.createEvent("MouseEvent");
  var screenX = window.screenX + options.clientX;
  var screenY = window.screenY + options.clientY;
  var clientX = options.clientX;
  var clientY = options.clientY;
  if (event != null && event.initMouseEvent) {
    event.initMouseEvent(eventName, true, true, window, 0, screenX, screenY,
        clientX, clientY, false, false, false, false, 0, null);
  } else {
    event = document.createEvent("CustomEvent");
    event.initCustomEvent(eventName, true, true, null);
    event.view = window;
    event.detail = 0;
    event.screenX = screenX;
    event.screenY = screenY;
    event.clientX = clientX;
    event.clientY = clientY;
    event.ctrlKey = false;
    event.altKey = false;
    event.shiftKey = false;
    event.metaKey = false;
    event.button = 0;
    event.relatedTarget = null;
  }
  return event;
}

/* Runs the events */
function dispatchEvent(webElement, eventName, event) {
  if (webElement.dispatchEvent) {
    webElement.dispatchEvent(event);
  } else if (webElement.fireEvent) {
    webElement.fireEvent("on" + eventName, event);
  }
}

/* Simulates an individual event */
function simulateEventCall(element, eventName, dragStartEvent, options) {
  var event = null;
  if (eventName.indexOf("mouse") > -1) {
    event = createMouseEvent(eventName, options);
  } else {
    event = createDragEvent(eventName, options);
  }
  if (dragStartEvent != null) {
    event.dataTransfer = dragStartEvent.dataTransfer;
  }
  dispatchEvent(element, eventName, event);
  return event;
}
''';

  /// Simulates an individual events.
  static String _simulateEvent = '''${_javaScriptEventSimulator}
function simulateEvent(element, eventName, clientX, clientY, dragData) {
  return simulateEventCall(element, eventName, null, {clientX: clientX,
      clientY: clientY, dragData: dragData});
}

var event = simulateEvent(arguments[0], arguments[1], arguments[2],
    arguments[3], arguments[4]);
if (event.dataTransfer != null) {
  return event.dataTransfer.data;
}
''';

  /// Simulates drag and drop.
  static String _simulateDragAndDrop = '''${_javaScriptEventSimulator}
function simulateHTML5DragAndDrop(dragFrom, dragTo, dragFromX, dragFromY,
    dragToX, dragToY) {
 var mouseDownEvent = simulateEventCall(dragFrom, "mousedown", null,
     {clientX: dragFromX, clientY: dragFromY});
 var dragStartEvent = simulateEventCall(dragFrom, "dragstart", null,
     {clientX: dragFromX, clientY: dragFromY});
 var dragEnterEvent = simulateEventCall(dragTo,   "dragenter", dragStartEvent,
     {clientX: dragToX, clientY: dragToY});
 var dragOverEvent  = simulateEventCall(dragTo,   "dragover",  dragStartEvent,
     {clientX: dragToX, clientY: dragToY});
 var dropEvent      = simulateEventCall(dragTo,   "drop",      dragStartEvent,
     {clientX: dragToX, clientY: dragToY});
 var dragEndEvent   = simulateEventCall(dragFrom, "dragend",   dragStartEvent,
     {clientX: dragToX, clientY: dragToY});
}
simulateHTML5DragAndDrop(arguments[0], arguments[1], arguments[2], arguments[3],
    arguments[4], arguments[5]);
''';

  /// Calls a drag event.
  /// [driver] The WebDriver to execute on
  /// [dragFrom] The WebElement to simulate on
  /// [eventName] The event name to call
  /// [clientX] The mouse click X position on the screen
  /// [clientY] The mouse click Y position on the screen
  /// [data] The data transfer data
  /// Returns the updated data transfer data.
  static Object simulateEventXY(core.WebDriver driver, core.WebElement dragFrom,
      String eventName, int clientX, int clientY, Object data) {
    return driver.execute(
        _simulateEvent, [dragFrom, eventName, clientX, clientY, data]);
  }

  /// Calls a drag event.
  /// [driver] The WebDriver to execute on
  /// [dragFrom] The WebElement to simulate on
  /// [eventName] The event name to call
  /// [mousePosition] The mouse click area in the element
  /// [data] The data transfer data
  /// Returns the updated data transfer data
  static Object simulateEventPosition(
      core.WebDriver driver,
      core.WebElement dragFrom,
      String eventName,
      Position mousePosition,
      Object data) async {
    Point fromLocation = await dragFrom.location;
    Rectangle<int> fromSize = await dragFrom.size;

    // Get Client X and Client Y locations
    int clientX = fromLocation.x +
        (fromSize == null ? 0 : getX(mousePosition, fromSize.width));
    int clientY = fromLocation.y +
        (fromSize == null ? 0 : getY(mousePosition, fromSize.height));

    return simulateEventXY(driver, dragFrom, eventName, clientX, clientY, data);
  }

  /// Drags and drops a web element from source to target
  /// [driver] The WebDriver to execute on
  /// [dragFrom] The WebElement to drag from
  /// [dragTo] The WebElement to drag to
  /// [dragFromX] The position to click relative to the top-left-corner of the
  ///    client
  /// [dragFromY] The position to click relative to the top-left-corner of the
  ///    client
  /// [dragToX] The position to release relative to the top-left-corner of the
  ///    client
  /// [dragToY] The position to release relative to the top-left-corner of the
  ///    client
  static void dragAndDropXY(
      core.WebDriver driver,
      core.WebElement dragFrom,
      core.WebElement dragTo,
      int dragFromX,
      int dragFromY,
      int dragToX,
      int dragToY) {
    print(_simulateDragAndDrop);
    print('args: dragFrom: ${dragFrom}, dragTo: ${dragTo}, dragFromX: ${dragFromX}, dragFromY: ${dragFromY}, dragToX: ${dragToX}, dragToY: ${dragToY}');
    driver.execute(_simulateDragAndDrop,
        [dragFrom, dragTo, dragFromX, dragFromY, dragToX, dragToY]);
  }

  /// Drags and drops a web element from source to target.
  /// [driver] The WebDriver to execute on
  /// [dragFrom] The WebElement to drag from
  /// [dragTo] The WebElement to drag to
  /// [dragFromPosition] The place to click on the dragFrom
  /// [dragToPosition] The place to release on the dragTo
  static Future<Null> dragAndDropPosition(
      core.WebDriver driver,
      core.WebElement dragFrom,
      core.WebElement dragTo,
      Position dragFromPosition,
      Position dragToPosition) async {
    Point fromLocation = await dragFrom.location;
    Point toLocation = await dragTo.location;
    Rectangle<int> fromSize = await dragFrom.size;
    Rectangle<int> toSize = await dragTo.size;

    // Get Client X and Client Y locations
    int dragFromX = fromLocation.x +
        (fromSize == null ? 0 : getX(dragFromPosition, fromSize.width));
    int dragFromY = fromLocation.y +
        (fromSize == null ? 0 : getY(dragFromPosition, fromSize.height));
    int dragToX = toLocation.x +
        (toSize == null ? 0 : getX(dragToPosition, toSize.width));
    int dragToY = toLocation.y +
        (toSize == null ? 0 : getY(dragToPosition, toSize.height));

    dragAndDropXY(
        driver, dragFrom, dragTo, dragFromX, dragFromY, dragToX, dragToY);
  }

  /// Cross-Window Drag And Drop Example
  static Future<Null> dragToWindow(core.WebDriver dragFromDriver,
      core.WebElement dragFromElement, core.WebDriver dragToDriver) async {
    // Drag start
    simulateEventPosition(
        dragFromDriver, dragFromElement, "mousedown", Position.center, null);
    Object dragData = simulateEventPosition(
        dragFromDriver, dragFromElement, "dragstart", Position.center, null);
    dragData = simulateEventPosition(dragFromDriver, dragFromElement,
        "dragenter", Position.center, dragData);
    dragData = simulateEventPosition(
        dragFromDriver, dragFromElement, "dragleave", Position.left, dragData);
    dragData = simulateEventPosition(
        dragFromDriver,
        await dragFromDriver.findElement(new core.By.tagName("body")),
        "dragleave",
        Position.left,
        dragData);

    // Drag to other window
    simulateEventPosition(
        dragToDriver,
        await dragToDriver.findElement(new core.By.tagName("body")),
        "dragenter",
        Position.right,
        null);
    core.WebElement dropOverlay =
        await dragToDriver.findElement(new core.By.className("DropOverlay"));
    simulateEventPosition(
        dragToDriver, dropOverlay, "dragenter", Position.right, null);
    simulateEventPosition(
        dragToDriver, dropOverlay, "dragover", Position.center, null);
    dragData = simulateEventPosition(
        dragToDriver, dropOverlay, "drop", Position.center, dragData);
    simulateEventPosition(
        dragFromDriver, dragFromElement, "dragend", Position.center, dragData);
  }

  static int getX(Position pos, int width) {
    if (pos == Position.topLeft ||
        pos == Position.left ||
        pos == Position.bottomLeft) {
      return 1;
    } else if (pos == Position.top ||
        pos == Position.center ||
        pos == Position.bottom) {
      return width ~/ 2;
    } else if (pos == Position.topRight ||
        pos == Position.right ||
        pos == Position.bottomRight) {
      return width - 1;
    } else {
      return 0;
    }
  }

  static int getY(Position pos, int height) {
    if (pos == Position.topLeft ||
        pos == Position.top ||
        pos == Position.topRight) {
      return 1;
    } else if (pos == Position.left ||
        pos == Position.center ||
        pos == Position.right) {
      return height ~/ 2;
    } else if (pos == Position.bottomLeft ||
        pos == Position.bottom ||
        pos == Position.bottomRight) {
      return height - 1;
    } else {
      return 0;
    }
  }
}

enum Position {
  topLeft,
  top,
  topRight,
  left,
  center,
  right,
  bottomLeft,
  bottom,
  bottomRight
}

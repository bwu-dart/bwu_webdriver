// Source from https://gist.github.com/rcorreia/2362544
// See also http://stackoverflow.com/questions/31279145

part of bwu_webdriver.src.io;

const _loadJQueryJs = r'''
(function(jqueryUrl, callback) {
  if (typeof jqueryUrl != 'string') {
    jqueryUrl = 'https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js';
  }
  if (typeof jQuery == 'undefined') {
    var script = document.createElement('script');
    var head = document.getElementsByTagName('head')[0];
    var done = false;
    script.onload = script.onreadystatechange = (function() {
      if (!done && (!this.readyState || this.readyState == 'loaded'
          || this.readyState == 'complete')) {
        done = true;
        script.onload = script.onreadystatechange = null;
        head.removeChild(script);
        callback();
      }
    });
    script.src = jqueryUrl;
    head.appendChild(script);
  }
  else {
    callback();
  }
})(arguments[0], arguments[arguments.length - 1]);
''';

String _simulateDragDropScript(
    {String sourceSelector,
    Point sourceLocation,
    String targetSelector,
    Point targetLocation}) {
  if (sourceSelector == null && sourceLocation == null) {
    throw new ArgumentError(
        'Either sourceSelector or sourceLocation must be not null.');
  }
  if (sourceSelector != null && sourceLocation != null) {
    throw new ArgumentError(
        'Only sourceSecector or sourceLocation can be non-null.');
  }
  if (targetSelector == null && targetLocation == null) {
    throw new ArgumentError(
        'Either targetSelector or targetLocation must be not null.');
  }
//  if (targetSelector != null && targetLocation != null) {
//    throw new ArgumentError(
//        'Only targetSecector or targetLocation can be non-null.');
//  }
  final String sourceElement = sourceSelector != null
      ? '"${sourceSelector}"'
  // see http://stackoverflow.com/questions/1259585
      : 'document.elementFromPoint(${sourceLocation.x}, ${sourceLocation.y})';
  final String targetElement = targetSelector != null
      ? '"${targetSelector}"'
      : 'document.elementFromPoint(${targetLocation.x}, ${targetLocation.y})';
  if(targetLocation == null) {
  return '''
  ${_dragAndDropHelper}\$(${sourceElement})
   .simulateDragDrop({dropTarget: \$(${targetElement})});''';
  } else {
    return '''
    ${_dragAndDropHelper}\$(${sourceElement})
     .simulateDragDrop({dropTarget: \$(${targetElement}), dropLocation: {x: ${targetLocation.x}, y: ${targetLocation.y}}});''';
  }
}

const _dragAndDropHelper = r'''
(function( $ ) {
  $.fn.simulateDragDrop = function(options) {
    return this.each(function() {
        new $.simulateDragDrop(this, options);
    });
  };
  $.simulateDragDrop = function(elem, options) {
    this.options = options;
    this.simulateEvent(elem, options);
  };
  $.extend($.simulateDragDrop.prototype, {
    simulateEvent: function(elem, options) {
      /* Simulating drag start */
      var type = 'dragstart';
      var event = this.createEvent(type,
          {pageX: options.dropLocation.x - 30, pageY: options.dropLocation.y});
      this.dispatchEvent(elem, type, event);

      /* Simulating drag */
      if(options.dropLocation) {
        //alert(options.dropLocation.x + '-' + options.dropLocation.y);
        var type = 'drag';
        var event = this.createEvent(type,
            {pageX: options.dropLocation.x, pageY: options.dropLocation.y});
        this.dispatchEvent(elem, type, event);
      }

      /* Simulating drop */
      type = 'drop';
      var dropEvent = this.createEvent(type);
      dropEvent.dataTransfer = event.dataTransfer;
      this.dispatchEvent(options.dropTarget[0], type, dropEvent);

      /* Simulating drag end */
      type = 'dragend';
      console.log('dropTarget: ' + options.dropTarget);
      var dragEndEvent = this.createEvent(type, {target: options.dropTarget[0]});
      dragEndEvent.dataTransfer = event.dataTransfer;
      this.dispatchEvent(elem, type, dragEndEvent);
    },
    createEvent: function(type, options) {
      var event = new DragEvent(
      //var event = document.createEvent("CustomEvent");
      event.initCustomEvent(type, true, true, null);
      if(options && options.pageX) {
        event.pageX = options.pageX;
        event.pageY = options.pageY;
        console.log('createEvent: event.pageX ' + event.pageX);
      }
      event.dataTransfer = {
        data: {},
        setData: function(type, val) {
          this.data[type] = val;
        },
        getData: function(type) {
          return this.data[type];
        }
      };
      return event;
    },
    dispatchEvent: function(elem, type, event) {
      if(elem.dispatchEvent) {
        elem.dispatchEvent(event);
      } else if( elem.fireEvent ) {
        elem.fireEvent("on"+type, event);
      }
    }
  });
})(jQuery);
''';

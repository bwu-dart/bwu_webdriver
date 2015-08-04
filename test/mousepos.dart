import 'dart:html' as dom;

bool isButtonDown = false;

main() {
  final log = dom.document.querySelector('#log');
  dom.window.onMouseMove.listen((m) {
    if(isButtonDown) {
      print('x');
    }
    log.children.insert(
        0, new dom.DivElement()..text = 'x: ${m.client.x}, y: ${m.client.x}, btn: ${m.which}');
  });
  dom.window.onMouseDown.listen((m) {
    isButtonDown = true;
    log.children.insert(0, new dom.DivElement()
      ..text = 'down - x: ${m.client.x}, y: ${m.client.x}, btn: ${m.which}');
  });
  dom.window.onMouseUp.listen((m) {
    isButtonDown = false;
    log.children.insert(0, new dom.DivElement()
      ..text = 'up - x: ${m.client.x}, y: ${m.client.x}, btn: ${m.which}');
  });
  dom.window.onClick.listen((m) {
    log.children.insert(0, new dom.DivElement()
      ..text = 'click - x: ${m.client.x}, y: ${m.client.x}, btn: ${m.which}');
  });
}

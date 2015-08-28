import 'dart:async' show Future, Timer;
import 'dart:html' as dom;
import 'dart:math' as math;

main() {
  List<String> eat = ['yum!', 'gulp', 'burp!', 'nom'];
  dom.ParagraphElement yum = dom.document.createElement('p');
  int msie = /*@cc_on!@*/ 0;
  yum.style.opacity = '1';

  dom.ElementList<dom.AnchorElement> links =
      dom.document.querySelectorAll('li > a');
//  dom.AnchorElement el = null;
  for (int i = 0; i < links.length; i++) {
    dom.AnchorElement el = links[i];

    el.setAttribute('draggable', 'true');

    el.onDragStart.listen((dom.MouseEvent e) {
      print('dragStart: ${e.runtimeType}');
//      print('dragStart: target: ${(e.target as dom.Element).id}');
//      print('dragStart: x: ${e.page.x}');
//      print('dragStart: x: ${e.client.x}');
      e.dataTransfer.effectAllowed =
          'copy'; // only dropEffect='copy' will be dropable
      e.dataTransfer.setData('Text', el.id); // required otherwise doesn't work
    });

    el.onDrag.listen((dom.MouseEvent e) {
      print('drag: ${e.runtimeType}');
//      print('drag: x: ${e.page}');
//      print('drag: x: ${e.page.x}');
    });

    el.onDragEnd.listen((dom.MouseEvent e) {
      print('dragEnd: ${e.runtimeType}');
//      print('dragEnd: target: ${(e.target as dom.Element).id}');
    });
  }

  dom.DivElement bin = dom.document.querySelector('#bin');

  bin.onDragOver.listen((e) {
    e.preventDefault(); // allows us to drop
    bin.className = 'over';
    e.dataTransfer.dropEffect = 'copy';
    return false;
  });

  // to get IE to work
  bin.onDragEnter.listen((e) {
    bin.className = 'over';
    return false;
  });

  bin.onDragLeave.listen((e) {
    bin.className = '';
  });

  bin.onDrop.listen((e) {
    e.stopPropagation(); // stops the browser from redirecting...why???

    dom.AnchorElement el = dom.document.getElementById(e.dataTransfer.getData('Text'));

    el.remove();

    // stupid nom text + fade effect
    bin.className = '';
    yum.innerHtml = eat[(new math.Random().nextDouble() * eat.length).floor()];

    dom.ParagraphElement y = yum.clone(true);
    bin.append(y);

    new Future.delayed(const Duration(milliseconds: 250), () {
      new Timer.periodic(const Duration(milliseconds: 50), (Timer t) {
        if (double.parse(y.style.opacity) <= 0) {
          if (msie != 0) {
            // don't bother with the animation
            y.style.display = 'none';
          }
          t.cancel();
        } else {
          y.style.opacity = '${double.parse(y.style.opacity) - 0.1}';
        }
      });
    });

    return false;
  });
}

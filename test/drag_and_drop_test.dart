library bwu_webdriver.test.drag_and_drop_test;

import 'dart:math';
import 'dart:async' show Future, Stream;
import 'package:test/test.dart';
import 'package:webdriver/io.dart';
import 'package:bwu_webdriver/src/action.dart';
//import 'dart:convert' show UTF8, JSON;
//import 'package:crypto/crypto.dart' show CryptoUtils;

main() {
  group('webdriver', () {
    Action action;
    setUp(() async {
      // for capabilities see https://code.google.com/p/selenium/wiki/DesiredCapabilities
      action = new Action(await createDriver(
          uri: Uri.parse('http://localhost:4444/wd/hub/'),
          desired: {'browserName': 'chrome'}));
      await action.driver.timeouts
          .setScriptTimeout(const Duration(milliseconds: 1500));
    });

    tearDown(() {
      return action.driver.close();
    });

//    test('drag_and_drop with simple mouse down, move, up', () async {
//      await action.driver.get('http://webserver:8080/drag_and_drop.html');
//      WebElement p =
//          await action.driver.findElement(const By.cssSelector('#one'));
//      await action.driver.mouse.moveTo(element: p);
//      await action.driver.mouse.down(Mouse.left);
//      await new Future.delayed(const Duration(seconds: 2), () {});
//      await action.driver.mouse.moveTo(xOffset: 60, yOffset: 60);
//      await new Future.delayed(const Duration(seconds: 2), () {});
//      await action.driver.mouse.up(Mouse.left);
//      await new Future.delayed(const Duration(seconds: 10), () {});
//    }, skip: 'Doesn\'t work at least not in Chrome');

    test('drag_and_drop simulated with jQuery using CSS selectors', () async {
      await action.driver.get('http://webserver:8080/drag_and_drop.html');
      WebElement one = await action.driver.findElement(new By.id('one'));
      expect(one, isNotNull);
      await action.dragAndDrop(sourceSelector: '#one', targetSelector: '#bin');
      expect(action.driver.findElement(new By.id('one')),
          throwsA(new isInstanceOf<NoSuchElementException>()));
      WebElement two = await action.driver.findElement(new By.id('two'));
      expect(two, isNotNull);
      await action.dragAndDrop(sourceSelector: '#two', targetSelector: '#bin');
      expect(action.driver.findElement(new By.id('two')),
          throwsA(new isInstanceOf<NoSuchElementException>()));
      WebElement three = await action.driver.findElement(new By.id('three'));
      expect(three, isNotNull);
      await new Future.delayed(const Duration(seconds: 10), () {});
    }, timeout: const Timeout(const Duration(seconds: 180)));

    test('drag_and_drop simulated with jQuery using location', () async {
      await action.driver.get('http://webserver:8080/drag_and_drop.html');
      WebElement one = await action.driver.findElement(new By.id('one'));
      expect(one, isNotNull);
      await action.dragAndDrop(
          sourceLocation: new Point(280, 120),
          targetLocation: new Point(30, 120));
      expect(action.driver.findElement(new By.id('one')),
          throwsA(new isInstanceOf<NoSuchElementException>()));
      WebElement two = await action.driver.findElement(new By.id('two'));
      expect(two, isNotNull);
      await action.dragAndDrop(
          sourceLocation: new Point(280, 120),
          targetLocation: new Point(30, 120));
      expect(action.driver.findElement(new By.id('two')),
          throwsA(new isInstanceOf<NoSuchElementException>()));
      WebElement three = await action.driver.findElement(new By.id('three'));
      expect(three, isNotNull);
      await new Future.delayed(const Duration(seconds: 10), () {});
    }, timeout: const Timeout(const Duration(seconds: 180)));
  });
}

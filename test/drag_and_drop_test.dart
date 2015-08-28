library bwu_webdriver.test.drag_and_drop_test;

import 'dart:math';
import 'dart:async' show Future, Stream;
import 'package:test/test.dart';
import 'package:webdriver/io.dart';
import 'package:bwu_webdriver/bwu_webdriver.dart';
//import 'dart:convert' show UTF8, JSON;
//import 'package:crypto/crypto.dart' show CryptoUtils;

main() {
  group('webdriver', () {
    ExtendedWebDriver driver;
    setUp(() async {
      // for capabilities see https://code.google.com/p/selenium/wiki/DesiredCapabilities
      driver = await ExtendedWebDriver.createNew(
          uri: Uri.parse('http://localhost:4444/wd/hub/'),
          desired: {'browserName': 'chrome'});
      await driver.timeouts
        ..setScriptTimeout(const Duration(milliseconds: 1500))
        ..setImplicitTimeout(const Duration(seconds: 1000));
    });

    tearDown(() {
      return driver.close();
    });

    test('drag_and_drop with simple mouse down, move, up', () async {
      await driver.get('http://webserver:8080/drag_and_drop.html');
      WebElement p = await driver.findElement(const By.cssSelector('#one'));
      await driver.mouse.moveTo(element: p);
      await driver.mouse.down(Mouse.left);
      await new Future.delayed(const Duration(seconds: 2), () {});
      await driver.mouse.moveTo(xOffset: 60, yOffset: 60);
      await new Future.delayed(const Duration(seconds: 2), () {});
      await driver.mouse.up(Mouse.left);
      await new Future.delayed(const Duration(seconds: 10), () {});
    }, skip: 'Doesn\'t work at least not in Chrome');

    group('drag_and_drop', () {
      test('with actions', () async {
        await driver.get('http://webserver:8080/drag_and_drop.html');
        WebElement one = await driver.findElement(new By.id('one'));
        expect(one, isNotNull);
        WebElement bin = await driver.findElement(new By.id('bin'));
        expect(bin, isNotNull);

//        await action.dragAndDrop(
//            sourceSelector: '#one', targetSelector: '#bin');
        await driver.dragAndDrop2(new DragAndDrop(one, targetElement: bin));

//        expect(driver.findElement(new By.id('one')),
//            throwsA(new isInstanceOf<NoSuchElementException>()));
//        WebElement two = await driver.findElement(new By.id('two'));
//        expect(two, isNotNull);
//        await driver.dragAndDrop(
//            sourceSelector: '#two', targetSelector: '#bin');
//        expect(driver.findElement(new By.id('two')),
//            throwsA(new isInstanceOf<NoSuchElementException>()));
//        WebElement three = await driver.findElement(new By.id('three'));
//        expect(three, isNotNull);
        await new Future.delayed(const Duration(seconds: 100), () {});
      }, skip: '/actions is not yet supported in WebDriver');

      test('simulated with jQuery using CSS selectors', () async {
        await driver.get('http://webserver:8080/drag_and_drop.html');
        WebElement one = await driver.findElement(new By.id('one'));
        expect(one, isNotNull);
        await driver.dragAndDrop(
            sourceSelector: '#one', targetSelector: '#bin');
        expect(driver.findElement(new By.id('one')),
            throwsA(new isInstanceOf<NoSuchElementException>()));
        WebElement two = await driver.findElement(new By.id('two'));
        expect(two, isNotNull);
        await driver.dragAndDrop(
            sourceSelector: '#two', targetSelector: '#bin');
        expect(driver.findElement(new By.id('two')),
            throwsA(new isInstanceOf<NoSuchElementException>()));
        WebElement three = await driver.findElement(new By.id('three'));
        expect(three, isNotNull);
//        await new Future.delayed(const Duration(seconds: 10), () {});
      }, skip: true);

      test('simulated with jQuery using location', () async {
        await driver.get('http://webserver:8080/drag_and_drop.html');
        WebElement one = await driver.findElement(new By.id('one'));
        expect(one, isNotNull);

        WebElement bin = await driver.findElement(new By.id('bin'));
        expect(bin, isNotNull);

        Html5DragDropHelper.dragAndDropPosition(
            driver, one, bin, Position.center, Position.center);

//        await action.dragAndDrop(
//            sourceLocation: new Point(280, 120),
//            targetLocation: new Point(30, 120));

//        expect(action.driver.findElement(new By.id('one')),
//            throwsA(new isInstanceOf<NoSuchElementException>()));
//        WebElement two = await action.driver.findElement(new By.id('two'));
//        expect(two, isNotNull);
//        await action.dragAndDrop(
//            sourceLocation: new Point(280, 120),
//            targetLocation: new Point(30, 120));
//        expect(action.driver.findElement(new By.id('two')),
//            throwsA(new isInstanceOf<NoSuchElementException>()));
//        WebElement three = await action.driver.findElement(new By.id('three'));
//        expect(three, isNotNull);
        await new Future.delayed(const Duration(seconds: 100), () {});
      }, timeout: const Timeout(const Duration(seconds: 180)), skip: true);
    });

    group('getBoundingClientRect', () {
      test('simple', () async {
        await driver.get('http://webserver:8080/mousepos.html');
        WebElement area = await driver.findElement(new By.id('area'));
        expect(area, isNotNull);
        Rectangle result = await driver.getBoundingClientRect(area);
        expect(result.top, 50);
        expect(result.left, 50);
        expect(result.width, 502);
        expect(result.height, 502);
//        await new Future.delayed(const Duration(seconds: 10), () {});
      }, timeout: const Timeout(const Duration(seconds: 180)));
    }, skip: true);
  }, timeout: const Timeout(const Duration(seconds: 180)));
}

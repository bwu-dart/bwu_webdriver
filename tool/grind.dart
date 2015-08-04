library bwu_webdriver.tool.grind;

import 'dart:io' as io;
import 'package:http/http.dart' as http;
import 'package:grinder/grinder.dart';
import 'package:bwu_docker/bwu_docker.dart';
import 'package:bwu_docker/tasks.dart' as task;

import 'package:bwu_grinder_tasks/bwu_grinder_tasks.dart' as grinderTasks;
export 'package:bwu_grinder_tasks/bwu_grinder_tasks.dart' hide main;

main(List<String> args) async {
  final origTestTask = grinderTasks.testTask;
//  grinderTasks.testTask = (List<String> platforms) async {
    try {
      await startSelenium();
//      origTestTask(platforms);
    } finally {
//      await stopSelenium();
    }
//  };
  grind(args);
}

@Task('dummy')
dummy() {}

DockerConnection dockerConnection;
CreateResponse seleniumHub;
CreateResponse seleniumNodeChrome;
CreateResponse seleniumNodeFirefox;

startSelenium() async {
  final dockerHostStr = io.Platform.environment[dockerHostFromEnvironment];
  assert(dockerHostStr != null && dockerHostStr.isNotEmpty);
//  final dockerHost = Uri.parse(dockerHostStr);

  dockerConnection = new DockerConnection(
      Uri.parse(io.Platform.environment[dockerHostFromEnvironment]),
      new http.Client());
  await dockerConnection.init();
  seleniumHub = await task.run(dockerConnection, 'selenium/hub:2.46.0',
      name: 'selenium-hub',
      detach: true,
      publish: const ['4444:4444'],
      rm: true);
  seleniumNodeChrome = await task.run(
      dockerConnection, 'selenium/node-chrome-debug:2.46.0',
      detach: true,
      publishAll: true,
      rm: true,
      link: const ['selenium-hub:hub'],
      addHost: const ['webserver:192.168.2.96']);
  seleniumNodeFirefox = await task.run(
      dockerConnection, 'selenium/node-firefox-debug:2.46.0',
      detach: true,
      publishAll: true,
      rm: true,
      link: const ['selenium-hub:hub'],
      addHost: const ['webserver:192.168.2.96']);
}

stopSelenium() async {
  if (dockerConnection != null) {
    try {
      if (seleniumNodeChrome != null) await dockerConnection
          .stop(seleniumNodeChrome.container);
    } catch (_) {}
    try {
      if (seleniumNodeFirefox != null) await dockerConnection
          .stop(seleniumNodeFirefox.container);
    } catch (_) {}
    if (seleniumHub != null) await dockerConnection.stop(seleniumHub.container);
  }
}

import 'dart:io';
import 'package:builder/core/dependency.dart';
import 'package:builder/infrastructure/git_dependency.dart';

class Command {
  final String executable;
  final List<String>? args;
  final String? workingDir;
  const Command({required this.executable, this.args, this.workingDir});

  factory Command.fromMap(Map<String, dynamic> map) => Command(
    executable: map['executable'],
    args: map['args']?.cast<String>(),
    workingDir: map['working_dir'],
  );

  Future<void> run() async {
    final result = await Process.run(
      executable,
      args ?? [],
      workingDirectory: workingDir,
    );
    stdout.write(result.stdout);
    stderr.write(result.stderr);
  }

  Command copyWith({
    String? executable,
    List<String>? args,
    String? workingDir,
  }) => Command(
    executable: executable ?? this.executable,
    args: args ?? this.args,
    workingDir: workingDir ?? this.workingDir,
  );
}

class Runnable {
  final List<Command> commands;
  final Dependency dependency;

  const Runnable({
    required this.commands,
    required this.dependency,
  });

  factory Runnable.fromMap(Map<String, dynamic> map) => Runnable(
    commands: (map['commands'] as List)
      .map((command) => Command.fromMap(command))
      .toList(),
    dependency: GitDependency.fromMap(map['dependency']),
  );
  
  Future<void> run() async {
    await dependency.resolve();
    for(final command in commands) {
      await command.copyWith(
        workingDir: dependency.workingDir.path,
      ).run();
    }
  }
}
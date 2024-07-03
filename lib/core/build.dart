import 'package:builder/core/runnable.dart';

class Build {
  final Iterable<Runnable> _runnables;

  const Build({
    required Iterable<Runnable> runnables,
  }) : _runnables = runnables;

  factory Build.fromMap(Map<String,dynamic> map) => Build(
    runnables: (map['runnables'] as List).map((map) => Runnable.fromMap(map)),
  );

  Future<void> run() => Future.wait(
    _runnables.map((r) => r.run())
  );
}
import 'dart:io';
import 'package:builder/core/dependency.dart';
import 'package:path/path.dart' as path;

class GitDependency implements Dependency {
  final Directory _target;
  final Uri _repoUrl;
  final String _ref;

  const GitDependency({
    required Directory target,
    required Uri repoUrl,
    required String ref,
  }) :
    _target = target,
    _repoUrl = repoUrl,
    _ref = ref;

  factory GitDependency.fromMap(Map<String, dynamic> map) => GitDependency(
    repoUrl: Uri.parse(map['git']['repo']),
    ref: map['git']['ref'],
    target: Directory(map['target'])
  );

  @override
  Future<bool> get isResolved async {
    final repoTarget = workingDir;
    return (await repoTarget.exists()) && !(await repoTarget.list().isEmpty);
  }

  @override
  Future<void> resolve() async {
    if (!(await isResolved)) {
      final repoTarget = workingDir;
      await repoTarget.create(recursive: true);
      final result = await Process.run(
        'git',
        ['clone', '-b', _ref, '--depth', '1', '$_repoUrl', repoTarget.path],
      );
      stdout.write(result.stdout);
      stderr.write(result.stderr);
    }
  }
  
  @override
  Directory get workingDir => Directory(
    path.joinAll([_target.path, _repoUrl.pathSegments.last, _ref]),
  );
}
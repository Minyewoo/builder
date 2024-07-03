import 'dart:io';

abstract interface class Dependency {
  Directory get workingDir;
  Future<bool> get isResolved;
  Future<void> resolve();
}
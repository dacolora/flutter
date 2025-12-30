import 'package:mylifegame/core/errors.dart';

sealed class Result<T> {
  const Result();
  R when<R>({required R Function(T) ok, required R Function(AppError) err});
}

class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;

  @override
  R when<R>({required R Function(T) ok, required R Function(AppError) err}) => ok(value);
}

class Err<T> extends Result<T> {
  const Err(this.error);
  final AppError error;

  @override
  R when<R>({required R Function(T) ok, required R Function(AppError) err}) => err(error);
}
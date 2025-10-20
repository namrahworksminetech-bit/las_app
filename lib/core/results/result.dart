sealed class Result<T> {
  const Result();
  R when<R>({required R Function(T) success, required R Function(String) failure}) =>
      switch (this) { Success<T>(value: var v) => success(v), Failure<T>(message: var m) => failure(m) };
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class Failure<T> extends Result<T> {
  final String message;
  const Failure(this.message);
}

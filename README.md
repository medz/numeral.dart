# Numeral

A Dart library for Format number into beautiful string, Format the number into a beautiful, readable and short string.

[![Dart CI](https://github.com/medz/numeral.dart/actions/workflows/dart.yml/badge.svg)](https://github.com/medz/numeral.dart/actions/workflows/dart.yml)
[![Pub Version](https://img.shields.io/pub/v/numeral?label=pub.dev&style=flat)](https://pub.dev/packages/numeral)

## Install

See [pub.dev Numeral install document](https://pub.dev/packages/numeral/install)

## Getting Started

```dart
import 'package:numeral/numeral.dart';

// number < 1 thousand.
Numeral(520).format(); // > 520

// number >= 1 thousand.
Numeral(1314).format(); // > 1.314K

// number >= 1 million.
Numeral(1000000).format(); // > 1M

// number >= 1 billion.
Numeral(1000000000).format(); // > 1B

// number >= 1 trillion.
Numeral(1000000000000).format(); // > 1T
```

See [Example](example)


### Using `numeral` function

```dart
import 'package:numeral/fun.dart';

numeral(10000); /// 10K
```

### Extension

```dart
import 'package:numeral/ext.dart';


10000.numeral(); // 10K
```

## License

The component is open-sourced software licensed under the [MIT license](LICENSE).

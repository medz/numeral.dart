# Numeral

Format number into beautiful string.

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

```
import 'package:numeral/fun.dart';

numeral(10000); /// 10K
```

### Extension

```
import 'package:numeral/ext.dart';


10000.number(); // 10K
```

## License

The component is open-sourced software licensed under the [MIT license](LICENSE).

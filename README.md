# Flex List

[![Pub Points](https://img.shields.io/pub/v/flex_list)](https://pub.dev/packages/flex_list)
[![Pub Points](https://img.shields.io/pub/points/flex_list)](https://pub.dev/packages/flex_list/score)
[![Pub Points](https://img.shields.io/pub/popularity/flex_list)](https://pub.dev/packages/flex_list/score)
---

Provides a flexible list layout that behaves as you would expect from `Expand` widgets within
a `Wrap`.

## Features

`FlexList` puts as many provided elements as possible in one row (like `Wrap`), but also extends the
width of the elements by the remaining space per row. This means that each row is filled to the
maximum width.

## Getting started

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  ...
  flex_list: <latest_version>
```

In your library add the following import:

```dart
import 'package:flex_list/flex_list.dart';
```

## Usage

The following example shows how to use `FlexList`. Beside the `children` property, you can
set `horizontalSpacing` and `verticalSpacing` to define the spacing between the elements.

**Note:** Both spacing values are `10` by default.

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'FlexList Demo',
        theme: ThemeData(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
                width: 300,
                child: FlexList(
                  horizontalSpacing: 5,
                  verticalSpacing: 10,
                  children: [
                    for (var i = 0; i < 10; i++)
                      Container(
                        color: Theme
                            .of(context)
                            .colorScheme.surfaceContainer,
                        padding: EdgeInsets.symmetric(
                            horizontal: 20 + 20 * (i % 4), vertical: 10),
                        child: Text("Item $i"),
                      )
                  ],
                )),
          ),
        ));
  }
}
```

### Rendering of above Example

<img src="https://github.com/Jozott00/flex_list/blob/main/blob/media/example1.png?raw=true" alt="Example Rendering" width="400"/>

## Additional information

This package was written because of the lack of such layout function. The package repository is
maintained on [Github](https://github.com/Jozott00/flex_list) and published
on [pub.dev](https://pub.dev/packages/flex_list)

Provides a flexible list layout that acts like a combination of `Expand` widgets in a `Wrap`.

## Features

`FlexList` puts as many provided elements as possible in one line (like `Wrap`), but also extends
the width of the elements by the remaining space per line. This means that each row is filled to the
maximum width.

## Getting started

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  ...
  flex_list: <latest_version>
```

In you library add the following import:

```dart
import 'package:flex_list/flex_list.dart';
```

## Usage

The following ecample shows how use `FlexList`. Beside the `children` property, you can
set `horizontalSpacing` and `verticalSpacing` to define the space between the elements.

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
                            .backgroundColor,
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

## Additional information

This package was written because of the lack of such layout function. The package repository is
maintained on (Github)[].
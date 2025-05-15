import 'package:flutter/material.dart';
import 'package:flex_list/flex_list.dart';

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

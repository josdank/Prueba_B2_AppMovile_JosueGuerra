import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? trailing;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.trailing,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActions = <Widget>[...?actions];
    if (trailing != null) effectiveActions.add(trailing!);
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: body,
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

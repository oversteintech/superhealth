import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MainTab { dashboard, live, assistant, features, profile }

final mainTabProvider =
    NotifierProvider<MainTabController, MainTab>(MainTabController.new);

class MainTabController extends Notifier<MainTab> {
  @override
  MainTab build() => MainTab.dashboard;

  void select(MainTab tab) => state = tab;
}

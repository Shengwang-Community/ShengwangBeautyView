// i_page_builder.dart
// Mirrors iOS IPageBuilder.swift

import '../models/beauty_page_info.dart';

/// Page builder interface
abstract class IPageBuilder {
  Future<BeautyPageInfo> buildPage();
}

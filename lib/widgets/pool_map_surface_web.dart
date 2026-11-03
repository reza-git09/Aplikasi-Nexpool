import 'dart:html' as html;

import 'package:flutter/widgets.dart';

Widget buildWebMapSurface({required String url, required VoidCallback onLoad}) {
  return HtmlElementView.fromTagName(
    tagName: 'iframe',
    onElementCreated: (element) {
      final iframe = element as html.IFrameElement
        ..src = url
        ..allowFullscreen = true
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%';
      iframe.onLoad.listen((_) => onLoad());
    },
  );
}

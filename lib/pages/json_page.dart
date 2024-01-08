import 'package:flongo_client/pages/api_page.dart';
import 'package:flongo_client/widgets/json_widget.dart';
import 'package:flutter/material.dart';

abstract class JSON_Page<T extends StatefulWidget> extends API_Page {
  const JSON_Page({super.key});

  @override
  JSON_PageState createState() => JSON_PageState();
}

class JSON_PageState<T extends JSON_Page> extends API_PageState<T> {
  @override
  Widget getPageWidget(BuildContext context) => JSON_Widget(data: data, apiURL: widget.apiURL);
}

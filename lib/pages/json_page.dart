import 'package:flongo_client/pages/api_page.dart';
import 'package:flongo_client/widgets/json_widget.dart';
import 'package:flutter/material.dart';

abstract class JSON_Page<W extends JSON_Widget> extends API_Page {
  
  const JSON_Page({super.key});

  @override
  JSON_PageState<W> createState() => JSON_PageState<W>();
}

class JSON_PageState<W extends JSON_Widget> extends API_PageState<JSON_Page<W>> {

  @override
  Widget getPageWidget(BuildContext context) => JSON_Widget(data: data, apiURL: widget.apiURL);
  
}


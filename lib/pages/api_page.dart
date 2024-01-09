import 'package:flongo_client/pages/base_page.dart';
import 'package:flongo_client/utilities/http_client.dart';
import 'dart:convert';

import 'package:flutter/material.dart';

class API_Page extends BasePage {
  // URL to send the API request to
  final String apiURL = '/';
  // Key to read response data from
  final String dataPath = 'data';
  // True if the API call should be made when the widget loads
  final bool fetchOnLoad = false;
  // Data to filter from the API call response
  final List<String> filterFields = const [];
  // Query params to pass in the API call (overridden by concrete constructors)
  final Map<String, String> queryParams = {};

  API_Page({super.key});

  @override
  API_PageState createState() => API_PageState();
}

class API_PageState<T extends API_Page> extends BasePageState<T> {
  late HTTPClient client;
  dynamic data;

  @override
  void initState() {
    super.initState();
    client = HTTPClient(widget.apiURL);
    
    if (widget.fetchOnLoad) {
      isLoading = true;
      fetchData();
    } else {
      isLoading = false;
    }
  }

  List<Widget> getNavBarWidgets(BuildContext context) => [];

  Future<void> fetchData() async {
    await client.get(
        onSuccess: (response) {
          dynamic responseData;
          if (response.body != null) {
            responseData = json.decode(response.body);
            if (widget.dataPath.isNotEmpty) {
              responseData = responseData[widget.dataPath];
            }
          }
          setState(() {
            data = responseData;
            isLoading = false;
          });
        },
        onError: (response) {
          setState(() {
            Map<String, dynamic> errorData = jsonDecode(response.body);
            error = errorData["error"];
            isLoading = false;
          });
        });
  }

  @override
  Widget getPageWidget(BuildContext context) => Text(data != null ? data.toString() : 'No data found');
}

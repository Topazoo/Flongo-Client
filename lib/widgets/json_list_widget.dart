import 'package:flongo_client/utilities/http_client.dart';
import 'package:flongo_client/widgets/json_widget_mixin.dart';
import 'package:flutter/material.dart';

class JSON_List_Widget extends StatefulWidget {
  final dynamic data;
  final String apiURL;
  final Future<void> Function()? onRefresh;

  const JSON_List_Widget({
    Key? key,
    required this.data,
    required this.apiURL,
    this.onRefresh
  }) : super(key: key);

  @override
  JSONWidgetState createState() => JSONWidgetState();
}


class JSONWidgetState extends State<JSON_List_Widget> with JSON_Widget_Mixin{
  late List data;
  String currentSearchTerm = "";

  @override
  void initState() {
    super.initState();
    data = widget.data;
  }

  void filterData(String query) {
    currentSearchTerm = query;
    setState(() {
      data = query.isEmpty ? widget.data : filter(data, query);
    });
  }

  List filter(List data, String query) {
    if (query.isEmpty) {
      return data;
    }

    return data.where((item) {
      return item['name']?.toLowerCase().contains(query.toLowerCase()) ?? false;
    }).toList();
  }

  Future<void> updateItem(Map item, int index, {String idKey = '_id', Function? onSuccess, Function? onError}) async {
    final controllers = <String, TextEditingController>{};

    Map<String, dynamic> updatedItem = Map<String, dynamic>.from(item);
    updatedItem.forEach((key, value) {
      controllers[key] = TextEditingController(text: value.toString());
    });

    bool? isUpdated = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _buildUpdateDialog(
        controllers, updatedItem, updatedItem.remove(idKey), index, idKey, onSuccess: onSuccess, onError: onError
      ),
    );

    if (isUpdated != null) {
      showSnackBar(context, isUpdated ? 'Updated Successfully' : 'Failed to Update');
    }
  }

  AlertDialog _buildUpdateDialog(
      Map<String, TextEditingController> controllers, 
      Map<String, dynamic> updatedItem, 
      String? _id, 
      int index,
      String idKey,
      {Function? onSuccess , Function? onError}
    ) {
    return AlertDialog(
      title: const Text('Update Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: updatedItem.keys.map((key) {
            return TextField(
              controller: controllers[key],
              decoration: InputDecoration(labelText: key),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        TextButton(
          child: const Text('Update'),
          onPressed: () async {
            final finalItem = {...updatedItem, if (_id != null) idKey: _id};

            controllers.forEach((key, controller) {
              finalItem[key] = convertToRawType(controller.text);
            });

            bool success = await _updateData(finalItem, index, onSuccess: onSuccess, onError: onError);
            Navigator.of(context).pop(success);
          },
        ),
      ],
    );
  }

  void updateStateData(int index, Map<String, dynamic> updatedItem, dynamic response) {
    setState(() { data[index] = updatedItem; });
  }

  Future<bool> _updateData(Map<String, dynamic> updatedItem, int index, {Function? onSuccess, Function? onError}) async {
    bool success = false;
    await HTTPClient(widget.apiURL).patch(
      body: updatedItem,
      onSuccess: (response) {
        (onSuccess ?? updateStateData)(index, updatedItem, response);
        success = true;
      },
      onError: (error) {
        if (onError != null) {
          onError(index, updatedItem, error);
        }
        success = false;
      },
    );
    return success;
  }

  void deleteStateData(int index, Map<String, dynamic> item, dynamic response) {
    setState(() { data.removeAt(index); });
  }

  Future<void> deleteItem(Map<String, dynamic> item, int index, {Function? onSuccess, Function? onError}) async {
    await HTTPClient(widget.apiURL).delete(
      queryParams: {
        '_id': item['_id'].toString(),
      },
      onSuccess: (response) {
        (onSuccess ?? deleteStateData)(index, item, response);
        showSnackBar(context, 'Deleted Successfully');
      },
      onError: (error) {
        if (onError != null) {
          onError(index, item, error);
        }
        showSnackBar(context, 'Failed to Delete');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(data.toString());
  }
}

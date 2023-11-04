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

  Future<void> updateItem(Map item, int index, {String idKey = '_id'}) async {
    final controllers = <String, TextEditingController>{};

    Map<String, dynamic> updatedItem = Map<String, dynamic>.from(item);
    updatedItem.forEach((key, value) {
      controllers[key] = TextEditingController(text: value.toString());
    });

    bool? isUpdated = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _buildUpdateDialog(controllers, updatedItem, updatedItem.remove(idKey), index, idKey),
    );

    if (isUpdated != null) {
      showSnackBar(context, isUpdated ? 'Updated Successfully' : 'Failed to Update');
    }
  }

  AlertDialog _buildUpdateDialog(Map<String, TextEditingController> controllers, Map<String, dynamic> updatedItem, String? _id, int index, String idKey) {
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

            bool success = await _updateData(finalItem, index);
            Navigator.of(context).pop(success);
          },
        ),
      ],
    );
  }

  Future<bool> _updateData(Map<String, dynamic> updatedItem, int index) async {
    bool success = false;
    await HTTPClient(widget.apiURL).patch(
      body: updatedItem,
      onSuccess: (response) {
        setState(() { data[index] = updatedItem; });
        success = true;
      },
      onError: (error) {
        success = false;
      },
    );
    return success;
  }

  Future<void> deleteItem(Map<String, dynamic> item, int index) async {
    await HTTPClient(widget.apiURL).delete(
      queryParams: {
        '_id': item['_id'].toString(),
      },
      onSuccess: (response) {
        setState(() { data.removeAt(index); });
        showSnackBar(context, 'Deleted Successfully');
      },
      onError: (response) {
        showSnackBar(context, 'Failed to Delete');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(data.toString());
  }
}

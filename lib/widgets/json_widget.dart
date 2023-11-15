import 'package:flongo_client/utilities/http_client.dart';
import 'package:flongo_client/widgets/json_widget_mixin.dart';
import 'package:flutter/material.dart';

class JSON_Widget extends StatefulWidget {
  final Map data;
  final String apiURL;
  final List<String> filterFields;

  const JSON_Widget({
    Key? key,
    required this.data,
    required this.apiURL, 
    this.filterFields = const []
  }) : super(key: key);

  @override
  JSON_WidgetState createState() => JSON_WidgetState();
}


class JSON_WidgetState<T extends JSON_Widget> extends State<T> with JSON_Widget_Mixin {
  late Map data;

  @override
  void initState() {
    super.initState();
    data = _filterData(widget.data);
  }

  Map<dynamic, dynamic> _filterData(Map<dynamic, dynamic> data) {
    data.removeWhere((key, value) => widget.filterFields.contains(key));
    return data;
  }

  Future<void> updateItem(Map item, {String idKey = '_id', Function? onSuccess, Function? onError}) async {
    final controllers = <String, TextEditingController>{};

    Map<String, dynamic> updatedItem = Map<String, dynamic>.from(item);
    updatedItem.forEach((key, value) {
      controllers[key] = TextEditingController(text: value.toString());
    });

    bool? isUpdated = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _buildUpdateDialog(
        controllers, updatedItem, updatedItem.remove(idKey), idKey, onSuccess: onSuccess, onError: onError
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
      String idKey,
      {Function? onSuccess, Function? onError}
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
              if (controller.text.isNotEmpty) {
                finalItem[key] = convertToRawType(controller.text);
              } else {
                finalItem.remove(key);
              }
            });

            bool success = await _updateData(finalItem, onSuccess: onSuccess, onError: onError);
            Navigator.of(context).pop(success);
          },
        ),
      ],
    );
  }

  void updateStateData(Map<String, dynamic> updatedItem, dynamic response) {
    setState(() { data = {...data, ...updatedItem}; });
  }

  Future<bool> _updateData(Map<String, dynamic> updatedItem, {Function? onSuccess, Function? onError}) async {
    bool success = false;
    await HTTPClient(widget.apiURL).patch(
      body: updatedItem,
      onSuccess: (response) {
        (onSuccess ?? updateStateData)(updatedItem, response);
        success = true;
      },
      onError: (error) {
        if (onError != null) {
          onError(updatedItem, error);
        }
        success = false;
      },
    );
    return success;
  }

  void deleteStateData(Map item, dynamic response) {
    setState(() { data = {}; });
  }

  Future<void> deleteItem(Map item, {Function? onSuccess, Function? onError}) async {
    await HTTPClient(widget.apiURL).delete(
      queryParams: {
        '_id': item['_id'].toString(),
      },
      onSuccess: (response) {
        (onSuccess ?? deleteStateData)(item, response);
        showSnackBar(context, 'Deleted Successfully');
      },
      onError: (error) {
        if (onError != null) {
          onError(item, error);
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

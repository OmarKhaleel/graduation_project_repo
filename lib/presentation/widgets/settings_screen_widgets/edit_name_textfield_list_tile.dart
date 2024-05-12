import 'package:flutter/material.dart';
import 'package:palmear_application/data/services/user_services/user_details.dart';
import 'package:palmear_application/presentation/widgets/general_widgets/toast.dart';

class EditNameTextFieldListTile extends StatefulWidget {
  final TextEditingController nameController;
  final UserDetails userDetails;

  const EditNameTextFieldListTile({
    super.key,
    required this.nameController,
    required this.userDetails,
  });

  @override
  State<EditNameTextFieldListTile> createState() =>
      _EditNameTextFieldListTileState();
}

class _EditNameTextFieldListTileState extends State<EditNameTextFieldListTile> {
  void _updateName() async {
    bool success =
        await widget.userDetails.updateUserName(widget.nameController.text);
    if (success) {
      showToast(message: "Name updated successfully");
    } else {
      showToast(message: "Failed to update name");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      textColor: Colors.black,
      subtitle: Column(
        children: [
          TextField(
            controller: widget.nameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Edit Name",
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _updateName,
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:flutter_complete_guide/widgets/text_field_container.dart';

class RoundedPhoneInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  const RoundedPhoneInputField({
    Key key,
    this.hintText,
    this.icon = Icons.person,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      child: TextFieldContainer(
        child: TextFormField(
          validator: (val) => val.isEmpty ? 'Enter the phone' : null,
          keyboardType: TextInputType.phone,
          onChanged: onChanged,
          cursorColor: primaryColor,
          decoration: InputDecoration(
            icon: Icon(
              icon,
              color: darkPrimaryColor,
            ),
            hintText: hintText,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

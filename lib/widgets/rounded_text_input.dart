import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/constants.dart';
import 'package:flutter_complete_guide/widgets/text_field_container.dart';

class RoundedTextInput extends StatelessWidget {
  final String hintText;
  final TextInputType type;
  final Function validator;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  const RoundedTextInput({
    Key key,
    this.hintText,
    this.type,
    this.validator,
    this.icon = Icons.person,
    this.onChanged,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    Size size = MediaQuery.of(context).size;
    return Container(
      height: 70,
      child: TextFieldContainer(
        child: TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: type,
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

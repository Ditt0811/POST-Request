import 'package:flutter/material.dart';

/// Field dengan label di dalam container yang menghilang saat ada teks/selected value.
class InlineLabelField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final IconData? icon;
  final TextInputType keyboardType;
  final bool readOnly;
  final String? dropdownValue;
  final List<DropdownMenuItem<String>>? dropdownItems;
  final ValueChanged<String?>? onDropdownChanged;
  final FormFieldValidator<String>? validator;
  final bool isDropdown;

  const InlineLabelField({
    super.key,
    this.controller,
    required this.label,
    this.icon,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.dropdownValue,
    this.dropdownItems,
    this.onDropdownChanged,
    this.validator,
    this.isDropdown = false,
  });

  @override
  State<InlineLabelField> createState() => _InlineLabelFieldState();
}

class _InlineLabelFieldState extends State<InlineLabelField> {
  late bool _hasText;

  @override
  void initState() {
    super.initState();
    _hasText = _computeHasText();
    widget.controller?.addListener(_onControllerChanged);
  }

  bool _computeHasText() {
    if (widget.isDropdown) {
      return widget.dropdownValue != null &&
          widget.dropdownValue!.trim().isNotEmpty;
    }
    return (widget.controller?.text.isNotEmpty ?? false);
  }

  void _onControllerChanged() {
    final now = _computeHasText();
    if (now != _hasText) {
      setState(() => _hasText = now);
    }
  }

  @override
  void didUpdateWidget(covariant InlineLabelField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final now = _computeHasText();
    if (now != _hasText) setState(() => _hasText = now);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labelVisible = !_hasText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // label inside container
          AnimatedOpacity(
            opacity: labelVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 220),
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                ],
                Text(widget.label,
                    style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),

          // actual input (TextField or Dropdown)
          Padding(
            padding: const EdgeInsets.only(left: 0),
            child: widget.isDropdown ? _buildDropdown() : _buildTextField(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      readOnly: widget.readOnly,
      validator: widget.validator,
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        hintText: '',
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: widget.dropdownValue,
      items: widget.dropdownItems,
      onChanged: widget.onDropdownChanged,
      validator: widget.validator,
      decoration: const InputDecoration(
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),
    );
  }
}

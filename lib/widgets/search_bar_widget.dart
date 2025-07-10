// lib/widgets/search_bar_widget.dart
import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onSearchChanged;
  final TextEditingController? controller; // Optional: Pass an external controller
  final bool autofocus;

  const SearchBarWidget({
    super.key,
    this.hintText = 'Search by name, account, or rep...',
    required this.onSearchChanged,
    this.controller,
    this.autofocus = false,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
    // Add a listener to the controller to trigger onSearchChanged
    _internalController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    widget.onSearchChanged(_internalController.text);
  }

  @override
  void dispose() {
    _internalController.removeListener(_onTextChanged);
    // Only dispose if we created the controller internally
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _internalController,
        autofocus: widget.autofocus,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _internalController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _internalController.clear();
              widget.onSearchChanged(''); // Notify parent about clear
              FocusScope.of(context).unfocus(); // Dismiss keyboard
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor, // Use card color for search bar background
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
      ),
    );
  }
}
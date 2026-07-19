import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_dimens.dart';

/// The search box.
///
/// The [TextEditingController] is supplied by the page rather than created
/// here, because tapping a recent search has to *write* into the field. The
/// alternative — driving `TextField.text` from provider state — resets the
/// cursor to the start on every keystroke, which makes editing a term
/// mid-string impossible.
class SearchField extends StatelessWidget {
  const SearchField({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onCleared,
    super.key,
    this.hintText = 'Search for products, brands…',
    this.autofocus = true,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onCleared;
  final String hintText;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return TextField(
      controller: controller,
      autofocus: autofocus,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: context.text.bodyMedium,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(Icons.search, size: 20, color: palette.inkSubtle),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: 'Clear',
                  onPressed: () {
                    controller.clear();
                    onCleared();
                  },
                ),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppDimens.space12,
        ),
      ),
    );
  }
}

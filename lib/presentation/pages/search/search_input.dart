import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SearchInput extends StatefulWidget {
  const SearchInput({super.key});

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clearInput() {
    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Localizations(
        locale: const Locale('en', 'US'),
        delegates: const <LocalizationsDelegate<dynamic>>[
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        child: TextField(
          controller: _controller,
          onChanged: (value) {
            setState(() {});
          },
          decoration: InputDecoration(
            prefixIcon: Icon(
              LucideIcons.search,
              size: 16.0,
              color: const Color(0xFF999999),
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? GestureDetector(
                    onTap: _clearInput,
                    child: Icon(
                      LucideIcons.x,
                      size: 16.0,
                      color: const Color(0xFF999999),
                    ),
                  )
                : null,
            hintText: '搜索播客',
            hintStyle: const TextStyle(
              fontSize: 12.0,
              color: Color(0xFF999999),
              height: 16.0 / 12.0,
            ),
            filled: true,
            fillColor: const Color(0xFFF0F0F0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 8.0,
            ),
            constraints: const BoxConstraints(
              minHeight: 34.0,
              maxHeight: 40.0,
            ),
          ),
          style: const TextStyle(
            fontSize: 12.0,
            color: Color(0xFF000000),
            height: 16.0 / 12.0,
          ),
          cursorColor: const Color(0xFF000000),
          maxLines: 1,
          minLines: 1,
        ),
      ),
    );
  }
}

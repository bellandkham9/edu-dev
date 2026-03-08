import 'package:flutter/material.dart';
import '../theme/colors.dart';

class TopSearchBar extends StatelessWidget {
  final String hint;
  final bool menuHint;
  const TopSearchBar({super.key, this.hint = "Que voulez vous apprendre ?", required this.menuHint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: AppColors.brun,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  menuHint==true?SizedBox():IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration.collapsed(
                          hintText: hint, hintStyle: TextStyle(color: Colors.black54)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.search, color: Colors.black54),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

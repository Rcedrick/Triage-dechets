import 'package:flutter/material.dart';

//const Color primaryColor = Color(0xFF0B5309);
const Color primaryColor = Color(0xFF3E8F3C);
const Color backgroundColor = Color(0xFFF2FFF5);
const Color textColor = Colors.black;
const Color cardColor = Color(0xFFF2FFF5);

const TextStyle titleTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: textColor,
);

const TextStyle subtitleTextStyle = TextStyle(
  fontSize: 16,
  color: Colors.grey,
);

PreferredSizeWidget buildAppBar(BuildContext context, String title,
    {bool showBack = true, List<Widget>? actions}) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: showBack
        ? IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.black),
      onPressed: () => Navigator.pop(context),
    )
        : null,
    title: Text(
      title,
      style: titleTextStyle,
    ),
    centerTitle: true,
    actions: actions,
  );
}

class ThemedScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final bool showBack;

  const ThemedScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: buildAppBar(context, title, showBack: showBack, actions: actions),
      body: body,
    );
  }
}


Widget buildFancyHeader(String title, {String? logoPath}) {
  return SizedBox(
    height: 120,
    child: Stack(
      children: [
        Container(
          height: 90,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor.withOpacity(0.9),
                primaryColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(40),
            ),
          ),
        ),

        // Carte blanche flottante
        Positioned(
          top: 30,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (logoPath != null) ...[
                  ClipOval(
                    child: Image.asset(
                      logoPath,
                      width: 35,
                      height: 35,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  title,
                  style: titleTextStyle.copyWith(
                    color: cardColor,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
PreferredSizeWidget buildCustomAppBar(BuildContext context, String titleText) {
  return AppBar(
    leading: GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Row(
        children: const [
          SizedBox(width: 8),
          Icon(Icons.arrow_back, size: 30, color: Colors.white),
        ],
      ),
    ),
    title: Text(
      titleText,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 25,
      ),
    ),
    centerTitle: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: const IconThemeData(color: Colors.white),
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.9),
            primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ),
  );
}


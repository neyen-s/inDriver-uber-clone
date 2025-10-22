import 'package:flutter/material.dart';
import 'package:indriver_uber_clone/core/common/widgets/scaffold/drawer_items.dart';

class GenericHomeScaffold<S> extends StatelessWidget {
  const GenericHomeScaffold({
    required this.drawerTitle,
    required this.drawerItems,
    required this.selectedSection,
    required this.buildBody,
    required this.onSectionSelected,
    required this.onSignOut,
    super.key,
  });

  final String drawerTitle;
  final List<DrawerItem<S>> drawerItems;
  final S selectedSection;
  final Widget Function(S section) buildBody;
  final void Function(S section) onSectionSelected;
  final VoidCallback onSignOut;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(drawerTitle)),
      //extendBodyBehindAppBar: true,
      // extendBody: true,
      body: buildBody(selectedSection),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0E1D6A), Color(0xFF1E70E3)],
                ),
              ),
              child: Text(
                drawerTitle,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            ...drawerItems.map((item) {
              final isSelected = selectedSection == item.section;
              return ListTile(
                title: Text(item.label),
                selected: isSelected,
                onTap: () {
                  if (!isSelected) {
                    onSectionSelected(item.section);
                  }
                  Navigator.pop(context);
                },
              );
            }),
            const Divider(),
            ListTile(
              title: const Text('Sign out'),
              leading: const Icon(Icons.logout),
              onTap: () {
                onSignOut();
                Navigator.pop(context); // Cierra el drawer
              },
            ),
          ],
        ),
      ),
    );
  }
}

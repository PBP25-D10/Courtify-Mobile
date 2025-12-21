// import 'package:flutter/material.dart';
// import '../module/artikel/screens/news_list_page.dart';

// class LeftDrawer extends StatelessWidget {
//   const LeftDrawer({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         children: [
//           const DrawerHeader(
//             child: Text("Courtify"),
//           ),
//           ListTile(
//             leading: const Icon(Icons.newspaper),
//             title: const Text("Berita Olahraga"),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => const NewsListPage()),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:courtify_mobile/module/artikel/screens/news_list_page.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Courtify',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Booking & Berita Olahraga',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.newspaper),
            title: const Text("Berita Olahraga"),
            onTap: () {
              Navigator.pop(context); // tutup drawer dulu biar rapi
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NewsListPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

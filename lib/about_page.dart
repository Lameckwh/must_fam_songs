import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        automaticallyImplyLeading: false,
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            const Column(
              children: [
                Image(
                  height: 140,
                  width: 140,
                  image: AssetImage("images/music_note.png"),
                ),
                SizedBox(
                  height: 7,
                ),
                Text(
                  "MUST FAM Songs App",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                Text("v3.234"),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: ListBody(
                    children: [
                      ListTile(
                        // trailing: const Icon(Icons.arrow_forward_ios),
                        leading: const Icon(FontAwesomeIcons.github),
                        title: const Text("View source code"),
                        onTap: () async {
                          // String email =
                          //     Uri.encodeComponent("bit-032-19@must.ac.mw");
                          // String subject =
                          //     Uri.encodeComponent("MaterniTech FeedBack ");
                          // String body = Uri.encodeComponent("Hi, I am .....");
                          // Uri mail = Uri.parse(
                          //     "mailto:$email?subject=$subject&body=$body");
                          // if (await launchUrl(mail)) {
                          //   // Email app opened
                          // } else {
                          //   // Email app is not opened
                          // }
                        },
                      ),
                      const Divider(
                        // Add a divider (bottom border)
                        color: Colors.grey,
                        height: 1,
                        thickness: 0.6,
                      ),
                      ListTile(
                        // trailing: const Icon(Icons.arrow_forward_ios),
                        leading: const Icon(Icons.help),
                        title: const Text("Help or FeedBack"),
                        onTap: () async {
                          // String email =
                          //     Uri.encodeComponent("bit-032-19@must.ac.mw");
                          // String subject =
                          //     Uri.encodeComponent("MaterniTech FeedBack ");
                          // String body = Uri.encodeComponent("Hi, I am .....");
                          // Uri mail = Uri.parse(
                          //     "mailto:$email?subject=$subject&body=$body");
                          // if (await launchUrl(mail)) {
                          //   // Email app opened
                          // } else {
                          //   // Email app is not opened
                          // }
                        },
                      ),
                      const Divider(
                        // Add a divider (bottom border)
                        color: Colors.grey,
                        height: 1,
                        thickness: 0.6,
                      ),
                      ListTile(
                        onTap: () {},
                        leading: const Icon(Icons.dark_mode_sharp),
                        trailing: ValueListenableBuilder(
                          valueListenable: Hive.box('settings').listenable(),
                          builder: (context, box, child) {
                            final isDark =
                                box.get("isDark", defaultValue: false);
                            return Switch(
                              value: isDark,
                              onChanged: (val) {
                                box.put("isDark", val);
                              },
                            );
                          },
                        ),
                        title: const Text("Dark Theme"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 30.0, right: 30, bottom: 30),
              child: Text(
                "This app was developed by Lameck Mbewe, the former chair of MUST Future Adventist Men and Software Developer",
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }
}

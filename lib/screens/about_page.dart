import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  _launchURL() async {
    final Uri url = Uri.parse("https://github.com/Lameckwh/must_fam_songs");
    if (!await launchUrl(url)) {
      throw Exception('Could not launch the url');
    }
  }

  _launchLinkedInURL() async {
    final Uri url = Uri.parse("https://www.linkedin.com/in/lameckmbewe/");
    if (!await launchUrl(url)) {
      throw Exception('Could not launch the url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Scaffold(
          appBar: AppBar(
            elevation: 1,
            automaticallyImplyLeading: false,
            title: const Text('About'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 20.h,
                ),
                Column(
                  children: [
                    Image(
                      height: 90.h,
                      width: 90.w,
                      image: const AssetImage("images/ic_launcher.png"),
                    ),
                    SizedBox(
                      height: 7.h,
                    ),
                    Text(
                      "MUST FAM Songs App",
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 18.sp),
                    ),
                    Text("v3.13.2", style: TextStyle(fontSize: 16.sp)),
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),
                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
                      child: ListBody(
                        children: [
                          ListTile(
                            leading: const Icon(FontAwesomeIcons.github),
                            title: const Text("View source code"),
                            onTap: _launchURL,
                          ),
                          const Divider(
                            color: Colors.grey,
                            height: 1,
                            thickness: 0.6,
                          ),
                          ListTile(
                            leading: const Icon(
                              FontAwesomeIcons.linkedin,
                              color: Colors.blue,
                            ),
                            title: const Text("LinkedIn"),
                            onTap: _launchLinkedInURL,
                          ),
                          const Divider(
                            color: Colors.grey,
                            height: 1,
                            thickness: 0.6,
                          ),
                          ListTile(
                            leading: const Icon(Icons.help),
                            title: const Text("Help or FeedBack"),
                            onTap: () async {
                              String email =
                                  Uri.encodeComponent("bit-032-19@must.ac.mw");
                              String subject = Uri.encodeComponent(
                                  "MUST FAM Songs App FeedBack ");
                              String body = Uri.encodeComponent("Hi, I am ");
                              Uri mail = Uri.parse(
                                  "mailto:$email?subject=$subject&body=$body");
                              if (await launchUrl(mail)) {
                                // Email app opened
                              } else {
                                // Email app is not opened
                              }
                            },
                          ),
                          const Divider(
                            color: Colors.grey,
                            height: 1,
                            thickness: 0.6,
                          ),
                          ListTile(
                            onTap: () {},
                            leading: const Icon(Icons.dark_mode_sharp),
                            trailing: ValueListenableBuilder(
                              valueListenable:
                                  Hive.box('settings').listenable(),
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
                SizedBox(
                  height: 20.h,
                ),
                Padding(
                  padding:
                      EdgeInsets.only(left: 30.w, right: 30.w, bottom: 30.h),
                  child: Text(
                    "This app was developed by Lameck Mbewe, the former chair of MUST Future Adventist Men",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.sp),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

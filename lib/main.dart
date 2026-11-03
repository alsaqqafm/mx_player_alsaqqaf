import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:file_picker/file_picker.dart';

void main(List<String> args) {
  // 1. تهيئة المحرك قبل تشغيل التطبيق لضمان عدم وجود أخطاء
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MaxAlsaqafPlayer(args: args),
  ));
}

class MaxAlsaqafPlayer extends StatefulWidget {
  final List<String> args;
  const MaxAlsaqafPlayer({super.key, this.args = const []});

  @override
  State<MaxAlsaqafPlayer> createState() => _MaxAlsaqafPlayerState();
}

class _MaxAlsaqafPlayerState extends State<MaxAlsaqafPlayer> {
  // إنشاء المحرك والمتحكم
  late final Player player = Player();
  late final VideoController controller = VideoController(player);

  double currentSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable(); // منع الشاشة من الانطفاء
    
    // تشغيل الملف إذا تم فتحه من الخارج (Double Click)
    if (widget.args.isNotEmpty) {
      final file = widget.args.first;
      player.open(Media(file));
    }
  }

  @override
  void dispose() {
    player.dispose(); // إغلاق المحرك عند الخروج لتوفير الذاكرة
    WakelockPlus.disable();
    super.dispose();
  }

  // دالة لاختيار الفيديوهات من الجهاز
  Future<void> pickFiles() async {
    var result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );
    if (result != null) {
      final files = result.paths.whereType<String>().toList();
      final playlist = Playlist(files.map((e) => Media(e)).toList());
      player.open(playlist);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          // برمجة أزرار الكيبورد (الأسهم)
          const SingleActivator(LogicalKeyboardKey.arrowUp): () {
            player.setVolume(player.state.volume + 5);
          },
          const SingleActivator(LogicalKeyboardKey.arrowDown): () {
            player.setVolume(player.state.volume - 5);
          },
          const SingleActivator(LogicalKeyboardKey.arrowRight): () {
            if (player.state.playlist.medias.length > 1) {
              player.next(); // الفيديو التالي
            } else {
              player.seek(player.state.position + const Duration(seconds: 10)); // تخطي 10 ثواني
            }
          },
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
            if (player.state.playlist.medias.length > 1) {
              player.previous(); // الفيديو السابق
            } else {
              player.seek(player.state.position - const Duration(seconds: 10)); // رجوع 10 ثواني
            }
          },
        },
        child: Focus(
          autofocus: true,
          child: Stack(
            children: [
              // 1. عرض الفيديو
              Center(
                child: Video(controller: controller),
              ),

              // 2. الأسهم الجانبية للتنقل (يمين ويسار)
              _buildSideArrow(Alignment.centerLeft, Icons.arrow_back_ios, () {
                if (player.state.playlist.medias.length > 1) {
                  player.previous();
                } else {
                  player.seek(player.state.position - const Duration(seconds: 10));
                }
              }),
              _buildSideArrow(Alignment.centerRight, Icons.arrow_forward_ios, () {
                if (player.state.playlist.medias.length > 1) {
                  player.next();
                } else {
                  player.seek(player.state.position + const Duration(seconds: 10));
                }
              }),

              // 3. شريط التحكم العلوي (السرعة واختيار الملفات)
              Positioned(
                top: 20,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("max alsaqaf Player", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        _buildSpeedButton(),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: pickFiles,
                          icon: const Icon(Icons.file_open),
                          label: const Text("فتح ملفات"),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // تصميم الزر الجانبي المخفي (يظهر عند تمرير الماوس)
  Widget _buildSideArrow(Alignment alignment, IconData icon, VoidCallback onTap) {
    return Align(
      alignment: alignment,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 80,
          height: double.infinity,
          color: Colors.transparent, // منطقة شفافة للنقر
          child: Icon(icon, color: Colors.white.withOpacity(0.3), size: 40),
        ),
      ),
    );
  }

  // زر التحكم في السرعة
  Widget _buildSpeedButton() {
    return PopupMenuButton<double>(
      initialValue: currentSpeed,
      icon: const Icon(Icons.speed, color: Colors.white),
      onSelected: (double speed) {
        setState(() {
          currentSpeed = speed;
          player.setRate(speed); // تغيير سرعة الفيديو
        });
      },
      itemBuilder: (context) => [0.5, 1.0, 1.5, 2.0]
          .map((s) => PopupMenuItem(value: s, child: Text("${s}x السرعة")))
          .toList(),
    );
  }
}

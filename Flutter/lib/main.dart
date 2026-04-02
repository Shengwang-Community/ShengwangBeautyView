import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'Example/example_page.dart';
import 'Utils/beauty_localizer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shengwang Beauty Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = false;

  static const String _zipAssetKey   = 'assets/AgoraBeautyMaterial.zip';
  static const String _md5AssetKey   = 'assets/zip.md5';
  static const String _bundleDirName = 'AgoraBeautyMaterial.bundle';
  static const String _md5StoreKey   = 'beauty_zip_md5';
  static const String _materialRoot  = '/beauty_material_functional';

  Future<void> _onStartPreview() async {
    await [Permission.camera, Permission.microphone].request();
    setState(() => _loading = true);

    try {
      final destPath = await _prepareBundle();
      debugPrint('[Beauty] Bundle ready at: $destPath');
      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ExamplePage(
            materialBundlePath: destPath + _materialRoot,
            lang: 'zh',
          ),
        ),
      );
    } catch (e, st) {
      debugPrint('[Beauty] Error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('资源准备失败: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<String> _prepareBundle() async {
    final appSupport = await getApplicationSupportDirectory();
    final destDir = Directory('${appSupport.path}/$_bundleDirName');

    final assetMd5 = (await rootBundle.loadString(_md5AssetKey)).trim();
    final prefs = await _loadPrefs();
    final storedMd5 = (prefs[_md5StoreKey] as String?) ?? '';

    if (storedMd5 == assetMd5 && destDir.existsSync()) {
      debugPrint('[Beauty] Resources up to date, skipping.');
      return destDir.path;
    }

    debugPrint('[Beauty] Extracting (stored=$storedMd5, asset=$assetMd5)…');
    if (destDir.existsSync()) await destDir.delete(recursive: true);

    final data = await rootBundle.load(_zipAssetKey);
    final archive = ZipDecoder().decodeBytes(data.buffer.asUint8List());
    for (final file in archive) {
      if (!file.isFile) continue;
      final outFile = File('${appSupport.path}/$_bundleDirName/${file.name}');
      await outFile.parent.create(recursive: true);
      await outFile.writeAsBytes(file.content as List<int>);
    }

    prefs[_md5StoreKey] = assetMd5;
    await _savePrefs(prefs);
    debugPrint('[Beauty] Extraction complete.');
    return destDir.path;
  }

  Future<File> get _prefsFile async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/.beauty_prefs.json');
  }

  Future<Map<String, dynamic>> _loadPrefs() async {
    try {
      final f = await _prefsFile;
      if (f.existsSync()) {
        return jsonDecode(await f.readAsString()) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {_md5StoreKey: ''};
  }

  Future<void> _savePrefs(Map<String, dynamic> prefs) async {
    final f = await _prefsFile;
    await f.writeAsString(jsonEncode(prefs));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _loading
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Preparing beauty resource pack...'),
                ],
              )
            : ElevatedButton.icon(
                onPressed: _onStartPreview,
                icon: const Icon(Icons.play_circle_outline),
                label: const Text(
                  'Start Camera',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                ),
              ),
      ),
    );
  }
}

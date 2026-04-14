// example_page.dart
//
// Layout:
//   - Full-screen AgoraVideoView (local preview)
//   - StatsMonitoringWidget overlay (bottom-left)
//   - BeautyControlBar pinned to right center
//   - ShengwangBeautyView panel slides in from bottom

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import '../agora.config.dart' as config;
import '../BeautyView/shengwang_beauty_view.dart';
import '../BeautyView/shengwang_beauty_sdk.dart';
import '../BeautyView/builders/beauty_page_builder.dart';
import '../BeautyView/models/beauty_page_info.dart';
import '../Utils/beauty_localizer.dart';
import 'beauty_control_bar.dart';

class ExamplePage extends StatefulWidget {
  /// Concrete [BeautyConfig] implementation wired to the SDK.
  /// Defaults to [ShengwangBeautySDK.instance.beautyConfig] if not provided.
  final BeautyConfig? beautyConfig;

  /// Path to extracted AgoraBeautyMaterial.bundle in sandbox.
  final String materialBundlePath;

  /// Use Chinese labels in the beauty panel.
  final String lang;

  const ExamplePage({
    Key? key,
    this.beautyConfig,
    required this.materialBundlePath,
    this.lang = 'en',
  }) : super(key: key);

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  // ── RTC ──────────────────────────────────────────────────────────────────
  late final RtcEngine _engine;
  late final RtcEngineEventHandler _rtcEngineEventHandler;

  bool _isJoined = false;
  bool _isCameraOpen = true;
  bool _isFrontCamera = true;
  Set<int> _remoteUids = {};

  // ── UI ───────────────────────────────────────────────────────────────────
  bool _beautyPanelVisible = false;
  bool _disposed = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  BeautyConfig get _beautyConfig =>
      widget.beautyConfig ?? ShengwangBeautySDK.instance.beautyConfig;

  @override
  void initState() {
    super.initState();
    BeautyLocalizer.setLang(widget.lang);
    _initEngine();
  }

  @override
  void dispose() {
    _disposeEngine();
    super.dispose();
  }

  // ── Engine ────────────────────────────────────────────────────────────────

  Future<void> _initEngine() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: config.appId));

    _rtcEngineEventHandler = RtcEngineEventHandler(
      onError: (ErrorCodeType err, String msg) {
        debugPrint('[onError] err: $err, msg: $msg');
      },
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        debugPrint('[onJoinChannelSuccess] ${connection.toJson()}');
        setState(() => _isJoined = true);
      },
      onUserJoined: (RtcConnection connection, int rUid, int elapsed) {
        debugPrint('[onUserJoined] remoteUid: $rUid');
        setState(() => _remoteUids.add(rUid));
      },
      onUserOffline: (RtcConnection connection, int rUid,
          UserOfflineReasonType reason) {
        debugPrint('[onUserOffline] remoteUid: $rUid');
        setState(() => _remoteUids.remove(rUid));
      },
      onLeaveChannel: (RtcConnection connection, RtcStats stats) {
        debugPrint('[onLeaveChannel] ${connection.toJson()}');
        setState(() {
          _isJoined = false;
          _remoteUids.clear();
        });
      },
      onExtensionErrorWithContext: (ExtensionContext context, int error, String message) {
        debugPrint(
            '[onExtensionErrored] provider: ${context.providerName}, extName: ${context.extensionName}, error: $error, message: $message');
      },
      onExtensionStartedWithContext: (ExtensionContext context) {
        debugPrint(
            '[onExtensionStarted] provider: ${context.providerName}, extName: ${context.extensionName}');
      },
      onExtensionEventWithContext: (ExtensionContext context, String key, String value) {
        debugPrint(
            '[onExtensionEvent] provider: ${context.providerName}, extName: ${context.extensionName}');
      },
      onExtensionStoppedWithContext: (ExtensionContext context) {
        debugPrint(
            '[onExtensionStopped] provider: ${context.providerName}, extName: ${context.extensionName}');
      },
    );

    _engine.registerEventHandler(_rtcEngineEventHandler);
    await _engine.enableVideo();
    await _engine.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 960, height: 540),
        frameRate: 30,
        bitrate: 0,
      ),
    );
    await _engine.startPreview();

    // Initialize beauty SDK
    await ShengwangBeautySDK.instance.initBeautySDK(
      rtcEngine: _engine,
      materialBundlePath: widget.materialBundlePath,
    );
  }

  Future<void> _disposeEngine() async {
    if (_disposed) return;
    _disposed = true;
    await ShengwangBeautySDK.instance.unInitBeautySDK();
    _engine.unregisterEventHandler(_rtcEngineEventHandler);
    await _engine.leaveChannel();
    await _engine.release();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _joinChannel() async {
    await _engine.joinChannel(
      token: config.token,
      channelId: config.channelId,
      uid: config.uid,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );

    await ShengwangBeautySDK.instance.enable(true);
  }

  Future<void> _leaveChannel() async {
    await ShengwangBeautySDK.instance.enable(false);
    await _engine.leaveChannel();
  }

  Future<void> _switchCamera() async {
    await _engine.switchCamera();
    setState(() => _isFrontCamera = !_isFrontCamera);
  }

  Future<void> _toggleCamera() async {
    await _engine.enableLocalVideo(!_isCameraOpen);
    setState(() => _isCameraOpen = !_isCameraOpen);
  }

  void _toggleBeautyPanel() {
    setState(() => _beautyPanelVisible = !_beautyPanelVisible);
  }

  void _saveBeauty() {
    _beautyConfig.saveBeauty(BeautyModule.beauty);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(beautyLocalized('beauty_setting_saved_info')),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _resetBeauty() {
    _beautyConfig.resetBeauty(BeautyModule.beauty);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(beautyLocalized('beauty_setting_reseted_info')),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Local video preview (full screen)
          Positioned.fill(
            child: AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: _engine,
                canvas: const VideoCanvas(uid: 0),
              ),
              onAgoraVideoViewCreated: (_) => _engine.startPreview(),
            ),
          ),

          // 2. Back button — top-left
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: GestureDetector(
              onTap: () async {
                await _disposeEngine();
                if (mounted) Navigator.of(context).pop();
              },
              behavior: HitTestBehavior.opaque,
              child: Image.asset(
                'assets/Icons/ic_back.png',
                width: 24,
                height: 24,
                color: Colors.white,
              ),
            ),
          ),

          // 3. Right-side control bar — vertically centered
          BeautyControlBar(
            onBeautyTap: _toggleBeautyPanel,
            onSwitchCamera: _switchCamera,
            onSave: _saveBeauty,
            onReset: _resetBeauty,
            onJoinLeave: _isJoined ? _leaveChannel : _joinChannel,
            isJoined: _isJoined,
          ),

          // 4. Beauty panel — slides in from bottom
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            left: 0,
            right: 0,
            bottom: _beautyPanelVisible ? 0 : -280,
            child: ShengwangBeautyView(
              beautyConfig: _beautyConfig,
            ),
          ),

          // 5. Tap-outside overlay to dismiss beauty panel
          if (_beautyPanelVisible)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 215, // leave the panel itself tappable
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleBeautyPanel,
              ),
            ),
        ],
      ),
    );
  }
}
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class VoiceRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  Timer? _durationTimer;
  Duration _currentDuration = Duration.zero;

  final ValueNotifier<bool> isRecording = ValueNotifier(false);
  final ValueNotifier<Duration> recordingDuration =
      ValueNotifier(Duration.zero);

  String? _currentPath;

  // microphone permission
  Future<bool> _requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  
  Future<bool> startRecording() async {
    final hasPermission = await _requestPermission();
    if (!hasPermission) return false;

    try {
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentPath = '${dir.path}/voice_$timestamp.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentPath!,
      );

      _currentDuration = Duration.zero;
      recordingDuration.value = Duration.zero;
      isRecording.value = true;

      
      _durationTimer = Timer.periodic(
        const Duration(milliseconds: 100),
        (_) {
          _currentDuration += const Duration(milliseconds: 100);
          recordingDuration.value = _currentDuration;
        },
      );

      return true;
    } catch (e) {
      debugPrint('Recording error: $e');
      return false;
    }
  }

  
  Future<String?> stopRecording() async {
    _durationTimer?.cancel();
    _durationTimer = null;

    try {
      final path = await _recorder.stop();
      isRecording.value = false;
      recordingDuration.value = Duration.zero;
      return path;
    } catch (e) {
      debugPrint('Stop recording error: $e');
      isRecording.value = false;
      return null;
    }
  }

  
  Future<void> cancelRecording() async {
    _durationTimer?.cancel();
    _durationTimer = null;

    try {
      await _recorder.stop();
    } catch (_) {}

    isRecording.value = false;
    recordingDuration.value = Duration.zero;
    _currentPath = null;
  }

  void dispose() {
    _durationTimer?.cancel();
    isRecording.dispose();
    recordingDuration.dispose();
    _recorder.dispose();
  }
}

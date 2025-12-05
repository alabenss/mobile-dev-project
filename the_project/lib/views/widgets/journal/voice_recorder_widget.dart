import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../themes/style_simple/colors.dart';

class VoiceRecorderWidget extends StatefulWidget {
  final Function(String audioPath) onRecordingComplete;

  const VoiceRecorderWidget({
    super.key,
    required this.onRecordingComplete,
  });

  @override
  State<VoiceRecorderWidget> createState() => _VoiceRecorderWidgetState();
}

class _VoiceRecorderWidgetState extends State<VoiceRecorderWidget> {
final AudioRecorder _audioRecorder = AudioRecorder();

  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordedFilePath;
  int _recordDuration = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      // Request microphone permission
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        _showError('Microphone permission denied');
        return;
      }

      // Get app directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // Start recording
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );

      setState(() {
        _isRecording = true;
        _recordDuration = 0;
      });

      // Start timer
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordDuration++;
        });
      });
    } catch (e) {
      _showError('Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _timer?.cancel();

      setState(() {
        _isRecording = false;
        _recordedFilePath = path;
      });
    } catch (e) {
      _showError('Failed to stop recording: $e');
    }
  }

  Future<void> _playRecording() async {
    if (_recordedFilePath == null) return;

    try {
      await _audioPlayer.play(DeviceFileSource(_recordedFilePath!));
      setState(() => _isPlaying = true);

      _audioPlayer.onPlayerComplete.listen((event) {
        setState(() => _isPlaying = false);
      });
    } catch (e) {
      _showError('Failed to play recording: $e');
    }
  }

  Future<void> _stopPlaying() async {
    await _audioPlayer.stop();
    setState(() => _isPlaying = false);
  }

  void _saveRecording() {
    if (_recordedFilePath != null) {
      widget.onRecordingComplete(_recordedFilePath!);
      Navigator.pop(context);
    }
  }

  void _deleteRecording() {
    setState(() {
      _recordedFilePath = null;
      _recordDuration = 0;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Voice Note',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Recording indicator
                  if (_isRecording)
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.error.withOpacity(0.1),
                        border: Border.all(
                          color: AppColors.error,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.mic,
                          size: 60,
                          color: AppColors.error,
                        ),
                      ),
                    )
                  else if (_recordedFilePath != null)
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentGreen.withOpacity(0.1),
                        border: Border.all(
                          color: AppColors.accentGreen,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check_circle,
                          size: 60,
                          color: AppColors.accentGreen,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.icon.withOpacity(0.1),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.mic_none,
                          size: 60,
                          color: AppColors.icon,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Timer
                  Text(
                    _formatDuration(_recordDuration),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Status text
                  Text(
                    _isRecording
                        ? 'Recording...'
                        : _recordedFilePath != null
                            ? 'Recording saved'
                            : 'Tap to start recording',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Control buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Delete button (if recorded)
                      if (_recordedFilePath != null && !_isRecording)
                        IconButton(
                          onPressed: _deleteRecording,
                          icon: const Icon(Icons.delete),
                          iconSize: 32,
                          color: AppColors.error,
                        ),

                      const SizedBox(width: 24),

                      // Main button (record/stop)
                      GestureDetector(
                        onTap: _isRecording ? _stopRecording : _startRecording,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isRecording
                                ? AppColors.error
                                : AppColors.icon,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            size: 40,
                            color: AppColors.card,
                          ),
                        ),
                      ),

                      const SizedBox(width: 24),

                      // Play/Pause button (if recorded)
                      if (_recordedFilePath != null && !_isRecording)
                        IconButton(
                          onPressed:
                              _isPlaying ? _stopPlaying : _playRecording,
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                          ),
                          iconSize: 32,
                          color: AppColors.accentBlue,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Save button
          if (_recordedFilePath != null && !_isRecording)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveRecording,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.icon,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Add Voice Note',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.card,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
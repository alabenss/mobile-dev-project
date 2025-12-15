import 'dart:async';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:the_project/l10n/app_localizations.dart';

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

  Future<void> _startRecording(AppLocalizations l10n) async {
    try {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        _showError(l10n.journalVoicePermissionDenied);
        return;
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';

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

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordDuration++;
        });
      });
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      _showError(l10n.journalVoiceStartFailed( e.toString()));
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
      final l10n = AppLocalizations.of(context)!;
      _showError(l10n.journalVoiceStopFailed( e.toString()));
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
      final l10n = AppLocalizations.of(context)!;
      _showError(l10n.journalVoicePlayFailed( e.toString()));
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
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.journalVoiceNote,
                    style: const TextStyle(
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

            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      if (_isRecording)
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.error.withOpacity(0.1),
                            border: Border.all(
                              color: AppColors.error,
                              width: 3,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.mic,
                              size: 50,
                              color: AppColors.error,
                            ),
                          ),
                        )
                      else if (_recordedFilePath != null)
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accentGreen.withOpacity(0.1),
                            border: Border.all(
                              color: AppColors.accentGreen,
                              width: 3,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check_circle,
                              size: 50,
                              color: AppColors.accentGreen,
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.icon.withOpacity(0.1),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.mic_none,
                              size: 50,
                              color: AppColors.icon,
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      Text(
                        _formatDuration(_recordDuration),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        _isRecording
                            ? l10n.journalVoiceRecording
                            : _recordedFilePath != null
                                ? l10n.journalVoiceSaved
                                : l10n.journalVoiceTapToStart,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 25),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_recordedFilePath != null && !_isRecording)
                            IconButton(
                              onPressed: _deleteRecording,
                              icon: const Icon(Icons.delete),
                              iconSize: 25,
                              color: AppColors.error,
                            ),

                          const SizedBox(width: 20),

                          GestureDetector(
                            onTap: _isRecording ? _stopRecording : () => _startRecording(l10n),
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

                          const SizedBox(width: 20),

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

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            if (_recordedFilePath != null && !_isRecording)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
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
                    child: Text(
                      l10n.journalVoiceAddNote,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.card,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
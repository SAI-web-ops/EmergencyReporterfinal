import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../repositories/upload_repository.dart';

class MediaCaptureWidget extends StatefulWidget {
  final ValueChanged<List<String>> onMediaCaptured;

  const MediaCaptureWidget({
    super.key,
    required this.onMediaCaptured,
  });

  @override
  State<MediaCaptureWidget> createState() => _MediaCaptureWidgetState();
}

class _MediaCaptureWidgetState extends State<MediaCaptureWidget> {
  List<String> _mediaUrls = [];
  bool _uploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Card
(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.camera_alt,
                  color: Colors.blue[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Capture Media Evidence',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_uploading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Media Grid
            if (_mediaUrls.isEmpty)
              Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey[300]!,
                    style: BorderStyle.solid,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 32,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No media captured',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _mediaUrls.length + 1,
                itemBuilder: (context, index) {
                  if (index == _mediaUrls.length) {
                    return _buildAddButton();
                  }
                  return _buildMediaItem(_mediaUrls[index], index);
                },
              ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _uploading ? null : _capturePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Photo'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _uploading ? null : _captureVideo,
                    icon: const Icon(Icons.videocam),
                    label: const Text('Video'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _uploading ? null : _selectFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _uploading ? null : _showMediaOptions,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[300]!,
            style: BorderStyle.solid,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(
            Icons.add,
            color: Colors.grey[600],
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildMediaItem(String url, int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(url),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeMedia(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showMediaOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _capturePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Record Video'),
              onTap: () {
                Navigator.pop(context);
                _captureVideo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _selectFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _capturePhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (picked == null) return;
    await _uploadAndAdd(File(picked.path));
  }

  Future<void> _captureVideo() async {
    final picked = await _picker.pickVideo(source: ImageSource.camera, maxDuration: const Duration(minutes: 5));
    if (picked == null) return;
    await _uploadAndAdd(File(picked.path));
  }

  Future<void> _selectFromGallery() async {
    final picked = await _picker.pickMultiImage(imageQuality: 85);
    if (picked.isEmpty) return;
    for (final x in picked) {
      await _uploadAndAdd(File(x.path));
    }
  }

  Future<void> _uploadAndAdd(File file) async {
    try {
      setState(() { _uploading = true; });
      final repo = context.read<UploadRepository>();
      final url = await repo.uploadFile(file);
      setState(() {
        _mediaUrls.add(url);
      });
      widget.onMediaCaptured(_mediaUrls);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Media uploaded')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() { _uploading = false; });
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _mediaUrls.removeAt(index);
    });
    widget.onMediaCaptured(_mediaUrls);
  }
}

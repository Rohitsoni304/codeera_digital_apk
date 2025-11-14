import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import 'File_uploadScreen.dart';
import 'Todayvideodetails.dart';

class TodayVideosGalleryScreen extends StatefulWidget {
  const TodayVideosGalleryScreen({super.key});

  @override
  State<TodayVideosGalleryScreen> createState() =>
      _TodayVideosGalleryScreenState();
}

class _TodayVideosGalleryScreenState extends State<TodayVideosGalleryScreen> {
  // -----------------------------------------------------------------
  //  API & UI state
  // -----------------------------------------------------------------
  List<dynamic> tasks = [];
  bool isLoading = true;
  String? errorMessage;

  final String _baseUrl = "https://codeeratech.in/uploads/tasks/";

  // -----------------------------------------------------------------
  //  API call
  // -----------------------------------------------------------------
  Future<void> _fetchVideos() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) {
      setState(() {
        errorMessage = "Auth token missing";
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("https://codeeratech.in/api/user/tasks?type=video"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          tasks = data['tasks'] ?? [];
          isLoading = false;
        });
        print(data);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loaded ${tasks.length} video(s)'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          errorMessage = data["message"] ?? "Failed to load videos";
          isLoading = false;
        });
        _showSnack(data["message"] ?? "Something went wrong");
      }
    } catch (e) {
      setState(() {
        errorMessage = "Network error: $e";
        isLoading = false;
      });
      _showSnack("Network error: $e");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // -----------------------------------------------------------------
  //  Lifecycle
  // -----------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  // -----------------------------------------------------------------
  //  Helpers – status
  // -----------------------------------------------------------------
  String _statusText(int status) {
    switch (status) {
      case 0:
        return "Pending";
      case 5:
        return "Completed";
      default:
        return "Unknown";
    }
  }

  Color _statusColor(int status) {
    switch (status) {
      case 0:
        return Colors.orange.shade700;
      case 5:
        return Colors.green.shade600;
      default:
        return Colors.grey;
    }
  }

  // -----------------------------------------------------------------
  //  UI
  // -----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              const Center(
                child: Text(
                  "Videos",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ------------------- Loading / Error / Empty -------------------
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                    ? _buildErrorWidget()
                    : tasks.isEmpty
                    ? const Center(
                  child: Text(
                    "No videos available",
                    style: TextStyle(
                        fontSize: 18, color: Colors.grey),
                  ),
                )
                    : _buildGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------
  //  Error UI (with retry)
  // -----------------------------------------------------------------
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              size: 60, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style:
            TextStyle(fontSize: 16, color: Colors.red.shade700),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchVideos,
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------
  //  Grid of video thumbnails
  // -----------------------------------------------------------------
  Widget _buildGrid() {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.51,
      ),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        print(task['file_path']);
        print(task['file_path']);
        final videoUrl = task['file_path'] != null
            ? _baseUrl + task['file_path']
            : null;

        return _videoThumbnail(
          videoUrl: videoUrl,
          title: task['title'] ?? "Untitled",
          status: task['status'] ?? 0,
          id:task['id'] ?? 0,
        );
      },
    );
  }

  // -----------------------------------------------------------------
  //  Single thumbnail + title + status badge
  // -----------------------------------------------------------------
  Widget _videoThumbnail({
    required String? videoUrl,
    required String title,
    required int status,
    required int id,
  }) {
    return GestureDetector(
      onTap:(){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoDetails(postvideo: videoUrl.toString(),id: id.toString(),name: title,),
          ),
        );
      },
      //videoUrl == null ? null : () => _openVideoPlayer(context, videoUrl),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // --- Video Thumbnail ---
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Placeholder
                    if (videoUrl == null)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.grey.shade200,
                              Colors.grey.shade300,
                            ],
                          ),
                        ),
                        child: Icon(
                          Icons.videocam_off_rounded,
                          color: Colors.grey.shade500,
                          size: 40,
                        ),
                      )
                    else
                      _VideoThumbnailPlayer(url: videoUrl),

                    // Dark overlay + Play Button
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.35),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),

                    Center(
                      child: Icon(
                        Icons.play_circle_fill_rounded,
                        size: 48,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 10),

            // --- Video Title ---
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: Colors.black87,
              ),
            ),

            SizedBox(height: 8),

            // --- Status Badge ---
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(status),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _statusText(status),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SizedBox(height: 10),

            // --- Update Status Button ---
            if (status == 0)
              InkWell(
                onTap: () {

                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      "Update Status",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
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


  // -----------------------------------------------------------------
  //  Open full-screen player (Chewie)
  // -----------------------------------------------------------------
  Future<void> _openVideoPlayer(BuildContext ctx, String url) async {
    final videoPlayerController = VideoPlayerController.network(url);
    await videoPlayerController.initialize();

    final chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      showControlsOnInitialize: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Theme.of(ctx).primaryColor,
        handleColor: Theme.of(ctx).primaryColor,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.grey.shade400,
      ),
    );

    if (!ctx.mounted) return;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (_) => SafeArea(
        child: Stack(
          children: [
            Center(
              child: Chewie(controller: chewieController),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      chewieController.dispose();
      videoPlayerController.dispose();
    });
  }
}

// ---------------------------------------------------------------------
//  Small widget that extracts the **first frame** of a video for thumbnail
// ---------------------------------------------------------------------
class _VideoThumbnailPlayer extends StatefulWidget {
  final String url;
  const _VideoThumbnailPlayer({required this.url});

  @override
  State<_VideoThumbnailPlayer> createState() => _VideoThumbnailPlayerState();
}

class _VideoThumbnailPlayerState extends State<_VideoThumbnailPlayer> {
  late VideoPlayerController _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        if (mounted) setState(() {});
        _controller.setVolume(0);
        _controller.pause();
      }).catchError((e) {
        if (mounted) setState(() => _hasError = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image,
            color: Colors.grey, size: 30),
      );
    }

    return _controller.value.isInitialized
        ? FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: _controller.value.size.width,
        height: _controller.value.size.height,
        child: VideoPlayer(_controller),
      ),
    )
        : Container(
      color: Colors.grey.shade200,
      child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}
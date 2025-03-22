import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:resilify/core/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class SleepAidPlayer extends StatefulWidget {
  const SleepAidPlayer({super.key});

  @override
  _SleepAidPlayerState createState() => _SleepAidPlayerState();
}

class _SleepAidPlayerState extends State<SleepAidPlayer> {
  final String clientId = '4bdf70e57eec47cb9d2037dc49c9435b';
  final String clientSecret = '899f97fe5aad4863be3e63e146bd1d36';

  List<Map<String, dynamic>> sleepPlaylists = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchSleepPlaylists();
  }

  Future<String> getAccessToken() async {
    try {
      final response = await http.post(
        Uri.parse('https://accounts.spotify.com/api/token'),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'client_credentials',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['access_token'] != null) {
          return data['access_token'];
        } else {
          throw Exception('Access token not found in response');
        }
      } else {
        throw Exception('Failed to get access token: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting access token: $e');
      throw Exception('Failed to get access token: $e');
    }
  }

  Future<void> fetchSleepPlaylists() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final token = await getAccessToken();

      final playlistsResponse = await http.get(
        Uri.parse('https://api.spotify.com/v1/browse/categories/sleep/playlists?limit=20'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (playlistsResponse.statusCode != 200) {
        throw Exception('Failed to fetch playlists: ${playlistsResponse.statusCode}');
      }

      final data = json.decode(playlistsResponse.body);
      if (data == null || !data.containsKey('playlists')) {
        throw Exception('Invalid response format');
      }

      final playlists = data['playlists']['items'] as List;

      final processedPlaylists = playlists.map((item) {
        String imageUrl = '';
        if (item['images'] != null && item['images'].isNotEmpty) {
          imageUrl = item['images'][0]['url'] ?? '';
        }

        return {
          'name': item['name'] ?? 'Unknown Playlist',
          'description': item['description'] ?? 'No description available',
          'image': imageUrl,
          'external_url': item['external_urls']?['spotify'] ?? '',
          'duration': '45 MIN', // Default duration
        };
      }).toList();

      setState(() {
        sleepPlaylists = List<Map<String, dynamic>>.from(processedPlaylists);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching playlists: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> openSpotify(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch Spotify';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open Spotify: $e')),
      );
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 120,
      width: 120,
      color: AppColors.primaryColor.withOpacity(0.2),
      child: Icon(
        Icons.music_note,
        color: AppColors.primaryColor,
        size: 40,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.primaryTextColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Sleep Music',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryTextColor,
                    ),
                  ),
                ],
              ),
            ),

            if (isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                ),
              )
            else if (error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Failed to load playlists',
                        style: TextStyle(
                          color: AppColors.primaryTextColor,
                          fontSize: 18,
                        ),
                      ),
                      TextButton(
                        onPressed: fetchSleepPlaylists,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: sleepPlaylists.length,
                  itemBuilder: (context, index) {
                    final playlist = sleepPlaylists[index];
                    return GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (context) => PlaylistDetailsSheet(
                            playlist: playlist,
                            onPlay: () => openSpotify(playlist['external_url']),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: playlist['image']?.isNotEmpty == true
                                  ? Image.network(
                                playlist['image']!,
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                              )
                                  : _buildPlaceholderImage(),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    playlist['name'] ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryTextColor,
                                    ),
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Sleep Music • ${playlist['duration']}',
                                    style: TextStyle(
                                      color: AppColors.primaryTextColor.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PlaylistDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> playlist;
  final VoidCallback onPlay;

  const PlaylistDetailsSheet({
    super.key,
    required this.playlist,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: playlist['image']?.isNotEmpty == true
                      ? Image.network(
                    playlist['image']!,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      width: 200,
                      color: AppColors.primaryColor.withOpacity(0.2),
                      child: Icon(
                        Icons.music_note,
                        color: AppColors.primaryColor,
                        size: 60,
                      ),
                    ),
                  )
                      : Container(
                    height: 200,
                    width: 200,
                    color: AppColors.primaryColor.withOpacity(0.2),
                    child: Icon(
                      Icons.music_note,
                      color: AppColors.primaryColor,
                      size: 60,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  playlist['name'] ?? '',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  playlist['description'] ?? '',
                  style: TextStyle(
                    color: AppColors.primaryTextColor.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onPlay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Open in Spotify',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
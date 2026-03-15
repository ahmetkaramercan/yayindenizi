import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';

class RehberlikVideo {
  final String id;
  final String title;
  final String thumbnailUrl;
  final Duration duration;

  const RehberlikVideo({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.duration,
  });

  String get youtubeUrl => 'https://www.youtube.com/shorts/$id';
}

class RehberlikState {
  final List<RehberlikVideo> videos;
  final bool isLoading;
  final String? error;

  RehberlikState({
    this.videos = const [],
    this.isLoading = false,
    this.error,
  });

  RehberlikState copyWith({
    List<RehberlikVideo>? videos,
    bool? isLoading,
    String? error,
  }) {
    return RehberlikState(
      videos: videos ?? this.videos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class RehberlikNotifier extends StateNotifier<RehberlikState> {
  RehberlikNotifier() : super(RehberlikState()) {
    loadVideos();
  }

  Future<void> loadVideos() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await sl<ApiClient>().get('/youtube/shorts');
      final list = (data as List<dynamic>).cast<Map<String, dynamic>>();

      final videos = list.map((item) {
        return RehberlikVideo(
          id: item['id'] as String,
          title: item['title'] as String,
          thumbnailUrl: item['thumbnailUrl'] as String,
          duration:
              Duration(seconds: (item['durationSeconds'] as num).toInt()),
        );
      }).toList();

      state = state.copyWith(videos: videos, isLoading: false);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error:
            'Videolar yüklenirken hata oluştu.\nLütfen internet bağlantınızı kontrol edin.',
      );
    }
  }
}

final rehberlikProvider =
    StateNotifierProvider<RehberlikNotifier, RehberlikState>((ref) {
  return RehberlikNotifier();
});

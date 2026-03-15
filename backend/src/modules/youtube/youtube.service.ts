import { Injectable } from '@nestjs/common';

export interface YouTubeShortDto {
  id: string;
  title: string;
  thumbnailUrl: string;
  durationSeconds: number;
}

interface CachedData {
  videos: YouTubeShortDto[];
  fetchedAt: number;
}

@Injectable()
export class YoutubeService {
  private cache: CachedData | null = null;
  private readonly CACHE_DURATION_MS = 30 * 60 * 1000; // 30 dakika
  private readonly CHANNEL_HANDLE = 'kazimtanerresmi';
  private readonly MAX_RESULTS = 25;

  async getShorts(): Promise<YouTubeShortDto[]> {
    if (
      this.cache &&
      Date.now() - this.cache.fetchedAt < this.CACHE_DURATION_MS
    ) {
      return this.cache.videos;
    }

    const apiKey = process.env.YOUTUBE_API_KEY;
    if (!apiKey) return [];

    try {
      const channelId = await this.fetchChannelId(apiKey);
      if (!channelId) return [];

      const items = await this.fetchShortItems(apiKey, channelId);
      if (items.length === 0) return [];

      const videoIds = items.map((i: any) => i.id.videoId).join(',');
      const durationMap = await this.fetchDurations(apiKey, videoIds);

      const videos: YouTubeShortDto[] = items.map((item: any) => ({
        id: item.id.videoId,
        title: item.snippet.title,
        thumbnailUrl:
          item.snippet.thumbnails.high?.url ??
          item.snippet.thumbnails.medium?.url ??
          item.snippet.thumbnails.default?.url ??
          '',
        durationSeconds: durationMap.get(item.id.videoId) ?? 0,
      }));

      this.cache = { videos, fetchedAt: Date.now() };
      return videos;
    } catch {
      return this.cache?.videos ?? [];
    }
  }

  private async fetchChannelId(apiKey: string): Promise<string | null> {
    const url = `https://www.googleapis.com/youtube/v3/channels?forHandle=${this.CHANNEL_HANDLE}&part=id&key=${apiKey}`;
    const res = await fetch(url);
    const data = (await res.json()) as any;
    return data.items?.[0]?.id ?? null;
  }

  private async fetchShortItems(
    apiKey: string,
    channelId: string,
  ): Promise<any[]> {
    const url = `https://www.googleapis.com/youtube/v3/search?channelId=${channelId}&type=video&videoDuration=short&maxResults=${this.MAX_RESULTS}&order=date&part=snippet&key=${apiKey}`;
    const res = await fetch(url);
    const data = (await res.json()) as any;
    return data.items ?? [];
  }

  private async fetchDurations(
    apiKey: string,
    videoIds: string,
  ): Promise<Map<string, number>> {
    const url = `https://www.googleapis.com/youtube/v3/videos?id=${videoIds}&part=contentDetails&key=${apiKey}`;
    const res = await fetch(url);
    const data = (await res.json()) as any;

    const map = new Map<string, number>();
    for (const video of data.items ?? []) {
      map.set(video.id, this.parseIsoDuration(video.contentDetails.duration));
    }
    return map;
  }

  private parseIsoDuration(iso: string): number {
    const match = iso.match(/PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?/);
    if (!match) return 0;
    const h = parseInt(match[1] ?? '0', 10);
    const m = parseInt(match[2] ?? '0', 10);
    const s = parseInt(match[3] ?? '0', 10);
    return h * 3600 + m * 60 + s;
  }
}

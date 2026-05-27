import { Injectable } from '@nestjs/common';

type Artwork = {
  id: string;
  userId: string;
  title: string;
  description?: string;
  imageUrl: string;
  sourceType: string;
  isPublic: boolean;
  createdAt: string;
};

@Injectable()
export class CommunityService {
  private artworks: Artwork[] = [];

  /** Tạo bản ghi tác phẩm sau khi có đường dẫn ảnh. */
  createArtwork(body: {
    title: string;
    description?: string;
    imageUrl: string;
    sourceType?: string;
    isPublic?: boolean;
  }) {
    const artwork: Artwork = {
      id: `artwork-${Date.now()}`,
      userId: 'user-1',
      title: body.title,
      description: body.description,
      imageUrl: body.imageUrl,
      sourceType: body.sourceType ?? 'draw',
      isPublic: body.isPublic ?? true,
      createdAt: new Date().toISOString(),
    };

    this.artworks.unshift(artwork);

    return artwork;
  }

  /** Lấy danh sách tác phẩm đã tạo. */
  findArtworks() {
    return this.artworks;
  }
}
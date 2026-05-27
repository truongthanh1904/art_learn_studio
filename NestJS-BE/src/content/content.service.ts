import { Injectable } from '@nestjs/common';

type TutorialStep = {
  id: string;
  stepOrder: number;
  title: string;
  content: string;
  imageUrl?: string;
};

type TutorialMaterial = {
  id: string;
  name: string;
  quantity?: string;
  note?: string;
};

type TutorialReview = {
  id: string;
  tutorialId: string;
  userId: string;
  userName: string;
  rating: number;
  comment?: string;
  createdAt: string;
};

type Tutorial = {
  id: string;
  title: string;
  category: string;
  description: string;
  thumbnailUrl?: string;
  difficultyLevel: string;
  createdBy: string;
  createdAt: string;
  updatedAt: string;
  authorName: string;
  authorUsername: string;
  authorAvatarUrl: string;
  stepCount: number;
  steps: TutorialStep[];
  materials: TutorialMaterial[];
  reviewCount: number;
  averageRating: number;
  isSaved: boolean;
};

@Injectable()
export class ContentService {
  private tutorials: Tutorial[] = [
    {
      id: 'tutorial-1',
      title: 'Vẽ bông hoa đơn giản',
      category: 'Vẽ',
      description:
        'Bài hướng dẫn giúp người mới bắt đầu luyện nét cong, bố cục cánh hoa và phối màu cơ bản.',
      difficultyLevel: 'Dễ',
      createdBy: 'user-1',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      authorName: 'Art Learn',
      authorUsername: 'artlearn',
      authorAvatarUrl: '',
      stepCount: 5,
      steps: [
        {
          id: 'step-1',
          stepOrder: 1,
          title: 'Vẽ nhụy hoa',
          content: 'Vẽ một hình tròn nhỏ ở giữa làm nhụy hoa.',
        },
        {
          id: 'step-2',
          stepOrder: 2,
          title: 'Vẽ cánh hoa',
          content: 'Dùng các nét cong để vẽ cánh hoa xung quanh nhụy.',
        },
        {
          id: 'step-3',
          stepOrder: 3,
          title: 'Vẽ thân và lá',
          content: 'Thêm thân hoa và hai chiếc lá đơn giản.',
        },
        {
          id: 'step-4',
          stepOrder: 4,
          title: 'Tô màu',
          content: 'Tô màu cho nhụy, cánh hoa và lá.',
        },
        {
          id: 'step-5',
          stepOrder: 5,
          title: 'Hoàn thiện',
          content: 'Điều chỉnh lại đường viền và thêm bóng nhẹ.',
        },
      ],
      materials: [
        { id: 'material-1', name: 'Canvas số hoặc giấy vẽ' },
        { id: 'material-2', name: 'Bút vẽ' },
        { id: 'material-3', name: 'Màu hồng, vàng, xanh lá' },
      ],
      reviewCount: 0,
      averageRating: 0,
      isSaved: false,
    },
    {
      id: 'tutorial-2',
      title: 'Vẽ chú mèo dễ thương',
      category: 'Vẽ',
      description:
        'Bài học hướng dẫn phác thảo nhân vật mèo theo phong cách đơn giản.',
      difficultyLevel: 'Trung bình',
      createdBy: 'user-1',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      authorName: 'Art Learn',
      authorUsername: 'artlearn',
      authorAvatarUrl: '',
      stepCount: 5,
      steps: [
        {
          id: 'step-6',
          stepOrder: 1,
          title: 'Phác đầu mèo',
          content: 'Vẽ hình tròn làm đầu mèo.',
        },
        {
          id: 'step-7',
          stepOrder: 2,
          title: 'Thêm tai',
          content: 'Vẽ hai tai tam giác ở phía trên đầu.',
        },
        {
          id: 'step-8',
          stepOrder: 3,
          title: 'Vẽ mặt',
          content: 'Thêm mắt, mũi, miệng và râu.',
        },
        {
          id: 'step-9',
          stepOrder: 4,
          title: 'Vẽ thân',
          content: 'Vẽ thân mèo bằng hình oval.',
        },
        {
          id: 'step-10',
          stepOrder: 5,
          title: 'Tô màu',
          content: 'Tô màu và thêm bóng nhẹ.',
        },
      ],
      materials: [
        { id: 'material-4', name: 'Canvas số' },
        { id: 'material-5', name: 'Bút nét mảnh' },
        { id: 'material-6', name: 'Màu xám, hồng, đen' },
      ],
      reviewCount: 0,
      averageRating: 0,
      isSaved: false,
    },
  ];

  private reviews: TutorialReview[] = [];
  private favoriteTutorialIds = new Set<string>();

  /** Lấy danh sách bài hướng dẫn, có hỗ trợ tìm kiếm và lọc danh mục. */
  findTutorials(query?: string, category?: string) {
    let result = [...this.tutorials];

    if (query && query.trim()) {
      const keyword = query.trim().toLowerCase();

      result = result.filter(
        (item) =>
          item.title.toLowerCase().includes(keyword) ||
          item.description.toLowerCase().includes(keyword) ||
          item.category.toLowerCase().includes(keyword),
      );
    }

    if (category && category.trim() && category !== 'Tất cả') {
      result = result.filter((item) => item.category === category);
    }

    return result.map((tutorial) => this.attachAggregates(tutorial));
  }

  /** Lấy chi tiết bài hướng dẫn theo mã bài học. */
  findTutorialDetail(id: string) {
    const tutorial = this.tutorials.find((item) => item.id === id);

    if (!tutorial) {
      return null;
    }

    return this.attachAggregates(tutorial);
  }

  /** Lấy danh sách đánh giá của một bài hướng dẫn. */
  findReviews(tutorialId: string) {
    return this.reviews.filter((review) => review.tutorialId === tutorialId);
  }

  /** Tạo đánh giá mới cho bài hướng dẫn. */
  createReview(tutorialId: string, body: { rating: number; comment?: string }) {
    const review: TutorialReview = {
      id: `review-${Date.now()}`,
      tutorialId,
      userId: 'user-1',
      userName: 'Người dùng mẫu',
      rating: Number(body.rating),
      comment: body.comment,
      createdAt: new Date().toISOString(),
    };

    this.reviews.push(review);

    return review;
  }

  /** Cập nhật trạng thái lưu yêu thích của bài hướng dẫn. */
  setFavorite(tutorialId: string, favorite: boolean) {
    if (favorite) {
      this.favoriteTutorialIds.add(tutorialId);
    } else {
      this.favoriteTutorialIds.delete(tutorialId);
    }

    return {
      tutorialId,
      isSaved: this.favoriteTutorialIds.has(tutorialId),
    };
  }

  /** Gắn dữ liệu tổng hợp như số đánh giá, điểm trung bình và trạng thái yêu thích. */
  private attachAggregates(tutorial: Tutorial) {
    const reviews = this.findReviews(tutorial.id);
    const reviewCount = reviews.length;
    const averageRating =
      reviewCount === 0
        ? 0
        : reviews.reduce((sum, item) => sum + item.rating, 0) / reviewCount;

    return {
      ...tutorial,
      reviewCount,
      averageRating,
      isSaved: this.favoriteTutorialIds.has(tutorial.id),
    };
  }
}
import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Query,
} from '@nestjs/common';
import { ContentService } from './content.service';

@Controller('tutorials')
export class ContentController {
  constructor(private readonly contentService: ContentService) {}

  /** API lấy danh sách bài hướng dẫn. */
  @Get()
  getTutorials(
    @Query('q') query?: string,
    @Query('category') category?: string,
  ) {
    return {
      data: this.contentService.findTutorials(query, category),
    };
  }

  /** API lấy chi tiết bài hướng dẫn. */
  @Get(':id')
  getTutorialDetail(@Param('id') id: string) {
    return {
      data: this.contentService.findTutorialDetail(id),
    };
  }

  /** API lấy danh sách đánh giá của bài hướng dẫn. */
  @Get(':id/reviews')
  getTutorialReviews(@Param('id') id: string) {
    return {
      data: this.contentService.findReviews(id),
    };
  }

  /** API gửi đánh giá bài hướng dẫn. */
  @Post(':id/reviews')
  createTutorialReview(
    @Param('id') id: string,
    @Body() body: { rating: number; comment?: string },
  ) {
    return {
      data: this.contentService.createReview(id, body),
    };
  }

  /** API lưu bài hướng dẫn yêu thích. */
  @Post(':id/favorite')
  saveTutorial(@Param('id') id: string) {
    return {
      data: this.contentService.setFavorite(id, true),
    };
  }

  /** API bỏ lưu bài hướng dẫn yêu thích. */
  @Delete(':id/favorite')
  removeSavedTutorial(@Param('id') id: string) {
    return {
      data: this.contentService.setFavorite(id, false),
    };
  }
}
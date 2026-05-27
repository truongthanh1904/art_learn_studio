import {
  Body,
  Controller,
  Get,
  Post,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { CommunityService } from './community.service';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import * as path from 'path';

@Controller('artworks')
export class CommunityController {
  constructor(private readonly communityService: CommunityService) {}

  /** API lấy danh sách tác phẩm. */
  @Get()
  getArtworks() {
    return {
      data: this.communityService.findArtworks(),
    };
  }

  /** API tạo bản ghi tác phẩm. */
  @Post()
  createArtwork(
    @Body()
    body: {
      title: string;
      description?: string;
      imageUrl: string;
      sourceType?: string;
      isPublic?: boolean;
    },
  ) {
    return {
      data: this.communityService.createArtwork(body),
    };
  }

  /** API upload ảnh tác phẩm. */
  @Post('upload')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: './uploads',
        filename: (req, file, callback) => {
          const ext = path.extname(file.originalname);
          const filename = `artwork-${Date.now()}${ext}`;
          callback(null, filename);
        },
      }),
    }),
  )
  uploadArtworkImage(@UploadedFile() file: Express.Multer.File) {
    return {
      imageUrl: `http://localhost:3000/uploads/${file.filename}`,
    };
  }
}
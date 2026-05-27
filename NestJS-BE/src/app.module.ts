import { Module } from '@nestjs/common';
import { ContentModule } from './content/content.module';
import { CommunityModule } from './community/community.module';

@Module({
  imports: [ContentModule, CommunityModule],
})
export class AppModule {}
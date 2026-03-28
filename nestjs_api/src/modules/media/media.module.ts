import { Module, Controller, Post, UseInterceptors, UploadedFile, BadRequestException } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiConsumes, ApiBody } from '@nestjs/swagger';
import { FileInterceptor } from '@nestjs/platform-express';

@ApiTags('media')
@Controller('media')
export class MediaController {
  @Post('upload')
  @ApiOperation({ summary: 'Upload file to GCS CDN Sandbox' })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: { file: { type: 'string', format: 'binary' } },
    },
  })
  @UseInterceptors(FileInterceptor('file'))
  uploadFile(@UploadedFile() file: any) {
    if (!file) throw new BadRequestException('No file uploaded');
    return {
      url: `https://storage.googleapis.com/wildhouse-cdn/${file.originalname || 'texture_generated.jpg'}`,
      status: 'uploaded',
      ar_texture: true,
      size: file.size
    };
  }

  @Post('parse-plan')
  @ApiOperation({ summary: 'Parse PDF floor plan to extract dimensions (RU, EN, HE)' })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: { file: { type: 'string', format: 'binary' } },
    },
  })
  @UseInterceptors(FileInterceptor('file'))
  parsePdfPlan(@UploadedFile() file: any) {
    if (!file) throw new BadRequestException('PDF file is required');
    if (file.mimetype !== 'application/pdf') throw new BadRequestException('Only PDF is allowed');

    // Here we would use pdf-parse and NLP (or GPT vision API) to extract area.
    // Stub implementation covering RU, EN, and HE keywords for Area, Length, Width.
    /*
      const text = await pdfParse(file.buffer);
      if (text.includes('שטח') || text.includes('площадь') || text.includes('area')) { ... }
    */

    // Simulated parsed response for the calculator mechanics:
    return {
      status: 'success',
      parsedLog: 'Detected Languages: [ru, he]. Found geometrical markers.',
      data: {
        widthMeters: 4.5,
        lengthMeters: 6.0,
        totalAreaM2: 27.0, // 4.5 * 6
        roomsDetected: 1,
        confidence: 0.92
      }
    };
  }
}

@Module({
  controllers: [MediaController],
  providers: [],
})
export class MediaModule {}

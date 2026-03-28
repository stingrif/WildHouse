// src/modules/catalog/catalog.service.ts
import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, SelectQueryBuilder } from 'typeorm';
import { Product } from './product.entity';
import { CatalogFilterDto } from './product.entity'; // dto co-located for brevity

@Injectable()
export class CatalogService {
  constructor(
    @InjectRepository(Product)
    private readonly repo: Repository<Product>,
  ) {}

  async findAll(filter: CatalogFilterDto) {
    const qb: SelectQueryBuilder<Product> = this.repo
      .createQueryBuilder('p')
      .where('p.is_active = true');

    if (filter.search) {
      qb.andWhere(
        '(p.name ILIKE :q OR p.brand ILIKE :q OR p.collection ILIKE :q)',
        { q: `%${filter.search}%` },
      );
    }
    if (filter.categoryId)       qb.andWhere('p.category_id = :cat', { cat: filter.categoryId });
    if (filter.brand)            qb.andWhere('p.brand ILIKE :br', { br: `%${filter.brand}%` });
    if (filter.wearClass)        qb.andWhere('p.wear_class = :wc', { wc: filter.wearClass });
    if (filter.moistureResistant !== undefined)
      qb.andWhere('p.moisture_resistant = :mr', { mr: filter.moistureResistant });
    if (filter.floorHeatCompat !== undefined)
      qb.andWhere('p.floor_heat_compat = :fh', { fh: filter.floorHeatCompat });
    if (filter.priceMin !== undefined)
      qb.andWhere('p.price_per_m2 >= :pmin', { pmin: filter.priceMin });
    if (filter.priceMax !== undefined)
      qb.andWhere('p.price_per_m2 <= :pmax', { pmax: filter.priceMax });

    qb.orderBy('p.is_featured', 'DESC').addOrderBy('p.created_at', 'DESC');

    const page  = filter.page  ?? 1;
    const limit = filter.limit ?? 20;
    qb.skip((page - 1) * limit).take(limit);

    const [items, total] = await qb.getManyAndCount();

    return {
      items,
      meta: { total, page, limit, pages: Math.ceil(total / limit) },
    };
  }

  async findOne(id: string): Promise<Product> {
    const product = await this.repo.findOne({ where: { id, isActive: true } });
    if (!product) throw new NotFoundException(`Product ${id} not found`);
    return product;
  }

  async findBrands(): Promise<string[]> {
    const rows = await this.repo
      .createQueryBuilder('p')
      .select('DISTINCT p.brand', 'brand')
      .where('p.is_active = true')
      .orderBy('brand', 'ASC')
      .getRawMany();
    return rows.map((r) => r.brand);
  }
}

// ─────────────────────────────────────────────────────────────
// src/modules/catalog/catalog.controller.ts
import { Controller, Get, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';

@ApiTags('catalog')
@Controller('catalog')
export class CatalogController {
  constructor(private readonly catalogService: CatalogService) {}

  @Get('products')
  @ApiOperation({ summary: 'List products with filters & pagination' })
  @Throttle({ default: { ttl: 60000, limit: 120 } })
  findAll(@Query() filter: CatalogFilterDto) {
    return this.catalogService.findAll(filter);
  }

  @Get('products/:id')
  @ApiOperation({ summary: 'Get product by id' })
  findOne(@Param('id') id: string) {
    return this.catalogService.findOne(id);
  }

  @Get('brands')
  @ApiOperation({ summary: 'List all active brands' })
  getBrands() {
    return this.catalogService.findBrands();
  }
}

// ─────────────────────────────────────────────────────────────
// src/modules/catalog/catalog.module.ts
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

@Module({
  imports: [TypeOrmModule.forFeature([Product])],
  controllers: [CatalogController],
  providers: [CatalogService],
  exports: [CatalogService],
})
export class CatalogModule {}

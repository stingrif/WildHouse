// src/modules/catalog/product.entity.ts
import {
  Entity, PrimaryGeneratedColumn, Column,
  CreateDateColumn, UpdateDateColumn, Index,
} from 'typeorm';

export type InstallType = 'glue' | 'lock' | 'glue_lock' | 'floating';
export type WearClass   = 'AC1' | 'AC2' | 'AC3' | 'AC4' | 'AC5' | 'AC6';

@Entity('products')
@Index(['categoryId', 'isActive'])
@Index(['brand'])
export class Product {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true, length: 50 })
  sku: string;

  @Column({ length: 200 })
  name: string;

  @Column({ length: 100 })
  brand: string;

  @Column({ length: 100 })
  collection: string;

  @Column({ name: 'category_id' })
  @Index()
  categoryId: string;

  @Column({ name: 'color_name', length: 100 })
  colorName: string;

  @Column({ name: 'color_hex', length: 7, nullable: true })
  colorHex?: string;

  @Column({ name: 'thickness_mm', type: 'decimal', precision: 4, scale: 1 })
  thicknessMm: number;

  @Column({ name: 'wear_class', type: 'varchar', length: 3 })
  wearClass: WearClass;

  @Column({ name: 'moisture_resistant', default: false })
  moistureResistant: boolean;

  @Column({ name: 'install_type', type: 'varchar', length: 20 })
  installType: InstallType;

  @Column({ name: 'floor_heat_compat', default: false })
  floorHeatCompat: boolean;

  @Column({ name: 'price_per_m2', type: 'decimal', precision: 10, scale: 2 })
  pricePerM2: number;

  @Column({ name: 'vat_rate', type: 'decimal', precision: 5, scale: 2, default: 18 })
  vatRate: number;

  @Column({ name: 'photo_urls', type: 'text', array: true, default: [] })
  photoUrls: string[];

  @Column({ name: 'texture_url', type: 'text' })
  textureUrl: string;

  @Column({ name: 'stock_qty', type: 'decimal', precision: 10, scale: 2, default: 0 })
  stockQty: number;

  @Column({ name: 'reserved_qty', type: 'decimal', precision: 10, scale: 2, default: 0 })
  reservedQty: number;

  @Column({ name: 'is_active', default: true })
  @Index()
  isActive: boolean;

  @Column({ name: 'is_featured', default: false })
  isFeatured: boolean;

  @Column({ type: 'jsonb', nullable: true })
  attributes?: Record<string, unknown>;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;

  get availableQty(): number {
    return Number(this.stockQty) - Number(this.reservedQty);
  }

  get priceWithVat(): number {
    return Number(this.pricePerM2) * (1 + Number(this.vatRate) / 100);
  }
}

// ─────────────────────────────────────────────────────────────
// src/modules/catalog/dto/catalog-filter.dto.ts
import { IsOptional, IsBoolean, IsString, IsNumber, Min, Max } from 'class-validator';
import { Transform } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';

export class CatalogFilterDto {
  @ApiPropertyOptional() @IsOptional() @IsString()
  search?: string;

  @ApiPropertyOptional() @IsOptional() @IsString()
  categoryId?: string;

  @ApiPropertyOptional() @IsOptional() @IsString()
  brand?: string;

  @ApiPropertyOptional() @IsOptional() @IsString()
  wearClass?: string;

  @ApiPropertyOptional() @IsOptional()
  @Transform(({ value }) => value === 'true')
  @IsBoolean()
  moistureResistant?: boolean;

  @ApiPropertyOptional() @IsOptional()
  @Transform(({ value }) => value === 'true')
  @IsBoolean()
  floorHeatCompat?: boolean;

  @ApiPropertyOptional() @IsOptional() @IsNumber() @Min(0)
  priceMin?: number;

  @ApiPropertyOptional() @IsOptional() @IsNumber() @Min(0)
  priceMax?: number;

  @ApiPropertyOptional({ default: 1 }) @IsOptional() @IsNumber() @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ default: 20 }) @IsOptional() @IsNumber() @Min(1) @Max(100)
  limit?: number = 20;
}

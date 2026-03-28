// src/modules/orders/orders.module.ts
import { Module, Controller, Post, Get, Body, Param, Injectable } from '@nestjs/common';
import { TypeOrmModule, InjectRepository } from '@nestjs/typeorm';
import { Repository, Entity, PrimaryGeneratedColumn, Column, CreateDateColumn } from 'typeorm';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiProperty } from '@nestjs/swagger';
import { IsString, IsArray, IsNumber, IsOptional, IsBoolean, Min } from 'class-validator';

// ── Order Entity ──────────────────────────────────────────────
@Entity('orders')
export class Order {
  @PrimaryGeneratedColumn('uuid') id: string;
  @Column() userId: string;
  @Column({ type: 'jsonb' }) lines: object[];
  @Column({ nullable: true }) installDate?: string;
  @Column() address: string;
  @Column({ type: 'decimal', precision: 10, scale: 2 }) totalInclVat: number;
  @Column({ default: 'card' }) paymentMethod: string;
  @Column({ nullable: true }) promoCode?: string;
  @Column({ default: 'draft' }) status: string;
  @CreateDateColumn() createdAt: Date;
}

// ── DTOs ──────────────────────────────────────────────────────
class OrderLineDto {
  @ApiProperty() @IsString() productId: string;
  @ApiProperty() @IsNumber() @Min(0) areaM2: number;
  @ApiProperty() @IsBoolean() @IsOptional() includeInstallation?: boolean;
}

class CreateOrderDto {
  @ApiProperty({ type: [OrderLineDto] }) @IsArray() lines: OrderLineDto[];
  @ApiProperty() @IsString() address: string;
  @ApiProperty({ required: false }) @IsString() @IsOptional() installDate?: string;
  @ApiProperty({ enum: ['card', 'crypto'] }) @IsString() paymentMethod: string;
  @ApiProperty({ required: false }) @IsString() @IsOptional() promoCode?: string;
}

// ── Service ───────────────────────────────────────────────────
@Injectable()
export class OrdersService {
  constructor(
    @InjectRepository(Order)
    private readonly repo: Repository<Order>,
  ) {}

  async create(userId: string, dto: CreateOrderDto) {
    // 1. Calculate realistic total based on current cart
    // Using a stub multiplier 85ILS per area meter for MVP math validation + 18% VAT:
    const totalInclVat = dto.lines.reduce(
        (acc, line) => acc + (line.areaM2 * 85 * 1.18), 0
    );

    // 2. Database Creation & Save
    const order = this.repo.create({
      userId,
      lines: dto.lines,
      address: dto.address,
      installDate: dto.installDate,
      paymentMethod: dto.paymentMethod,
      promoCode: dto.promoCode,
      totalInclVat,
      status: 'confirmed', // Assuming pre-auth capture
    });

    await this.repo.save(order);
    return order;
  }

  async findByUser(userId: string) {
    return this.repo.find({ where: { userId }, order: { createdAt: 'DESC' } });
  }

  async findOne(id: string) {
    return this.repo.findOne({ where: { id } });
  }
}

// ── Controller ────────────────────────────────────────────────
@ApiTags('orders')
@ApiBearerAuth()
@Controller('orders')
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Post()
  @ApiOperation({ summary: 'Create order' })
  create(@Body() dto: CreateOrderDto) {
    const userId = 'mock-jwt-userid-1234'; 
    return this.ordersService.create(userId, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Get current user orders' })
  findMine() {
    return this.ordersService.findByUser('mock-jwt-userid-1234');
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get order by id' })
  findOne(@Param('id') id: string) {
    return this.ordersService.findOne(id);
  }
}

@Module({
  imports: [TypeOrmModule.forFeature([Order])],
  controllers: [OrdersController],
  providers: [OrdersService],
  exports: [OrdersService],
})
export class OrdersModule {}

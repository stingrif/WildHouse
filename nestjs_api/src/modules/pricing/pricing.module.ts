// src/modules/pricing/pricing.service.ts
import { Injectable } from '@nestjs/common';
import { ApiProperty } from '@nestjs/swagger';
import { IsNumber, IsBoolean, IsOptional, IsString, Min } from 'class-validator';

export class CalculateDto {
  @ApiProperty({ description: 'Area in m²', example: 24.5 })
  @IsNumber() @Min(0)
  areaM2: number;

  @ApiProperty({ description: 'Product price per m² (excl. VAT)', example: 85 })
  @IsNumber() @Min(0)
  pricePerM2: number;

  @ApiProperty({ default: 18 })
  @IsNumber() @IsOptional()
  vatRate?: number = 18;

  @ApiProperty({ description: 'Include installation cost', default: false })
  @IsBoolean() @IsOptional()
  includeInstallation?: boolean = false;

  @ApiProperty({ description: 'Installation type for pricing', example: 'standard' })
  @IsString() @IsOptional()
  installationType?: 'standard' | 'fishbone' | 'stairs';

  @ApiProperty({ description: 'Apply 15% token discount', default: false })
  @IsBoolean() @IsOptional()
  tokenDiscount?: boolean = false;

  @ApiProperty({ description: 'Promo code', required: false })
  @IsString() @IsOptional()
  promoCode?: string;
}

export interface PriceBreakdown {
  areaM2:           number;
  areaWithWasteM2:  number;
  wastePercent:     number;
  materialNet:      number;
  installationNet:  number;
  subtotal:         number;
  tokenDiscount:    number;
  promoDiscount:    number;
  vatAmount:        number;
  total:            number;
  currency:         string;
}

@Injectable()
export class PricingService {
  // Installation prices (₪) — from docs
  private static readonly INSTALL_PRICES = {
    standard: { small: 700, large: 1000 }, // до / свыше 13 м²
    fishbone:  { small: 900, large: 1200 },
    stairs:    { perStep: 300 },           // per step
  };

  private static readonly WASTE_PERCENT  = 0.10; // +10% запас
  private static readonly TOKEN_DISCOUNT = 0.15;

  calculate(dto: CalculateDto): PriceBreakdown {
    const vatRate       = dto.vatRate ?? 18;
    const areaWithWaste = dto.areaM2 * (1 + PricingService.WASTE_PERCENT);

    // Material cost (ex VAT)
    const materialNet = areaWithWaste * dto.pricePerM2;

    // Installation
    let installationNet = 0;
    if (dto.includeInstallation) {
      const prices = PricingService.INSTALL_PRICES[dto.installationType ?? 'standard'];
      installationNet = 'perStep' in prices
        ? prices.perStep  // stairs — per step
        : dto.areaM2 <= 13 ? prices.small : prices.large;
    }

    const subtotal = materialNet + installationNet;

    // Discounts
    const tokenDiscount = dto.tokenDiscount
      ? materialNet * PricingService.TOKEN_DISCOUNT : 0;
    const promoDiscount = 0; // TODO: PromoService.validate(dto.promoCode)

    const discounted = subtotal - tokenDiscount - promoDiscount;
    const vatAmount  = discounted * (vatRate / 100);
    const total      = discounted + vatAmount;

    return {
      areaM2:          dto.areaM2,
      areaWithWasteM2: parseFloat(areaWithWaste.toFixed(2)),
      wastePercent:    PricingService.WASTE_PERCENT * 100,
      materialNet:     parseFloat(materialNet.toFixed(2)),
      installationNet: parseFloat(installationNet.toFixed(2)),
      subtotal:        parseFloat(subtotal.toFixed(2)),
      tokenDiscount:   parseFloat(tokenDiscount.toFixed(2)),
      promoDiscount:   parseFloat(promoDiscount.toFixed(2)),
      vatAmount:       parseFloat(vatAmount.toFixed(2)),
      total:           parseFloat(total.toFixed(2)),
      currency:        'ILS',
    };
  }
}

// ─────────────────────────────────────────────────────────────
// src/modules/pricing/pricing.controller.ts
import { Body, Controller, Post } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';

@ApiTags('pricing')
@Controller('pricing')
export class PricingController {
  constructor(private readonly pricingService: PricingService) {}

  @Post('calculate')
  @ApiOperation({ summary: 'Calculate total price with VAT, installation, discounts' })
  calculate(@Body() dto: CalculateDto): PriceBreakdown {
    return this.pricingService.calculate(dto);
  }
}

// ─────────────────────────────────────────────────────────────
// src/modules/pricing/pricing.module.ts
import { Module } from '@nestjs/common';

@Module({
  controllers: [PricingController],
  providers: [PricingService],
  exports: [PricingService],
})
export class PricingModule {}

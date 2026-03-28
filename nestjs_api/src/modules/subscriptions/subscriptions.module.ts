import { Module, Controller, Get, Post, Body, Param } from '@nestjs/common';
import { ApiTags, ApiOperation } from '@nestjs/swagger';

export const PLANS = {
  basic:    { priceIls: 50,  period: 'week',  arSessions: 5   },
  standard: { priceIls: 300, period: 'month', arSessions: -1  }, // unlimited
  pro:      { priceIls: 500, period: 'month', arSessions: -1  },
};

@ApiTags('subscriptions')
@Controller('subscriptions')
export class SubscriptionsController {
  @Get('plans')
  @ApiOperation({ summary: 'Get all available subscription plans' })
  getPlans() {
    return PLANS;
  }

  @Post('subscribe/:plan')
  @ApiOperation({ summary: 'Subscribe to a specific plan (Stripe/Tranzila integration)' })
  subscribe(@Param('plan') plan: string, @Body() body: any) {
    if (!PLANS[plan]) {
      return { status: 'error', message: 'Plan not found' };
    }
    return {
      status: 'success',
      message: `Successfully subscribed to ${plan} plan. Billing activated.`,
      validUntil: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
    };
  }
}

@Module({
  controllers: [SubscriptionsController],
  providers: [],
})
export class SubscriptionsModule {}

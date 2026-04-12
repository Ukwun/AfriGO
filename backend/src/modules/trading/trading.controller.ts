import {
  Controller,
  Post,
  Get,
  Body,
  Param,
  Query,
  UseGuards,
  Request,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { TradingService } from './trading.service';
import {
  CreateOrderDto,
  OrderSearchQueryDto,
} from './dtos/order.dto';
import {
  CreateQuoteDto,
  CounterQuoteDto,
  RejectQuoteDto,
  QuoteSearchQueryDto,
} from './dtos/quote.dto';

@Controller('trading')
export class TradingController {
  constructor(private readonly tradingService: TradingService) {}

  // ============ ORDER ENDPOINTS ============

  /**
   * POST /trading/orders - Create a new order
   */
  @UseGuards(JwtAuthGuard)
  @Post('orders')
  async createOrder(@Request() req, @Body() createOrderDto: CreateOrderDto) {
    return this.tradingService.createOrder(req.user.id, createOrderDto);
  }

  /**
   * GET /trading/orders/buyer - Get buyer's orders
   */
  @UseGuards(JwtAuthGuard)
  @Get('orders/buyer')
  async getOrdersByBuyer(@Request() req, @Query() query: OrderSearchQueryDto) {
    return this.tradingService.getOrdersByBuyer(req.user.id, query);
  }

  /**
   * GET /trading/orders/seller - Get seller's orders
   */
  @UseGuards(JwtAuthGuard)
  @Get('orders/seller')
  async getOrdersBySeller(@Request() req, @Query() query: OrderSearchQueryDto) {
    return this.tradingService.getOrdersBySeller(req.user.id, query);
  }

  /**
   * GET /trading/orders/:orderId - Get specific order
   */
  @UseGuards(JwtAuthGuard)
  @Get('orders/:orderId')
  async getOrderById(@Request() req, @Param('orderId') orderId: string) {
    return this.tradingService.getOrderById(orderId, req.user.id);
  }

  /**
   * POST /trading/orders/:orderId/confirm - Confirm order (buyer)
   */
  @UseGuards(JwtAuthGuard)
  @Post('orders/:orderId/confirm')
  async confirmOrder(@Request() req, @Param('orderId') orderId: string) {
    return this.tradingService.confirmOrder(orderId, req.user.id);
  }

  /**
   * POST /trading/orders/:orderId/cancel - Cancel order
   */
  @UseGuards(JwtAuthGuard)
  @Post('orders/:orderId/cancel')
  async cancelOrder(@Request() req, @Param('orderId') orderId: string) {
    return this.tradingService.cancelOrder(orderId, req.user.id);
  }

  /**
   * POST /trading/orders/:orderId/ship - Ship order (seller)
   */
  @UseGuards(JwtAuthGuard)
  @Post('orders/:orderId/ship')
  async shipOrder(@Request() req, @Param('orderId') orderId: string) {
    return this.tradingService.shipOrder(orderId, req.user.id);
  }

  /**
   * POST /trading/orders/:orderId/deliver - Confirm delivery (buyer)
   */
  @UseGuards(JwtAuthGuard)
  @Post('orders/:orderId/deliver')
  async deliverOrder(@Request() req, @Param('orderId') orderId: string) {
    return this.tradingService.deliverOrder(orderId, req.user.id);
  }

  /**
   * POST /trading/orders/:orderId/complete - Complete order
   */
  @UseGuards(JwtAuthGuard)
  @Post('orders/:orderId/complete')
  async completeOrder(@Request() req, @Param('orderId') orderId: string) {
    return this.tradingService.completeOrder(orderId, req.user.id);
  }

  /**
   * POST /trading/orders/:orderId/rate - Rate order (buyer or seller)
   */
  @UseGuards(JwtAuthGuard)
  @Post('orders/:orderId/rate')
  async rateOrder(
    @Request() req,
    @Param('orderId') orderId: string,
    @Body() body: { rating: number; review: string },
  ) {
    return this.tradingService.rateOrder(
      orderId,
      req.user.id,
      body.rating,
      body.review,
    );
  }

  // ============ QUOTE ENDPOINTS ============

  /**
   * POST /trading/quotes - Create a quote (seller)
   */
  @UseGuards(JwtAuthGuard)
  @Post('quotes')
  async createQuote(@Request() req, @Body() createQuoteDto: CreateQuoteDto) {
    return this.tradingService.createQuote(req.user.id, createQuoteDto);
  }

  /**
   * GET /trading/quotes/orders/:orderId - Get quotes for an order
   */
  @UseGuards(JwtAuthGuard)
  @Get('quotes/orders/:orderId')
  async getQuotesByOrderId(
    @Request() req,
    @Param('orderId') orderId: string,
  ) {
    return this.tradingService.getQuotesByOrderId(orderId, req.user.id);
  }

  /**
   * GET /trading/quotes/received - Get received quotes (buyer)
   */
  @UseGuards(JwtAuthGuard)
  @Get('quotes/received')
  async getReceivedQuotes(
    @Request() req,
    @Query() query: QuoteSearchQueryDto,
  ) {
    return this.tradingService.getReceivedQuotes(req.user.id, query);
  }

  /**
   * GET /trading/quotes/sent - Get sent quotes (seller)
   */
  @UseGuards(JwtAuthGuard)
  @Get('quotes/sent')
  async getSentQuotes(
    @Request() req,
    @Query() query: QuoteSearchQueryDto,
  ) {
    return this.tradingService.getSentQuotes(req.user.id, query);
  }

  /**
   * GET /trading/quotes/:quoteId - Get specific quote
   */
  @UseGuards(JwtAuthGuard)
  @Get('quotes/:quoteId')
  async getQuoteById(@Request() req, @Param('quoteId') quoteId: string) {
    return this.tradingService.getQuoteById(quoteId, req.user.id);
  }

  /**
   * POST /trading/quotes/:quoteId/accept - Accept quote (buyer)
   */
  @UseGuards(JwtAuthGuard)
  @Post('quotes/:quoteId/accept')
  async acceptQuote(@Request() req, @Param('quoteId') quoteId: string) {
    return this.tradingService.acceptQuote(quoteId, req.user.id);
  }

  /**
   * POST /trading/quotes/:quoteId/reject - Reject quote (buyer)
   */
  @UseGuards(JwtAuthGuard)
  @Post('quotes/:quoteId/reject')
  async rejectQuote(
    @Request() req,
    @Param('quoteId') quoteId: string,
    @Body() rejectDto: RejectQuoteDto,
  ) {
    return this.tradingService.rejectQuote(quoteId, req.user.id, rejectDto);
  }

  /**
   * POST /trading/quotes/:quoteId/counter - Submit counter quote (buyer)
   */
  @UseGuards(JwtAuthGuard)
  @Post('quotes/:quoteId/counter')
  async submitCounterQuote(
    @Request() req,
    @Param('quoteId') quoteId: string,
    @Body() counterDto: CounterQuoteDto,
  ) {
    return this.tradingService.submitCounterQuote(
      quoteId,
      req.user.id,
      counterDto,
    );
  }
}

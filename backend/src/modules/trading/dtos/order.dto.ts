import { IsDecimal, IsString, IsUUID, IsOptional, IsDate, IsEnum, Min, Max } from 'class-validator';

// Create Order DTO
export class CreateOrderDto {
  @IsUUID()
  lotId: string;

  @IsDecimal({ decimal_digits: '2' })
  quantity: number;

  @IsString()
  quantityUnit: string; // e.g., 'kg', 'bags', 'tons'

  @IsOptional()
  @IsString()
  notes?: string;
}

// Update Order DTO
export class UpdateOrderDto {
  @IsOptional()
  @IsEnum(['confirmed', 'cancelled'])
  status?: 'confirmed' | 'cancelled';

  @IsOptional()
  @IsString()
  notes?: string;
}

// Order Response DTO
export class OrderResponseDto {
  id: string;
  lotId: string;
  buyerId: string;
  sellerId: string;
  quantity: number;
  quantityUnit: string;
  pricePerUnit: number;
  totalPrice: number;
  status: string;
  paymentStatus: string;
  createdAt: Date;
  updatedAt: Date;
  lot?: {
    id: string;
    productName: string;
    productImage: string;
    seller?: {
      id: string;
      fullName: string;
      phoneNumber: string;
    };
  };
}

// Order Search Query DTO
export class OrderSearchQueryDto {
  @IsOptional()
  @IsString()
  status?: string;

  @IsOptional()
  @IsEnum(['pending', 'quoted', 'negotiating', 'confirmed', 'paid', 'shipped', 'delivered', 'completed', 'cancelled', 'disputed'])
  statusEnum?: 'pending' | 'quoted' | 'negotiating' | 'confirmed' | 'paid' | 'shipped' | 'delivered' | 'completed' | 'cancelled' | 'disputed';

  @IsOptional()
  @IsString()
  sortBy?: 'createdAt' | 'totalPrice' | 'updatedAt';

  @IsOptional()
  @IsString()
  order?: 'ASC' | 'DESC';

  @IsOptional()
  skip?: number;

  @IsOptional()
  take?: number;
}

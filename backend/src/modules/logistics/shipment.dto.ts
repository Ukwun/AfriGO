import { IsNotEmpty, IsUUID, IsEnum, IsString, IsDateString, IsLatitude, IsLongitude, IsOptional, IsNumber, Min, Max, IsEmail, IsPhoneNumber, Length } from 'class-validator';
import { ShipmentStatus, TransportMode } from './shipment.entity';
import { TrackingEventType } from './shipment-tracking.entity';
import { ProofType } from './delivery-proof.entity';

// ======================== CREATE/UPDATE DTOS ========================

export class CreateShipmentDTO {
  @IsNotEmpty()
  @IsUUID()
  contractId: string;

  @IsEnum(TransportMode)
  transportMode: TransportMode;

  @IsString()
  @IsNotEmpty()
  pickupLocationName: string;

  @IsLatitude()
  pickupLatitude: string;

  @IsLongitude()
  pickupLongitude: string;

  @IsDateString()
  @IsNotEmpty()
  pickupDate: string;

  @IsString()
  @IsNotEmpty()
  deliveryLocationName: string;

  @IsLatitude()
  deliveryLatitude: string;

  @IsLongitude()
  deliveryLongitude: string;

  @IsDateString()
  @IsNotEmpty()
  expectedDeliveryDate: string;

  @IsOptional()
  @IsString()
  vehicleRegistration?: string;

  @IsOptional()
  @IsString()
  vehicleType?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  totalWeight?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  totalVolume?: number;

  @IsOptional()
  @IsString()
  recipientName?: string;

  @IsOptional()
  @IsPhoneNumber()
  recipientPhone?: string;

  @IsOptional()
  @IsEmail()
  recipientEmail?: string;

  @IsOptional()
  @IsString()
  specialHandlingInstructions?: string;

  @IsOptional()
  insured: boolean;

  @IsOptional()
  @IsString()
  insuranceProvider?: string;

  @IsOptional()
  @IsString()
  policyNumber?: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  declaredValue?: number;
}

export class AssignDriverDTO {
  @IsNotEmpty()
  @IsUUID()
  driverId: string;

  @IsOptional()
  @IsString()
  vehicleRegistration?: string;

  @IsOptional()
  @IsString()
  vehicleType?: string;

  @IsOptional()
  @IsString()
  driverLicenseNumber?: string;
}

export class UpdateShipmentStatusDTO {
  @IsEnum(ShipmentStatus)
  status: ShipmentStatus;

  @IsOptional()
  @IsString()
  notes?: string;

  @IsOptional()
  @IsString()
  deliveryFailureReason?: string;
}

export class AddTrackingEventDTO {
  @IsEnum(TrackingEventType)
  eventType: TrackingEventType;

  @IsString()
  @IsNotEmpty()
  message: string;

  @IsOptional()
  @IsLatitude()
  latitude?: string;

  @IsOptional()
  @IsLongitude()
  longitude?: string;

  @IsOptional()
  @IsString()
  locationName?: string;

  @IsOptional()
  metadata?: any; // Temperature, humidity, speed, etc.

  @IsOptional()
  @IsString()
  notes?: string;
}

export class CaptureDeliveryProofDTO {
  @IsEnum(ProofType)
  proofType: ProofType;

  @IsString()
  @IsNotEmpty()
  description: string;

  @IsOptional()
  @IsString()
  dataBlobUrl?: string; // Base64 encoded or S3 URL

  @IsOptional()
  signatureCanvas?: {
    base64: string;
    imageFormat: string;
    width: number;
    height: number;
  };

  @IsOptional()
  @IsString()
  recipientName?: string;

  @IsOptional()
  @IsString()
  recipientIdType?: string;

  @IsOptional()
  @IsString()
  recipientIdNumber?: string;

  @IsOptional()
  @IsString()
  recipientPhone?: string;

  @IsOptional()
  conditionAssessment?: {
    packageCondition?: string;
    damageDescription?: string;
    productCondition?: string;
    temperatureAtDelivery?: number;
  };

  @IsOptional()
  @IsLatitude()
  latitude?: string;

  @IsOptional()
  @IsLongitude()
  longitude?: string;

  @IsOptional()
  @IsString()
  notes?: string;
}

export class RescheduleDeliveryDTO {
  @IsDateString()
  @IsNotEmpty()
  newDeliveryDate: string;

  @IsString()
  reason: string;

  @IsOptional()
  @IsString()
  notes?: string;
}

// ======================== RESPONSE DTOS ========================

export class ShipmentResponseDTO {
  id: string;
  shipmentReference: string;
  status: ShipmentStatus;
  transportMode: TransportMode;
  pickupLocationName: string;
  deliveryLocationName: string;
  pickupDate: Date;
  expectedDeliveryDate: Date;
  actualDeliveryDate?: Date;
  daysInTransit: number;
  isDelayed: boolean;
  driver?: {
    id: string;
    name: string;
    phone: string;
  };
  vehicleRegistration?: string;
  trackingUrl?: string;
  deliveryProofCount: number;
  createdAt: Date;
  updatedAt: Date;
}

export class ShipmentListResponseDTO {
  data: ShipmentResponseDTO[];
  pagination: {
    limit: number;
    offset: number;
    total: number;
    hasMore: boolean;
  };
}

export class ShipmentDetailsResponseDTO extends ShipmentResponseDTO {
  contract: {
    id: string;
    totalValue: number;
    currency: string;
    buyer: { id: string; name: string };
    seller: { id: string; name: string };
  };
  trackingHistory: TrackingEventResponseDTO[];
  deliveryProofs: DeliveryProofResponseDTO[];
  recipientName?: string;
  recipientPhone?: string;
  requiresSignature: boolean;
  specialHandlingInstructions?: string;
}

export class TrackingEventResponseDTO {
  id: string;
  eventType: TrackingEventType;
  message: string;
  latitude?: string;
  longitude?: string;
  locationName?: string;
  metadata?: any;
  createdAt: Date;
}

export class DeliveryProofResponseDTO {
  id: string;
  proofType: ProofType;
  description: string;
  dataBlobUrl?: string;
  recipientName?: string;
  recipientIdNumber?: string;
  conditionAssessment?: any;
  latitude?: string;
  longitude?: string;
  isVerified: boolean;
  createdAt: Date;
  capturedBy: {
    id: string;
    name: string;
  };
}

export class ShipmentSummaryDTO {
  totalShipments: number;
  inTransit: number;
  delivered: number;
  failed: number;
  avgDeliveryDays: number;
  onTimeDeliveryRate: number; // percentage
}

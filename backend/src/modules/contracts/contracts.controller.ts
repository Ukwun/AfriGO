import {
  Controller,
  Post,
  Get,
  Patch,
  Delete,
  Param,
  Body,
  UseGuards,
  Request,
  Query,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { ContractService } from './contracts.service';
import {
  CreateContractDTO,
  SignContractDTO,
  AmendContractDTO,
  ApproveAmendmentDTO,
  InitiateDisputeDTO,
} from './dto/contract.dto';

@Controller('api/contracts')
@UseGuards(JwtAuthGuard, RolesGuard)
export class ContractController {
  constructor(private contractService: ContractService) {}

  /**
   * Auto-generate contract from RFQ award
   * POST /api/contracts/auto-generate
   * Body: { rfqId, winnerId }
   * Auth: seller, buyer, admin
   */
  @Post('auto-generate')
  @Roles('seller', 'buyer', 'admin')
  @HttpCode(HttpStatus.CREATED)
  async autoGenerateFromRFQ(
    @Body() body: { rfqId: string; winnerId: string },
  ) {
    const contract = await this.contractService.autoGenerateFromRFQ(
      body.rfqId,
      body.winnerId,
    );
    return {
      success: true,
      message: 'Contract auto-generated from RFQ',
      data: contract,
    };
  }

  /**
   * Create custom contract
   * POST /api/contracts
   * Body: CreateContractDTO
   * Auth: buyer, admin
   */
  @Post()
  @Roles('buyer', 'admin')
  @HttpCode(HttpStatus.CREATED)
  async createContract(@Body() dto: CreateContractDTO) {
    const contract = await this.contractService.createContract(dto);
    return {
      success: true,
      message: 'Contract created',
      data: contract,
    };
  }

  /**
   * Get contract by ID
   * GET /api/contracts/:id
   * Auth: all authenticated users
   */
  @Get(':id')
  async getContract(@Param('id') id: string) {
    const contract = await this.contractService.getContractById(id);
    return {
      success: true,
      data: contract,
    };
  }

  /**
   * List contracts
   * GET /api/contracts?status=signed&limit=20&offset=0
   * Query: status (optional), contractType (optional), limit, offset
   * Auth: all authenticated (filters to user's contracts)
   */
  @Get()
  async listContracts(
    @Request() req,
    @Query('status') status?: string,
    @Query('contractType') contractType?: string,
    @Query('limit') limit: number = 20,
    @Query('offset') offset: number = 0,
  ) {
    const { data, total } = await this.contractService.listContracts(
      req.user.id,
      status,
      contractType,
      limit,
      offset,
    );
    return {
      success: true,
      data,
      pagination: { limit, offset, total },
    };
  }

  /**
   * Sign contract
   * POST /api/contracts/:id/sign
   * Body: SignContractDTO (signature: base64 image)
   * Auth: buyer, seller (must be party to contract)
   */
  @Post(':id/sign')
  @Roles('buyer', 'seller')
  @HttpCode(HttpStatus.OK)
  async signContract(
    @Param('id') contractId: string,
    @Request() req,
    @Body() dto: SignContractDTO,
  ) {
    const contract = await this.contractService.signContract(
      contractId,
      req.user.id,
      dto,
    );
    return {
      success: true,
      message: contract.status === 'signed' 
        ? 'Contract fully signed and activated'
        : 'Signature recorded (awaiting counter-signature)',
      data: contract,
    };
  }

  /**
   * Submit amendment
   * POST /api/contracts/:id/amend
   * Body: AmendContractDTO
   * Auth: buyer, seller (parties to contract)
   */
  @Post(':id/amend')
  @Roles('buyer', 'seller')
  @HttpCode(HttpStatus.CREATED)
  async submitAmendment(
    @Param('id') contractId: string,
    @Request() req,
    @Body() dto: AmendContractDTO,
  ) {
    const amendment = await this.contractService.submitAmendment(
      contractId,
      req.user.id,
      dto,
    );
    return {
      success: true,
      message: 'Amendment proposed',
      data: amendment,
    };
  }

  /**
   * Get amendments for contract
   * GET /api/contracts/:id/amendments
   * Auth: parties to contract
   */
  @Get(':id/amendments')
  async getAmendments(@Param('id') contractId: string) {
    const amendments = await this.contractService.getContractAmendments(
      contractId,
    );
    return {
      success: true,
      data: amendments,
    };
  }

  /**
   * Approve/reject amendment
   * POST /api/contracts/amendments/:id/approve
   * Body: ApproveAmendmentDTO (approved: boolean)
   * Auth: buyer, seller (parties)
   */
  @Post('amendments/:id/approve')
  @Roles('buyer', 'seller')
  @HttpCode(HttpStatus.OK)
  async approveAmendment(
    @Param('id') amendmentId: string,
    @Request() req,
    @Body() dto: ApproveAmendmentDTO,
  ) {
    const amendment = await this.contractService.approveAmendment(
      amendmentId,
      req.user.id,
      dto,
    );
    return {
      success: true,
      message: amendment.status === 'approved' 
        ? 'Amendment approved and applied'
        : 'Amendment rejected',
      data: amendment,
    };
  }

  /**
   * Initiate dispute
   * POST /api/contracts/:id/dispute
   * Body: InitiateDisputeDTO
   * Auth: buyer, seller
   */
  @Post(':id/dispute')
  @Roles('buyer', 'seller')
  @HttpCode(HttpStatus.OK)
  async initiateDispute(
    @Param('id') contractId: string,
    @Request() req,
    @Body() dto: InitiateDisputeDTO,
  ) {
    const contract = await this.contractService.initiateDispute(
      contractId,
      req.user.id,
      dto,
    );
    return {
      success: true,
      message: 'Dispute initiated - mediator will be assigned',
      data: contract,
    };
  }

  /**
   * Resolve dispute (mediator only)
   * PATCH /api/contracts/:id/resolve-dispute
   * Body: { newStatus: 'active'|'terminated', adjustments: {...} }
   * Auth: admin (mediator)
   */
  @Patch(':id/resolve-dispute')
  @Roles('admin')
  @HttpCode(HttpStatus.OK)
  async resolveDispute(
    @Param('id') contractId: string,
    @Request() req,
    @Body() body: { newStatus: 'active' | 'terminated'; adjustments?: any },
  ) {
    const contract = await this.contractService.resolveDispute(
      contractId,
      req.user.id,
      body.newStatus,
      body.adjustments,
    );
    return {
      success: true,
      message: `Dispute resolved - contract ${body.newStatus}`,
      data: contract,
    };
  }

  /**
   * Get contract summary
   * GET /api/contracts/:id/summary
   * Auth: parties + admin
   */
  @Get(':id/summary')
  async getContractSummary(@Param('id') contractId: string) {
    const summary = await this.contractService.generateContractSummary(
      contractId,
    );
    return {
      success: true,
      data: summary,
    };
  }

  /**
   * Terminate contract
   * DELETE /api/contracts/:id
   * Query: reason
   * Auth: parties
   */
  @Delete(':id')
  @Roles('buyer', 'seller')
  @HttpCode(HttpStatus.OK)
  async terminateContract(
    @Param('id') contractId: string,
    @Request() req,
    @Query('reason') reason: string,
  ) {
    const contract = await this.contractService.terminateContract(
      contractId,
      req.user.id,
      reason,
    );
    return {
      success: true,
      message: 'Contract terminated',
      data: contract,
    };
  }
}

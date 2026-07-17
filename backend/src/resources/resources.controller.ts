import {
  Body,
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  Query,
  Req,
  UseGuards,
} from "@nestjs/common";
import { FirebaseAuthGuard } from "../common/firebase-auth.guard";
import { ResourcesService } from "./resources.service";

@Controller("api")
@UseGuards(FirebaseAuthGuard)
export class ResourcesController {
  constructor(private readonly resources: ResourcesService) {}

  @Get(":resource")
  list(
    @Param("resource") resource: string,
    @Req() request: any,
    @Query("limit") limit?: string,
    @Query("scope") scope?: string,
  ) {
    return this.resources.list(
      resource,
      request.user,
      Number(limit || 30),
      scope,
    );
  }

  @Get(":resource/:id")
  get(
    @Param("resource") resource: string,
    @Param("id") id: string,
    @Req() request: any,
  ) {
    return this.resources.get(resource, id, request.user);
  }

  @Post(":resource")
  create(
    @Param("resource") resource: string,
    @Body() body: any,
    @Req() request: any,
  ) {
    return this.resources.create(resource, body, request.user);
  }

  @Patch(":resource/:id")
  update(
    @Param("resource") resource: string,
    @Param("id") id: string,
    @Body() body: any,
    @Req() request: any,
  ) {
    return this.resources.update(resource, id, body, request.user);
  }
}

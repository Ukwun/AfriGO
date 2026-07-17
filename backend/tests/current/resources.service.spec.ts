import { ForbiddenException } from "@nestjs/common";
import { ResourcesService } from "../../src/resources/resources.service";

describe("ResourcesService authorization", () => {
  const collection = {
    doc: jest.fn(),
    where: jest.fn(),
  };
  const firebase = {
    collection: jest.fn(() => collection),
    serverTimestamp: jest.fn(() => "server-time"),
  } as any;
  const service = new ResourcesService(firebase);

  beforeEach(() => jest.clearAllMocks());

  it("prevents buyers from creating supplier lots", async () => {
    await expect(
      service.create(
        "lots",
        { productName: "Cocoa" },
        { uid: "buyer-1", role: "buyer", accountStatus: "active" },
      ),
    ).rejects.toBeInstanceOf(ForbiddenException);
  });

  it("prevents suppliers from creating buyer RFQs", async () => {
    await expect(
      service.create(
        "rfqs",
        { productName: "Cocoa" },
        { uid: "supplier-1", role: "supplier", accountStatus: "active" },
      ),
    ).rejects.toBeInstanceOf(ForbiddenException);
  });

  it("requires verified KYC for orders", async () => {
    await expect(
      service.create(
        "orders",
        { participantIds: ["supplier-1"] },
        {
          uid: "buyer-1",
          role: "buyer",
          accountStatus: "active",
          kycStatus: "pending",
        },
      ),
    ).rejects.toBeInstanceOf(ForbiddenException);
  });

  it("does not let clients manufacture notifications", async () => {
    await expect(
      service.create(
        "notifications",
        { title: "Fake status" },
        { uid: "buyer-1", role: "buyer", accountStatus: "active" },
      ),
    ).rejects.toBeInstanceOf(ForbiddenException);
  });
});

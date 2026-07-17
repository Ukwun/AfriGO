import { Injectable } from '@nestjs/common';
import { FirebaseService } from '../firebase/firebase.service';

@Injectable()
export class AnalyticsService {
  constructor(private readonly firebase: FirebaseService) {}

  async market(user: any) {
    const [lots, offers, shipments] = await Promise.all([
      this.visible('lots', user.uid),
      this.visible('offers', user.uid),
      this.visible('shipments', user.uid),
    ]);
    const activeLots = lots.filter((lot) => ['active', 'published'].includes(lot.status));
    const prices = activeLots
      .map((lot) => Number(lot.pricePerUnit ?? lot.price))
      .filter((price) => Number.isFinite(price) && price > 0);
    const averagePrice = prices.length
      ? prices.reduce((sum, price) => sum + price, 0) / prices.length
      : null;
    return {
      data: {
        activeLots: activeLots.length,
        activeOffers: offers.filter((offer) => !['rejected', 'withdrawn'].includes(offer.status)).length,
        shipmentsInProgress: shipments.filter((shipment) =>
          !['delivered', 'cancelled'].includes(shipment.status)).length,
        averagePrice,
        currency: this.singleCurrency(activeLots),
        calculatedAt: new Date().toISOString(),
      },
    };
  }

  private async visible(collection: string, uid: string) {
    const snapshot = await this.firebase
      .collection(collection)
      .where('participantIds', 'array-contains', uid)
      .limit(500)
      .get();
    return snapshot.docs.map((document) => ({ id: document.id, ...document.data() } as any));
  }

  private singleCurrency(lots: any[]) {
    const currencies = new Set(lots.map((lot) => lot.currency).filter(Boolean));
    return currencies.size === 1 ? [...currencies][0] : null;
  }
}

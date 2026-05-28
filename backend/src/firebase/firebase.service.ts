import { Injectable } from '@nestjs/common';
import * as admin from 'firebase-admin';

@Injectable()
export class FirebaseService {
  private db: FirebaseFirestore.Firestore;

  constructor() {
    const serviceAccount = {
      projectId: process.env.FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
    };

    if (!admin.apps.length) {
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount as admin.ServiceAccount),
      });
    }

    this.db = admin.firestore();
  }

  getFirestore(): FirebaseFirestore.Firestore {
    return this.db;
  }

  // Collections
  users() {
    return this.db.collection('users');
  }

  lots() {
    return this.db.collection('lots');
  }

  orders() {
    return this.db.collection('orders');
  }

  transactions() {
    return this.db.collection('transactions');
  }
}

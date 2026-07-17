import { Injectable } from "@nestjs/common";
import * as admin from "firebase-admin";

@Injectable()
export class FirebaseService {
  private db: FirebaseFirestore.Firestore;

  constructor() {
    if (!admin.apps.length) {
      const hasInlineCredentials =
        process.env.FIREBASE_PROJECT_ID &&
        process.env.FIREBASE_CLIENT_EMAIL &&
        process.env.FIREBASE_PRIVATE_KEY;
      const credential = hasInlineCredentials
        ? admin.credential.cert({
            projectId: process.env.FIREBASE_PROJECT_ID,
            clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
            privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, "\n"),
          } as admin.ServiceAccount)
        : admin.credential.applicationDefault();
      admin.initializeApp({
        credential,
        projectId: process.env.FIREBASE_PROJECT_ID,
        storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
      });
    }

    this.db = admin.firestore();
  }

  getFirestore(): FirebaseFirestore.Firestore {
    return this.db;
  }

  getAuth(): admin.auth.Auth {
    return admin.auth();
  }

  async verifyIdToken(token: string): Promise<admin.auth.DecodedIdToken> {
    return this.getAuth().verifyIdToken(token, true);
  }

  serverTimestamp(): FirebaseFirestore.FieldValue {
    return admin.firestore.FieldValue.serverTimestamp();
  }

  collection(name: string): FirebaseFirestore.CollectionReference {
    return this.db.collection(name);
  }

  // Collections
  users() {
    return this.db.collection("users");
  }

  lots() {
    return this.db.collection("lots");
  }

  orders() {
    return this.db.collection("orders");
  }

  transactions() {
    return this.db.collection("transactions");
  }
}

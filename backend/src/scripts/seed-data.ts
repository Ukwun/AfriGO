import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { Repository } from 'typeorm';
import { User } from '../modules/auth/entities/user.entity';
import { UserRole } from '../modules/auth/entities/user-role.entity';
import { Lot } from '../modules/lots/entities/lot.entity';
import * as bcrypt from 'bcrypt';

/**
 * DATABASE SEEDING SCRIPT
 * Populates database with realistic sample data for testing
 * 
 * Usage: npx ts-node src/scripts/seed-data.ts
 */

async function main() {
  const app = await NestFactory.create(AppModule);
  const dataSource = app.get('DataSource');

  // Get repositories
  const userRepo = dataSource.getRepository(User);
  const roleRepo = dataSource.getRepository(UserRole);
  const lotRepo = dataSource.getRepository(Lot);

  console.log('🌱 Starting database seeding...');

  try {
    // Step 1: Create roles
    console.log('\n📋 Creating roles...');
    const buyerRole = await roleRepo.findOne({ where: { name: 'buyer' } });
    const sellerRole = await roleRepo.findOne({ where: { name: 'seller' } });
    const exporterRole = await roleRepo.findOne({ where: { name: 'exporter' } });

    if (!buyerRole) {
      await roleRepo.save({
        name: 'buyer',
        description: 'Can view lots, submit RFQs, make purchases',
        permissions: ['view_lots', 'submit_rfq', 'make_payment'],
      });
      console.log('✅ Created buyer role');
    }

    if (!sellerRole) {
      await roleRepo.save({
        name: 'seller',
        description: 'Can create lots, sell commodities',
        permissions: ['create_lot', 'view_orders', 'manage_payment'],
      });
      console.log('✅ Created seller role');
    }

    if (!exporterRole) {
      await roleRepo.save({
        name: 'exporter',
        description: 'Can manage export pipelines, compliance docs',
        permissions: ['manage_shipments', 'export_docs', 'track_delivery'],
      });
      console.log('✅ Created exporter role');
    }

    // Step 2: Create sample users
    console.log('\n👥 Creating sample users...');
    
    const sampleUsers = [
      {
        email: 'john.supplier@afrigo.com',
        phone: '+233712345671',
        firstName: 'John',
        lastName: 'Mensah',
        password: 'TestPassword123!',
        organization: 'Mensah Farms',
        khAddress: 'Accra, Ghana',
        roles: ['seller'],
      },
      {
        email: 'jane.buyer@afrigo.com',
        phone: '+233712345672',
        firstName: 'Jane',
        lastName: 'Owusu',
        password: 'TestPassword123!',
        organization: 'Global Trade Corp',
        khAddress: 'Kumasi, Ghana',
        roles: ['buyer'],
      },
      {
        email: 'mark.exporter@afrigo.com',
        phone: '+233712345673',
        firstName: 'Mark',
        lastName: 'Boateng',
        password: 'TestPassword123!',
        organization: 'Africa Export Ltd',
        khAddress: 'Tema, Ghana',
        roles: ['exporter'],
      },
      {
        email: 'amara.supplier@afrigo.com',
        phone: '+233712345674',
        firstName: 'Amara',
        lastName: 'Kone',
        password: 'TestPassword123!',
        organization: 'Kone Cooperative',
        khAddress: 'Abidjan, Ivory Coast',
        roles: ['seller'],
      },
      {
        email: 'david.buyer@afrigo.com',
        phone: '+233712345675',
        firstName: 'David',
        lastName: 'Chen',
        password: 'TestPassword123!',
        organization: 'Asian Import One',
        khAddress: 'Shanghai, China',
        roles: ['buyer'],
      },
    ];

    const createdUsers = [];
    for (const userData of sampleUsers) {
      let user = await userRepo.findOne({ where: { email: userData.email } });
      
      if (!user) {
        const hashedPassword = await bcrypt.hash(userData.password, 10);
        const rolesData = await roleRepo.find({
          where: userData.roles.map(r => ({ name: r })),
        });

        user = userRepo.create({
          email: userData.email,
          phone: userData.phone,
          firstName: userData.firstName,
          lastName: userData.lastName,
          password: hashedPassword,
          organization: userData.organization,
          khAddress: userData.khAddress,
          roles: rolesData,
          isEmailVerified: true,
          isPhoneVerified: true,
          kycStatus: 'verified',
        });

        await userRepo.save(user);
        console.log(`✅ Created user: ${userData.firstName} ${userData.lastName}`);
      }
      
      createdUsers.push(user);
    }

    // Step 3: Create sample lots
    console.log('\n📦 Creating sample lots...');

    const sampleLots = [
      {
        productName: 'Grade A Organic Cocoa Beans',
        quantity: 500,
        unit: 'kg',
        pricePerUnit: 45.50,
        quality: 'A',
        pickupLocation: 'Accra, Ghana',
        description: 'High-quality organic cocoa from Mensah Farms',
        status: 'active',
      },
      {
        productName: 'Premium Arabica Coffee',
        quantity: 200,
        unit: 'kg',
        pricePerUnit: 85.00,
        quality: 'A',
        pickupLocation: 'Kumasi, Ghana',
        description: 'Single-origin arabica coffee',
        status: 'active',
      },
      {
        productName: 'Cashew Nuts - Raw',
        quantity: 300,
        unit: 'kg',
        pricePerUnit: 28.75,
        quality: 'B',
        pickupLocation: 'Abidjan, Ivory Coast',
        description: 'Fresh raw cashew nuts',
        status: 'active',
      },
      {
        productName: 'Grade B Cocoa Beans',
        quantity: 400,
        unit: 'kg',
        pricePerUnit: 35.00,
        quality: 'B',
        pickupLocation: 'Tema, Ghana',
        description: 'Grade B cocoa beans suitable for processing',
        status: 'active',
      },
      {
        productName: 'Robusta Coffee - Bulk',
        quantity: 250,
        unit: 'kg',
        pricePerUnit: 42.00,
        quality: 'B',
        pickupLocation: 'Accra, Ghana',
        description: 'Bulk robusta coffee for businesses',
        status: 'active',
      },
      {
        productName: 'Shea Butter - Pure',
        quantity: 150,
        unit: 'kg',
        pricePerUnit: 65.00,
        quality: 'A',
        pickupLocation: 'Kumasi, Ghana',
        description: 'Pure unrefined shea butter',
        status: 'active',
      },
      {
        productName: 'Ginger - Fresh',
        quantity: 80,
        unit: 'kg',
        pricePerUnit: 12.50,
        quality: 'A',
        pickupLocation: 'Accra, Ghana',
        description: 'Fresh ginger rhizomes',
        status: 'active',
      },
      {
        productName: 'Black Pepper - Ground',
        quantity: 120,
        unit: 'kg',
        pricePerUnit: 18.00,
        quality: 'B',
        pickupLocation: 'Tema, Ghana',
        description: 'Ground black pepper',
        status: 'active',
      },
      {
        productName: 'Rice - White Long Grain',
        quantity: 1000,
        unit: 'kg',
        pricePerUnit: 8.50,
        quality: 'B',
        pickupLocation: 'Delta, Nigeria',
        description: 'White long grain rice - bulk',
        status: 'active',
      },
      {
        productName: 'Plantains - Fresh',
        quantity: 500,
        unit: 'kg',
        pricePerUnit: 5.00,
        quality: 'A',
        pickupLocation: 'Lagos, Nigeria',
        description: 'Fresh green plantains',
        status: 'active',
      },
      {
        productName: 'Honey - Pure',
        quantity: 100,
        unit: 'kg',
        pricePerUnit: 55.00,
        quality: 'A',
        pickupLocation: 'Accra, Ghana',
        description: 'Pure raw honey from our apiaries',
        status: 'active',
      },
      {
        productName: 'Sesame Seeds - White',
        quantity: 75,
        unit: 'kg',
        pricePerUnit: 22.00,
        quality: 'A',
        pickupLocation: 'Kano, Nigeria',
        description: 'High-quality white sesame seeds',
        status: 'active',
      },
      {
        productName: 'Hibiscus Flowers - Dried',
        quantity: 50,
        unit: 'kg',
        pricePerUnit: 38.00,
        quality: 'A',
        pickupLocation: 'Accra, Ghana',
        description: 'Dried organic hibiscus flowers',
        status: 'active',
      },
      {
        productName: 'Coconut Oil - Virgin',
        quantity: 200,
        unit: 'kg',
        pricePerUnit: 42.00,
        quality: 'A',
        pickupLocation: 'Tema, Ghana',
        description: 'Cold-pressed virgin coconut oil',
        status: 'active',
      },
      {
        productName: 'Cinnamon - Quills',
        quantity: 60,
        unit: 'kg',
        pricePerUnit: 28.00,
        quality: 'A',
        pickupLocation: 'Colombo, Sri Lanka',
        description: 'Ceylon cinnamon quills',
        status: 'active',
      },
      {
        productName: 'Turmeric - Ground',
        quantity: 90,
        unit: 'kg',
        pricePerUnit: 15.00,
        quality: 'B',
        pickupLocation: 'Accra, Ghana',
        description: 'Ground turmeric powder',
        status: 'active',
      },
      {
        productName: 'Cardamom - Green',
        quantity: 40,
        unit: 'kg',
        pricePerUnit: 65.00,
        quality: 'A',
        pickupLocation: 'Guatemala City, Guatemala',
        description: 'Premium green cardamom',
        status: 'active',
      },
      {
        productName: 'Vanilla Beans',
        quantity: 25,
        unit: 'kg',
        pricePerUnit: 185.00,
        quality: 'A',
        pickupLocation: 'Kumasi, Ghana',
        description: 'Grade A Madagascar vanilla beans',
        status: 'active',
      },
      {
        productName: 'Cloves - Whole',
        quantity: 70,
        unit: 'kg',
        pricePerUnit: 32.00,
        quality: 'A',
        pickupLocation: 'Tema, Ghana',
        description: 'Premium whole cloves',
        status: 'active',
      },
      {
        productName: 'Nutmeg - Ground',
        quantity: 55,
        unit: 'kg',
        pricePerUnit: 24.00,
        quality: 'B',
        pickupLocation: 'Accra, Ghana',
        description: 'Ground nutmeg spice',
        status: 'active',
      },
    ];

    const seller1 = createdUsers.find(u => u.email === 'john.supplier@afrigo.com');
    const seller2 = createdUsers.find(u => u.email === 'amara.supplier@afrigo.com');

    let lotsCreated = 0;
    for (let i = 0; i < sampleLots.length; i++) {
      const lotData = sampleLots[i];
      const seller = i % 2 === 0 ? seller1 : seller2;

      const existingLot = await lotRepo.findOne({
        where: { 
          productName: lotData.productName,
          sellerId: seller.id,
        },
      });

      if (!existingLot) {
        const lot = lotRepo.create({
          ...lotData,
          sellerId: seller.id,
          qrCode: this.generateQRCode(seller.id, lotData.productName),
          verifyStatus: 'verified',
          status: 'active',
          averageRating: Math.floor(Math.random() * 2) + 4, // 4-5 stars
        });

        await lotRepo.save(lot);
        lotsCreated++;
      }
    }

    console.log(`✅ Created ${lotsCreated} sample lots`);

    console.log('\n✨ Database seeding completed successfully!');
    console.log('\n📊 Summary:');
    console.log(`   - Users created: ${createdUsers.length}`);
    console.log(`   - Lots created: ${lotsCreated}`);
    console.log(`   - Test user (buyer): jane.buyer@afrigo.com / TestPassword123!`);
    console.log(`   - Test user (seller): john.supplier@afrigo.com / TestPassword123!`);
    console.log(`   - Test user (exporter): mark.exporter@afrigo.com / TestPassword123!`);

  } catch (error) {
    console.error('❌ Seeding failed:', error);
  } finally {
    await app.close();
  }
}

function generateQRCode(userId: string, productName: string): string {
  const crypto = require('crypto');
  const hash = crypto.createHash('sha256');
  hash.update(`${userId}-${productName}-${Date.now()}`);
  return hash.digest('hex').substring(0, 16).toUpperCase();
}

main().catch(console.error);

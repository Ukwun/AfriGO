import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, OneToMany } from 'typeorm';
import { LotEntity } from './lot.entity';

@Entity('product_categories')
export class ProductCategoryEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 100, nullable: false })
  name: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'jsonb', default: () => "'[\"A\", \"B\", \"C\"]'" })
  commonGrades: string[];

  @Column({ type: 'varchar', length: 100, nullable: true })
  category: string; // 'coffee', 'cocoa', 'cashew', 'grain', etc.

  @Column({ type: 'jsonb', nullable: true, default: () => "'{}'" })
  standardSpecs: Record<string, any>; // Standard specifications for this category

  @Column({ type: 'boolean', default: true })
  isActive: boolean;

  @OneToMany(() => LotEntity, (lot) => lot.productCategory)
  lots: LotEntity[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

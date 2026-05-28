import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToMany,
  Index,
} from 'typeorm';
import { User } from './user.entity';

/**
 * UserRole Entity - Defines user roles and permissions
 * AfriGo supports multiple roles per user
 *
 * Standard Roles:
 * - supplier: Can create lots, sell commodities
 * - buyer: Can view lots, submit RFQs, make purchases
 * - exporter: Can export goods, manage documentation
 * - logistics: Can manage shipments, track deliveries
 * - compliance: Can verify KYC, review documents
 * - admin: Full platform access
 */
@Entity('user_roles')
@Index(['name'], { unique: true })
export class UserRole {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  /**
   * Role identifier
   * Examples: 'supplier', 'buyer', 'exporter', 'logistics', 'compliance', 'admin'
   */
  @Column({ type: 'varchar', length: 100 })
  name: string;

  /**
   * Human-readable description
   */
  @Column({ type: 'varchar', length: 500 })
  description: string;

  /**
   * JSON array of permissions
   * Examples: ['create_lot', 'view_lots', 'submit_bid', 'make_payment']
   * This is stored as JSON for flexibility (SQLite-compatible)
   */
  @Column({ type: 'simple-json', default: [] })
  permissions: string[];

  /**
   * Is this a default role (assigned automatically based on KYC type)?
   */
  @Column({ type: 'boolean', default: false })
  isDefault: boolean;

  /**
   * Can this role be assigned manually by admins?
   */
  @Column({ type: 'boolean', default: true })
  isAssignable: boolean;

  /**
   * Many-to-Many: Multiple users can have this role
   */
  @ManyToMany(() => User, (user) => user.roles)
  users: User[];

  /**
   * Created timestamp
   */
  @CreateDateColumn({ type: 'datetime' })
  createdAt: Date;

  /**
   * Check if role has a specific permission
   */
  hasPermission(permission: string): boolean {
    return this.permissions.includes(permission);
  }
}

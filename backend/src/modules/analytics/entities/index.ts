// Analytics entities
export { BehavioralAnomaly } from './behavioral-anomaly.entity';
export { Recommendation } from './recommendation.entity';
export { AnalyticsSummary } from './analytics-summary.entity';
export { Cohort } from './cohort.entity';
export { UserSegment } from './user-segment.entity';
export { UserActivityLog } from './user-activity-log.entity';

// Placeholder types for missing entities (used by User relationships)
export type UserActivity = any;
export type UserSession = any;
export type PageView = any;
export type UserMetric = any;
export type Event = any;

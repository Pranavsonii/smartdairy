# API Performance Optimization Plan

## Critical Issues Identified

1. **N+1 Query Problems** - Multiple separate queries in loops (e.g., `getCustomers` fetches QR codes and transactions for each customer separately)
2. **Large Default Page Sizes** - Default limit of 500 records is too large for mobile apps
3. **Missing Database Indexes** - No indexes on foreign keys and frequently queried columns
4. **No Response Compression** - Missing compression middleware
5. **Unoptimized Connection Pooling** - No pool configuration (max connections, idle timeout)
6. **Large Payloads** - Fetching all transactions for customers unnecessarily
7. **Inefficient Subqueries** - Using subqueries in SELECT statements instead of JOINs
8. **No Caching Layer** - Frequently accessed data not cached
9. **No Rate Limiting** - Could cause performance degradation under load

## Implementation Plan

### Phase 1: Database Optimization (High Impact)

#### 1.1 Add Database Indexes

**Files**: Create new migration file `migrations/add-performance-indexes.js`

Add indexes on:

- `customers.status`, `customers.location`, `customers.name`
- `payment_logs.customer_id`, `payment_logs.date`, `payment_logs.status`
- `point_transactions.customer_id`, `point_transactions.date`
- `qr_codes.customer_id`, `qr_codes.code`
- `drives.route_id`, `drives.delivery_guy_id`, `drives.status`, `drives.created_at`
- `drive_customers_sales.drive_id`, `drive_customers_sales.customer_id`
- `route_customers.route_id`, `route_customers.customer_id`
- `delivery_guys.is_active`, `delivery_guys.phone`

#### 1.2 Optimize Connection Pooling

**File**: `config/database.js`

Configure pool with:

- `max: 20` (max connections)
- `min: 2` (min idle connections)
- `idleTimeoutMillis: 30000`
- `connectionTimeoutMillis: 2000`

#### 1.3 Fix N+1 Query Problems

**File**: `controllers/customerController.js`

**In `getCustomers` function (lines 5-124)**:

- Replace individual QR code queries with LEFT JOIN
- Replace individual transaction queries with aggregated subquery or remove if not needed
- Use single query with JOINs instead of Promise.all with multiple queries

**Example fix**:

```sql
SELECT c.*,
       qr.* as qr,
       COALESCE(SUM(CASE WHEN pt.transaction_type = 'credit' THEN pt.points ELSE -pt.points END), 0) as points
FROM customers c
LEFT JOIN qr_codes qr ON c.customer_id = qr.customer_id
LEFT JOIN point_transactions pt ON c.customer_id = pt.customer_id
GROUP BY c.customer_id, qr.qr_id
```

#### 1.4 Optimize Subqueries

**File**: `controllers/deliveryPersonController.js`

**In `getDeliveryPersons` (lines 4-21)**:

- Replace subquery in SELECT with LEFT JOIN
- Change from `(SELECT COUNT(*) FROM users...)` to proper JOIN

### Phase 2: API Response Optimization (High Impact)

#### 2.1 Add Response Compression

**File**: `index.js`

Add `compression` middleware:

```javascript
import compression from "compression";
app.use(compression());
```

#### 2.2 Reduce Default Page Sizes

**Files**: All controller files with pagination

Change default limits from 500 to:

- `controllers/customerController.js` - line 11: `limit = 20`
- `controllers/paymentController.js` - line 38: `limit = 20`
- `controllers/driveController.js` - line 7: `limit = 20`
- `controllers/deliveryPersonController.js` - line 326: `limit = 20`
- `controllers/reportController.js` - Remove or limit large result sets

#### 2.3 Optimize Transaction Fetching

**File**: `controllers/customerController.js`

**In `getCustomers` (lines 86-100)**:

- Remove fetching all transactions for each customer in list view
- Only fetch transactions when viewing individual customer details
- Or limit to last 10 transactions with pagination

**In `getCustomerById` (lines 171-300)**:

- Already has pagination, but ensure default limit is reasonable (e.g., 50 instead of 500)

#### 2.4 Add Response Field Selection

**File**: Create middleware `middlewares/fieldSelection.js`

Allow clients to specify which fields they need using query parameter `fields=name,phone,location`

### Phase 3: Caching Layer (Medium Impact)

#### 3.1 Add Redis Caching (Optional - if Redis available)

**File**: Create `utils/cache.js`

Cache frequently accessed data:

- Customer lists (5 min TTL)
- Route lists (10 min TTL)
- Delivery person lists (5 min TTL)
- Customer details (2 min TTL)

#### 3.2 Add In-Memory Caching (If Redis not available)

**File**: Create `utils/memoryCache.js`

Simple in-memory cache with TTL for:

- Static/semi-static data (routes, delivery persons)
- Cache invalidation on updates

### Phase 4: Query Optimization (Medium Impact)

#### 4.1 Optimize Report Queries

**File**: `controllers/reportController.js`

**In `getRoutesReport` (lines 148-220)**:

- Replace multiple queries per route with single aggregated query using JOINs
- Use window functions or CTEs for better performance

**In `getCustomersReport` (lines 3-76)**:

- Optimize LEFT JOIN subqueries
- Consider materialized views for complex reports

#### 4.2 Add Query Result Limits

**File**: All controllers

Add maximum limit cap (e.g., max 100 records per request) to prevent abuse

### Phase 5: Additional Optimizations (Low-Medium Impact)

#### 5.1 Add Rate Limiting

**File**: `index.js`

Add `express-rate-limit` middleware:

```javascript
import rateLimit from "express-rate-limit";
const limiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 100 });
app.use("/api/", limiter);
```

#### 5.2 Optimize Photo URL Generation

**File**: `controllers/customerController.js`

- Generate photo URLs only when needed
- Consider CDN for static assets
- Use environment variable for base URL instead of `req.get('host')`

#### 5.3 Add Database Query Logging (Development)

**File**: `config/database.js`

Add query logging in development to identify slow queries:

```javascript
if (config.nodeEnv === "development") {
  pool.on("query", (query) => console.log("Query:", query.text));
}
```

#### 5.4 Optimize Date Filtering

**Files**: Multiple controllers

Replace `CAST(d.created_at AS TEXT) LIKE` with proper date range queries using `>=` and `<=`

### Phase 6: Monitoring & Testing

#### 6.1 Add Response Time Logging

**File**: Create middleware `middlewares/responseTime.js`

Log slow requests (>1 second) for monitoring

#### 6.2 Performance Testing

- Test endpoints with realistic data volumes
- Measure response times before/after optimizations
- Use tools like `autocannon` or `artillery` for load testing

## Priority Order

1. **Immediate (Do First)**:

   - Fix N+1 queries in `getCustomers`
   - Add database indexes
   - Reduce default page sizes
   - Add response compression
   - Optimize connection pooling

2. **High Priority (Do Next)**:

   - Optimize subqueries in delivery person controller
   - Remove unnecessary transaction fetching
   - Optimize report queries

3. **Medium Priority**:

   - Add caching layer
   - Add rate limiting
   - Optimize date filtering

4. **Nice to Have**:

   - Field selection middleware
   - Query logging
   - Response time monitoring

## Expected Performance Improvements

- **Database queries**: 50-80% faster with indexes and optimized queries
- **Response sizes**: 30-50% smaller with compression and reduced payloads
- **API response times**: 60-70% improvement overall
- **Mobile app experience**: Significantly faster load times, especially for lists

## Notes

- Test each change incrementally
- Monitor database performance after adding indexes
- Consider database connection limits when configuring pool
- Cache invalidation strategy needed if implementing caching
- Mobile apps should implement proper pagination on client side

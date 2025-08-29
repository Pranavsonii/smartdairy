# Milk Delivery Management System API Documentation

## Core APIs

### 1. Authentication APIs

1. `POST /api/auth/login` - Authenticate users (admin and delivery personnel)
2. `POST /api/auth/logout` - End user session
3. `POST /api/auth/reset-password` - Password reset request
4. `GET /api/auth/me` - Get current user profile

### 2. Customer Management APIs

1. `GET /api/customers` - List all customers (with pagination and filters)
2. `GET /api/customers/:id` - Get customer details by ID
3. `POST /api/customers` - Create new customer
4. `PUT /api/customers/:id` - Update customer information
5. `DELETE /api/customers/:id` - Delete customer
6. `GET /api/customers/:id/points` - Get customer points
7. `POST /api/customers/:id/points` - Add points to customer
8. `PUT /api/customers/:id/points/deduct` - Deduct points from customer
9. `GET /api/customers/:id/payment-logs` - Get customer payment history

### 3. Route Management APIs

1. `GET /api/routes` - List all routes
2. `GET /api/routes/:id` - Get route details
3. `POST /api/routes` - Create new route
4. `PUT /api/routes/:id` - Update route
5. `DELETE /api/routes/:id` - Delete route
6. `POST /api/routes/:id/customers` - Add customers to a route
7. `DELETE /api/routes/:id/customers/:customer_id` - Remove customer from route
8. `GET /api/routes/:id/customers` - Get customers in a route

### 4. Drive Management APIs

1. `GET /api/drives` - List all drives
2. `GET /api/drives/:id` - Get drive details
3. `POST /api/drives` - Create new drive
4. `PUT /api/drives/:id` - Update drive
5. `DELETE /api/drives/:id` - Delete drive
6. `GET /api/drives/:id/details` - Get complete drive with customer list
7. `POST /api/drives/:id/assign` - Assign delivery person to drive
8. `POST /api/drives/:id/start` - Start drive
9. `POST /api/drives/:id/end` - End drive
10. `GET /api/drives/:id/locations` - Get location history for drive
11. `POST /api/drives/:id/locations` - Log new location for drive
12. `GET /api/drives/:id/summary` - Get financial summary for drive
13. `GET /api/drives/:id/manifest` - Get delivery manifest for drive

### 5. Payment Log Management APIs

1. `GET /api/payments` - List all payments (with pagination)
2. `GET /api/payments/:id` - Get payment details
3. `POST /api/payments` - Create new payment
4. `PUT /api/payments/:id` - Update payment
5. `DELETE /api/payments/:id` - Delete payment
6. `GET /api/payments/overdue` - Get list of overdue accounts
7. `POST /api/payments/:id/receipt` - Generate receipt for payment
8. `POST /api/payments/:id/send-receipt` - Send receipt via SMS/Email

### 6. QR Management APIs

1. `GET /api/qr-codes` - List all QR codes
2. `GET /api/qr-codes/:id` - Get QR code details
3. `POST /api/qr-codes/generate` - Generate new QR codes (bulk)
4. `POST /api/qr-codes/:id/assign` - Assign QR to customer
5. `PUT /api/qr-codes/:id/status` - Update QR code status
6. `GET /api/qr-codes/download` - Download QR codes as PDF
7. `POST /api/qr-codes/:id/replace` - Replace damaged/lost QR code

### 7. Drive Execution APIs

1. `GET /api/drive-execution/:id` - Get active drive execution details
2. `POST /api/drive-execution/:id/sales` - Record sales during drive
3. `POST /api/drive-execution/:id/skip-customer` - Skip customer during drive
4. `POST /api/drive-execution/:id/scan` - Process QR scan during drive
5. `GET /api/drive-execution/:id/progress` - Get drive progress
6. `POST /api/drive-execution/:id/reconcile` - Reconcile sales and returns

### 8. Report APIs

1. `GET /api/reports/customers` - Generate customer details report
2. `GET /api/reports/payments` - Generate payment logs report
3. `GET /api/reports/routes` - Generate routes report
4. `GET /api/reports/drives` - Generate drives report
5. `GET /api/reports/custom` - Generate custom date range report

## Additional Recommended APIs

### 9. User Management APIs

1. `GET /api/users` - List all users (admin only)
2. `POST /api/users` - Create new user (admin only)
3. `PUT /api/users/:id` - Update user details
4. `DELETE /api/users/:id` - Delete user
5. `PUT /api/users/:id/role` - Update user role

### 10. Delivery Person APIs

1. `GET /api/delivery-persons` - List all delivery persons
2. `GET /api/delivery-persons/:id` - Get delivery person details
3. `POST /api/delivery-persons` - Create delivery person
4. `PUT /api/delivery-persons/:id` - Update delivery person
5. `DELETE /api/delivery-persons/:id` - Delete delivery person
6. `GET /api/delivery-persons/:id/drives` - Get drives assigned to delivery person
7. `GET /api/delivery-persons/:id/performance` - Get performance metrics

### 11. Inventory Management APIs

1. `GET /api/inventory` - Get current inventory
2. `POST /api/inventory/add` - Add inventory
3. `POST /api/inventory/deduct` - Deduct inventory
4. `GET /api/inventory/low-stock` - Get low stock alerts

### 12. Map and Location APIs

1. `GET /api/map/route-optimization/:route_id` - Get optimized route
2. `GET /api/map/distance-matrix` - Get distance matrix for locations
3. `GET /api/map/geocode/:address` - Geocode customer address
4. `GET /api/map/reverse-geocode/:lat/:lng` - Reverse geocode coordinates

### 13. Analytics APIs

1. `GET /api/analytics/sales` - Get sales analytics
2. `GET /api/analytics/customers` - Get customer growth metrics
3. `GET /api/analytics/routes` - Get route efficiency metrics
4. `GET /api/analytics/payments` - Get payment trend analytics
5. `GET /api/analytics/delivery-persons` - Get delivery person performance

### 14. Notification APIs

1. `GET /api/notifications` - Get user notifications
2. `POST /api/notifications/read/:id` - Mark notification as read
3. `POST /api/notifications/send` - Send notification to user(s)
4. `POST /api/notifications/schedule` - Schedule notification

### 15. Settings APIs

1. `GET /api/settings` - Get application settings
2. `PUT /api/settings` - Update application settings
3. `GET /api/settings/business` - Get business configuration
4. `PUT /api/settings/business` - Update business configuration

### 16. Offline Sync APIs

1. `POST /api/sync/upload` - Upload offline data
2. `GET /api/sync/download/:entityType` - Download data for offline use
3. `GET /api/sync/status` - Check sync status
4. `POST /api/sync/resolve-conflicts` - Resolve data conflicts

### 17. Export APIs

1. `GET /api/export/customers` - Export customers data (CSV/Excel)
2. `GET /api/export/payments` - Export payments data (CSV/Excel)
3. `GET /api/export/routes` - Export routes data (CSV/Excel)
4. `GET /api/export/drives` - Export drives data (CSV/Excel)

### 18. Utility APIs

1. `GET /api/utils/health` - API health check
2. `GET /api/utils/version` - Get application version
3. `POST /api/utils/feedback` - Submit user feedback
4. `GET /api/utils/metrics` - Get system metrics (admin only)

---

## API Implementation Notes

1. **Authentication and Authorization**:

   - All APIs should require authentication except login and password reset
   - Role-based access control should be implemented (admin vs. delivery person)
   - JWT or similar token-based auth recommended

2. **Response Format**:

   - Standardize on consistent JSON response format
   - Include metadata for pagination where applicable
   - Use appropriate HTTP status codes

3. **Performance Considerations**:

   - Implement caching where appropriate (e.g., routes, customer lists)
   - Optimize location tracking APIs for minimal battery usage
   - Use compression for larger datasets

4. **Mobile-Specific Optimizations**:

   - Minimize payload sizes for mobile data efficiency
   - Support partial responses and fields filtering
   - Implement proper error handling with meaningful messages

5. **Offline Support**:
   - Design APIs to support offline-first operations
   - Implement robust conflict resolution mechanisms
   - Use ETags or Last-Modified headers for efficient syncing

This API structure provides a comprehensive foundation for implementing the Milk Delivery Management System while ensuring scalability, efficiency, and maintainability.


# Sample JSON Data for Milk Delivery Management System Frontend

Here are sample JSON data structures that can be used for creating a frontend application that works with your API. These represent common API responses for key entities in your system.

## 1. Authentication Responses

### Login Response
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "user_id": 1,
    "phone": "9876543210",
    "role": "admin",
    "created_at": "2025-04-01T10:30:00Z"
  },
  "message": "Login successful"
}
```

### Current User Response
```json
{
  "user_id": 1,
  "phone": "9876543210",
  "role": "admin",
  "delivery_guy_id": null,
  "created_at": "2025-04-01T10:30:00Z",
  "updated_at": "2025-04-01T10:30:00Z"
}
```

## 2. Customers Data

### Get Customers List Response
```json
{
  "customers": [
    {
      "customer_id": 1,
      "name": "John Doe",
      "location": "Downtown",
      "phone": "9876543210",
      "address": "123 Main St, Apt 4B",
      "price": 30.00,
      "points": 120,
      "status": "active",
      "default_quantity": 2,
      "created_at": "2025-03-10T08:45:22Z",
      "updated_at": "2025-04-15T14:22:10Z"
    },
    {
      "customer_id": 2,
      "name": "Jane Smith",
      "location": "Uptown",
      "phone": "9876543211",
      "address": "456 Oak Ave",
      "price": 28.00,
      "points": 80,
      "status": "active",
      "default_quantity": 1,
      "created_at": "2025-03-15T10:20:45Z",
      "updated_at": "2025-04-10T09:15:30Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "totalCount": 45,
    "totalPages": 5
  }
}
```

### Customer Details Response
```json
{
  "customer_id": 1,
  "name": "John Doe",
  "location": "Downtown",
  "phone": "9876543210",
  "address": "123 Main St, Apt 4B",
  "price": 30.00,
  "points": 120,
  "status": "active",
  "default_quantity": 2,
  "created_at": "2025-03-10T08:45:22Z",
  "updated_at": "2025-04-15T14:22:10Z",
  "routes": [
    {
      "route_id": 2,
      "name": "Downtown Morning Route"
    },
    {
      "route_id": 5,
      "name": "Weekend Special Route"
    }
  ],
  "qrCode": {
    "qr_id": 12,
    "code": "a8f5e7d9-c123-48b7-9a52-7e85f6b2c941",
    "status": "active"
  }
}
```

## 3. Routes Data

### Routes List Response
```json
{
  "routes": [
    {
      "route_id": 1,
      "name": "North Zone Morning",
      "created_at": "2025-02-10T09:00:00Z",
      "updated_at": "2025-03-15T11:30:00Z",
      "customer_count": 12
    },
    {
      "route_id": 2,
      "name": "Downtown Morning Route",
      "created_at": "2025-02-15T09:00:00Z",
      "updated_at": "2025-03-20T11:30:00Z",
      "customer_count": 8
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "totalCount": 8,
    "totalPages": 1
  }
}
```

### Route Details with Customers Response
```json
{
  "route_id": 1,
  "name": "North Zone Morning",
  "created_at": "2025-02-10T09:00:00Z",
  "updated_at": "2025-03-15T11:30:00Z",
  "customers": [
    {
      "customer_id": 1,
      "name": "John Doe",
      "location": "Downtown",
      "phone": "9876543210",
      "address": "123 Main St, Apt 4B",
      "default_quantity": 2,
      "status": "active"
    },
    {
      "customer_id": 3,
      "name": "Robert Johnson",
      "location": "Northside",
      "phone": "9876543212",
      "address": "789 Pine Rd",
      "default_quantity": 1,
      "status": "active"
    }
  ]
}
```

## 4. Drives Data

### Drives List Response
```json
{
  "drives": [
    {
      "drive_id": 1,
      "delivery_guy_id": 2,
      "route_id": 1,
      "stock": 50,
      "sold": 42,
      "returned": 8,
      "remarks": "Traffic delayed delivery by 20 minutes",
      "start_time": "2025-04-10T06:30:00Z",
      "end_time": "2025-04-10T10:45:00Z",
      "total_amount": 1260.00,
      "status": "completed",
      "created_at": "2025-04-09T18:00:00Z",
      "updated_at": "2025-04-10T10:45:00Z",
      "route_name": "North Zone Morning",
      "delivery_guy_name": "Mike Wilson"
    },
    {
      "drive_id": 2,
      "delivery_guy_id": 3,
      "route_id": 2,
      "stock": 30,
      "sold": 28,
      "returned": 2,
      "remarks": "Smooth delivery",
      "start_time": "2025-04-10T07:00:00Z",
      "end_time": "2025-04-10T09:30:00Z",
      "total_amount": 784.00,
      "status": "completed",
      "created_at": "2025-04-09T18:00:00Z",
      "updated_at": "2025-04-10T09:30:00Z",
      "route_name": "Downtown Morning Route",
      "delivery_guy_name": "Sarah Thompson"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "totalCount": 120,
    "totalPages": 12
  }
}
```

### Drive Details Response
```json
{
  "drive": {
    "drive_id": 1,
    "delivery_guy_id": 2,
    "route_id": 1,
    "stock": 50,
    "sold": 42,
    "returned": 8,
    "remarks": "Traffic delayed delivery by 20 minutes",
    "start_time": "2025-04-10T06:30:00Z",
    "end_time": "2025-04-10T10:45:00Z",
    "total_amount": 1260.00,
    "status": "completed",
    "created_at": "2025-04-09T18:00:00Z",
    "updated_at": "2025-04-10T10:45:00Z",
    "route_name": "North Zone Morning",
    "delivery_guy_name": "Mike Wilson"
  },
  "customers": [
    {
      "id": 1,
      "customer_id": 1,
      "name": "John Doe",
      "quantity": 2,
      "price": 30.00,
      "total_amount": 60.00,
      "status": "success",
      "timestamp": "2025-04-10T07:15:20Z"
    },
    {
      "id": 2,
      "customer_id": 3,
      "name": "Robert Johnson",
      "quantity": 1,
      "price": 28.00,
      "total_amount": 28.00,
      "status": "success",
      "timestamp": "2025-04-10T07:30:45Z"
    }
  ]
}
```

## 5. Payments Data

### Payments List Response
```json
{
  "payments": [
    {
      "payment_id": 1,
      "customer_id": 1,
      "date": "2025-04-15T14:30:00Z",
      "amount": 900.00,
      "status": "completed",
      "mode": "cash",
      "remarks": "Monthly payment",
      "created_at": "2025-04-15T14:30:00Z",
      "updated_at": "2025-04-15T14:30:00Z",
      "customerName": "John Doe",
      "customerPhone": "9876543210"
    },
    {
      "payment_id": 2,
      "customer_id": 2,
      "date": "2025-04-15T16:45:00Z",
      "amount": 560.00,
      "status": "completed",
      "mode": "online",
      "remarks": "Paid via UPI",
      "created_at": "2025-04-15T16:45:00Z",
      "updated_at": "2025-04-15T16:45:00Z",
      "customerName": "Jane Smith",
      "customerPhone": "9876543211"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "totalCount": 240,
    "totalPages": 24
  }
}
```

## 6. QR Codes Data

### QR Codes List Response
```json
{
  "qrCodes": [
    {
      "qr_id": 1,
      "code": "a8f5e7d9-c123-48b7-9a52-7e85f6b2c941",
      "customer_id": 1,
      "status": "active",
      "activated_at": "2025-03-10T09:15:00Z",
      "created_at": "2025-03-10T09:00:00Z",
      "updated_at": "2025-03-10T09:15:00Z",
      "customerName": "John Doe"
    },
    {
      "qr_id": 2,
      "code": "b7d4f6c8-e234-59a8-8b41-6f74g5a1d832",
      "customer_id": 2,
      "status": "active",
      "activated_at": "2025-03-15T10:30:00Z",
      "created_at": "2025-03-15T10:20:00Z",
      "updated_at": "2025-03-15T10:30:00Z",
      "customerName": "Jane Smith"
    },
    {
      "qr_id": 3,
      "code": "c6e3g5b7-f345-60b9-7c30-5e63h4b0c723",
      "customer_id": null,
      "status": "inactive",
      "activated_at": null,
      "created_at": "2025-03-20T11:45:00Z",
      "updated_at": "2025-03-20T11:45:00Z",
      "customerName": null
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "totalCount": 150,
    "totalPages": 15
  }
}
```

## 7. Reports Data

### Customer Report Response
```json
{
  "reportName": "Customer Details Report",
  "generatedAt": "2025-04-28T14:30:00Z",
  "customerCount": 45,
  "customers": [
    {
      "customer_id": 1,
      "name": "John Doe",
      "location": "Downtown",
      "phone": "9876543210",
      "price": 30.00,
      "points": 120,
      "status": "active",
      "metrics": {
        "totalPayments": 2700.00,
        "paymentCount": 3,
        "totalDeliveries": 90,
        "deliveryQuantity": 180,
        "averagePayment": 900.00
      }
    },
    {
      "customer_id": 2,
      "name": "Jane Smith",
      "location": "Uptown",
      "phone": "9876543211",
      "price": 28.00,
      "points": 80,
      "status": "active",
      "metrics": {
        "totalPayments": 1680.00,
        "paymentCount": 3,
        "totalDeliveries": 60,
        "deliveryQuantity": 60,
        "averagePayment": 560.00
      }
    }
  ],
  "filters": {
    "location": "Downtown",
    "status": "active"
  }
}
```

## 8. Delivery Persons Data

### Delivery Persons List Response
```json
{
  "deliveryPersons": [
    {
      "delivery_guy_id": 1,
      "name": "David Brown",
      "phone": "9876543215",
      "address": "101 Driver St",
      "created_at": "2025-01-05T10:00:00Z",
      "updated_at": "2025-01-05T10:00:00Z",
      "activeDriveCount": 0,
      "completedDriveCount": 85
    },
    {
      "delivery_guy_id": 2,
      "name": "Mike Wilson",
      "phone": "9876543216",
      "address": "202 Delivery Ave",
      "created_at": "2025-01-10T11:30:00Z",
      "updated_at": "2025-01-10T11:30:00Z",
      "activeDriveCount": 1,
      "completedDriveCount": 72
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "totalCount": 6,
    "totalPages": 1
  }
}
```

This set of sample JSON responses should help you build a frontend application that works concurrently with the backend API. The data structures align with the database schema defined in your project and include the relationships between different entities.
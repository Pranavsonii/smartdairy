# Delivery Person Controller API Documentation

## Overview
The Delivery Person Controller manages delivery personnel in the Smart Dairy system. It handles creation, management, and performance tracking of delivery guys, including optional user account creation for app access. This controller provides comprehensive functionality for managing the delivery workforce.

## Endpoints

### 1. **GET /delivery-persons** - Get All Delivery Persons
**Purpose**: Retrieve a list of all delivery persons with their account status information.

**Authentication**: Bearer Token required

**Query Parameters**: None

**Sample Request**:
```http
GET /api/delivery-persons
Authorization: Bearer your-token-here
```

**Sample Response**:
```json
{
  "deliveryPersons": [
    {
      "delivery_guy_id": 1,
      "name": "John Doe",
      "phone": "9876543210",
      "address": "123 Main Street, Downtown",
      "created_at": "2025-07-15T10:30:00Z",
      "updated_at": "2025-07-15T10:30:00Z",
      "hasaccount": "1"
    },
    {
      "delivery_guy_id": 2,
      "name": "Jane Smith",
      "phone": "9876543211",
      "address": "456 Oak Avenue, Uptown",
      "created_at": "2025-07-16T09:15:00Z",
      "updated_at": "2025-07-16T09:15:00Z",
      "hasaccount": "0"
    }
  ]
}
```

**Response Fields**:
- `hasaccount`: "1" if delivery person has a user account, "0" otherwise

---

### 2. **GET /delivery-persons/:id** - Get Delivery Person By ID
**Purpose**: Retrieve detailed information about a specific delivery person, including associated user account details.

**Path Parameters**:
- `id`: Delivery person ID

**Sample Request**:
```http
GET /api/delivery-persons/1
Authorization: Bearer your-token-here
```

**Sample Response**:
```json
{
  "deliveryPerson": {
    "delivery_guy_id": 1,
    "name": "John Doe",
    "phone": "9876543210",
    "address": "123 Main Street, Downtown",
    "created_at": "2025-07-15T10:30:00Z",
    "updated_at": "2025-07-15T10:30:00Z",
    "user_id": 5,
    "userphone": "9876543210"
  }
}
```

**Response Fields**:
- `user_id`: Associated user account ID (null if no account)
- `userphone`: Phone number of associated user account

---

### 3. **POST /delivery-persons** - Create Delivery Person
**Purpose**: Create a new delivery person with optional user account creation for app access.

**Request Body**:
```json
{
  "name": "Alice Johnson",
  "phone": "9876543212",
  "address": "789 Pine Street, Midtown",
  "password": "securePassword123",
  "createUserAccount": true
}
```

**Request Fields**:
- `name` (required): Full name of delivery person
- `phone` (required): Contact phone number (must be unique)
- `address` (optional): Residential address
- `password` (required if createUserAccount=true): Password for user account
- `createUserAccount` (optional, default: true): Whether to create app access account

**Business Rules**:
- Phone number must be unique across both delivery_guys and users tables
- Password is mandatory when createUserAccount is true
- User account is created with role "delivery_guy"
- Transaction ensures data consistency

**Sample Request**:
```http
POST /api/delivery-persons
Authorization: Bearer your-token-here
Content-Type: application/json

{
  "name": "Alice Johnson",
  "phone": "9876543212",
  "address": "789 Pine Street, Midtown",
  "password": "securePassword123",
  "createUserAccount": true
}
```

**Sample Response**:
```json
{
  "message": "Delivery person and user account created successfully",
  "deliveryPerson": {
    "delivery_guy_id": 3,
    "name": "Alice Johnson",
    "phone": "9876543212",
    "address": "789 Pine Street, Midtown",
    "created_at": "2025-07-18T11:45:00Z",
    "updated_at": "2025-07-18T11:45:00Z"
  },
  "userAccount": {
    "user_id": 8,
    "phone": "9876543212",
    "role": "delivery_guy",
    "delivery_guy_id": 3,
    "outlet_id": 1,
    "created_at": "2025-07-18T11:45:00Z"
  },
  "hasUserAccount": true
}
```

---

### 4. **PUT /delivery-persons/:id** - Update Delivery Person
**Purpose**: Update delivery person information. Only provided fields are updated.

**Path Parameters**:
- `id`: Delivery person ID

**Request Body**:
```json
{
  "name": "John Doe Updated",
  "phone": "9876543210",
  "address": "123 Updated Street, New Area"
}
```

**Business Rules**:
- Phone number uniqueness is validated
- Partial updates supported
- Only basic profile information can be updated (not user account details)

**Sample Request**:
```http
PUT /api/delivery-persons/1
Authorization: Bearer your-token-here
Content-Type: application/json

{
  "name": "John Doe Updated",
  "address": "123 Updated Street, New Area"
}
```

**Sample Response**:
```json
{
  "message": "Delivery person updated successfully",
  "deliveryPerson": {
    "delivery_guy_id": 1,
    "name": "John Doe Updated",
    "phone": "9876543210",
    "address": "123 Updated Street, New Area",
    "created_at": "2025-07-15T10:30:00Z",
    "updated_at": "2025-07-18T12:00:00Z"
  }
}
```

---

### 5. **DELETE /delivery-persons/:id** - Delete Delivery Person
**Purpose**: Delete a delivery person with safety checks for data integrity.

**Path Parameters**:
- `id`: Delivery person ID

**Business Rules**:
- Cannot delete if delivery person has an active user account
- Cannot delete if delivery person has associated drives
- Ensures referential integrity

**Sample Request**:
```http
DELETE /api/delivery-persons/1
Authorization: Bearer your-token-here
```

**Sample Response (Success)**:
```json
{
  "message": "Delivery person deleted successfully"
}
```

**Sample Response (Error - Has User Account)**:
```json
{
  "message": "Cannot delete delivery person with an active user account. Delete the user account first."
}
```

**Sample Response (Error - Has Drives)**:
```json
{
  "message": "Cannot delete delivery person with associated drives."
}
```

---

### 6. **GET /delivery-persons/:id/drives** - Get Delivery Person Drives
**Purpose**: Retrieve paginated list of drives assigned to a specific delivery person with filtering options.

**Path Parameters**:
- `id`: Delivery person ID

**Query Parameters**:
- `status` (optional): Filter by drive status (pending, ongoing, completed)
- `fromDate` (optional): Start date filter (YYYY-MM-DD)
- `toDate` (optional): End date filter (YYYY-MM-DD)
- `page` (optional, default: 1): Page number for pagination
- `limit` (optional, default: 10): Records per page

**Sample Request**:
```http
GET /api/delivery-persons/1/drives?status=completed&fromDate=2025-07-01&toDate=2025-07-31&page=1&limit=5
Authorization: Bearer your-token-here
```

**Sample Response**:
```json
{
  "drives": [
    {
      "drive_id": 15,
      "route_id": 1,
      "delivery_guy_id": 1,
      "stock": 100,
      "sold": 85,
      "returned": 15,
      "status": "completed",
      "name": "Morning Route A",
      "start_time": "2025-07-18T06:00:00Z",
      "end_time": "2025-07-18T10:30:00Z",
      "total_amount": 2125.50,
      "remarks": "Completed successfully",
      "created_at": "2025-07-18T05:45:00Z",
      "updated_at": "2025-07-18T10:30:00Z",
      "route_name": "Downtown Route"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 5,
    "totalCount": 25,
    "totalPages": 5
  }
}
```

---

### 7. **GET /delivery-persons/:id/performance** - Get Delivery Person Performance
**Purpose**: Comprehensive performance analytics and metrics for a delivery person.

**Path Parameters**:
- `id`: Delivery person ID

**Query Parameters**:
- `fromDate` (optional): Start date for performance period (YYYY-MM-DD)
- `toDate` (optional): End date for performance period (YYYY-MM-DD)

**Sample Request**:
```http
GET /api/delivery-persons/1/performance?fromDate=2025-07-01&toDate=2025-07-31
Authorization: Bearer your-token-here
```

**Sample Response**:
```json
{
  "performance": {
    "deliveryPersonName": "John Doe",
    "overallMetrics": {
      "totalDrives": 25,
      "completedDrives": 23,
      "ongoingDrives": 2,
      "completionRate": 92.0,
      "avgDriveHours": 4.5
    },
    "salesMetrics": {
      "totalUnitsSold": 2150,
      "totalRevenue": 53750.0,
      "total_customersServed": 345,
      "deliveryEfficiency": 86.0,
      "avgSalesPerDrive": 2150.0
    },
    "routePerformance": [
      {
        "route_name": "Downtown Route",
        "driveCount": 15,
        "unitsSold": 1275,
        "revenue": 31875.0
      },
      {
        "route_name": "Uptown Route",
        "driveCount": 8,
        "unitsSold": 680,
        "revenue": 17000.0
      },
      {
        "route_name": "Suburban Route",
        "driveCount": 2,
        "unitsSold": 195,
        "revenue": 4875.0
      }
    ]
  }
}
```

**Performance Metrics Explained**:
- `completionRate`: Percentage of drives completed successfully
- `avgDriveHours`: Average time taken per drive in hours
- `deliveryEfficiency`: Percentage of stock successfully sold
- `avgSalesPerDrive`: Average revenue generated per drive
- `routePerformance`: Performance breakdown by route assignment

---

## Authentication
All endpoints require Bearer token authentication:
```http
Authorization: Bearer your-jwt-token-here
```

## Error Responses
All endpoints return consistent error responses:

**400 Bad Request**:
```json
{
  "message": "Name and phone are required"
}
```

**404 Not Found**:
```json
{
  "message": "Delivery person not found"
}
```

**500 Internal Server Error**:
```json
{
  "message": "Server error"
}
```

## Business Rules & Features

### User Account Management:
1. **Optional Account Creation**: Can create delivery persons with or without app access
2. **Role-Based Access**: User accounts created with "delivery_guy" role
3. **Phone Validation**: Ensures phone uniqueness across the system
4. **Transaction Safety**: Account creation uses database transactions

### Data Integrity:
1. **Referential Integrity**: Cannot delete delivery persons with active relationships
2. **Cascading Checks**: Validates user accounts and drives before deletion
3. **Unique Constraints**: Enforces phone number uniqueness
4. **Partial Updates**: Supports updating only specified fields

### Performance Analytics:
1. **Comprehensive Metrics**: Drive completion, sales efficiency, revenue tracking
2. **Time-Based Filtering**: Performance analysis for specific date ranges
3. **Route-Wise Analysis**: Performance breakdown by assigned routes
4. **Real-Time Calculations**: Dynamic metric calculations based on current data

### Pagination & Filtering:
1. **Flexible Filtering**: Multiple filter options for drives and performance
2. **Pagination Support**: Efficient handling of large datasets
3. **Sorting**: Logical ordering of results (newest first, performance-based)

## Database Tables Used
- `delivery_guys`: Primary delivery person information
- `users`: User account information for app access
- `drives`: Drive assignments and completion data
- routes: Route information for performance analysis
- `drive_customers_sales`: Individual sales data for metrics

## Use Cases
1. **HR Management**: Create and manage delivery personnel profiles
2. **Access Control**: Manage app access for delivery personnel
3. **Performance Monitoring**: Track individual and comparative performance
4. **Route Optimization**: Analyze route-wise delivery efficiency
5. **Workforce Planning**: Historical performance data for scheduling
6. **Audit Trail**: Complete history of drives and performance metrics

This controller provides comprehensive delivery personnel management with robust performance analytics and user account integration for the Smart Dairy system.
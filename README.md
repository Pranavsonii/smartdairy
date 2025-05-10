# Milk Delivery Management System Backend

This is the backend API for the Milk Delivery Management System, a comprehensive application designed to streamline daily dairy business operations.

## Features

- Authentication and user management
- Customer management
- Routes management
- Drive planning and execution
- Payment processing
- QR code generation and management
- Reporting and analytics

## Getting Started

### Prerequisites

- Node.js (v14 or higher)
- PostgreSQL (v12 or higher)
- npm or yarn

### Installation

1. Clone the repository
2. Install dependencies:
   ```
   npm install
   ```
3. Configure environment variables:

   - Copy `.env.example` to `.env`
   - Update the values to match your environment

4. Initialize the database:

   ```
   npm run init-db
   ```

5. Start the server:

   ```
   npm start
   ```

   For development with auto-reload:

   ```
   npm run dev
   ```

## API Documentation

The API endpoints are organized into the following groups:

- `/api/auth` - Authentication endpoints
- `/api/customers` - Customer management
- `/api/routes` - Route management
- `/api/drives` - Drive management
- `/api/payments` - Payment logging
- `/api/qr-codes` - QR code generation and management
- `/api/drive-execution` - Drive execution
- `/api/reports` - Report generation
- `/api/users` - User management
- `/api/delivery-persons` - Delivery personnel management
- `/api/inventory` - Inventory tracking
- `/api/map` - Map and location services
- `/api/analytics` - Analytics and metrics
- `/api/notifications` - Notification services
- `/api/settings` - Application settings
- `/api/sync` - Data synchronization
- `/api/export` - Data exports
- `/api/utils` - Utility functions

For detailed API documentation, see the [API Documentation](Milk%20Apis.md) file.

## Project Structure

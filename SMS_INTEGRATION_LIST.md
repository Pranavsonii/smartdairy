# SMS Integration List

This document lists all the places where SMS code needs to be added in the Smart Dairy project.

## Available SMS Templates

You currently have **3 SMS templates**:

1. **PAYMENT_RECEIVED** (`sendPaymentReceivedSMS`)
   - Template ID: `1107176215216476261`
   - Variables: `customerName`, `paymentAmount`, `currentBalance`
   - Message: "Dear {#var#}, we have received your payment of Rs. {#var#}. Thank you for your timely payment. Your current balance is {#var#} - Milkyway-Milkyway Pro"

2. **WELCOME_MESSAGE** (`sendWelcomeSMS`)
   - Template ID: `1107176215267013738`
   - Variables: `customerName`
   - Message: "Welcome {#var#} to Milkyway! Thank you for joining our milk delivery service. We are happy to serve you daily. - Milkyway-Milkyway Pro"
   - ✅ **Already Implemented** in `customerController.js` (line 420)

3. **CREDIT_DEDUCTED** (`sendCreditDeductedSMS`)
   - Template ID: `1107176215246118343`
   - Variables: `deductedAmount`, `currentBalance`
   - Message: "Rs.{#var#} deducted from your wallet for milk delivery. Current balance: Rs.{#var#}. - Milkyway-Milkyway Pro"

---

## Places Where SMS Code Needs to Be Added

### 1. Payment Controller - `createPayment` Function
**File:** `controllers/paymentController.js`
**Function:** `createPayment` (lines 188-302)
**Template to Use:** `PAYMENT_RECEIVED`
**When:** After successful payment is recorded and customer points are updated
**Location:** After line 270 (after `COMMIT` transaction)
**Required Data:**
- Customer phone number (need to fetch from customer table)
- Customer name (need to fetch from customer table)
- Payment amount: `amount`
- Current balance: `newPoints`

**Code to Add:**
```javascript
// After line 270, before the response
// Fetch customer details for SMS
const customerDetails = await pool.query(
  "SELECT name, phone FROM customers WHERE customer_id = $1",
  [customer_id]
);

if (customerDetails.rows.length > 0) {
  const customer = customerDetails.rows[0];
  try {
    await sendPaymentReceivedSMS(
      customer.phone,
      customer.name,
      amount,
      newPoints
    );
  } catch (smsError) {
    console.error("Failed to send payment received SMS:", smsError);
    // Don't fail the payment if SMS fails
  }
}
```

**Import Statement to Add:**
```javascript
import { sendPaymentReceivedSMS } from "../utils/smsService.js";
```

---

### 2. Customer Controller - `deductCustomerPoints` Function
**File:** `controllers/customerController.js`
**Function:** `deductCustomerPoints` (lines 915-997)
**Template to Use:** `CREDIT_DEDUCTED`
**When:** After points are successfully deducted from customer wallet
**Location:** After line 976 (after `COMMIT` transaction)
**Required Data:**
- Customer phone number (need to fetch from customer table)
- Deducted amount: `points`
- Current balance: `newBalance`

**Code to Add:**
```javascript
// After line 976, before the response
// Fetch customer phone for SMS
const customerPhoneResult = await pool.query(
  "SELECT phone FROM customers WHERE customer_id = $1",
  [id]
);

if (customerPhoneResult.rows.length > 0) {
  const customerPhone = customerPhoneResult.rows[0].phone;
  try {
    await sendCreditDeductedSMS(
      customerPhone,
      points,
      newBalance
    );
  } catch (smsError) {
    console.error("Failed to send credit deducted SMS:", smsError);
    // Don't fail the deduction if SMS fails
  }
}
```

**Import Statement to Add:**
```javascript
import { sendCreditDeductedSMS } from "../utils/smsService.js";
```

---

### 3. Drive Execution Controller - `recordSale` Function (Optional)
**File:** `controllers/driveExecutionController.js`
**Function:** `recordSale` (lines 94-211)
**Template to Use:** `CREDIT_DEDUCTED` (if points are automatically deducted)
**When:** After sale is recorded, IF points are automatically deducted for the sale
**Location:** After line 193 (after `COMMIT` transaction)
**Note:** This depends on your business logic - check if points are deducted automatically when a sale is recorded, or if it's done manually later.

**If points are deducted automatically, add:**
```javascript
// After line 193, before the response
// Check if points need to be deducted and send SMS
// This is optional - only add if your system automatically deducts points on sale
const customerInfo = await pool.query(
  "SELECT phone, points FROM customers WHERE customer_id = $1",
  [customer_id]
);

if (customerInfo.rows.length > 0 && total_amount > 0) {
  // If you deduct points automatically, uncomment and modify:
  // try {
  //   await sendCreditDeductedSMS(
  //     customerInfo.rows[0].phone,
  //     total_amount,
  //     customerInfo.rows[0].points // Updated balance after deduction
  //   );
  // } catch (smsError) {
  //   console.error("Failed to send credit deducted SMS:", smsError);
  // }
}
```

**Import Statement to Add:**
```javascript
import { sendCreditDeductedSMS } from "../utils/smsService.js";
```

---

### 4. Drive Execution Controller - `scanQrCode` Function (Optional)
**File:** `controllers/driveExecutionController.js`
**Function:** `scanQrCode` (lines 291-406)
**Template to Use:** `CREDIT_DEDUCTED` (if points are automatically deducted)
**When:** After QR code is scanned and sale is recorded, IF points are automatically deducted
**Location:** After line 385 (after `COMMIT` transaction)
**Note:** Same as above - only add if points are automatically deducted on QR scan.

**If points are deducted automatically, add:**
```javascript
// After line 385, before the response
// Check if points need to be deducted and send SMS
// This is optional - only add if your system automatically deducts points on QR scan
try {
  await sendCreditDeductedSMS(
    qrCodeData.phone,
    total_amount,
    // Updated balance after deduction - you may need to fetch this
  );
} catch (smsError) {
  console.error("Failed to send credit deducted SMS:", smsError);
}
```

**Import Statement to Add:**
```javascript
import { sendCreditDeductedSMS } from "../utils/smsService.js";
```

---

## Summary

### Priority 1 (Must Add):
1. ✅ **Payment Controller - `createPayment`** - Send PAYMENT_RECEIVED SMS
2. ✅ **Customer Controller - `deductCustomerPoints`** - Send CREDIT_DEDUCTED SMS

### Priority 2 (Optional - Check Business Logic):
3. ⚠️ **Drive Execution Controller - `recordSale`** - Send CREDIT_DEDUCTED SMS (only if points auto-deduct)
4. ⚠️ **Drive Execution Controller - `scanQrCode`** - Send CREDIT_DEDUCTED SMS (only if points auto-deduct)

---

## Implementation Notes

1. **Error Handling:** Always wrap SMS sending in try-catch blocks. SMS failures should NOT break the main business logic (payment, deduction, etc.)

2. **Non-blocking:** SMS sending should be non-blocking. The main operation should complete successfully even if SMS fails.

3. **Customer Data:** You may need to fetch customer phone and name from the database if not already available in the function.

4. **Testing:** Test each SMS integration separately to ensure:
   - SMS is sent correctly
   - SMS failure doesn't break the main operation
   - Correct data is passed to SMS templates

---

## Files to Modify

1. `controllers/paymentController.js` - Add PAYMENT_RECEIVED SMS
2. `controllers/customerController.js` - Add CREDIT_DEDUCTED SMS
3. `controllers/driveExecutionController.js` - Add CREDIT_DEDUCTED SMS (optional)

---

## Current Status

- ✅ WELCOME_MESSAGE SMS - Already implemented in `customerController.js` (line 420)
- ❌ PAYMENT_RECEIVED SMS - **Not implemented** - Add to `paymentController.js`
- ❌ CREDIT_DEDUCTED SMS - **Not implemented** - Add to `customerController.js` and optionally to `driveExecutionController.js`

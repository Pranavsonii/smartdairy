import { config } from "../config/config.js";

/**
 * SMS Message Templates
 */
const SMS_TEMPLATES = {
  PAYMENT_RECEIVED: {
    template: "Dear {#var#}, we have received your payment of Rs. {#var#}. Thank you for your timely payment. Your current balance is {#var#} - Milkyway-Milkyway Pro",
    templateId: "1107176215216476261",
    templateName: "Payment Received",
    senderId: "MILKWP", // Approved sender ID: MILKY or MILKWP
    module: "TRANS_SMS",
    variables: ["customerName", "paymentAmount", "currentBalance"],
  },
  WELCOME_MESSAGE: {
    template: "Welcome {#var#} to Milkyway! Thank you for joining our milk delivery service. We are happy to serve you daily. - Milkyway-Milkyway Pro",
    templateId: "1107176215267013738",
    templateName: "Welcome Message",
    senderId: "MILKWP", // Approved sender ID: MILKY or MILKWP
    module: "TRANS_SMS",
    variables: ["customerName"],
  },
  CREDIT_DEDUCTED: {
    template: "Rs.{#var#} deducted from your wallet for milk delivery. Current balance: Rs.{#var#}. - Milkyway-Milkyway Pro",
    templateId: "1107176215246118343",
    templateName: "Credit Deducted",
    senderId: "MILKWP", // Approved sender ID: MILKY or MILKWP
    module: "TRANS_SMS",
    variables: ["deductedAmount", "currentBalance"],
  },
};

/**
 * Send SMS using 2factor.in API
 * @param {string|string[]} phoneNumbers - Phone number(s) to send SMS to (with country code, e.g., "919876543210" or ["919876543210", "919876543211"])
 * @param {string} messageType - Type of message: 'PAYMENT_RECEIVED', 'WELCOME_MESSAGE', or 'CREDIT_DEDUCTED'
 * @param {object} variables - Variables to replace in the template
 * @returns {Promise<object>} API response
 */
export async function sendSMS(phoneNumbers, messageType, variables = {}) {
  try {
    // Validate message type
    if (!SMS_TEMPLATES[messageType]) {
      throw new Error(`Invalid message type: ${messageType}`);
    }

    const template = SMS_TEMPLATES[messageType];

    // Validate required variables
    const missingVariables = template.variables.filter(
      (varName) => !variables[varName]
    );

    if (missingVariables.length > 0) {
      throw new Error(
        `Missing required variables: ${missingVariables.join(", ")}`
      );
    }

    // Replace template variables
    let message = template.template;
    template.variables.forEach((varName) => {
      const placeholder = "{#var#}";
      // Replace first occurrence of {#var#} with the variable value
      message = message.replace(placeholder, variables[varName]);
    });

    // Convert phone numbers to array if single number
    const phoneNumbersArray = Array.isArray(phoneNumbers)
      ? phoneNumbers
      : [phoneNumbers];

    // Format phone numbers (ensure they start with country code)
    const formattedPhones = phoneNumbersArray.map((phone) => {
      // Remove any spaces or special characters
      let cleaned = phone.replace(/\D/g, "");
      // Ensure it starts with country code (91 for India)
      if (!cleaned.startsWith("91") && cleaned.length === 10) {
        cleaned = "91" + cleaned;
      }
      return cleaned;
    });

    // Join multiple numbers with comma
    const toNumbers = formattedPhones.join(",");

    // Prepare form data according to 2factor.in API documentation
    const urlencoded = new URLSearchParams();
    urlencoded.append("module", template.module);
    urlencoded.append("apikey", config.sms.apiKey);
    urlencoded.append("to", toNumbers);
    // Use template-specific sender ID if available, otherwise fall back to config
    urlencoded.append("from", template.senderId || config.sms.senderId);
    urlencoded.append("msg", message);
    // Add DLT Content Template ID (ctid) - optional but recommended for DLT compliance
    if (template.templateId) {
      urlencoded.append("ctid", template.templateId);
    }
    // Add PE ID (DLT Registration Number) if available - optional
    if (template.peId) {
      urlencoded.append("peid", template.peId);
    }

    // Send SMS via API
    const requestOptions = {
      method: "POST",
      body: urlencoded,
      redirect: "follow",
    };

    const response = await fetch(config.sms.apiUrl, requestOptions);
    const result = await response.text();

    // Try to parse JSON response if possible
    let responseData;
    try {
      responseData = JSON.parse(result);
    } catch (e) {
      // If response is not JSON, use the text result
      responseData = { rawResponse: result };
    }

    // Check API response status
    if (responseData.Status === "Success") {
      return {
        success: true,
        message: "SMS sent successfully",
        data: responseData,
        rawResponse: result,
      };
    } else {
      throw new Error(
        `SMS sending failed: ${responseData.Details || responseData.Status || result}`
      );
    }
  } catch (error) {
    console.error("SMS sending error:", error);
    return {
      success: false,
      message: error.message || "Failed to send SMS",
      error: error.message,
    };
  }
}

/**
 * Helper function to send payment received SMS
 * @param {string|string[]} phoneNumbers - Phone number(s)
 * @param {string} customerName - Customer name
 * @param {number|string} paymentAmount - Payment amount
 * @param {number|string} currentBalance - Current balance
 */
export async function sendPaymentReceivedSMS(
  phoneNumbers,
  customerName,
  paymentAmount,
  currentBalance
) {
  return await sendSMS(phoneNumbers, "PAYMENT_RECEIVED", {
    customerName,
    paymentAmount,
    currentBalance,
  });
}

/**
 * Helper function to send welcome message SMS
 * @param {string|string[]} phoneNumbers - Phone number(s)
 * @param {string} customerName - Customer name
 */
export async function sendWelcomeSMS(phoneNumbers, customerName) {
  return await sendSMS(phoneNumbers, "WELCOME_MESSAGE", {
    customerName,
  });
}

/**
 * Helper function to send credit deducted SMS
 * @param {string|string[]} phoneNumbers - Phone number(s)
 * @param {number|string} deductedAmount - Deducted amount
 * @param {number|string} currentBalance - Current balance
 */
export async function sendCreditDeductedSMS(
  phoneNumbers,
  deductedAmount,
  currentBalance
) {
  return await sendSMS(phoneNumbers, "CREDIT_DEDUCTED", {
    deductedAmount,
    currentBalance,
  });
}

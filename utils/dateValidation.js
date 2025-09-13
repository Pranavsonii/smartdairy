export const isValidDateTime = (input) => {
  if (!input) return true; // Allow null/undefined dates

  // Regex: YYYY-MM-DD with optional " HH:MM[:SS]"
  const regex = /^\d{4}-\d{2}-\d{2}( \d{2}:\d{2}(:\d{2})?)?$/;

  if (!regex.test(input)) return false;

  // Use Date to verify actual validity (e.g., no Feb 30th)
  const parsed = new Date(input.replace(" ", "T")); // convert to ISO-like
  return !isNaN(parsed.getTime());
};

export const validateDateParams = (req, res, next) => {
  const { fromDate, toDate, date } = req.query || req.body;

  if (fromDate && !isValidDateTime(fromDate)) {
    return res.status(400).json({
      message: "Invalid fromDate format. Please use YYYY-MM-DD or YYYY-MM-DD HH:MM:SS"
    });
  }

  if (toDate && !isValidDateTime(toDate)) {
    return res.status(400).json({
      message: "Invalid toDate format. Please use YYYY-MM-DD or YYYY-MM-DD HH:MM:SS"
    });
  }

  if (date && !isValidDateTime(date)) {
    return res.status(400).json({
      message: "Invalid date format. Please use YYYY-MM-DD or YYYY-MM-DD HH:MM:SS"
    });
  }

  next();
};
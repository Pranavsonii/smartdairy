import pool from "../config/database.js";

export const getCustomersReport = async (req, res) => {
  try {
    const { format = "json", location, status } = req.query;

    let query = `
      SELECT c.*,
             COALESCE(p.total_payments, 0) as total_payments,
             COALESCE(p.payment_count, 0) as payment_count,
             COALESCE(d.total_deliveries, 0) as total_deliveries,
             COALESCE(d.delivery_quantity, 0) as delivery_quantity
      FROM customers c
      LEFT JOIN (
        SELECT customer_id,
               COUNT(*) as payment_count,
               SUM(amount) as total_payments
        FROM payment_logs
        GROUP BY customer_id
      ) p ON c.customer_id = p.customer_id
      LEFT JOIN (
        SELECT customer_id,
               COUNT(*) as total_deliveries,
               SUM(quantity) as delivery_quantity
        FROM drive_customers_sales
        WHERE status = 'success'
        GROUP BY customer_id
      ) d ON c.customer_id = d.customer_id
      WHERE 1=1
    `;

    const params = [];

    if (location) {
      params.push(`%${location}%`);
      query += ` AND c.location ILIKE $${params.length}`;
    }

    if (status) {
      params.push(status);
      query += ` AND c.status = $${params.length}`;
    }

    query += ` ORDER BY c.name`;

    const result = await pool.query(query, params);

    // Add payment and delivery metrics
    const customersWithMetrics = result.rows.map((customer) => ({
      ...customer,
      metrics: {
        totalPayments: parseFloat(customer.total_payments) || 0,
        paymentCount: parseInt(customer.payment_count) || 0,
        totalDeliveries: parseInt(customer.total_deliveries) || 0,
        deliveryQuantity: parseInt(customer.delivery_quantity) || 0,
        averagePayment:
          customer.payment_count > 0
            ? parseFloat(customer.total_payments) /
            parseInt(customer.payment_count)
            : 0
      }
    }));

    // Format could be 'json', 'csv', 'excel' but only implementing 'json' for now
    res.json({
      reportName: "Customer Details Report",
      generatedAt: new Date(),
      customerCount: customersWithMetrics.length,
      customers: customersWithMetrics,
      filters: { location, status }
    });
  } catch (error) {
    console.error("Generate customers report error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const getPaymentsReport = async (req, res) => {
  try {
    const { format = "json", fromDate, toDate, mode } = req.query;

    let query = `
      SELECT pl.*, c.name as customerName, c.phone as customerPhone
      FROM payment_logs pl
      JOIN customers c ON pl.customer_id = c.customer_id
      WHERE 1=1
    `;

    const params = [];

    if (fromDate) {
      params.push(fromDate);
      query += ` AND pl.date >= $${params.length}`;
    }

    if (toDate) {
      params.push(toDate);
      query += ` AND pl.date <= $${params.length}`;
    }

    if (mode) {
      params.push(mode);
      query += ` AND pl.mode = $${params.length}`;
    }

    query += ` ORDER BY pl.date DESC`;

    const result = await pool.query(query, params);

    // Calculate summary metrics
    const total_amount = result.rows.reduce(
      (sum, payment) => sum + parseFloat(payment.amount),
      0
    );
    const paymentCountByMode = {};
    const amountByMode = {};

    result.rows.forEach((payment) => {
      const mode = payment.mode;
      paymentCountByMode[mode] = (paymentCountByMode[mode] || 0) + 1;
      amountByMode[mode] =
        (amountByMode[mode] || 0) + parseFloat(payment.amount);
    });

    const summary = {
      totalPayments: result.rows.length,
      total_amount,
      averageAmount:
        result.rows.length > 0 ? total_amount / result.rows.length : 0,
      paymentCountByMode,
      amountByMode
    };

    // Format could be 'json', 'csv', 'excel' but only implementing 'json' for now
    res.json({
      reportName: "Payment Logs Report",
      generatedAt: new Date(),
      filters: { fromDate, toDate, mode },
      summary,
      payments: result.rows
    });
  } catch (error) {
    console.error("Generate payments report error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const getRoutesReport = async (req, res) => {
  try {
    const { format = "json" } = req.query;

    // Get routes with customer count
    const routesResult = await pool.query(`
      SELECT r.*,
             COUNT(rc.customer_id) as customerCount
      FROM routes r
      LEFT JOIN route_customers rc ON r.route_id = rc.route_id
      GROUP BY r.route_id
      ORDER BY r.name
    `);

    // Get delivery metrics for each route
    const routeMetricsPromises = routesResult.rows.map(async (route) => {
      const driveResult = await pool.query(
        `
        SELECT COUNT(*) as driveCount,
               COALESCE(SUM(stock), 0) as totalStock,
               COALESCE(SUM(sold), 0) as totalSold,
               COALESCE(SUM(returned), 0) as totalReturned,
               COALESCE(SUM(total_amount), 0) as total_amount
        FROM drives
        WHERE route_id = $1
      `,
        [route.route_id]
      );

      const customerCountResult = await pool.query(
        `
        SELECT COUNT(DISTINCT c.customer_id) as activeCustomers
        FROM customers c
        JOIN route_customers rc ON c.customer_id = rc.customer_id
        WHERE rc.route_id = $1 AND c.status = 'active'
      `,
        [route.route_id]
      );

      return {
        ...route,
        metrics: {
          driveCount: parseInt(driveResult.rows[0].drivecount),
          totalStock: parseInt(driveResult.rows[0].totalstock),
          totalSold: parseInt(driveResult.rows[0].totalsold),
          totalReturned: parseInt(driveResult.rows[0].totalreturned),
          total_amount: parseFloat(driveResult.rows[0].totalamount),
          deliveryRate:
            driveResult.rows[0].totalstock > 0
              ? (driveResult.rows[0].totalsold /
                driveResult.rows[0].totalstock) *
              100
              : 0,
          customerCount: parseInt(route.customercount),
          activeCustomers: parseInt(customerCountResult.rows[0].activecustomers)
        }
      };
    });

    const routesWithMetrics = await Promise.all(routeMetricsPromises);

    // Format could be 'json', 'csv', 'excel' but only implementing 'json' for now
    res.json({
      reportName: "Routes Report",
      generatedAt: new Date(),
      routeCount: routesWithMetrics.length,
      routes: routesWithMetrics
    });
  } catch (error) {
    console.error("Generate routes report error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const getDrivesReport = async (req, res) => {
  try {
    const { format = "json", fromDate, toDate, route_id, status } = req.query;

    let query = `
      SELECT d.*, r.name as route_name, dg.name as delivery_guy_name
      FROM drives d
      LEFT JOIN routes r ON d.route_id = r.route_id
      LEFT JOIN delivery_guys dg ON d.delivery_guy_id = dg.delivery_guy_id
      WHERE 1=1
    `;

    const params = [];

    if (fromDate) {
      params.push(fromDate);
      query += ` AND d.created_at >= $${params.length}`;
    }

    if (toDate) {
      params.push(toDate);
      query += ` AND d.created_at <= $${params.length}`;
    }

    if (route_id) {
      params.push(route_id);
      query += ` AND d.route_id = $${params.length}`;
    }

    if (status) {
      params.push(status);
      query += ` AND d.status = $${params.length}`;
    }

    query += ` ORDER BY d.created_at DESC`;

    const result = await pool.query(query, params);

    // Calculate summary metrics
    const totalStock = result.rows.reduce(
      (sum, drive) => sum + parseInt(drive.stock || 0),
      0
    );
    const totalSold = result.rows.reduce(
      (sum, drive) => sum + parseInt(drive.sold || 0),
      0
    );
    const totalReturned = result.rows.reduce(
      (sum, drive) => sum + parseInt(drive.returned || 0),
      0
    );
    const total_amount = result.rows.reduce(
      (sum, drive) => sum + parseFloat(drive.totalamount || 0),
      0
    );

    const summary = {
      totalDrives: result.rows.length,
      totalStock,
      totalSold,
      totalReturned,
      total_amount,
      averageSoldPerDrive:
        result.rows.length > 0 ? totalSold / result.rows.length : 0,
      averageAmountPerDrive:
        result.rows.length > 0 ? total_amount / result.rows.length : 0,
      deliveryRate: totalStock > 0 ? (totalSold / totalStock) * 100 : 0
    };

    // Format could be 'json', 'csv', 'excel' but only implementing 'json' for now
    res.json({
      reportName: "Drives Report",
      generatedAt: new Date(),
      filters: { fromDate, toDate, route_id, status },
      summary,
      drives: result.rows
    });
  } catch (error) {
    console.error("Generate drives report error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const
  getCustomReport = async (req, res) => {
    try {
      const { format = "json", fromDate, toDate, reportType } = req.query;

      if (!fromDate || !toDate) {
        return res
          .status(400)
          .json({ message: "From date and to date are required" });
      }

      if (
        !reportType ||
        !["sales", "payments", "customers"].includes(reportType)
      ) {
        return res.status(400).json({
          message: "Valid report type is required (sales, payments, or customers)"
        });
      }

      let data, summary;

      switch (reportType) {
        case "sales":
          // Get daily sales data
          const salesResult = await pool.query(
            `
          SELECT
            DATE_TRUNC('day', d.created_at) as date,
            COUNT(DISTINCT d.drive_id) as driveCount,
            SUM(d.sold) as totalSold,
            SUM(d.total_amount) as total_amount
          FROM drives d
          WHERE d.created_at BETWEEN $1 AND $2
          GROUP BY DATE_TRUNC('day', d.created_at)
          ORDER BY date
        `,
            [fromDate, toDate]
          );

          data = salesResult.rows;

          // Calculate summary metrics
          summary = {
            totalDays: data.length,
            totalSales: data.reduce(
              (sum, day) => sum + parseFloat(day.totalamount || 0),
              0
            ),
            totalSold: data.reduce(
              (sum, day) => sum + parseInt(day.totalsold || 0),
              0
            ),
            totalDrives: data.reduce(
              (sum, day) => sum + parseInt(day.drivecount || 0),
              0
            ),
            averageDailySales:
              data.length > 0
                ? data.reduce(
                  (sum, day) => sum + parseFloat(day.totalamount || 0),
                  0
                ) / data.length
                : 0
          };
          break;

        case "payments":
          // Get daily payment data
          const paymentsResult = await pool.query(
            `
          SELECT
            DATE_TRUNC('day', date) as day,
            COUNT(*) as paymentCount,
            SUM(amount) as total_amount,
            mode
          FROM payment_logs
          WHERE date BETWEEN $1 AND $2
          GROUP BY DATE_TRUNC('day', date), mode
          ORDER BY day, mode
        `,
            [fromDate, toDate]
          );

          data = paymentsResult.rows;

          // Calculate summary metrics
          const uniqueDays = [
            ...new Set(data.map((row) => row.day.toISOString().split("T")[0]))
          ];
          const totalPayments = data.reduce(
            (sum, day) => sum + parseInt(day.paymentcount || 0),
            0
          );
          const total_amount = data.reduce(
            (sum, day) => sum + parseFloat(day.totalamount || 0),
            0
          );

          // Group by payment mode
          const paymentsByMode = data.reduce((acc, row) => {
            const mode = row.mode;
            if (!acc[mode]) {
              acc[mode] = { count: 0, amount: 0 };
            }
            acc[mode].count += parseInt(row.paymentcount);
            acc[mode].amount += parseFloat(row.totalamount);
            return acc;
          }, {});

          summary = {
            totalDays: uniqueDays.length,
            totalPayments,
            total_amount,
            averageDailyPayments:
              uniqueDays.length > 0 ? totalPayments / uniqueDays.length : 0,
            averageDailyAmount:
              uniqueDays.length > 0 ? total_amount / uniqueDays.length : 0,
            paymentsByMode
          };
          break;

        case "customers":
          // Get customer growth data
          const customersResult = await pool.query(
            `
          SELECT
            DATE_TRUNC('day', created_at) as date,
            COUNT(*) as newCustomers
          FROM customers
          WHERE created_at BETWEEN $1 AND $2
          GROUP BY DATE_TRUNC('day', created_at)
          ORDER BY date
        `,
            [fromDate, toDate]
          );

          data = customersResult.rows;

          // Get overall customer metrics
          const customerMetricsResult = await pool.query(
            `
          SELECT
            COUNT(*) as total_customers,
            COUNT(CASE WHEN status = 'active' THEN 1 END) as activeCustomers,
            COUNT(CASE WHEN status != 'active' THEN 1 END) as inactiveCustomers,
            COUNT(CASE WHEN created_at BETWEEN $1 AND $2 THEN 1 END) as newCustomers
          FROM customers
        `,
            [fromDate, toDate]
          );

          summary = {
            ...customerMetricsResult.rows[0],
            dailyGrowthData: data
          };
          break;
      }

      // Format could be 'json', 'csv', 'excel' but only implementing 'json' for now
      res.json({
        reportName: `Custom ${reportType.charAt(0).toUpperCase() + reportType.slice(1)
          } Report`,
        generatedAt: new Date(),
        dateRange: { fromDate, toDate },
        reportType,
        summary,
        data
      });
    } catch (error) {
      console.error("Generate custom report error:", error);
      res.status(500).json({ message: "Server error" });
    }
  };

import pool from "../config/database.js";
export const getRoutes = async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM routes ORDER BY name");

    // fetch all customers associated with each route
    const routesWithCustomers = await Promise.all(
      result.rows.map(async (route) => {
        const customersResult = await pool.query(
          `SELECT c.*
           FROM customers c
           JOIN route_customers rc ON c.customer_id = rc.customer_id
           WHERE rc.route_id = $1
           ORDER BY c.name`,
          [route.route_id]
        );
        return {
          ...route,
          customers: customersResult.rows
        };
      })
    );

    res.json({
      routes: routesWithCustomers
    });
  } catch (error) {
    console.error("Get routes error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const getRouteById = async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      "SELECT * FROM routes WHERE route_id = $1",
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "Route not found" });
    }

    // get customers associated with the route
    const customersResult = await pool.query(
      `SELECT c.*
       FROM customers c
       JOIN route_customers rc ON c.customer_id = rc.customer_id
       WHERE rc.route_id = $1
       ORDER BY c.name`,
      [id]
    );
    const customers = customersResult.rows;

    res.json({
      route: { ...result.rows[0], customers: customers }
    });
  } catch (error) {
    console.error("Get route by ID error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const createRoute = async (req, res) => {
  try {
    const { name, description, route } = req.body;

    if (!name) {
      return res.status(400).json({ message: "Route name is required" });
    }
    // Check if description is provided
    if (!description) {
      return res.status(400).json({ message: "Route description is required" });
    }
    // // Check if customer_ids is an array
    // if (!Array.isArray(customer_ids)) {
    //   return res.status(400).json({
    //     message: "Customer IDs should be an array"
    //   });
    // }

    // Check if route with same name already exists
    const checkResult = await pool.query(
      "SELECT route_id FROM routes WHERE name = $1",
      [name]
    );

    if (checkResult.rows.length > 0) {
      return res
        .status(400)
        .json({ message: "Route with this name already exists" });
    }

    // Insert route with name and description
    const insertQuery = route
      ? "INSERT INTO routes (name, description, route_data) VALUES ($1, $2, $3) RETURNING *"
      : "INSERT INTO routes (name, description) VALUES ($1, $2) RETURNING *";

    const insertParams = route
      ? [name, description, JSON.stringify(route)]
      : [name, description];

    const result = await pool.query(insertQuery, insertParams);

    res.status(201).json({
      message: "Route created successfully",
      route: result.rows[0]
    });
  } catch (error) {
    console.error("Create route error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const updateRoute = async (req, res) => {
  try {
    const { id } = req.params;
    const { name } = req.body;

    if (!name) {
      return res.status(400).json({ message: "Route name is required" });
    }

    // Check if route exists
    const checkResult = await pool.query(
      "SELECT route_id FROM routes WHERE route_id = $1",
      [id]
    );

    if (checkResult.rows.length === 0) {
      return res.status(404).json({ message: "Route not found" });
    }

    // Check if another route with the same name exists
    const nameCheckResult = await pool.query(
      "SELECT route_id FROM routes WHERE name = $1 AND route_id != $2",
      [name, id]
    );

    if (nameCheckResult.rows.length > 0) {
      return res
        .status(400)
        .json({ message: "Another route with this name already exists" });
    }

    const result = await pool.query(
      "UPDATE routes SET name = $1, updated_at = NOW() WHERE route_id = $2 RETURNING *",
      [name, id]
    );

    res.json({
      message: "Route updated successfully",
      route: result.rows[0]
    });
  } catch (error) {
    console.error("Update route error:", error);
    res.status(500).json({ message: "Server error" });
  }
};


export const deleteRoute = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if route exists
    const checkResult = await pool.query(
      "SELECT route_id FROM routes WHERE route_id = $1",
      [id]
    );

    if (checkResult.rows.length === 0) {
      return res.status(404).json({ message: "Route not found" });
    }

    // Check if there are active drives for this route
    const driveCheckResult = await pool.query(
      "SELECT drive_id FROM drives WHERE route_id = $1 AND status IN ('pending', 'ongoing')",
      [id]
    );

    if (driveCheckResult.rows.length > 0) {
      return res.status(400).json({
        message: "Cannot delete route with active drives",
        activeDrivers: driveCheckResult.rows.length
      });
    }

    // Delete route (cascade will handle route_customers junction)
    await pool.query("DELETE FROM routes WHERE route_id = $1", [id]);

    res.json({ message: "Route deleted successfully" });
  } catch (error) {
    console.error("Delete route error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const addCustomersToRoute = async (req, res) => {
  try {
    const { id } = req.params;
    const { customer_ids } = req.body;

    if (
      !customer_ids ||
      !Array.isArray(customer_ids) ||
      customer_ids.length === 0
    ) {
      return res
        .status(400)
        .json({ message: "Valid customer IDs array is required" });
    }

    // Check if route exists
    const routeCheck = await pool.query(
      "SELECT route_id FROM routes WHERE route_id = $1",
      [id]
    );

    if (routeCheck.rows.length === 0) {
      return res.status(404).json({ message: "Route not found" });
    }

    // Check if all customers exist
    const customersCheck = await pool.query(
      "SELECT customer_id FROM customers WHERE customer_id = ANY($1)",
      [customer_ids]
    );

    if (customersCheck.rows.length !== customer_ids.length) {
      return res
        .status(400)
        .json({ message: "One or more customers not found" });
    }

    // Add customers to route
    const addedCustomers = [];
    const skippedCustomers = [];

    for (const customer_id of customer_ids) {
      try {
        const result = await pool.query(
          "INSERT INTO route_customers (route_id, customer_id) VALUES ($1, $2) RETURNING *",
          [id, customer_id]
        );
        addedCustomers.push(result.rows[0]);
      } catch (err) {
        // If customer is already in route (unique constraint violation)
        if (err.code === "23505") {
          skippedCustomers.push(customer_id);
        } else {
          throw err;
        }
      }
    }

    res.status(201).json({
      message: "Customers added to route",
      addedCount: addedCustomers.length,
      skippedCount: skippedCustomers.length,
      addedCustomers,
      skippedCustomers
    });
  } catch (error) {
    console.error("Add customers to route error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const removeCustomerFromRoute = async (req, res) => {
  try {
    const { id, customer_id } = req.params;

    // Check if mapping exists
    const checkResult = await pool.query(
      "SELECT route_customer_id FROM route_customers WHERE route_id = $1 AND customer_id = $2",
      [id, customer_id]
    );

    if (checkResult.rows.length === 0) {
      return res
        .status(404)
        .json({ message: "Customer not found in this route" });
    }

    await pool.query(
      "DELETE FROM route_customers WHERE route_id = $1 AND customer_id = $2",
      [id, customer_id]
    );

    res.json({ message: "Customer removed from route successfully" });
  } catch (error) {
    console.error("Remove customer from route error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const getRouteCustomers = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if route exists
    const routeCheck = await pool.query(
      "SELECT route_id FROM routes WHERE route_id = $1",
      [id]
    );

    if (routeCheck.rows.length === 0) {
      return res.status(404).json({ message: "Route not found" });
    }

    // Get customers in route with their details
    const result = await pool.query(
      `SELECT c.*
       FROM customers c
       JOIN route_customers rc ON c.customer_id = rc.customer_id
       WHERE rc.route_id = $1
       ORDER BY c.name`,
      [id]
    );

    res.json({
      route_id: parseInt(id),
      customers: result.rows,
      count: result.rows.length
    });
  } catch (error) {
    console.error("Get route customers error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

import pool from "../config/database.js";

// In a real application, you would integrate with Google Maps or similar services
// This is a simplified example with mock responses

export const getRouteOptimization = async (req, res) => {
  try {
    const { route_id } = req.params;
    const { startLat, startLng } = req.query;

    // Check if route exists
    const routeCheck = await pool.query(
      "SELECT route_id FROM routes WHERE route_id = $1",
      [route_id]
    );

    if (routeCheck.rows.length === 0) {
      return res.status(404).json({ message: "Route not found" });
    }

    // Get customers in the route
    const customersResult = await pool.query(
      `SELECT c.customer_id, c.name, c.location, c.address
       FROM customers c
       JOIN route_customers rc ON c.customer_id = rc.customer_id
       WHERE rc.route_id = $1 AND c.status = 'active'
       ORDER BY c.name`,
      [route_id]
    );

    if (customersResult.rows.length === 0) {
      return res
        .status(404)
        .json({ message: "No active customers found in this route" });
    }

    // In a real application, you would:
    // 1. Call Google Maps Distance Matrix API to get distances between all points
    // 2. Use an algorithm like TSP (Traveling Salesman Problem) to optimize the route
    // 3. Return the optimized sequence

    // For this example, return a simple mock response with the customers in alphabetical order
    const optimizedRoute = customersResult.rows.map((customer, index) => ({
      stop: index + 1,
      customer_id: customer.customer_id,
      name: customer.name,
      location: customer.location,
      address: customer.address,
      // Mock coordinates (would come from geocoding in real app)
      latitude: Math.random() * 0.1 + 51.5, // Random around London
      longitude: Math.random() * 0.1 - 0.15, // Random around London
    }));

    res.json({
      route_id: parseInt(route_id),
      stops: optimizedRoute,
      totalDistanceKm: 15.7, // Mock value
      estimatedDurationMinutes: 45, // Mock value
      startPoint:
        startLat && startLng
          ? { latitude: startLat, longitude: startLng }
          : null,
    });
  } catch (error) {
    console.error("Get route optimization error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const getDistanceMatrix = async (req, res) => {
  try {
    const { origins, destinations } = req.query;

    if (!origins || !destinations) {
      return res.status(400).json({
        message:
          "Both origins and destinations are required as comma-separated lat,lng pairs",
      });
    }

    // Parse origins and destinations
    const originsArray = origins.split("|").map((o) => {
      const [lat, lng] = o.split(",");
      return { lat, lng };
    });

    const destinationsArray = destinations.split("|").map((d) => {
      const [lat, lng] = d.split(",");
      return { lat, lng };
    });

    // In a real application, you would call Google Maps Distance Matrix API
    // For this example, generate mock response
    const matrix = originsArray.map(() =>
      destinationsArray.map(() => ({
        distance: {
          value: Math.floor(Math.random() * 10000),
          text: `${Math.floor(Math.random() * 10)} km`,
        },
        duration: {
          value: Math.floor(Math.random() * 1800),
          text: `${Math.floor(Math.random() * 30)} mins`,
        },
        status: "OK",
      }))
    );

    res.json({
      origins: originsArray,
      destinations: destinationsArray,
      matrix,
    });
  } catch (error) {
    console.error("Get distance matrix error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const geocodeAddress = async (req, res) => {
  try {
    const { address } = req.params;

    if (!address) {
      return res.status(400).json({ message: "Address is required" });
    }

    // In a real application, you would call Google Maps Geocoding API
    // For this example, return a mock response
    res.json({
      address,
      latitude: 51.5074,
      longitude: -0.1278,
      formatted_address: `${address}, London, UK`,
    });
  } catch (error) {
    console.error("Geocode address error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const reverseGeocode = async (req, res) => {
  try {
    const { lat, lng } = req.params;

    if (!lat || !lng) {
      return res
        .status(400)
        .json({ message: "Latitude and longitude are required" });
    }

    // In a real application, you would call Google Maps Reverse Geocoding API
    // For this example, return a mock response
    res.json({
      latitude: parseFloat(lat),
      longitude: parseFloat(lng),
      formatted_address: "123 Example Street, London, UK",
      location_type: "ROOFTOP",
      components: {
        street: "Example Street",
        house_number: "123",
        city: "London",
        country: "United Kingdom",
        postal_code: "SW1A 1AA",
      },
    });
  } catch (error) {
    console.error("Reverse geocode error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

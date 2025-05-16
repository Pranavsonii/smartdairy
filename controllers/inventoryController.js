import pool from "../config/database.js";

// Note: This is a simplified mock implementation
// In a real app, you would have inventory tables in your database

export const getInventory = async (req, res) => {
  try {
    // Mock inventory data since we don't have inventory tables in the schema
    const mockInventory = [
      {
        id: 1,
        name: "Milk",
        quantity: 500,
        unit: "liters",
        threshold: 100,
        lastUpdated: new Date(),
      },
      {
        id: 2,
        name: "Bottles",
        quantity: 200,
        unit: "pieces",
        threshold: 50,
        lastUpdated: new Date(),
      },
    ];

    res.json({
      inventory: mockInventory,
    });
  } catch (error) {
    console.error("Get inventory error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const addInventory = async (req, res) => {
  try {
    const { itemId, quantity, notes } = req.body;

    if (!itemId || !quantity || quantity <= 0) {
      return res
        .status(400)
        .json({ message: "Valid item ID and quantity are required" });
    }

    // In a real app, you would update inventory in the database
    // For this example, return a mock response
    res.json({
      message: "Inventory added successfully",
      transaction: {
        id: `TRX-${Date.now()}`,
        itemId,
        quantity,
        notes: notes || "",
        type: "addition",
        timestamp: new Date(),
      },
    });
  } catch (error) {
    console.error("Add inventory error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const deductInventory = async (req, res) => {
  try {
    const { itemId, quantity, notes } = req.body;

    if (!itemId || !quantity || quantity <= 0) {
      return res
        .status(400)
        .json({ message: "Valid item ID and quantity are required" });
    }

    // In a real app, you would update inventory in the database
    // For this example, return a mock response
    res.json({
      message: "Inventory deducted successfully",
      transaction: {
        id: `TRX-${Date.now()}`,
        itemId,
        quantity,
        notes: notes || "",
        type: "deduction",
        timestamp: new Date(),
      },
    });
  } catch (error) {
    console.error("Deduct inventory error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

export const getLowStockAlerts = async (req, res) => {
  try {
    // Mock low stock alerts since we don't have inventory tables in the schema
    const mockAlerts = [
      {
        itemId: 2,
        name: "Bottles",
        currentQuantity: 45,
        threshold: 50,
        deficit: 5,
      },
    ];

    res.json({
      alerts: mockAlerts,
      count: mockAlerts.length,
    });
  } catch (error) {
    console.error("Get low stock alerts error:", error);
    res.status(500).json({ message: "Server error" });
  }
};

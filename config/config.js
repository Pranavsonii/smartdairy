import dotenv from "dotenv";
dotenv.config();
export const config = {
  port: process.env.PORT || 3005,
  nodeEnv: process.env.NODE_ENV || "development",

  db: {
    host: process.env.DB_HOST || "localhost",
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || "milk_delivery_db",
    user: process.env.DB_USER || "postgres",
    password: process.env.DB_PASSWORD || "123",
  },

  jwt: {
    secret: process.env.JWT_SECRET || "your_jwt_secret",
    expiresIn: process.env.JWT_EXPIRES_IN || "1y",
  },
};

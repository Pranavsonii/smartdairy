import { initializeSchema } from './schemaInit.js';

// Execute the schema initialization function
(async () => {
  try {
    await initializeSchema();
    console.log('Schema setup completed successfully');
  } catch (error) {
    console.error('Failed to setup schema:', error);
    process.exit(1);
  }
})();
// SurrealDB JavaScript Client Examples

import { Surreal } from 'surrealdb.js';

// Initialize connection
const db = new Surreal();

// Configuration
const config = {
  // Railway production
  production: {
    endpoint: 'https://your-service.railway.app/rpc',
    username: 'root',
    password: process.env.SURREAL_PASS,
    namespace: 'production',
    database: 'main'
  },
  // Local development
  development: {
    endpoint: 'ws://localhost:8000/rpc',
    username: 'root', 
    password: 'root',
    namespace: 'dev',
    database: 'test'
  }
};

async function connect(environment = 'development') {
  const cfg = config[environment];
  
  try {
    // Connect to SurrealDB
    await db.connect(cfg.endpoint);
    
    // Sign in
    await db.signin({
      user: cfg.username,
      pass: cfg.password,
    });
    
    // Select namespace and database
    await db.use({ ns: cfg.namespace, db: cfg.database });
    
    console.log(`✅ Connected to SurrealDB (${environment})`);
    return db;
  } catch (error) {
    console.error('❌ Connection failed:', error);
    throw error;
  }
}

// Example: Create and query users
async function userExamples() {
  await connect();
  
  // Create a user
  const [user] = await db.create('users', {
    name: 'John Doe',
    email: 'john@example.com',
    age: 30,
    active: true,
    created_at: new Date(),
  });
  
  console.log('Created user:', user);
  
  // Query users
  const users = await db.select('users');
  console.log('All users:', users);
  
  // Update user
  const [updated] = await db.merge(user.id, {
    age: 31,
    last_login: new Date(),
  });
  
  console.log('Updated user:', updated);
  
  // Query with conditions
  const activeUsers = await db.query(`
    SELECT * FROM users WHERE active = true ORDER BY created_at DESC
  `);
  
  console.log('Active users:', activeUsers);
  
  // Delete user
  await db.delete(user.id);
  console.log('User deleted');
}

// Example: Graph relationships
async function graphExamples() {
  await connect();
  
  // Create users and posts with relationships
  const [author] = await db.create('users', {
    name: 'Alice Smith',
    email: 'alice@example.com'
  });
  
  const [post] = await db.create('posts', {
    title: 'My First Post',
    content: 'Hello SurrealDB!',
    published: true
  });
  
  // Create relationship
  await db.query(`
    RELATE $author->wrote->$post SET created_at = time::now()
  `, { author: author.id, post: post.id });
  
  // Query relationships
  const authorPosts = await db.query(`
    SELECT *, ->wrote->posts.* as posts 
    FROM users:${author.id.split(':')[1]}
  `);
  
  console.log('Author with posts:', authorPosts);
  
  // Complex graph traversal
  const socialGraph = await db.query(`
    SELECT *,
      ->follows->users as following,
      <-follows<-users as followers,
      ->wrote->posts[WHERE published = true] as published_posts
    FROM users
    WHERE name CONTAINS 'Alice'
  `);
  
  console.log('Social graph:', socialGraph);
}

// Example: Real-time subscriptions
async function realtimeExamples() {
  await connect();
  
  // Subscribe to live changes
  const unsubscribe = await db.live('users', (action, result) => {
    console.log(`Live update - ${action}:`, result);
  });
  
  // Make some changes to trigger live updates
  setTimeout(async () => {
    await db.create('users', { name: 'Live User', email: 'live@example.com' });
  }, 1000);
  
  // Unsubscribe after 10 seconds
  setTimeout(() => {
    unsubscribe();
    console.log('Unsubscribed from live updates');
  }, 10000);
}

// Example: Transactions
async function transactionExamples() {
  await connect();
  
  try {
    // Begin transaction
    const result = await db.query(`
      BEGIN TRANSACTION;
      
      LET $user = CREATE users SET 
        name = 'Transaction User',
        email = 'tx@example.com',
        balance = 100;
      
      LET $account = CREATE accounts SET 
        user = $user.id,
        balance = $user.balance,
        created_at = time::now();
      
      UPDATE $user SET account = $account.id;
      
      COMMIT TRANSACTION;
      
      RETURN { user: $user, account: $account };
    `);
    
    console.log('Transaction result:', result);
  } catch (error) {
    console.error('Transaction failed:', error);
    // Transaction automatically rolled back on error
  }
}

// Example: Advanced queries
async function advancedQueries() {
  await connect();
  
  // Aggregation
  const stats = await db.query(`
    SELECT 
      count() as total_users,
      math::mean(age) as avg_age,
      math::max(age) as max_age,
      math::min(age) as min_age
    FROM users
    WHERE active = true
  `);
  
  console.log('User statistics:', stats);
  
  // Full-text search
  const searchResults = await db.query(`
    SELECT * FROM posts 
    WHERE string::lowercase(title) CONTAINS 'surrealdb'
    OR string::lowercase(content) CONTAINS 'surrealdb'
    ORDER BY created_at DESC
    LIMIT 10
  `);
  
  console.log('Search results:', searchResults);
  
  // Geospatial queries
  await db.query(`
    CREATE locations SET
      name = 'New York',
      coordinates = { latitude: 40.7128, longitude: -74.0060 }
  `);
  
  const nearbyLocations = await db.query(`
    SELECT * FROM locations
    WHERE geo::distance(coordinates, { latitude: 40.7589, longitude: -73.9851 }) < 10000
  `);
  
  console.log('Nearby locations:', nearbyLocations);
}

// Error handling wrapper
async function withErrorHandling(fn) {
  try {
    await fn();
  } catch (error) {
    console.error('Operation failed:', error);
  } finally {
    await db.close();
  }
}

// Export examples
export {
  connect,
  userExamples,
  graphExamples, 
  realtimeExamples,
  transactionExamples,
  advancedQueries,
  withErrorHandling
};

// Run examples if called directly
if (import.meta.main) {
  await withErrorHandling(async () => {
    console.log('🚀 Running SurrealDB examples...\n');
    
    await userExamples();
    console.log('\n---\n');
    
    await graphExamples();
    console.log('\n---\n');
    
    await advancedQueries();
    console.log('\n---\n');
    
    await realtimeExamples();
    
    console.log('\n✅ Examples completed!');
  });
}

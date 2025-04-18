// Sample authentication utility for the admin dashboard
// In a real application, you would implement proper JWT verification

/**
 * Verify the admin token from the request
 * @param {Object} req - The request object
 * @returns {Object|null} The user object if token is valid, null otherwise
 */
export async function verifyAdminToken(req) {
  try {
    // Get the authorization header
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return null;
    }
    
    // Extract the token
    const token = authHeader.split(' ')[1];
    
    // In a real app, you would verify the JWT token
    // For this example, we'll just check if it's a non-empty string
    if (!token) {
      return null;
    }
    
    // Mock user data - in a real app, this would come from token verification
    return {
      id: 1,
      name: 'Admin User',
      email: 'admin@example.com',
      role: 'admin'
    };
  } catch (error) {
    console.error('Error verifying token:', error);
    return null;
  }
}

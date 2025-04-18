// Next.js API route for admin attendance
// This is a sample implementation - in a real app, you would connect to your database

import { verifyAdminToken } from '../../../lib/auth';

export default async function handler(req, res) {
  // Check if the request method is GET
  if (req.method !== 'GET') {
    return res.status(405).json({ message: 'Method not allowed' });
  }

  try {
    // Verify admin token
    const user = await verifyAdminToken(req);
    if (!user || user.role !== 'admin') {
      return res.status(401).json({ message: 'Unauthorized' });
    }

    // Get query parameters
    const { date, status, page = 1, limit = 10, search } = req.query;
    
    if (!date) {
      return res.status(400).json({ message: 'Date parameter is required' });
    }

    // In a real app, you would fetch data from your database
    // This is mock data for demonstration
    const mockData = generateMockAttendanceData(date);
    
    // Apply filters
    let filteredData = mockData;
    
    if (status && status !== 'all') {
      filteredData = filteredData.filter(item => item.status === status);
    }
    
    if (search) {
      const searchLower = search.toLowerCase();
      filteredData = filteredData.filter(item => 
        item.staff_name.toLowerCase().includes(searchLower)
      );
    }
    
    // Calculate pagination
    const startIndex = (page - 1) * limit;
    const endIndex = page * limit;
    const paginatedData = filteredData.slice(startIndex, endIndex);
    
    // Return the data
    return res.status(200).json({
      records: paginatedData,
      total: filteredData.length,
      page: parseInt(page),
      limit: parseInt(limit),
      totalPages: Math.ceil(filteredData.length / limit)
    });
  } catch (error) {
    console.error('Error in attendance API:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
}

// Helper function to generate mock data
function generateMockAttendanceData(date) {
  const statuses = ['present', 'absent', 'not_marked'];
  const staffCategories = ['Domestic Help', 'Cook', 'Driver', 'Security'];
  
  // Generate 20 mock records
  return Array.from({ length: 20 }, (_, i) => {
    const status = statuses[Math.floor(Math.random() * statuses.length)];
    const hasPhoto = status === 'present' && Math.random() > 0.3;
    const hasNote = Math.random() > 0.5;
    
    return {
      staff_id: 1000 + i,
      staff_name: `Staff Member ${i + 1}`,
      staff_category: staffCategories[Math.floor(Math.random() * staffCategories.length)],
      staff_photo: `https://randomuser.me/api/portraits/${i % 2 === 0 ? 'men' : 'women'}/${i + 1}.jpg`,
      status,
      note: hasNote ? `Attendance note for ${date}` : null,
      photo_url: hasPhoto ? `https://picsum.photos/seed/${i + date}/200/200` : null,
      date
    };
  });
}

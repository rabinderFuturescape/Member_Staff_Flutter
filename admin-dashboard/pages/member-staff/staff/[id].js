import React, { useEffect, useState } from 'react';
import { useRouter } from 'next/router';
import axios from 'axios';
import Layout from '../../../components/Layout';
import StaffRatingSummary from '../../../components/StaffRatingSummary';

export default function StaffDetailPage() {
  const router = useRouter();
  const { id } = router.query;
  
  const [staff, setStaff] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [staffType, setStaffType] = useState('member'); // Default to member staff

  useEffect(() => {
    if (id) {
      fetchStaffDetails();
    }
  }, [id]);

  const fetchStaffDetails = async () => {
    try {
      setLoading(true);
      // Determine if this is society staff or member staff
      // This is a simplified example - you would need to implement this logic
      // based on your actual API and data structure
      const response = await axios.get(`/api/staff/${id}`, {
        headers: {
          Authorization: `Bearer ${localStorage.getItem('admin_token')}`
        }
      });
      
      setStaff(response.data);
      setStaffType(response.data.staff_type || 'member');
      setError(null);
    } catch (error) {
      console.error('Error fetching staff details:', error);
      setError('Failed to load staff details');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <Layout>
        <div className="p-6 max-w-7xl mx-auto">
          <div className="animate-pulse flex space-x-4">
            <div className="rounded-full bg-gray-200 h-24 w-24"></div>
            <div className="flex-1 space-y-4 py-1">
              <div className="h-4 bg-gray-200 rounded w-3/4"></div>
              <div className="space-y-2">
                <div className="h-4 bg-gray-200 rounded"></div>
                <div className="h-4 bg-gray-200 rounded w-5/6"></div>
              </div>
            </div>
          </div>
        </div>
      </Layout>
    );
  }

  if (error) {
    return (
      <Layout>
        <div className="p-6 max-w-7xl mx-auto">
          <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded">
            <p>{error}</p>
            <button 
              onClick={fetchStaffDetails}
              className="mt-2 bg-red-500 hover:bg-red-700 text-white font-bold py-2 px-4 rounded"
            >
              Retry
            </button>
          </div>
        </div>
      </Layout>
    );
  }

  if (!staff) {
    return (
      <Layout>
        <div className="p-6 max-w-7xl mx-auto">
          <p>No staff found with ID: {id}</p>
        </div>
      </Layout>
    );
  }

  return (
    <Layout>
      <div className="p-6 max-w-7xl mx-auto">
        <div className="mb-6">
          <button
            onClick={() => router.back()}
            className="flex items-center text-blue-500 hover:text-blue-700"
          >
            <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 mr-1" viewBox="0 0 20 20" fill="currentColor">
              <path fillRule="evenodd" d="M9.707 16.707a1 1 0 01-1.414 0l-6-6a1 1 0 010-1.414l6-6a1 1 0 011.414 1.414L5.414 9H17a1 1 0 110 2H5.414l4.293 4.293a1 1 0 010 1.414z" clipRule="evenodd" />
            </svg>
            Back to Staff List
          </button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {/* Staff Info Card */}
          <div className="md:col-span-2">
            <div className="bg-white p-6 rounded-lg shadow">
              <div className="flex items-start">
                <div className="h-24 w-24 rounded-full overflow-hidden bg-gray-200 mr-6">
                  {staff.photo_url ? (
                    <img 
                      src={staff.photo_url} 
                      alt={staff.name} 
                      className="h-full w-full object-cover"
                    />
                  ) : (
                    <div className="h-full w-full flex items-center justify-center text-gray-500 text-2xl">
                      {staff.name.charAt(0).toUpperCase()}
                    </div>
                  )}
                </div>
                <div>
                  <h1 className="text-2xl font-bold text-gray-900">{staff.name}</h1>
                  <p className="text-gray-600">{staff.category || 'Staff'}</p>
                  <div className="mt-2">
                    <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${
                      staff.status === 'active' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                    }`}>
                      {staff.status || 'Active'}
                    </span>
                  </div>
                </div>
              </div>

              <div className="mt-6 border-t pt-6">
                <h2 className="text-lg font-medium text-gray-900 mb-4">Staff Details</h2>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <p className="text-sm text-gray-500">Phone</p>
                    <p className="font-medium">{staff.phone || 'N/A'}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Email</p>
                    <p className="font-medium">{staff.email || 'N/A'}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Address</p>
                    <p className="font-medium">{staff.address || 'N/A'}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500">Joined Date</p>
                    <p className="font-medium">
                      {staff.created_at ? new Date(staff.created_at).toLocaleDateString() : 'N/A'}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          {/* Rating Summary Card */}
          <div>
            <StaffRatingSummary staffId={id} staffType={staffType} />
          </div>
        </div>

        {/* Additional Sections */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-6">
          {/* Assigned Members */}
          <div className="bg-white p-6 rounded-lg shadow">
            <h2 className="text-lg font-medium text-gray-900 mb-4">Assigned Members</h2>
            {staff.members && staff.members.length > 0 ? (
              <ul className="divide-y divide-gray-200">
                {staff.members.map((member) => (
                  <li key={member.id} className="py-3">
                    <div className="flex items-center">
                      <div className="h-10 w-10 rounded-full bg-gray-200 flex items-center justify-center text-gray-500 mr-3">
                        {member.name.charAt(0).toUpperCase()}
                      </div>
                      <div>
                        <p className="font-medium">{member.name}</p>
                        <p className="text-sm text-gray-500">Unit: {member.unit_id || 'N/A'}</p>
                      </div>
                    </div>
                  </li>
                ))}
              </ul>
            ) : (
              <p className="text-gray-500">No members assigned</p>
            )}
          </div>

          {/* Recent Bookings */}
          <div className="bg-white p-6 rounded-lg shadow">
            <h2 className="text-lg font-medium text-gray-900 mb-4">Recent Bookings</h2>
            {staff.bookings && staff.bookings.length > 0 ? (
              <ul className="divide-y divide-gray-200">
                {staff.bookings.map((booking) => (
                  <li key={booking.id} className="py-3">
                    <div>
                      <p className="font-medium">
                        {new Date(booking.start_date).toLocaleDateString()} - 
                        {new Date(booking.end_date).toLocaleDateString()}
                      </p>
                      <p className="text-sm text-gray-500">
                        Member: {booking.member_name || 'N/A'}
                      </p>
                      <p className="text-sm text-gray-500">
                        Status: 
                        <span className={`ml-1 ${
                          booking.status === 'confirmed' ? 'text-green-600' : 
                          booking.status === 'pending' ? 'text-yellow-600' : 'text-red-600'
                        }`}>
                          {booking.status || 'N/A'}
                        </span>
                      </p>
                    </div>
                  </li>
                ))}
              </ul>
            ) : (
              <p className="text-gray-500">No recent bookings</p>
            )}
          </div>
        </div>
      </div>
    </Layout>
  );
}

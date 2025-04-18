import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { saveAs } from 'file-saver';
import { CSVLink } from 'react-csv';
import { format } from 'date-fns';
import Layout from '../../components/Layout';
import { Rating } from '@mui/material';

export default function StaffRatingsDashboard() {
  const [ratings, setRatings] = useState([]);
  const [loading, setLoading] = useState(false);
  const [filter, setFilter] = useState('all');
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [searchTerm, setSearchTerm] = useState('');
  const [staffType, setStaffType] = useState('');
  const [minRating, setMinRating] = useState('');
  const [maxRating, setMaxRating] = useState('');
  const recordsPerPage = 10;

  useEffect(() => {
    fetchRatings();
  }, [currentPage, staffType, minRating, maxRating, searchTerm]);

  const fetchRatings = async () => {
    try {
      setLoading(true);
      const response = await axios.get('/api/admin/staff/ratings', {
        params: {
          staff_type: staffType || undefined,
          min_rating: minRating || undefined,
          max_rating: maxRating || undefined,
          page: currentPage,
          limit: recordsPerPage,
          search: searchTerm || undefined
        },
        headers: {
          Authorization: `Bearer ${localStorage.getItem('admin_token')}`
        }
      });
      
      setRatings(response.data.ratings);
      setTotalPages(Math.ceil(response.data.total / recordsPerPage));
      setLoading(false);
    } catch (error) {
      console.error('Error fetching ratings:', error);
      setLoading(false);
    }
  };

  const handleFilterChange = (e) => {
    setFilter(e.target.value);
    setCurrentPage(1); // Reset to first page when filter changes
  };

  const handleStaffTypeChange = (e) => {
    setStaffType(e.target.value);
    setCurrentPage(1); // Reset to first page when filter changes
  };

  const handleMinRatingChange = (e) => {
    setMinRating(e.target.value);
    setCurrentPage(1); // Reset to first page when filter changes
  };

  const handleMaxRatingChange = (e) => {
    setMaxRating(e.target.value);
    setCurrentPage(1); // Reset to first page when filter changes
  };

  const handleSearch = (e) => {
    e.preventDefault();
    setCurrentPage(1); // Reset to first page when searching
  };

  const handlePageChange = (page) => {
    setCurrentPage(page);
  };

  const handleExportCSV = async () => {
    try {
      const response = await axios.get('/api/admin/staff/ratings/export', {
        params: {
          staff_type: staffType || undefined,
          min_rating: minRating || undefined,
          max_rating: maxRating || undefined,
        },
        headers: {
          Authorization: `Bearer ${localStorage.getItem('admin_token')}`
        },
        responseType: 'blob'
      });
      
      const blob = new Blob([response.data], { type: 'text/csv' });
      saveAs(blob, `staff-ratings-${format(new Date(), 'yyyy-MM-dd')}.csv`);
    } catch (error) {
      console.error('Error exporting ratings:', error);
    }
  };

  const csvData = [
    ['ID', 'Member Name', 'Staff ID', 'Staff Type', 'Rating', 'Feedback', 'Date'],
    ...ratings.map(rating => [
      rating.id,
      rating.member ? rating.member.name : 'Unknown',
      rating.staff_id,
      rating.staff_type,
      rating.rating,
      rating.feedback || '',
      format(new Date(rating.created_at), 'yyyy-MM-dd')
    ])
  ];

  const renderPagination = () => {
    const pages = [];
    for (let i = 1; i <= totalPages; i++) {
      pages.push(
        <button
          key={i}
          onClick={() => handlePageChange(i)}
          className={`px-3 py-1 mx-1 rounded ${
            currentPage === i ? 'bg-blue-500 text-white' : 'bg-gray-200'
          }`}
        >
          {i}
        </button>
      );
    }
    return (
      <div className="flex justify-center mt-4">
        <button
          onClick={() => handlePageChange(Math.max(1, currentPage - 1))}
          disabled={currentPage === 1}
          className="px-3 py-1 mx-1 rounded bg-gray-200 disabled:opacity-50"
        >
          Previous
        </button>
        {pages}
        <button
          onClick={() => handlePageChange(Math.min(totalPages, currentPage + 1))}
          disabled={currentPage === totalPages}
          className="px-3 py-1 mx-1 rounded bg-gray-200 disabled:opacity-50"
        >
          Next
        </button>
      </div>
    );
  };

  return (
    <Layout>
      <div className="p-6 max-w-7xl mx-auto">
        <h1 className="text-3xl font-bold mb-6">Staff Ratings Dashboard</h1>
        
        {/* Filters and Controls */}
        <div className="bg-white p-4 rounded-lg shadow mb-6">
          <div className="flex flex-wrap items-center justify-between gap-4">
            <div className="flex items-center">
              <label htmlFor="staffType" className="mr-2 font-medium">Staff Type:</label>
              <select
                id="staffType"
                value={staffType}
                onChange={handleStaffTypeChange}
                className="p-2 border rounded"
              >
                <option value="">All</option>
                <option value="society">Society Staff</option>
                <option value="member">Member Staff</option>
              </select>
            </div>
            
            <div className="flex items-center">
              <label htmlFor="minRating" className="mr-2 font-medium">Min Rating:</label>
              <select
                id="minRating"
                value={minRating}
                onChange={handleMinRatingChange}
                className="p-2 border rounded"
              >
                <option value="">Any</option>
                <option value="1">1</option>
                <option value="2">2</option>
                <option value="3">3</option>
                <option value="4">4</option>
                <option value="5">5</option>
              </select>
            </div>
            
            <div className="flex items-center">
              <label htmlFor="maxRating" className="mr-2 font-medium">Max Rating:</label>
              <select
                id="maxRating"
                value={maxRating}
                onChange={handleMaxRatingChange}
                className="p-2 border rounded"
              >
                <option value="">Any</option>
                <option value="1">1</option>
                <option value="2">2</option>
                <option value="3">3</option>
                <option value="4">4</option>
                <option value="5">5</option>
              </select>
            </div>
            
            <form onSubmit={handleSearch} className="flex">
              <input
                type="text"
                placeholder="Search member name..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="p-2 border rounded-l"
              />
              <button
                type="submit"
                className="bg-blue-500 text-white px-4 py-2 rounded-r"
              >
                Search
              </button>
            </form>
            
            <CSVLink
              data={csvData}
              filename={`staff-ratings-${format(new Date(), 'yyyy-MM-dd')}.csv`}
              className="bg-green-500 text-white px-4 py-2 rounded flex items-center"
            >
              <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
              </svg>
              Export CSV
            </CSVLink>
          </div>
        </div>
        
        {/* Ratings Table */}
        <div className="bg-white rounded-lg shadow overflow-hidden">
          {loading ? (
            <div className="flex justify-center items-center p-8">
              <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
            </div>
          ) : (
            <>
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Member</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Staff ID</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Staff Type</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Rating</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Feedback</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date</th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {ratings.length > 0 ? (
                    ratings.map((rating) => (
                      <tr key={rating.id} className="hover:bg-gray-50">
                        <td className="px-6 py-4 whitespace-nowrap">
                          <div className="flex items-center">
                            <div className="h-10 w-10 rounded-full bg-gray-200 flex items-center justify-center text-gray-500 mr-3">
                              {rating.member && rating.member.name ? (
                                rating.member.name.charAt(0).toUpperCase()
                              ) : (
                                '?'
                              )}
                            </div>
                            <div>
                              <div className="text-sm font-medium text-gray-900">
                                {rating.member ? rating.member.name : 'Unknown'}
                              </div>
                              <div className="text-sm text-gray-500">
                                Member ID: {rating.member_id}
                              </div>
                            </div>
                          </div>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                          {rating.staff_id}
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${
                            rating.staff_type === 'society' ? 'bg-purple-100 text-purple-800' : 'bg-blue-100 text-blue-800'
                          }`}>
                            {rating.staff_type === 'society' ? 'Society Staff' : 'Member Staff'}
                          </span>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap">
                          <Rating
                            value={rating.rating}
                            readOnly
                            size="small"
                          />
                        </td>
                        <td className="px-6 py-4">
                          <div className="text-sm text-gray-900 max-w-xs truncate">
                            {rating.feedback || '-'}
                          </div>
                        </td>
                        <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                          {format(new Date(rating.created_at), 'yyyy-MM-dd')}
                        </td>
                      </tr>
                    ))
                  ) : (
                    <tr>
                      <td colSpan="6" className="px-6 py-8 text-center text-gray-500">
                        No ratings found for the selected filters.
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
              
              {/* Pagination */}
              {ratings.length > 0 && renderPagination()}
            </>
          )}
        </div>
        
        {/* Summary Stats */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-6">
          <div className="bg-white p-4 rounded-lg shadow">
            <h3 className="text-lg font-medium text-gray-900 mb-2">Total Ratings</h3>
            <p className="text-3xl font-bold text-blue-600">
              {ratings.length > 0 ? ratings.length : 0}
            </p>
          </div>
          <div className="bg-white p-4 rounded-lg shadow">
            <h3 className="text-lg font-medium text-gray-900 mb-2">Average Rating</h3>
            <p className="text-3xl font-bold text-green-600">
              {ratings.length > 0 
                ? (ratings.reduce((sum, rating) => sum + rating.rating, 0) / ratings.length).toFixed(1)
                : 'N/A'}
            </p>
          </div>
          <div className="bg-white p-4 rounded-lg shadow">
            <h3 className="text-lg font-medium text-gray-900 mb-2">Low Ratings (≤ 2)</h3>
            <p className="text-3xl font-bold text-red-600">
              {ratings.filter(r => r.rating <= 2).length}
            </p>
          </div>
        </div>
      </div>
    </Layout>
  );
}

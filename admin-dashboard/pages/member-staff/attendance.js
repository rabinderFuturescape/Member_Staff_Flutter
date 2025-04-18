import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { saveAs } from 'file-saver';
import { CSVLink } from 'react-csv';
import { format } from 'date-fns';

export default function MemberStaffAttendanceDashboard() {
  const [selectedDate, setSelectedDate] = useState(new Date().toISOString().split('T')[0]);
  const [records, setRecords] = useState([]);
  const [loading, setLoading] = useState(false);
  const [filter, setFilter] = useState('all');
  const [currentPage, setCurrentPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [searchTerm, setSearchTerm] = useState('');
  const recordsPerPage = 10;

  useEffect(() => {
    fetchAttendance();
  }, [selectedDate, filter, currentPage, searchTerm]);

  const fetchAttendance = async () => {
    try {
      setLoading(true);
      const response = await axios.get('/api/admin/attendance', {
        params: {
          date: selectedDate,
          status: filter !== 'all' ? filter : undefined,
          page: currentPage,
          limit: recordsPerPage,
          search: searchTerm || undefined
        },
        headers: {
          Authorization: `Bearer ${localStorage.getItem('admin_token')}`
        }
      });
      
      setRecords(response.data.records);
      setTotalPages(Math.ceil(response.data.total / recordsPerPage));
      setLoading(false);
    } catch (error) {
      console.error('Error fetching attendance:', error);
      setLoading(false);
    }
  };

  const handleFilterChange = (e) => {
    setFilter(e.target.value);
    setCurrentPage(1); // Reset to first page when filter changes
  };

  const handleSearch = (e) => {
    e.preventDefault();
    setCurrentPage(1); // Reset to first page when searching
  };

  const handlePageChange = (page) => {
    setCurrentPage(page);
  };

  const getStatusColor = (status) => {
    switch (status) {
      case 'present':
        return 'bg-green-100 text-green-800';
      case 'absent':
        return 'bg-red-100 text-red-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  const csvData = [
    ['Staff Name', 'Status', 'Note', 'Photo URL', 'Date'],
    ...records.map(rec => [
      rec.staff_name,
      rec.status,
      rec.note || '',
      rec.photo_url || '',
      selectedDate
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
    <div className="p-6 max-w-7xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Member Staff Attendance Dashboard</h1>
      
      {/* Filters and Controls */}
      <div className="bg-white p-4 rounded-lg shadow mb-6">
        <div className="flex flex-wrap items-center justify-between gap-4">
          <div className="flex items-center">
            <label htmlFor="date" className="mr-2 font-medium">Date:</label>
            <input
              type="date"
              id="date"
              value={selectedDate}
              onChange={(e) => setSelectedDate(e.target.value)}
              className="p-2 border rounded"
            />
          </div>
          
          <div className="flex items-center">
            <label htmlFor="filter" className="mr-2 font-medium">Status:</label>
            <select
              id="filter"
              value={filter}
              onChange={handleFilterChange}
              className="p-2 border rounded"
            >
              <option value="all">All</option>
              <option value="present">Present</option>
              <option value="absent">Absent</option>
              <option value="not_marked">Not Marked</option>
            </select>
          </div>
          
          <form onSubmit={handleSearch} className="flex">
            <input
              type="text"
              placeholder="Search staff name..."
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
            filename={`attendance-${selectedDate}.csv`}
            className="bg-green-500 text-white px-4 py-2 rounded flex items-center"
          >
            <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
            </svg>
            Export CSV
          </CSVLink>
        </div>
      </div>
      
      {/* Attendance Records Table */}
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
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Staff Name</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Note</th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Photo</th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {records.length > 0 ? (
                  records.map((rec, index) => (
                    <tr key={index} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="flex items-center">
                          <div className="h-10 w-10 rounded-full overflow-hidden bg-gray-100 mr-3">
                            {rec.staff_photo ? (
                              <img src={rec.staff_photo} alt={rec.staff_name} className="h-full w-full object-cover" />
                            ) : (
                              <div className="h-full w-full flex items-center justify-center text-gray-500">
                                <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                </svg>
                              </div>
                            )}
                          </div>
                          <div>
                            <div className="text-sm font-medium text-gray-900">{rec.staff_name}</div>
                            <div className="text-sm text-gray-500">{rec.staff_category || 'Staff'}</div>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-2 py-1 inline-flex text-xs leading-5 font-semibold rounded-full ${getStatusColor(rec.status)}`}>
                          {rec.status.charAt(0).toUpperCase() + rec.status.slice(1)}
                        </span>
                      </td>
                      <td className="px-6 py-4">
                        <div className="text-sm text-gray-900 max-w-xs truncate">
                          {rec.note || '-'}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        {rec.photo_url ? (
                          <a 
                            href={rec.photo_url} 
                            target="_blank" 
                            rel="noopener noreferrer"
                            className="group relative"
                          >
                            <div className="h-16 w-16 rounded overflow-hidden bg-gray-100">
                              <img 
                                src={rec.photo_url} 
                                alt="Attendance proof" 
                                className="h-full w-full object-cover"
                              />
                            </div>
                            <div className="hidden group-hover:block absolute top-0 left-0 right-0 bottom-0 bg-black bg-opacity-50 flex items-center justify-center text-white">
                              <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                              </svg>
                            </div>
                          </a>
                        ) : (
                          <span className="text-gray-500">N/A</span>
                        )}
                      </td>
                    </tr>
                  ))
                ) : (
                  <tr>
                    <td colSpan="4" className="px-6 py-8 text-center text-gray-500">
                      No attendance records found for the selected date and filters.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
            
            {/* Pagination */}
            {records.length > 0 && renderPagination()}
          </>
        )}
      </div>
      
      {/* Summary Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mt-6">
        <div className="bg-white p-4 rounded-lg shadow">
          <h3 className="text-lg font-medium text-gray-900 mb-2">Present</h3>
          <p className="text-3xl font-bold text-green-600">
            {records.filter(r => r.status === 'present').length}
          </p>
        </div>
        <div className="bg-white p-4 rounded-lg shadow">
          <h3 className="text-lg font-medium text-gray-900 mb-2">Absent</h3>
          <p className="text-3xl font-bold text-red-600">
            {records.filter(r => r.status === 'absent').length}
          </p>
        </div>
        <div className="bg-white p-4 rounded-lg shadow">
          <h3 className="text-lg font-medium text-gray-900 mb-2">Not Marked</h3>
          <p className="text-3xl font-bold text-gray-600">
            {records.filter(r => r.status === 'not_marked').length}
          </p>
        </div>
      </div>
    </div>
  );
}

import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { Rating } from '@mui/material';

export default function StaffRatingSummary({ staffId, staffType }) {
  const [summary, setSummary] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchRatingSummary();
  }, [staffId, staffType]);

  const fetchRatingSummary = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`/api/staff/${staffId}/ratings`, {
        params: { staff_type: staffType },
        headers: {
          Authorization: `Bearer ${localStorage.getItem('admin_token')}`
        }
      });
      
      setSummary(response.data);
      setError(null);
    } catch (error) {
      console.error('Error fetching rating summary:', error);
      setError('Failed to load rating summary');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="bg-white p-4 rounded-lg shadow">
        <div className="animate-pulse flex space-x-4">
          <div className="flex-1 space-y-4 py-1">
            <div className="h-4 bg-gray-200 rounded w-3/4"></div>
            <div className="space-y-2">
              <div className="h-4 bg-gray-200 rounded"></div>
              <div className="h-4 bg-gray-200 rounded w-5/6"></div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-white p-4 rounded-lg shadow">
        <div className="text-red-500">{error}</div>
      </div>
    );
  }

  if (!summary || summary.total_ratings === 0) {
    return (
      <div className="bg-white p-4 rounded-lg shadow">
        <h3 className="text-lg font-medium text-gray-900 mb-2">Ratings & Reviews</h3>
        <p className="text-gray-500">No ratings yet</p>
      </div>
    );
  }

  return (
    <div className="bg-white p-4 rounded-lg shadow">
      <h3 className="text-lg font-medium text-gray-900 mb-2">Ratings & Reviews</h3>
      
      <div className="flex items-center mb-4">
        <div className="text-4xl font-bold mr-4">{summary.average_rating}</div>
        <div>
          <Rating value={summary.average_rating} readOnly precision={0.1} />
          <div className="text-sm text-gray-500">{summary.total_ratings} {summary.total_ratings === 1 ? 'review' : 'reviews'}</div>
        </div>
      </div>
      
      {/* Rating Distribution */}
      <div className="mb-4">
        {[5, 4, 3, 2, 1].map(rating => {
          const count = summary.rating_distribution[rating] || 0;
          const percentage = summary.total_ratings > 0 
            ? (count / summary.total_ratings) * 100 
            : 0;
            
          return (
            <div key={rating} className="flex items-center mb-1">
              <div className="w-8 text-sm text-gray-600">{rating}</div>
              <div className="w-full bg-gray-200 rounded-full h-2.5 mr-2">
                <div 
                  className="bg-yellow-400 h-2.5 rounded-full" 
                  style={{ width: `${percentage}%` }}
                ></div>
              </div>
              <div className="w-8 text-sm text-gray-600">{count}</div>
            </div>
          );
        })}
      </div>
      
      {/* Recent Reviews */}
      {summary.recent_reviews.length > 0 && (
        <div>
          <h4 className="font-medium text-gray-900 mb-2">Recent Reviews</h4>
          {summary.recent_reviews.map((review, index) => (
            <div key={index} className="mb-3 pb-3 border-b border-gray-200 last:border-0">
              <div className="flex justify-between items-center mb-1">
                <div className="font-medium">{review.member_name}</div>
                <div className="text-sm text-gray-500">{new Date(review.created_at).toLocaleDateString()}</div>
              </div>
              <Rating value={review.rating} readOnly size="small" />
              {review.feedback && (
                <p className="text-sm text-gray-700 mt-1">{review.feedback}</p>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}

import React from 'react';
import { useSelector } from 'react-redux';

const ReviewList = () => {
  const { reviews, currentPage, reviewsPerPage } = useSelector((state) => state.reviews);
  const startIndex = (currentPage - 1) * reviewsPerPage;
  const currentReviews = reviews.slice(startIndex, startIndex + reviewsPerPage);

  return (
    <div>
      {currentReviews.map((review, index) => (
        <div key={index}>
          <h3>{review.title}</h3>
          <p>{review.content}</p>
        </div>
      ))}
    </div>
  );
};

export default ReviewList;

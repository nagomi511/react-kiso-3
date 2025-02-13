// Pagination.js
import React from 'react';

function Pagination({ onPageChange }) {
  return (
    <div className="button">
      <div onClick={() => onPageChange('prev')}>まえへ</div>
      <div onClick={() => onPageChange('next')}>つぎへ</div>
    </div>
  );
}

export default Pagination;

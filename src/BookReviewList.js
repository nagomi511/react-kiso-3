import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import './App.css';
import Pagination from './Pagination';
import { Link } from 'react-router-dom';


function BookReviewList() {
  const [reviews, setReviews] = useState([]);
  const [error, setError] = useState('');
  const [page, setPage] = useState({ currentPage: 0 });
  const navigate = useNavigate();

  useEffect(() => {

    async function fetchReviews() {
      try {
        const response = await axios.get(`https://railway.bookreview.techtrain.dev/public/books?offset=${page.currentPage * 10}`);
        setReviews(response.data);
      } catch (err) {
        setError('レビューの取得に失敗しました');
      }
    }

    fetchReviews();
  }, [page]);

  const handleReviewClick = (id) => {
    navigate(`/detail/${id}`);
  };

  function handlePageChange(pageAction) {
    if (pageAction === "next") {
      setPage(prevPage => ({ ...prevPage, currentPage: prevPage.currentPage + 1 }));
    } else if (pageAction === "prev" && page.currentPage > 0) {
      setPage(prevPage => ({ ...prevPage, currentPage: prevPage.currentPage - 1 }));
    }
  }

  return (
    <div className="container mx-auto p-4">
      <h1 className="text-2xl font-bold mb-4">書籍レビュー一覧</h1>
      <Link to="/new" className="bg-blue-400 text-white py-1 px-1 rounded-md hover:bg-blue-100">新しい書籍レビューを投稿する</Link>
      {error && <p className="text-red-500">{error}</p>}
      <div className="mt-4 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {reviews.map((review) => (
          <div key={review.id} className="p-4 border rounded-lg shadow-md cursor-pointer hover:shadow-xl transition duration-300 ease-in-out" onClick={() => handleReviewClick(review.id)}>
            <h2 className="text-xl font-semibold mb-2">{review.title}</h2>
            <p className="text-gray-700 mb-2">{review.content}</p>
            <p className="text-gray-500 text-sm">著者: {review.author}</p>
          </div>
        ))}
      </div>
      <Pagination onPageChange={handlePageChange} />
    </div>
  );
}

export default BookReviewList;

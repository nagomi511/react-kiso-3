import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

function NewBookReview() {
  const [title, setTitle] = useState('');
  const [url, setUrl] = useState('');
  const [error, setError] = useState('');
  const [detail, setDetail] = useState('');
  const [review, setReview] = useState('');
  const navigate = useNavigate();

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (!token) {
      navigate('/');
    }
  }, [navigate]);


  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const token = localStorage.getItem('token');
      await axios.post('https://railway.bookreview.techtrain.dev/books', {
        title: title,
        url: url,
        detail: detail,
        review: review,
      },
        {
          headers: {
            authorization: `Bearer ${token}`
          },
        }
      );
   
      navigate('/');
    } catch (err) {
      setError('レビューの登録に失敗しました');
    }
  };

  return (
    <div className="container mx-auto p-4">
      <h1 className="text-2xl font-bold mb-4">書籍レビューを投稿する</h1>
      {error && <p className="text-red-500">{error}</p>}
      <form onSubmit={handleSubmit} className="max-w-md">
        <div className="mb-4">
          <label className="block text-gray-700">書籍タイトル</label>
          <input type="text" id="title" value={title} onChange={(e) => setTitle(e.target.value)} className="mt-1 p-2 border rounded-md w-full" required />
        </div>
        <div className="mb-4">
          <label className="block text-gray-700">URL</label>
          <input type="text" value={url} onChange={(e) => setUrl(e.target.value)} className="mt-1 p-2 border rounded-md w-full" required />
        </div>
        <div className="mb-4">
          <label className="block text-gray-700">レビュワー</label>
          <input type="text" id="review" value={review} onChange={(e) => setReview(e.target.value)} className="mt-1 p-2 border rounded-md w-full" required />
        </div>
        <div className="mb-4">
          <label className="block text-gray-700">レビュー内容</label>
          <textarea value={detail} onChange={(e) => setDetail(e.target.value)} className="mt-1 p-2 border rounded-md w-full h-32" required />
        </div>
        <button type="submit" className="bg-blue-500 text-white py-2 px-4 rounded-md hover:bg-blue-600">登録</button>
      </form>
    </div>
  );
}

export default NewBookReview;

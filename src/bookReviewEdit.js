import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import axios from 'axios';

function BookReviewEdit() {
    const { id } = useParams();
    const history = useNavigate();
    const [review, setReview] = useState({
        title: '',
        url: '',
        review: '',
        reviewer: '',
        detail: ''
    });

    useEffect(() => {
        const fetchReview = async () => {
            try {
                const token = localStorage.getItem("token");
                const res = await axios.get(`https://railway.bookreview.techtrain.dev/books/${id}`, {
                    headers: {
                        authorization: `Bearer ${token}`
                    }
                });
                setReview(res.data);
            } catch (error) {
                console.error('Error fetching review:', error);
                // エラー処理はここで行うこともできます
            }
        };

        fetchReview();
    }, [id]);

    const handleInputChange = (event) => {
        const { name, value } = event.target;
        setReview(prevReview => ({
            ...prevReview,
            [name]: value
        }));
    };

    const handleFormSubmit = async (event) => {
        event.preventDefault();
        try {
            const token = localStorage.getItem("token");
            await axios.put(`https://railway.bookreview.techtrain.dev/books/${id}`, review, {
                headers: {
                    authorization: `Bearer ${token}`
                }
            });
            history.push(`/review/${id}`); // 編集後に詳細画面に戻る
        } catch (error) {
            console.error('Error updating review:', error);
            // エラー処理はここで行うこともできます
        }
    };

    return (
        <div className="container mx-auto p-4">
            <h1 className="text-2xl font-bold mb-4">書籍レビューの編集</h1>
            <form onSubmit={handleFormSubmit}>

                <div className="mb-4">
                    <label htmlFor="title" className="block text-sm font-medium text-gray-700">タイトル</label>
                    <input type="text" id="title" name="title" value={review.title} onChange={handleInputChange} className="mt-1 p-2 w-full border rounded-md" required />
                </div>
                <div className="mb-4">
                    <label htmlFor="url" className="block text-sm font-medium text-gray-700">URL</label>
                    <input type="text" id="url" name="url" value={review.url} onChange={handleInputChange} className="mt-1 p-2 w-full border rounded-md" />
                </div>
                <div className="mb-4">
                    <label htmlFor="review" className="block text-sm font-medium text-gray-700">レビュー</label>
                    <textarea id="review" name="review" value={review.review} onChange={handleInputChange} className="mt-1 p-2 w-full border rounded-md" rows="4" required></textarea>
                </div>
                <div className="mb-4">
                    <label htmlFor="reviewer" className="block text-sm font-medium text-gray-700">レビュワー</label>
                    <input type="text" id="reviewer" name="reviewer" value={review.reviewer} onChange={handleInputChange} className="mt-1 p-2 w-full border rounded-md" required />
                </div>
                <div className="mb-4">
                    <label htmlFor="detail" className="block text-sm font-medium text-gray-700">詳細</label>
                    <textarea id="detail" name="detail" value={review.detail} onChange={handleInputChange} className="mt-1 p-2 w-full border rounded-md" rows="4"></textarea>
                </div>
                <button type="submit" className="bg-blue-500 hover:bg-blue-600 text-white py-2 px-4 rounded-md">更新する</button>
            </form>
        </div>
    );
}

export default BookReviewEdit;

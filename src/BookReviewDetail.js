import React, { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import axios from 'axios';
import './BookReviewDetail.css';
import { Link } from 'react-router-dom';

function BookReviewDetail() {
    const { reviewId } = useParams();
    const [review, setReview] = useState(null);

    const navigate = useNavigate();

    useEffect(() => {
        const fetchReview = async () => {
            if (!localStorage.getItem("token")) {
                navigate("/login");
                return;
            }

            const token = localStorage.getItem("token");

            const logData = {
                selectBookId: reviewId,
            };

            try {
                await axios.post('https://railway.bookreview.techtrain.dev/logs', logData, {
                    headers: {
                        authorization: `Bearer ${token}`
                    },
                });
            } catch (error) {
                console.error('Error sending log:', error);

            }

            try {
                const res = await axios.get(`https://railway.bookreview.techtrain.dev/books/${reviewId}`, {
                    headers: {
                        authorization: `Bearer ${token}`
                    },
                });
                setReview(res.data);
            } catch (error) {
                console.error('Error fetching review:', error);

            }
        };

        fetchReview();
    }, [reviewId, navigate]);

    if (!review) {
        return <p>読み込み中...</p>;
    }
    const user = localStorage.getItem('username') || localStorage.getItem('name') || '';
    const isMe = review.reviewer === user.name

    return (
        <div className="container mx-auto p-4">
            <h1 className="text-2xl font-bold mb-4">{review.title}</h1>
            {isMe && <Link to={`/edit/{id}`} edit className="bg-blue-400 text-white py-1 px-1 rounded-md hover:bg-blue-100">書籍レビューを編集する</Link>}
            <p className="text-gray-700 mb-2">URL: {review.url}</p>
            <p className="text-gray-500 text-sm">レビュー: {review.review}</p>
            <p className="text-gray-500 text-sm">レビュワー: {review.reviewer}</p>
            <p className="text-gray-500 text-sm">詳細: {review.detail}</p>
        </div>
    );
}

export default BookReviewDetail;

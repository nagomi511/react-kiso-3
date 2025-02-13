// ProfileEdit.jsx

import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './ProfileEdit.css';

function ProfileEdit() {
    const [userInfo, setUserInfo] = useState({ name: '', iconUrl: '' });

    useEffect(() => {
        async function fetchUserInfo() {
            try {
                const token = localStorage.getItem('token');
                const response = await axios.get('https://railway.bookreview.techtrain.dev/users', {
                    headers: { Authorization: `Bearer ${token}` }
                });
                const { name, iconUrl } = response.data;
                setUserInfo({ name, iconUrl });
            } catch (error) {
                console.error('Failed to fetch user info:', error);
            }
        }
        fetchUserInfo();
    }, []);

    const handleNameChange = (e) => {
        const { value } = e.target;
        setUserInfo(prevState => ({
            ...prevState,
            name: value
        }));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            const token = localStorage.getItem('token');
            await axios.put('https://railway.bookreview.techtrain.dev/users', userInfo, {
                headers: { Authorization: `Bearer ${token}` }
            });
            alert('ユーザー情報が更新されました');
        } catch (error) {
            console.error('Failed to update user info:', error);
            alert('ユーザー情報の更新に失敗しました');
        }
    };

    return (
        <div className="profile-edit-container">
            <h2>ユーザー情報編集</h2>
            <img src={userInfo.iconUrl} alt='' />
            <form onSubmit={handleSubmit}>
                <div>
                    <label htmlFor="name">ユーザー名</label>
                    <input type="text" id="name" name="name" value={userInfo.name} onChange={handleNameChange} required />
                </div>
                <button type="submit">更新</button>
            </form>
        </div>
    );
}

export default ProfileEdit;

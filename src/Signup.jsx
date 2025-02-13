import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Compressor from 'compressorjs';
import { useNavigate } from 'react-router-dom';
import { Formik, Form, Field, ErrorMessage } from 'formik';
import * as Yup from 'yup';

function SignUp() {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    password: '',
    icon: null
  });
  const [errorMessage, setErrorMessage] = useState('');
  const navigate = useNavigate();

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (token) {
      navigate('/');
    }
  }, [navigate]);


  const handleIconUpload = (e) => {
    const file = e.target.files[0];
    new Compressor(file, {
      quality: 0.6,
      success(result) {
        setFormData({ ...formData, icon: result });
      },
      error(err) {
        console.error("Compression Error:", err.message);
        setErrorMessage('画像の処理中にエラーが発生しました。');
      }
    });
  };

  const handleSubmit = async (values, { setSubmitting }) => {
    const { name, email, password } = values;
    const { icon } = formData;
    if (!icon) {
      setErrorMessage('アイコンをアップロードしてください。');
      setSubmitting(false);
      return;
    }

    try {
      let response = await axios.post('https://railway.bookreview.techtrain.dev/users', { name, email, password });
      console.log('サインアップ成功:', response.data);
      await uploadIcon(icon, response.data.token);
      navigate('/');
    } catch (error) {
      setErrorMessage(`サインアップに失敗しました。 ${error.response?.data || 'Error'}`);
    } finally {
      setSubmitting(false);
    }
  };

  const uploadIcon = async (iconFile, token) => {
    const formData = new FormData();
    formData.append('icon', iconFile);

    try {
      await axios.post('https://railway.bookreview.techtrain.dev/uploads', formData, {
        headers: {
          'Authorization': 'Bearer ' + token
        }
      });
    } catch (error) {
      console.error('アイコンアップロードエラー:', error);
      setErrorMessage('アイコンのアップロードに失敗しました。');
    }
  };

  const initialValues = {
    name: '',
    email: '',
    password: '',
  };

  const validationSchema = Yup.object({
    name: Yup.string().required('ユーザ名は必須です'),
    email: Yup.string().email('有効なメールアドレスを入力してください').required('メールアドレスは必須です'),
    password: Yup.string().required('パスワードは必須です'),
  });

  return (
    <div>
      <h2>新規作成</h2>
      <Formik
        initialValues={initialValues}
        validationSchema={validationSchema}
        onSubmit={handleSubmit}
      >
        {({ isSubmitting, setFieldValue }) => (
          <Form>
            <div>
              <label htmlFor="name">ユーザー名</label>
              <Field type="text" name="name" />
              <ErrorMessage name="name" component="div" style={{ color: 'red' }} />
            </div>
            <div>
              <label htmlFor="email">メールアドレス</label>
              <Field type="email" name="email" />
              <ErrorMessage name="email" component="div" style={{ color: 'red' }} />
            </div>
            <div>
              <label htmlFor="password">パスワード</label>
              <Field type="password" name="password" />
              <ErrorMessage name="password" component="div" style={{ color: 'red' }} />
            </div>
            <div>
              <label htmlFor="icon">アイコン</label>
              <input
                type="file"
                name="icon"
                onChange={(e) => {
                  handleIconUpload(e);
                  setFieldValue('icon', e.target.files[0]);
                }}
              />
            </div>
            <button type="submit" disabled={isSubmitting}>
              サインアップ
            </button>
          </Form>
        )}
      </Formik>
      {errorMessage && <p className="error">{errorMessage}</p>}
      <p>
        ログイン <a href="/login">Sign up</a>
      </p>
    </div>
  );
}

export default SignUp;

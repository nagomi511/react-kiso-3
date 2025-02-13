import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';
import { Formik, Form, Field, ErrorMessage } from 'formik';
import * as Yup from 'yup';

function Login() {
  const [error, setError] = useState('');
  const navigate = useNavigate();

  useEffect(() => {
    const token = localStorage.getItem('token');
    if (token) {
      navigate('/');
    }
  }, [navigate]);

  const validationSchema = Yup.object({
    name: Yup.string().required('ユーザー名は必須です'),
    email: Yup.string().email('有効なメールアドレスを入力してください').required('メールアドレスは必須です'),
    password: Yup.string().required('パスワードは必須です'),
  });

  const handleSubmit = async (values, { setSubmitting }) => {
    try {
      const response = await axios.post('https://railway.bookreview.techtrain.dev/signin', values);
      console.log('Login successful:', response.data);
      window.localStorage.setItem("token", response.data.token)
      navigate('/');
    } catch (error) {
      setError('Failed to login. ' + (error.response?.data?.message || 'Please check your credentials.'));
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div>
      <h2>ログイン</h2>
      <Formik
        initialValues={{ name: '', email: '', password: '' }}
        validationSchema={validationSchema}
        onSubmit={handleSubmit}
      >
        {({ isSubmitting }) => (
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
            <button type="submit" disabled={isSubmitting}>Login</button>
          </Form>
        )}
      </Formik>
      {error && <p style={{ color: 'red' }}>{error}</p>}
      <p>
        アカウント登録 <a href="/signup">Sign up</a>
      </p>
    </div>
  );
}

export default Login;

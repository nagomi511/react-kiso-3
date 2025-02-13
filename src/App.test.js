import React from 'react';
import { render, screen } from '@testing-library/react';
import App from './App';

describe('App component tests', () => {
  test('contains necessary input fields for the form', () => {
    render(<App />);
    
    // Check for company name input
    const companyNameInput = screen.getByPlaceholderText("会社名");
    expect(companyNameInput).toBeInTheDocument();
    expect(companyNameInput).toHaveAttribute('name', '会社名');
    
    // Check for name input
    const nameInput = screen.getByPlaceholderText("山田 太郎");
    expect(nameInput).toBeInTheDocument();
    expect(nameInput).toHaveAttribute('name', 'お名前');
    
    // Check for email address input
    const emailInput = screen.getByPlaceholderText("sample@co.jp");
    expect(emailInput).toBeInTheDocument();
    expect(emailInput).toHaveAttribute('name', 'メールアドレス');
    
    // Check for phone number input
    const phoneInput = screen.getByPlaceholderText("000000000");
    expect(phoneInput).toBeInTheDocument();
    expect(phoneInput).toHaveAttribute('name', '電話番号');
  });
});

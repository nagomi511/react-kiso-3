import React from "react";
import { Link, useNavigate } from "react-router-dom";

export const Header = () => {
  const isSignin = !!localStorage.getItem("token")
  const navigate = useNavigate()
  const signOut = () => {
    localStorage.removeItem("token");
    navigate("/");
  }
  return (
    <header>
      <nav>
        <Link to="/">ホーム</Link>
        {!isSignin && (<><Link to="/signup">サインアップ</Link>
          <Link to="/login">ログイン</Link></>)}
        {isSignin && <button onClick={signOut}>サインアウト</button>}
        {isSignin && <Link to="/profile">ユーザー情報編集</Link>}
      </nav>
    </header>
  );
};

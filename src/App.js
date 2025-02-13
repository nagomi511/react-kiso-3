import { BrowserRouter as Router, Routes, Route, } from 'react-router-dom';
import SignUp from './Signup';
import Login from './Login';
import BookReviewList from './BookReviewList';
import { Header } from './Header';
import NewBookReview from './NewBookReview';
import ProfileEdit from './ProfileEdit';
import BookReviewDetail from './BookReviewDetail';
import BookReviewEdit from './bookReviewEdit';


function App() {
  return (

    <Router>
      <div className="App">
        <Header />
        <Routes>
          <Route path="/" element={<BookReviewList />} />
          <Route path="/signup" element={<SignUp />} />
          <Route path="/login" element={<Login />} />
          <Route path="/new" element={<NewBookReview />} />
          <Route path="/profile" element={<ProfileEdit />} />
          <Route path="/detail/:reviewId" element={<BookReviewDetail />} />
          <Route path="/edit/:reviewId" element={<BookReviewEdit />} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;


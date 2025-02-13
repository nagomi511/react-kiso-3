import { createSlice } from '@reduxjs/toolkit';

const initialState = {
  reviews: [], // レビューのデータ
  currentPage: 1,
  reviewsPerPage: 10,
};

const reviewsSlice = createSlice({
  name: 'reviews',
  initialState,
  reducers: {
    setReviews: (state, action) => {
      state.reviews = action.payload;
    },
    setCurrentPage: (state, action) => {
      state.currentPage = action.payload;
    },
  },
});

export const { setReviews, setCurrentPage } = reviewsSlice.actions;
export default reviewsSlice.reducer;

import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Layout from './components/Layout';
import Home from './pages/Home';
import PDFViewerPage from './pages/PDFViewerPage';
import AdminLogin from './pages/AdminLogin';
import AdminUpload from './pages/AdminUpload';
import './index.css';

function App() {
  return (
    <Router>
      <Layout>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/pdf/:id" element={<PDFViewerPage />} />
          <Route path="/admin/login" element={<AdminLogin />} />
          <Route path="/admin/upload" element={<AdminUpload />} />
          <Route path="*" element={<NotFound />} />
        </Routes>
      </Layout>
    </Router>
  );
}

// 404 Page Component
const NotFound = () => {
  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div className="text-center">
        <div className="text-6xl mb-4">📄</div>
        <h1 className="text-4xl font-bold text-gray-900 dark:text-white mb-2">
          404 - Page Not Found
        </h1>
        <p className="text-gray-600 dark:text-gray-400 mb-4">
          The page you're looking for doesn't exist.
        </p>
        <a href="/" className="btn-primary">
          Go Home
        </a>
      </div>
    </div>
  );
};

export default App;
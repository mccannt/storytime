import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8080/api';

// Create axios instance
const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30000, // 30 seconds timeout
});

// Add auth token to requests
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('adminToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Handle auth errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('adminToken');
      window.location.href = '/admin/login';
    }
    return Promise.reject(error);
  }
);

// Auth API
export const authAPI = {
  login: (password) => api.post('/auth/login', { password }),
  verify: () => api.get('/auth/verify'),
};

// PDFs API
export const pdfAPI = {
  getAll: () => api.get('/pdfs'),
  getById: (id) => api.get(`/pdfs/${id}`),
  upload: (formData) => api.post('/pdfs/upload', formData, {
    headers: {
      'Content-Type': 'multipart/form-data',
    },
  }),
  delete: (id) => api.delete(`/pdfs/${id}`),
  getFileUrl: (filename) => `${API_BASE_URL}/pdfs/file/${filename}`,
  getDownloadUrl: (filename) => `${API_BASE_URL}/pdfs/download/${filename}`,
};

export default api;
// Auth utility functions
export const isAuthenticated = () => {
  const token = localStorage.getItem('adminToken');
  return !!token;
};

export const getToken = () => {
  return localStorage.getItem('adminToken');
};

export const setToken = (token) => {
  localStorage.setItem('adminToken', token);
};

export const removeToken = () => {
  localStorage.removeItem('adminToken');
};

export const logout = () => {
  removeToken();
  window.location.href = '/';
};
import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Upload, FileText, X, Check, AlertCircle } from 'lucide-react';
import { pdfAPI } from '../utils/api'; // Ensure pdfAPI is correctly imported
import { isAuthenticated } from '../utils/auth';
import { formatFileSize } from '../utils/formatters';

// Define the component
const AdminUpload = () => {
  const navigate = useNavigate();
  const [pdfs, setPdfs] = useState([]);
  const [file, setFile] = useState(null);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [uploading, setUploading] = useState(false);
  const [uploadSuccess, setUploadSuccess] = useState(false);
  const [error, setError] = useState('');
  const [dragOver, setDragOver] = useState(false);

  useEffect(() => {
    if (!isAuthenticated()) {
      navigate('/admin/login');
    } else {
      fetchPdfs();
    }
  }, [navigate]);

  const fetchPdfs = async () => {
    try {
      const response = await pdfAPI.getAll();
      setPdfs(response.data);
    } catch (error) {
      console.error('Error fetching PDFs:', error);
    }
  };

  const handleDelete = async (id) => {
    try {
      await pdfAPI.delete(id);
      setPdfs(pdfs.filter((pdf) => pdf.id !== id));
    } catch (error) {
      console.error('Error deleting PDF:', error);
      setError('Failed to delete PDF. Please try again.');
    }
  };

  const handleFileSelect = (selectedFile) => {
    if (selectedFile && selectedFile.type === 'application/pdf') {
      setFile(selectedFile);
      setError('');
      if (!title) {
        const filename = selectedFile.name.replace('.pdf', '');
        setTitle(filename);
      }
    } else {
      setError('Please select a valid PDF file');
    }
  };

  const handleDrop = (e) => {
    e.preventDefault();
    setDragOver(false);
    const droppedFile = e.dataTransfer.files[0];
    handleFileSelect(droppedFile);
  };

  const handleDragOver = (e) => {
    e.preventDefault();
    setDragOver(true);
  };

  const handleDragLeave = (e) => {
    e.preventDefault();
    setDragOver(false);
  };

  const handleFileInputChange = (e) => {
    const selectedFile = e.target.files[0];
    handleFileSelect(selectedFile);
  };

  const removeFile = () => {
    setFile(null);
    setError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!file) {
      setError('Please select a PDF file');
      return;
    }

    if (!title.trim()) {
      setError('Title is required');
      return;
    }

    setUploading(true);
    setError('');

    try {
      const formData = new FormData();
      formData.append('pdf', file);
      formData.append('title', title.trim());
      formData.append('description', description.trim());

      await pdfAPI.upload(formData);

      setUploadSuccess(true);
      setFile(null);
      setTitle('');
      setDescription('');

      setTimeout(() => {
        setUploadSuccess(false);
      }, 3000);
    } catch (error) {
      console.error('Upload error:', error);
      setError(
        error.response?.data?.error || 'Upload failed. Please try again.'
      );
    } finally {
      setUploading(false);
    }
  };

  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 dark:text-white mb-2">
          Add New Story
        </h1>
        <p className="text-gray-600 dark:text-gray-400">
          Upload a new story or document to your StoryTime library
        </p>
      </div>

      <div className="mt-12">
        <h2 className="text-2xl font-semibold text-gray-800 dark:text-white mb-4">
          Manage PDFs
        </h2>
        {pdfs.length === 0 ? (
          <p className="text-gray-600 dark:text-gray-400">No PDFs uploaded yet.</p>
        ) : (
          <ul className="divide-y divide-gray-200 dark:divide-gray-700">
            {pdfs.map((pdf) => (
              <li key={pdf.id} className="py-4 flex items-center justify-between">
                <div>
                  <h3 className="text-lg font-medium text-gray-900 dark:text-white">
                    {pdf.title}
                  </h3>
                  <p className="text-sm text-gray-500 dark:text-gray-400">
                    {pdf.description || 'No description'}
                  </p>
                </div>
                <button onClick={() => handleDelete(pdf.id)} className="btn-danger">
                  Delete
                </button>
              </li>
            ))}
          </ul>
        )}
      </div>

      {uploadSuccess && (
        <div className="mb-6 bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg p-4 animate-slide-up">
          <div className="flex items-center">
            <Check className="h-5 w-5 text-green-600 dark:text-green-400 mr-2" />
            <p className="text-green-600 dark:text-green-400 font-medium">
              Story uploaded successfully!
            </p>
          </div>
        </div>
      )}

      <div className="card p-6">
  <form onSubmit={handleSubmit} className="space-y-6">
    <div>
      <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
        PDF File *
      </label>

      {!file ? (
        <div
          onDrop={handleDrop}
          onDragOver={handleDragOver}
          onDragLeave={handleDragLeave}
          className="border-2 border-dashed rounded-lg p-8 text-center cursor-pointer"
        >
          {/* Hidden file input for selecting PDF */}
          <input
            type="file"
            accept=".pdf"
            onChange={handleFileInputChange}
            className="hidden"
            id="file-upload"
          />
          <label
            htmlFor="file-upload"
            className="btn-primary cursor-pointer inline-block"
          >
            Choose File
          </label>
        </div>
      ) : (
        <div className="border border-gray-300 dark:border-gray-600 rounded-lg p-4 bg-gray-50 dark:bg-gray-700">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <FileText className="h-8 w-8 text-red-500" />
              <div>
                <p className="font-medium text-gray-900 dark:text-white">
                  {file.name}
                </p>
                <p className="text-sm text-gray-500 dark:text-gray-400">
                  {formatFileSize(file.size)}
                </p>
              </div>
            </div>
            <button
              type="button"
              onClick={removeFile}
              className="p-1 text-gray-400 hover:text-red-500"
            >
              <X className="h-5 w-5" />
            </button>
          </div>
        </div>
      )}
    </div>

    {/* More form fields for title, description, etc. */}

    {error && (
      <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-3">
        <div className="flex items-center">
          <AlertCircle className="h-4 w-4 text-red-600 dark:text-red-400 mr-2" />
          <p className="text-red-600 dark:text-red-400 text-sm">{error}</p>
        </div>
      </div>
    )}

    <div className="flex justify-end space-x-3">
      <button
        type="button"
        onClick={() => {
          setFile(null);
          setTitle('');
          setDescription('');
          setError('');
        }}
        className="btn-secondary"
        disabled={uploading}
      >
        Clear
      </button>
      <button
        type="submit"
        disabled={uploading || !file || !title.trim()}
        className="btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
      >
        {uploading ? (
          <div className="flex items-center space-x-2">
            <div className="loading-spinner h-4 w-4"></div>
            <span>Uploading...</span>
          </div>
        ) : (
          <div className="flex items-center space-x-2">
            <Upload className="h-4 w-4" />
            <span>Upload PDF</span>
          </div>
        )}
      </button>
    </div>
  </form>
</div>
    </div>
  );
};

export default AdminUpload;
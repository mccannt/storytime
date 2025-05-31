import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { ArrowLeft, Calendar, HardDrive, Eye, Download as DownloadIcon } from 'lucide-react';
import PDFViewer from '../components/PDFViewer';
import LoadingSpinner from '../components/LoadingSpinner';
import { pdfAPI } from '../utils/api';
import { formatFileSize, formatDate } from '../utils/formatters';

const PDFViewerPage = () => {
  const { id } = useParams();
  const [pdf, setPdf] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchPdf();
  }, [id]);

  const fetchPdf = async () => {
    try {
      setLoading(true);
      const response = await pdfAPI.getById(id);
      setPdf(response.data);
      setError(null);
    } catch (error) {
      console.error('Error fetching PDF:', error);
      setError('PDF not found or failed to load.');
    } finally {
      setLoading(false);
    }
  };

  const handleDownload = () => {
    if (pdf) {
      const downloadUrl = pdfAPI.getDownloadUrl(pdf.filename);
      window.open(downloadUrl, '_blank');
    }
  };

  if (loading) {
    return (
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="flex items-center justify-center h-64">
          <LoadingSpinner size="lg" text="Loading PDF..." />
        </div>
      </div>
    );
  }

  if (error || !pdf) {
    return (
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="text-center">
          <div className="text-red-500 text-6xl mb-4">📄</div>
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">
            PDF Not Found
          </h2>
          <p className="text-gray-600 dark:text-gray-400 mb-4">
            {error || 'The requested PDF could not be found.'}
          </p>
          <Link to="/" className="btn-primary">
            Back to Library
          </Link>
        </div>
      </div>
    );
  }

  const fileUrl = pdfAPI.getFileUrl(pdf.filename);

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Header */}
      <div className="mb-6">
        <Link
          to="/"
          className="inline-flex items-center space-x-2 text-primary-600 dark:text-primary-400 hover:text-primary-700 dark:hover:text-primary-300 mb-4"
        >
          <ArrowLeft className="h-4 w-4" />
          <span>Back to Library</span>
        </Link>

        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-sm border border-gray-200 dark:border-gray-700 p-6">
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">
            {pdf.title}
          </h1>
          
          {pdf.description && (
            <p className="text-gray-600 dark:text-gray-300 mb-4">
              {pdf.description}
            </p>
          )}

          {/* Metadata */}
          <div className="flex flex-wrap items-center gap-4 text-sm text-gray-500 dark:text-gray-400">
            <div className="flex items-center space-x-1">
              <Calendar className="h-4 w-4" />
              <span>Uploaded {formatDate(pdf.uploaded_at)}</span>
            </div>
            
            <div className="flex items-center space-x-1">
              <HardDrive className="h-4 w-4" />
              <span>{formatFileSize(pdf.file_size)}</span>
            </div>

            {pdf.view_count > 0 && (
              <div className="flex items-center space-x-1">
                <Eye className="h-4 w-4" />
                <span>{pdf.view_count} views</span>
              </div>
            )}

            {pdf.download_count > 0 && (
              <div className="flex items-center space-x-1">
                <DownloadIcon className="h-4 w-4" />
                <span>{pdf.download_count} downloads</span>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* PDF Viewer */}
      <PDFViewer
        fileUrl={fileUrl}
        filename={pdf.filename}
        title={pdf.title}
        onDownload={handleDownload}
      />
    </div>
  );
};

export default PDFViewerPage;
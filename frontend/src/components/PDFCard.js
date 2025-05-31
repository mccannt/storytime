import React from 'react';
import { Link } from 'react-router-dom';
import { Eye, Download, Calendar, HardDrive, BarChart3 } from 'lucide-react';
import { formatFileSize, formatDate, truncateText } from '../utils/formatters';
import { pdfAPI } from '../utils/api';

const PDFCard = ({ pdf }) => {
  const handleDownload = async (e) => {
    e.preventDefault();
    e.stopPropagation();
    
    try {
      const downloadUrl = pdfAPI.getDownloadUrl(pdf.filename);
      window.open(downloadUrl, '_blank');
    } catch (error) {
      console.error('Download error:', error);
    }
  };

  return (
    <div className="card p-6 hover:shadow-lg transition-shadow duration-200 animate-fade-in">
      <div className="flex flex-col h-full">
        {/* Header */}
        <div className="flex-1">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-2 line-clamp-2">
            {pdf.title}
          </h3>
          
          {pdf.description && (
            <p className="text-gray-600 dark:text-gray-300 text-sm mb-4 line-clamp-3">
              {truncateText(pdf.description, 120)}
            </p>
          )}
        </div>

        {/* Metadata */}
        <div className="space-y-2 mb-4">
          <div className="flex items-center text-xs text-gray-500 dark:text-gray-400">
            <Calendar className="h-3 w-3 mr-1" />
            <span>{formatDate(pdf.uploaded_at)}</span>
          </div>
          
          <div className="flex items-center text-xs text-gray-500 dark:text-gray-400">
            <HardDrive className="h-3 w-3 mr-1" />
            <span>{formatFileSize(pdf.file_size)}</span>
          </div>

          {(pdf.view_count > 0 || pdf.download_count > 0) && (
            <div className="flex items-center space-x-3 text-xs text-gray-500 dark:text-gray-400">
              <div className="flex items-center">
                <Eye className="h-3 w-3 mr-1" />
                <span>{pdf.view_count || 0} views</span>
              </div>
              <div className="flex items-center">
                <Download className="h-3 w-3 mr-1" />
                <span>{pdf.download_count || 0} downloads</span>
              </div>
            </div>
          )}
        </div>

        {/* Actions */}
        <div className="flex space-x-2">
          <Link
            to={`/pdf/${pdf.id}`}
            className="flex-1 btn-primary text-center flex items-center justify-center space-x-1"
          >
            <Eye className="h-4 w-4" />
            <span>View</span>
          </Link>
          
          <button
            onClick={handleDownload}
            className="btn-secondary flex items-center justify-center space-x-1 px-4"
            title="Download PDF"
          >
            <Download className="h-4 w-4" />
            <span className="hidden sm:inline">Download</span>
          </button>
        </div>
      </div>
    </div>
  );
};

export default PDFCard;
import React from 'react';

const LoadingSpinner = ({ size = 'md', text = 'Loading...' }) => {
  const sizeClasses = {
    sm: 'h-4 w-4',
    md: 'h-8 w-8',
    lg: 'h-12 w-12',
  };

  return (
    <div className="flex items-center justify-center space-x-2">
      <div className={`loading-spinner ${sizeClasses[size]}`}></div>
      {text && <span className="text-gray-600 dark:text-gray-400">{text}</span>}
    </div>
  );
};

export default LoadingSpinner;
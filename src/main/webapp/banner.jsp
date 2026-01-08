<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Banner - Escape</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="admin-styles.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #e50914;
            --bg-dark: #0f0f0f;
            --bg-light: #f3f3f3;
            --text-dark: #333;
            --text-light: #fff;
        }

        body {
            background-color: var(--bg-light);
            font-family: 'Arial', sans-serif;
        }

        .admin-sidebar {
            width: 250px;
            height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            background: white;
            border-right: 1px solid #ddd;
            z-index: 1000;
        }

        .admin-logo {
            padding: 20px;
            border-bottom: 1px solid #ddd;
        }

        .admin-logo a {
            color: var(--primary-color);
            font-size: 24px;
            font-weight: bold;
            text-decoration: none;
            font-family: 'Arial', sans-serif;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .admin-nav {
            padding: 20px 0;
        }

        .nav-item {
            padding: 12px 20px;
            display: flex;
            align-items: center;
            color: var(--text-dark);
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .nav-item:hover, .nav-item.active {
            background-color: #f8f9fa;
            color: var(--primary-color);
        }

        .nav-item i {
            margin-right: 10px;
            width: 20px;
            text-align: center;
        }

        .admin-content {
            margin-left: 250px;
            padding: 20px;
        }

       .content-header {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }

        .content-header h1 {
            margin: 0;
            font-size: 24px;
            font-weight: 500;
        }

        .movie-form {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
        }

        .form-control {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }

        .form-control:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 2px rgba(229, 9, 20, 0.1);
        }

        .btn-submit {
            background-color: var(--primary-color);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-submit:hover {
            opacity: 0.9;
        }

        .banner-preview {
            width: 100%;
            height: 400px;
            border-radius: 8px;
            overflow: hidden;
            margin-top: 20px;
            position: relative;
            background-color: var(--bg-dark);
        }

        .preview-container {
            position: relative;
            width: 100%;
            height: 100%;
        }

        .preview-container img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .banner-content {
            position: absolute;
            bottom: 16%;
            left: 5%;
            right: 5%;
            color: #fff;
            z-index: 10;
        }

        .banner-title {
            font-size: 3rem;
            font-weight: bold;
            margin-bottom: 1rem;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.5);
        }

        .banner-description {
            font-size: 1.2rem;
            max-width: 600px;
            margin-bottom: 1.5rem;
            text-shadow: 1px 1px 2px rgba(0,0,0,0.5);
        }

        .banner-buttons .btn {
            margin-right: 1rem;
            padding: 0.6rem 1.5rem;
            font-size: 1rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            transition: all 0.3s ease;
        }

        .banner-buttons .btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 4px 10px rgba(0,0,0,0.3);
        }

        .loading {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            z-index: 9999;
            justify-content: center;
            align-items: center;
        }

        .loading-spinner {
            width: 50px;
            height: 50px;
            border: 5px solid #f3f3f3;
            border-top: 5px solid var(--primary-color);
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        .banner-selector-container {
            margin-bottom: 20px;
        }

        .button-container {
            display: flex;
            gap: 10px;
            align-items: center;
            margin-top: 1rem;
        }
    </style>
</head>
<body>
    <div class="loading">
        <div class="loading-spinner"></div>
    </div>
    
     <!-- Include Admin Header -->
    <jsp:include page="admin-header.jsp">
        <jsp:param name="pageTitle" value="Banner" />
        <jsp:param name="currentPage" value="banner" />
    </jsp:include>

    <div class="admin-sidebar">
        <div class="admin-logo">
            <a href="#">Escape</a>
        </div>
        <nav class="admin-nav">
            <a href="admin.jsp" class="nav-item">
                <i class="fas fa-home"></i>
                Dashboard
            </a>
            <a href="movies.jsp" class="nav-item">
                <i class="fas fa-film"></i>
                Movies
            </a>
            <a href="banner.jsp" class="nav-item active">
                <i class="fas fa-image"></i>
                Banner
            </a>
            <a href="users.jsp" class="nav-item">
                <i class="fas fa-users"></i>
                Users
            </a>
            <a href="notification.jsp" class="nav-item">
                <i class="fas fa-bell"></i>
                Notification
            </a>
            <a href="settings.jsp" class="nav-item">
                <i class="fas fa-cog"></i>
                Settings
            </a>
        </nav>
    </div>

    <div class="admin-content">
        <div class="content-header">
            <h1>Edit Banner</h1>
        </div>

        <div class="movie-form">
            <div class="banner-selector-container">
                <select id="bannerSelector" class="form-select">
                    <option value="">Select Existing Banner</option>
                </select>
            </div>

            <form id="bannerForm" method="post" enctype="multipart/form-data">
                <div class="row">
                    <div class="col-md-12">
                        <div class="form-group">
                            <label for="bannerTitle">Banner Title</label>
                            <input type="text" class="form-control" id="bannerTitle" name="bannerTitle" required>
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <label for="bannerDescription">Banner Description</label>
                    <textarea class="form-control" id="bannerDescription" name="bannerDescription" rows="3" required></textarea>
                </div>

                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="bannerPoster">Banner Poster</label>
                            <input type="file" class="form-control" id="bannerPoster" name="bannerPoster" accept="image/*" required onchange="previewBanner(event)">
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label for="bannerVideo">Banner Video</label>
                            <input type="file" class="form-control" id="bannerVideo" name="bannerVideo" accept="video/mp4" required>
                        </div>
                    </div>
                </div>

                <div class="preview-section" style="display: none;">
                    <h4 class="mt-4">Preview</h4>
                    <div class="banner-preview">
                        <div class="preview-container">
                            <img id="posterPreview" src="" alt="Banner Preview">
                            <div class="banner-content">
                                <h1 class="banner-title" id="previewTitle"></h1>
                                <p class="banner-description" id="previewDescription"></p>
                                <div class="banner-buttons">
                                    <button type="button" class="btn btn-light">
                                        <i class="fas fa-play me-2"></i>Play
                                    </button>
                                    <button type="button" class="btn btn-outline-light">
                                        <i class="fas fa-info-circle me-2"></i>More Info
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="button-container">
                    <button type="submit" class="btn-submit">Add Banner</button>
                    <button type="button" id="removeBannerBtn" class="btn btn-danger" style="display: none;">
                        <i class="fas fa-trash-alt me-2"></i>Remove Banner
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Global variables
        let currentBannerId = null;
        let domElements = null;

        // Utility functions
        function showLoading() {
            const loader = document.querySelector('.loading');
            if (loader) loader.style.display = 'flex';
        }

        function hideLoading() {
            const loader = document.querySelector('.loading');
            if (loader) loader.style.display = 'none';
        }

        function previewBanner(event) {
            const file = event.target.files[0];
            if (!file) return;

            const reader = new FileReader();
            reader.onload = function(e) {
                const previewSection = document.querySelector('.preview-section');
                const posterPreview = document.getElementById('posterPreview');
                
                if (previewSection && posterPreview) {
                    previewSection.style.display = 'block';
                    posterPreview.src = e.target.result;
                    updatePreview();
                }
            };
            reader.readAsDataURL(file);
        }

        function updatePreview() {
            const titleElem = document.getElementById('previewTitle');
            const descElem = document.getElementById('previewDescription');
            const titleInput = document.getElementById('bannerTitle');
            const descInput = document.getElementById('bannerDescription');

            if (titleElem && titleInput) {
                titleElem.textContent = titleInput.value || 'Banner Title';
            }
            if (descElem && descInput) {
                descElem.textContent = descInput.value || 'Banner Description';
            }
        }

        function initializeDomElements() {
            domElements = {
                bannerSelector: document.getElementById('bannerSelector'),
                bannerForm: document.getElementById('bannerForm'),
                bannerTitle: document.getElementById('bannerTitle'),
                bannerDescription: document.getElementById('bannerDescription'),
                bannerPoster: document.getElementById('bannerPoster'),
                bannerVideo: document.getElementById('bannerVideo'),
                posterPreview: document.getElementById('posterPreview'),
                previewTitle: document.getElementById('previewTitle'),
                previewDescription: document.getElementById('previewDescription'),
                previewSection: document.querySelector('.preview-section'),
                submitButton: document.querySelector('.btn-submit'),
                removeButton: document.getElementById('removeBannerBtn')
            };

            return Object.values(domElements).every(element => element !== null);
        }

        function handleBannerSelection(bannerData) {
            try {
                // Validate the input
                if (!bannerData || typeof bannerData !== 'string') {
                    console.warn('Invalid or missing bannerData:', bannerData);
                    return;
                }

                // Attempt to parse the JSON
                const data = JSON.parse(bannerData.trim());

                // Validate the parsed data
                if (!data || typeof data.bannerId === 'undefined') {
                    console.warn('Invalid bannerData structure:', data);
                    return;
                }

                // Assign the banner ID to the current context
                currentBannerId = data.bannerId;

                // Update DOM elements if they exist
                if (domElements.bannerTitle) {
                    domElements.bannerTitle.value = data.title || '';
                }
                if (domElements.bannerDescription) {
                    domElements.bannerDescription.value = data.description || '';
                }
                if (domElements.bannerPoster) {
                    domElements.bannerPoster.removeAttribute('required');
                }
                if (domElements.bannerVideo) {
                    domElements.bannerVideo.removeAttribute('required');
                }
                if (domElements.previewSection) {
                    domElements.previewSection.style.display = 'block';
                }
                if (domElements.posterPreview && data.posterPath) {
                    domElements.posterPreview.src = data.posterPath;
                }
                if (domElements.previewTitle) {
                    domElements.previewTitle.textContent = data.title || '';
                }
                if (domElements.previewDescription) {
                    domElements.previewDescription.textContent = data.description || '';
                }
                if (domElements.submitButton) {
                    domElements.submitButton.textContent = 'Update Banner';
                    domElements.submitButton.classList.remove('btn-primary');
                    domElements.submitButton.classList.add('btn-success');
                }
                if (domElements.removeButton) {
                    domElements.removeButton.style.display = 'inline-block';
                }
            } catch (error) {
                // Log error details for debugging
                console.error('Error in handleBannerSelection:', error, bannerData);
            }
        }


        function resetForm() {
            if (!domElements.bannerForm) return;
            
            domElements.bannerForm.reset();
            
            if (domElements.previewSection) {
                domElements.previewSection.style.display = 'none';
            }
            if (domElements.removeButton) {
                domElements.removeButton.style.display = 'none';
            }
            if (domElements.bannerPoster) {
                domElements.bannerPoster.setAttribute('required', '');
            }
            if (domElements.bannerVideo) {
                domElements.bannerVideo.setAttribute('required', '');
            }
            if (domElements.submitButton) {
                domElements.submitButton.textContent = 'Add Banner';
                domElements.submitButton.classList.remove('btn-success');
                domElements.submitButton.classList.add('btn-primary');
            }
            
            currentBannerId = null;
        }

        function loadBannersIntoDropdown(banners) {
            if (!domElements.bannerSelector || !Array.isArray(banners)) return;
            
            domElements.bannerSelector.innerHTML = '<option value="">Select Existing Banner</option>';
            
            banners.forEach(banner => {
                if (!banner) return;
                
                const option = document.createElement('option');
                const cleanBanner = {
                    bannerId: banner.bannerId,
                    title: banner.title || '',
                    description: banner.description || '',
                    posterPath: banner.posterPath || '',
                    videoPath: banner.videoPath || ''
                };
                
                option.value = JSON.stringify(cleanBanner);
                option.textContent = cleanBanner.title || 'Untitled Banner';
                domElements.bannerSelector.appendChild(option);
            });
        }

        function deleteBanner(bannerId) {
            if (!bannerId || bannerId === 'undefined') {
                alert('Please select a banner to delete');
                return;
            }
            
            if (!confirm('Are you sure you want to delete this banner?')) {
                return;
            }
            
            showLoading();
            
            // Create URLSearchParams object instead of FormData for this case
            const params = new URLSearchParams();
            params.append('bannerId', bannerId.toString());
            
            fetch('DeleteBannerServlet', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: params.toString()
            })
            .then(async response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                const text = await response.text();
                try {
                    return JSON.parse(text);
                } catch (e) {
                    console.error('Server response:', text);
                    throw new Error('Invalid JSON response from server');
                }
            })
            .then(data => {
                hideLoading();
                if (data.success) {
                    alert(data.message || 'Banner deleted successfully');
                    resetForm();
                    fetchBanners();
                } else {
                    throw new Error(data.message || 'Failed to delete banner');
                }
            })
            .catch(error => {
                hideLoading();
                console.error('Error:', error);
                alert('Error deleting banner: ' + error.message);
            });
        }

        async function fetchBanners() {
            try {
                const response = await fetch('AddBannerServlet');
                const data = await response.json();
                if (data.success && data.banners) {
                    loadBannersIntoDropdown(data.banners);
                }
            } catch (error) {
                console.error('Error fetching banners:', error);
            }
        }

        // Initialize when DOM is loaded
        document.addEventListener('DOMContentLoaded', function() {
            if (!initializeDomElements()) {
                console.error('Failed to initialize DOM elements');
                return;
            }

            // Banner selector change event
            domElements.bannerSelector.addEventListener('change', function(e) {
                if (this.value) {
                    handleBannerSelection(this.value);
                } else {
                    resetForm();
                }
            });

            // Live preview updates
            domElements.bannerTitle.addEventListener('input', updatePreview);
            domElements.bannerDescription.addEventListener('input', updatePreview);

            // Form submission handler
            domElements.bannerForm.addEventListener('submit', function(event) {
                event.preventDefault();
                showLoading();
                
                const formData = new FormData(this);
                if (currentBannerId) {
                    formData.append('bannerId', currentBannerId);
                }
                
                const url = currentBannerId ? 'UpdateBannerServlet' : 'AddBannerServlet';
                
                fetch(url, {
                    method: 'POST',
                    body: formData
                })
                .then(response => response.json())
                .then(data => {
                    hideLoading();
                    if (data.success) {
                        alert(data.message);
                        fetchBanners();
                        if (!currentBannerId) {
                            resetForm();
                        } else if (data.posterPath) {
                            domElements.posterPreview.src = data.posterPath;
                        }
                    } else {
                        alert(data.message || 'Error processing banner');
                    }
                })
                .catch(error => {
                    hideLoading();
                    console.error('Error:', error);
                    alert('Error processing banner. Please try again.');
                });
            });

         // Remove button click handler
            domElements.removeButton.addEventListener('click', function(e) {
                e.preventDefault();
                if (!currentBannerId) {
                    alert('Please select a banner to delete');
                    return;
                }
                deleteBanner(currentBannerId);
            });

            // Initial fetch of banners
            fetchBanners();
        });
    </script>
</body>
</html>
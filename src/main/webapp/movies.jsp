<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.escape.util.DatabaseConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Movies - Escape</title>
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

        .movie-selector {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
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

        .input-group {
            display: flex;
            gap: 10px;
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

        .btn-outline-secondary, .btn-outline-primary {
    padding: 8px 12px;
    border: 1px solid #6c757d;
    border-radius: 4px;
    cursor: pointer;
    transition: all 0.3s ease;
    background: transparent;
    font-weight: 500;
    min-width: 80px;
    color: #6c757d;
}

.btn-outline-secondary:hover {
    background-color: #6c757d;
    color: white;
    border-color: #6c757d;
}

.btn-outline-primary {
    border-color: var(--primary-color);
    color: var(--primary-color);
    font-weight: 500;
}

.btn-outline-primary:hover {
    background-color: #6c757d;
    color: white;
    border-color: #6c757d;
}

        .movie-preview {
            margin: 20px 0;
            max-width: 200px;
        }

        .movie-card {
            position: relative;
            border-radius: 8px;
            overflow: hidden;
            transition: transform 0.3s ease;
            width: 200px;
            aspect-ratio: 2/3;
        }

        .movie-card:hover {
            transform: scale(1.05);
        }

        .movie-poster {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .movie-info {
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            background: linear-gradient(to top, rgba(0,0,0,0.9), transparent);
            padding: 1rem;
            transform: translateY(100%);
            transition: transform 0.3s ease;
        }

        .movie-card:hover .movie-info {
            transform: translateY(0);
        }

        .movie-title {
            color: white;
            font-size: 1rem;
            font-weight: bold;
            margin-bottom: 0.5rem;
        }

        .movie-meta {
            color: #999;
            font-size: 0.8rem;
            margin-bottom: 0.5rem;
        }

        .button-group {
            display: flex;
            gap: 10px;
            margin-top: 20px;
        }

        .btn-submit, .btn-delete {
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.3s ease;
            border: none;
            color: white;
        }

        .btn-submit {
            background-color: var(--primary-color);
        }

        .btn-delete {
            background-color: #dc3545;
        }

        .btn-submit:hover, .btn-delete:hover {
            opacity: 0.9;
        }

        .loading {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
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

        .alert {
            display: none;
            position: fixed;
            top: 20px;
            right: 20px;
            padding: 15px;
            border-radius: 4px;
            z-index: 9999;
            animation: slideIn 0.5s ease-out;
        }

        .alert-success {
            background: #28a745;
            color: white;
        }

        .alert-error {
            background: #dc3545;
            color: white;
        }

        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }

        @keyframes slideIn {
            from { transform: translateX(100%); }
            to { transform: translateX(0); }
        }
    </style>
</head>
<body>
    <!-- Loading Spinner -->
    <div class="loading">
        <div class="loading-spinner"></div>
    </div>
 
    <!-- Alert Messages -->
    <div id="alertSuccess" class="alert alert-success"></div>
    <div id="alertError" class="alert alert-error"></div>
    
    <!-- Include the admin header -->
    <jsp:include page="admin-header.jsp">
        <jsp:param name="pageTitle" value="Movies" />
        <jsp:param name="currentPage" value="movies" />
    </jsp:include>

    <!-- Sidebar -->
    <div class="admin-sidebar">
        <div class="admin-logo">
            <a href="#">Escape</a>
        </div>
        <nav class="admin-nav">
            <a href="admin.jsp" class="nav-item">
                <i class="fas fa-home"></i>
                Dashboard
            </a>
            <a href="movies.jsp" class="nav-item active">
                <i class="fas fa-film"></i>
                Movies
            </a>
            <a href="banner.jsp" class="nav-item">
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

    <!-- Main Content -->
    <div class="admin-content">
        <div class="content-header">
            <h1>Edit Movies</h1>
        </div>

       <!-- Movie Selector -->
<div class="movie-selector">
    <div class="form-group">
        <label for="existingMovie">Select Existing Movie</label>
        <select class="form-control" id="existingMovie">
            <option value="">Select a movie to edit</option>
            <%
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                try {
                    conn = DatabaseConnection.getConnection();
                    String sql = "SELECT m.movie_id, m.title, c.name as category_name " +
                               "FROM movies m " +
                               "JOIN categories c ON m.category_id = c.category_id " +
                               "ORDER BY c.name, m.title";
                    pstmt = conn.prepareStatement(sql);
                    rs = pstmt.executeQuery();
                    String currentCategory = "";
                    boolean isFirstCategory = true;
                    
                    while(rs.next()) {
                        String categoryName = rs.getString("category_name");
                        if (!categoryName.equals(currentCategory)) {
                            if (!isFirstCategory) {
                                out.println("</optgroup>");
                            } else {
                                isFirstCategory = false;
                            }
                            out.println("<optgroup label=\"" + categoryName + "\">");
                            currentCategory = categoryName;
                        }
                        out.println("<option value=\"" + rs.getInt("movie_id") + "\">" + 
                                  rs.getString("title") + "</option>");
                    }
                    if (!isFirstCategory) {
                        out.println("</optgroup>");
                    }
                } catch (SQLException e) {
                    out.println("Error loading movies: " + e.getMessage());
                } finally {
                    if (rs != null) rs.close();
                    if (pstmt != null) pstmt.close();
                    if (conn != null) conn.close();
                }
            %>
        </select>
    </div>
</div>

        <div class="movie-form">
            <form id="movieForm" enctype="multipart/form-data" method="post">
                <div class="row">
                    <div class="col-md-4">
                        <div class="form-group">
                            <label for="categoryTitle">Category Title</label>
                            <div class="input-group">
                                <%
                                    try {
                                        conn = DatabaseConnection.getConnection();
                                        String sql = "SELECT category_id, name FROM categories ORDER BY name";
                                        pstmt = conn.prepareStatement(sql);
                                        rs = pstmt.executeQuery();
                                %>
                                <select class="form-control" id="categoryTitle" name="categoryId" required>
                                    <option value="">Select Category</option>
                                    <% while(rs.next()) { %>
                                        <option value="<%= rs.getInt("category_id") %>">
                                            <%= rs.getString("name") %>
                                        </option>
                                    <% } %>
                                </select>
                                <input type="text" class="form-control" id="newCategoryTitle" 
                                       name="newCategoryTitle" placeholder="New category name" 
                                       style="display:none;">
                                <button type="button" class="btn btn-outline-secondary" id="toggleCategoryInput">
                                    Add New
                                </button>
                                <button type="button" class="btn btn-outline-primary" id="editCategoryBtn" style="display:none;">
                                    Edit
                                </button>
                                <%
                                    } catch (SQLException e) {
                                        out.println("Error loading categories: " + e.getMessage());
                                    } finally {
                                        if (rs != null) rs.close();
                                        if (pstmt != null) pstmt.close();
                                        if (conn != null) conn.close();
                                    }
                                %>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="form-group">
                            <label for="genre">Select Genre</label>
                            <div class="input-group">
                                <select class="form-control" id="genre" name="genre" required>
                                    <option value="">Select Genre</option>
                                    <option>Action</option>
                                    <option>Comedy</option>
                                    <option>Drama</option>
                                    <option>Sci-Fi</option>
                                    <option>Animation</option>
                                </select>
                                <input type="text" class="form-control" id="newGenre" 
                                       name="newGenre" placeholder="New genre name" 
                                       style="display:none;">
                                <button type="button" class="btn btn-outline-secondary" id="toggleGenreInput">
                                    Add New
                                </button>
                        </div>
                    </div>
                </div>
                    <div class="col-md-4">
                        <div class="form-group">
                            <label for="year">Year</label>
                            <select class="form-control" id="year" name="year" required>
                                <option value="">Select Year</option>
                                <% for(int i = 2024; i >= 1990; i--) { %>
                                    <option><%= i %></option>
                                <% } %>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-4">
                        <div class="form-group">
                            <label for="duration">Duration</label>
                            <div class="input-group">
                                <input type="number" class="form-control" id="durationHours" 
                                       name="durationHours" min="0" max="5" placeholder="Hours" required>
                                <input type="number" class="form-control" id="durationMinutes" 
                                       name="durationMinutes" min="0" max="59" placeholder="Minutes" required>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-8">
                        <div class="form-group">
                            <label for="title">Movie Title</label>
                            <input type="text" class="form-control" id="title" name="title" 
                                   placeholder="Enter Movie Title" required>
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <label for="posterImage">Poster Image</label>
                    <input type="file" class="form-control" id="posterImage" name="posterImage" 
                           accept="image/*" onchange="previewPoster(event)">
                    <small class="form-text text-muted">Leave empty to keep existing poster when updating</small>
                </div>

                <div class="movie-preview" style="display: none;">
                    <div class="preview-label">Preview</div>
                    <div class="movie-card">
                        <img id="posterPreview" src="" alt="Movie Poster" class="movie-poster">
                        <div class="movie-info">
                            <h3 class="movie-title" id="previewTitle"></h3>
                            <p class="movie-meta">
                                <span id="previewYear"></span> | 
                                <span id="previewGenre"></span> | 
                                <span id="previewDuration"></span>
                            </p>
                            <div class="movie-buttons">
                                <button type="button" class="btn btn-sm btn-light play-btn">
                                    <i class="fas fa-play"></i>
                                </button>
                                <button type="button" class="btn btn-sm btn-outline-light toggle-mylist-btn">
                                    <i class="fas fa-plus"></i>
                                </button>
                                <button type="button" class="btn btn-sm btn-outline-light like-btn">
                                    <i class="fas fa-heart"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="form-group mt-4">
                    <label for="videoPath">Video</label>
                    <input type="file" class="form-control" id="videoPath" name="videoPath" 
                           accept="video/mp4">
                    <small class="form-text text-muted">Leave empty to keep existing video when updating</small>
                </div>

                <div class="button-group">
                    <button type="submit" class="btn-submit" id="submitBtn">Add Movie</button>
                    <button type="button" class="btn-delete" id="deleteBtn" style="display: none;">Delete Movie</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Scripts -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    // Initialize main variables and check for movieId in URL
    const defaultMovieId = new URLSearchParams(window.location.search).get('movieId');
    let currentMovieId = defaultMovieId || null;

    // Initialize all elements that we'll need to reference
    const elements = {
        form: document.getElementById('movieForm'),
        existingMovie: document.getElementById('existingMovie'),
        categoryTitle: document.getElementById('categoryTitle'),
        genre: document.getElementById('genre'),
        year: document.getElementById('year'),
        title: document.getElementById('title'),
        posterImage: document.getElementById('posterImage'),
        durationHours: document.getElementById('durationHours'),
        durationMinutes: document.getElementById('durationMinutes'),
        newGenre: document.getElementById('newGenre'),
        newCategoryTitle: document.getElementById('newCategoryTitle'),
        toggleCategoryInput: document.getElementById('toggleCategoryInput'),
        toggleGenreInput: document.getElementById('toggleGenreInput'),
        editCategoryBtn: document.getElementById('editCategoryBtn'),
        submitBtn: document.getElementById('submitBtn'),
        deleteBtn: document.getElementById('deleteBtn'),
        posterPreview: document.getElementById('posterPreview'),
        previewTitle: document.getElementById('previewTitle'),
        previewYear: document.getElementById('previewYear'),
        previewGenre: document.getElementById('previewGenre'),
        previewDuration: document.getElementById('previewDuration'),
        moviePreview: document.querySelector('.movie-preview'),
        likeBtn: document.querySelector('.like-btn'),
        loading: document.querySelector('.loading'),
        alertSuccess: document.getElementById('alertSuccess'),
        alertError: document.getElementById('alertError')
    };

    // Show loading spinner
    function showLoading() {
        if (elements.loading) {
            elements.loading.style.display = 'flex';
        }
    }

    // Hide loading spinner
    function hideLoading() {
        if (elements.loading) {
            elements.loading.style.display = 'none';
        }
    }

    // Show alert message
    function showAlert(message, isSuccess = true) {
        const alertElement = isSuccess ? elements.alertSuccess : elements.alertError;
        if (alertElement) {
            alertElement.textContent = message;
            alertElement.style.display = 'block';
            
            setTimeout(() => {
                alertElement.style.display = 'none';
            }, 3000);
        }
    }

    // Preview poster image
    function previewPoster(event) {
        const file = event.target.files[0];
        if (file && elements.moviePreview && elements.posterPreview) {
            const reader = new FileReader();
            reader.onload = function(e) {
                elements.moviePreview.style.display = 'block';
                elements.posterPreview.src = e.target.result;
                updatePreview();
            }
            reader.readAsDataURL(file);
        }
    }

    // Get formatted duration
    function getDuration() {
        const hours = parseInt(elements.durationHours?.value) || 0;
        const minutes = parseInt(elements.durationMinutes?.value) || 0;
        
        if (hours === 0 && minutes === 0) {
            return '';
        }

        let duration = '';
        if (hours > 0) {
            duration += hours + 'h ';
        }
        if (minutes > 0 || hours > 0) {
            duration += minutes + 'm';
        }
        return duration.trim();
    }

    // Update preview card
    function updatePreview() {
        if (elements.previewTitle && elements.previewYear && elements.previewGenre && elements.previewDuration) {
            const title = elements.title?.value || 'Movie Title';
            const year = elements.year?.value || new Date().getFullYear();
            const genre = elements.genre?.value || 'Genre';
            const duration = getDuration();

            elements.previewTitle.textContent = title;
            elements.previewYear.textContent = year;
            elements.previewGenre.textContent = genre;
            elements.previewDuration.textContent = duration;
        }
    }

    // Initialize event listeners
    function initializeEventListeners() {
        // Poster image preview
        if (elements.posterImage) {
            elements.posterImage.onchange = previewPoster;
        }

        // Toggle category input
        if (elements.toggleCategoryInput && elements.categoryTitle && elements.newCategoryTitle) {
            elements.toggleCategoryInput.addEventListener('click', function() {
                const categorySelect = elements.categoryTitle;
                const newCategoryInput = elements.newCategoryTitle;
                
                if (newCategoryInput.style.display === 'none') {
                    categorySelect.style.display = 'none';
                    newCategoryInput.style.display = 'block';
                    this.textContent = 'Select Existing';
                    categorySelect.removeAttribute('required');
                    newCategoryInput.setAttribute('required', 'required');
                } else {
                    categorySelect.style.display = 'block';
                    newCategoryInput.style.display = 'none';
                    this.textContent = 'Add New';
                    categorySelect.setAttribute('required', 'required');
                    newCategoryInput.removeAttribute('required');
                }
            });
        }

        
     // Toggle genre input
        if (elements.toggleGenreInput && elements.genre && elements.newGenre) {
            elements.toggleGenreInput.addEventListener('click', function() {
                if (elements.newGenre.style.display === 'none') {
                    elements.genre.style.display = 'none';
                    elements.newGenre.style.display = 'block';
                    this.textContent = 'Select Existing';
                    elements.genre.removeAttribute('required');
                    elements.newGenre.setAttribute('required', 'required');
                    
                    // Add keypress event for new genre
                    elements.newGenre.addEventListener('keypress', function(e) {
                        if (e.key === 'Enter') {
                            const newGenre = this.value.trim();
                            if (newGenre) {
                                // Add to dropdown
                                const option = new Option(newGenre, newGenre);
                                elements.genre.add(option);
                                
                                // Dispatch custom event to update index.jsp
                                const event = new CustomEvent('genreAdded', { 
                                    detail: { newGenre } 
                                });
                                window.dispatchEvent(event);
                                
                                // Reset input
                                this.value = '';
                                elements.genre.style.display = 'block';
                                elements.newGenre.style.display = 'none';
                                elements.toggleGenreInput.textContent = 'Add New';
                            }
                        }
                    });
                } else {
                    elements.genre.style.display = 'block';
                    elements.newGenre.style.display = 'none';
                    this.textContent = 'Add New';
                    elements.genre.setAttribute('required', 'required');
                    elements.newGenre.removeAttribute('required');
                }
            });
        }

        // Edit category button
        if (elements.editCategoryBtn && elements.categoryTitle) {
            elements.editCategoryBtn.addEventListener('click', function() {
                const selectedCategory = elements.categoryTitle.options[elements.categoryTitle.selectedIndex];
                const newName = prompt('Enter new name for category: ' + selectedCategory.text);
                
                if (newName) {
                    showLoading();
                    fetch('CategoryServlet', {
                        method: 'PUT',
                        headers: {
                            'Content-Type': 'application/json',
                        },
                        body: JSON.stringify({
                            categoryId: elements.categoryTitle.value,
                            newName: newName
                        })
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            showAlert('Category updated successfully!', true);
                            selectedCategory.text = newName;
                            setTimeout(() => window.location.reload(), 1500);
                        } else {
                            showAlert(data.message || 'Failed to update category', false);
                        }
                    })
                    .catch(error => {
                        console.error('Error:', error);
                        showAlert('Error updating category', false);
                    })
                    .finally(() => hideLoading());
                }
            });
        }

        // Existing movie selection
        if (elements.existingMovie) {
            elements.existingMovie.addEventListener('change', async function(e) {
                const movieId = e.target.value;
                
                if (!movieId) {
                    // Reset form
                    elements.form?.reset();
                    currentMovieId = null;
                    if (elements.submitBtn) elements.submitBtn.textContent = 'Add Movie';
                    if (elements.deleteBtn) elements.deleteBtn.style.display = 'none';
                    if (elements.moviePreview) elements.moviePreview.style.display = 'none';
                    if (elements.editCategoryBtn) elements.editCategoryBtn.style.display = 'none';
                    if (elements.toggleCategoryInput) elements.toggleCategoryInput.style.display = 'inline-block';
                    return;
                }
                
                showLoading();
                
                try {
                    const response = await fetch(`MovieServlet?movieId=${movieId}`);
                    const movies = await response.json();
                    const movie = movies.find(m => m.movieId.toString() === movieId);
                    
                    if (movie) {
                        // Fill form with movie data
                        if (elements.categoryTitle) elements.categoryTitle.value = movie.categoryId;
                        if (elements.genre) elements.genre.value = movie.genre;
                        if (elements.year) elements.year.value = movie.year;
                        if (elements.title) elements.title.value = movie.title;
                        
                        // Parse duration
                        const durationMatch = movie.duration.match(/(\d+)h\s*(\d+)m/);
                        if (durationMatch) {
                            if (elements.durationHours) elements.durationHours.value = durationMatch[1];
                            if (elements.durationMinutes) elements.durationMinutes.value = durationMatch[2];
                        }
                        
                        // Show preview with existing poster
                        if (elements.moviePreview) elements.moviePreview.style.display = 'block';
                        if (elements.posterPreview) elements.posterPreview.src = movie.posterPath;
                        updatePreview();
                        
                        // Update buttons
                        currentMovieId = movieId;
                        if (elements.submitBtn) {
                            elements.submitBtn.textContent = 'Update Movie';
                            elements.submitBtn.value = 'update';
                        }
                        if (elements.deleteBtn) elements.deleteBtn.style.display = 'inline-block';
                        
                        // Show edit button for category
                        if (elements.editCategoryBtn) elements.editCategoryBtn.style.display = 'inline-block';
                        if (elements.toggleCategoryInput) elements.toggleCategoryInput.style.display = 'none';
                    }
                } catch (error) {
                    console.error('Error:', error);
                    showAlert('Error loading movie details', false);
                } finally {
                    hideLoading();
                }
            });
        }

        // Preview fields event listeners
        ['title', 'genre', 'year', 'durationHours', 'durationMinutes'].forEach(fieldId => {
            const element = document.getElementById(fieldId);
            if(element) {
                ['input', 'change'].forEach(event => {
                    element.addEventListener(event, updatePreview);
                });
            }
        });

        // Form submission
        if (elements.form) {
            elements.form.addEventListener('submit', async function(event) {
                event.preventDefault();
                showLoading();
                
                const formData = new FormData(this);
                formData.append('duration', getDuration());
                
                if (currentMovieId) {
                    formData.append('movieId', currentMovieId);
                }
                
                try {
                    const response = await fetch('MovieServlet', {
                        method: currentMovieId ? 'PUT' : 'POST',
                        body: formData
                    });
                    
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    
                    const data = await response.json();
                    
                    if (data.success) {
                        showAlert(currentMovieId ? 'Movie updated successfully!' : 'Movie added successfully!', true);
                        console.log('Files saved at:', data.posterPath, data.videoPath);
                        
                        setTimeout(() => {
                            window.location.reload();
                        }, 1500);
                    } else {
                        showAlert(data.message || 'Operation failed', false);
                    }
                } catch (error) {
                    console.error('Error:', error);
                    showAlert('Error saving movie. Please try again.', false);
                } finally {
                    hideLoading();
                }
            });
        }

     // Movie deletion
        if (elements.deleteBtn) {
            elements.deleteBtn.addEventListener('click', async function() {
                if (!currentMovieId) {
                    showAlert('Please select a movie first', false);
                    return;
                }
                
                if (!confirm('Are you sure you want to delete this movie?')) {
                    return;
                }
                
                showLoading();
                
                try {
                    const response = await fetch('MovieServlet?movieId=' + currentMovieId, {
                        method: 'DELETE',
                        headers: {
                            'Content-Type': 'application/json'
                        }
                    });
                    
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    
                    const data = await response.json();
                    
                    if (data.success) {
                        showAlert('Movie deleted successfully!', true);
                        setTimeout(() => {
                            window.location.reload();
                        }, 1500);
                    } else {
                        showAlert(data.message || 'Failed to delete movie', false);
                    }
                } catch (error) {
                    console.error('Error:', error);
                    showAlert('Error deleting movie. Please try again.', false);
                } finally {
                    hideLoading();
                }
            });
        }

        // Like button
        if (elements.likeBtn) {
            elements.likeBtn.addEventListener('click', function() {
                this.classList.toggle('liked');
            });
        }
    }

    // Initialize everything
    initializeEventListeners();

    // Load initial movie if ID is present in URL
    if (defaultMovieId && elements.existingMovie) {
        elements.existingMovie.value = defaultMovieId;
        elements.existingMovie.dispatchEvent(new Event('change'));
    }
});
</script>
</body>
</html>
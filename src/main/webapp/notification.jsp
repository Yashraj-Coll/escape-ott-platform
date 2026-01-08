<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.escape.util.DatabaseConnection" %>
<%@ page import="com.escape.model.Category" %>
<%
    // Fetch categories from database
    List<Category> categories = new ArrayList<>();
    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM categories ORDER BY name");
         ResultSet rs = pstmt.executeQuery()) {
        while (rs.next()) {
            categories.add(new Category(
                rs.getInt("category_id"),
                rs.getString("name")
            ));
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Send Notification - Escape</title>
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

        .header {
            background: white;
            padding: 20px;
            margin-bottom: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .header h1 {
            margin: 0;
            font-size: 24px;
            font-weight: 500;
            color: var(--text-dark);
        }

        .notification-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }

        .form-control {
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 8px 12px;
        }

        .form-control:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 0.2rem rgba(229, 9, 20, 0.25);
        }

        .form-select {
            border: 1px solid #ddd;
            border-radius: 4px;
        }

        .form-select:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 0.2rem rgba(229, 9, 20, 0.25);
        }

        .btn-primary {
            background-color: var(--primary-color);
            border: none;
            padding: 10px 20px;
            color: white;
            border-radius: 4px;
            transition: all 0.3s ease;
        }

        .btn-primary:hover {
            background-color: #c50812;
        }

        .form-label {
            color: var(--text-dark);
            font-weight: normal;
            margin-bottom: 8px;
        }

        .form-group {
            margin-bottom: 1rem;
        }

        textarea.form-control {
            min-height: 120px;
        }

        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }

        .alert-success {
            background-color: #d4edda;
            border-color: #c3e6cb;
            color: #155724;
        }

        .alert-danger {
            background-color: #f8d7da;
            border-color: #f5c6cb;
            color: #721c24;
        }

        .error-text {
            color: #dc3545;
            font-size: 0.875em;
            margin-top: 5px;
            display: none;
        }

        .loading-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.7);
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

        .toast {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 10000;
            display: none;
        }
    </style>
</head>
<body>
    <!-- Loading Overlay -->
    <div class="loading-overlay">
        <div class="loading-spinner"></div>
    </div>

    <!-- Include Admin Header -->
    <jsp:include page="admin-header.jsp">
        <jsp:param name="pageTitle" value="Notification" />
        <jsp:param name="currentPage" value="notification" />
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
            <a href="movies.jsp" class="nav-item">
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
            <a href="notification.jsp" class="nav-item active">
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
        <!-- Header -->
        <div class="header">
            <h1>Send Notification</h1>
            
            <% if (request.getParameter("success") != null) { %>
                <div class="alert alert-success" role="alert">
                    Notification sent successfully to all users!
                </div>
            <% } %>
            
            <% if (request.getParameter("error") != null) { %>
                <div class="alert alert-danger" role="alert">
                    Error: <%= request.getParameter("error") %>
                </div>
            <% } %>
        </div>

        <!-- Notification Form -->
        <div class="notification-card">
            <form action="send-notification" method="POST" onsubmit="return validateAndSubmit(event)">
                <div class="form-group">
                    <label for="notificationType" class="form-label">Category (Required)</label>
                    <select class="form-select" id="notificationType" name="notificationType" onchange="loadMovies(this.value)">
                        <option value="">Select Category</option>
                        <% for(Category category : categories) { %>
                            <option value="<%= category.getId() %>"><%= category.getName() %></option>
                        <% } %>
                    </select>
                    <div class="error-text" id="categoryError">Please select a category</div>
                </div>

                <div class="form-group">
                    <label for="movie" class="form-label">Movie (Required)</label>
                    <select class="form-select" id="movie" name="movie">
                        <option value="">Select Movie</option>
                    </select>
                    <div class="error-text" id="movieError">Please select a movie</div>
                </div>

                <div class="form-group">
                    <label for="title" class="form-label">Title (Optional)</label>
                    <input type="text" class="form-control" id="title" name="title" 
                           placeholder="Enter notification title">
                </div>

                <div class="form-group">
                    <label for="message" class="form-label">Message (Optional)</label>
                    <textarea class="form-control" id="message" name="message" 
                              placeholder="Enter notification message"></textarea>
                </div>

                <button type="submit" class="btn btn-primary w-100">
                    <i class="fas fa-paper-plane me-2"></i>Send Notification
                </button>
            </form>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function showLoading() {
            document.querySelector('.loading-overlay').style.display = 'flex';
        }

        function hideLoading() {
            document.querySelector('.loading-overlay').style.display = 'none';
        }

        function showAlert(message, isSuccess = true) {
            const alertDiv = document.createElement('div');
            alertDiv.className = `alert ${isSuccess ? 'alert-success' : 'alert-danger'}`;
            alertDiv.style.position = 'fixed';
            alertDiv.style.top = '20px';
            alertDiv.style.right = '20px';
            alertDiv.style.zIndex = '10000';
            alertDiv.textContent = message;
            
            document.body.appendChild(alertDiv);
            
            setTimeout(() => {
                alertDiv.remove();
            }, 3000);
        }

        function loadMovies(categoryId) {
            const movieSelect = document.getElementById('movie');
            movieSelect.innerHTML = '<option value="">Select Movie</option>';
            
            if (!categoryId) {
                return;
            }

            showLoading();
            movieSelect.innerHTML = '<option value="">Loading movies...</option>';
            
            fetch('getMoviesByCategory?categoryId=' + categoryId)
                .then(response => response.json())
                .then(movies => {
                    movieSelect.innerHTML = '<option value="">Select Movie</option>';
                    
                    movies.forEach(movie => {
                        const option = document.createElement('option');
                        option.value = movie.movieId;
                        option.textContent = movie.title;
                        movieSelect.appendChild(option);
                    });
                    
                    if (movies.length === 0) {
                        movieSelect.innerHTML = '<option value="">No movies in this category</option>';
                    }
                })
                .catch(error => {
                    console.error('Error loading movies:', error);
                    movieSelect.innerHTML = '<option value="">Error loading movies</option>';
                    showAlert('Error loading movies. Please try again.', false);
                })
                .finally(() => {
                    hideLoading();
                });
        }

        function validateAndSubmit(event) {
            event.preventDefault();
            
            const category = document.getElementById('notificationType');
            const movie = document.getElementById('movie');
            let isValid = true;

            // Reset previous error states
            document.querySelectorAll('.error-text').forEach(err => err.style.display = 'none');
            
            if (!category.value) {
                document.getElementById('categoryError').style.display = 'block';
                isValid = false;
            }

            if (!movie.value) {
                document.getElementById('movieError').style.display = 'block';
                isValid = false;
            }

            if (isValid) {
                showLoading();
                const form = event.target;
                
                fetch(form.action, {
                    method: 'POST',
                    body: new FormData(form)
                })
                .then(response => {
                    if (response.redirected) {
                        window.location.href = response.url;
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    showAlert('Error sending notification. Please try again.', false);
                    hideLoading();
                });
            }

            return false;
        }

        // Initialize tooltips if using Bootstrap
        var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
        var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl)
        });

     // Handle initial page load
        document.addEventListener('DOMContentLoaded', function() {
            // Check for URL parameters
            const urlParams = new URLSearchParams(window.location.search);
            
            // Handle success message
            if (urlParams.has('success')) {
                showAlert('Notification sent successfully!', true);
            }
            
            // Handle error message
            if (urlParams.has('error')) {
                showAlert(urlParams.get('error'), false);
            }

            // Initialize form fields
            const categorySelect = document.getElementById('notificationType');
            const movieSelect = document.getElementById('movie');
            
            // If category is pre-selected, load its movies
            if (categorySelect.value) {
                loadMovies(categorySelect.value);
            }
            
            // Add change listeners for form validation
            const title = document.getElementById('title');
            const message = document.getElementById('message');
            
            [title, message, categorySelect, movieSelect].forEach(element => {
                if (element) {
                    element.addEventListener('change', function() {
                        // Hide error message when field is changed
                        const errorElement = document.getElementById(element.id + 'Error');
                        if (errorElement) {
                            errorElement.style.display = 'none';
                        }
                    });
                }
            });
        });
    </script>
</body>
</html>
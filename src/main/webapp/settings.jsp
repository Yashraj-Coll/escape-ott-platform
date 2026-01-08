<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Settings - Escape</title>
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

        .settings-card {
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

        .upload-area {
            border: 2px dashed #ddd;
            border-radius: 8px;
            padding: 30px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .upload-area:hover {
            border-color: var(--primary-color);
            background-color: rgba(229, 9, 20, 0.05);
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

        .nav-tabs {
            border-bottom: 1px solid #ddd;
            margin-bottom: 20px;
        }

        .nav-tabs .nav-link {
            color: var(--text-dark);
            border: none;
            padding: 10px 20px;
            margin-right: 10px;
        }

        .nav-tabs .nav-link.active {
            color: var(--primary-color);
            border-bottom: 2px solid var(--primary-color);
        }

        .editor-toolbar {
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 10px;
            margin-bottom: 10px;
        }

        .editor-toolbar button {
            background: none;
            border: none;
            padding: 5px 10px;
            margin-right: 5px;
            cursor: pointer;
        }

        .editor-toolbar button:hover {
            color: var(--primary-color);
        }
    </style>
</head>
<body>

<!-- Include the admin header -->
    <jsp:include page="admin-header.jsp">
        <jsp:param name="pageTitle" value="Settings" />
        <jsp:param name="currentPage" value="settings" />
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
            <a href="notification.jsp" class="nav-item">
                <i class="fas fa-bell"></i>
                Notification
            </a>
            <a href="settings.jsp" class="nav-item active">
                <i class="fas fa-cog"></i>
                Settings
            </a>
        </nav>
    </div>

    <!-- Main Content -->
    <div class="admin-content">
        <!-- Header -->
        <div class="header">
            <h1>Settings</h1>
        </div>

        <!-- Settings Form -->
        <div class="settings-card">
            <ul class="nav nav-tabs">
                <li class="nav-item">
                    <a class="nav-link active" href="#app">Ott Settings</a>
                </li>
            </ul>

            <form action="save-settings" method="POST" enctype="multipart/form-data">
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group mb-3">
                            <label for="appName" class="form-label">Ott Name</label>
                            <input type="text" class="form-control" id="appName" name="appName" placeholder="Escape">
                        </div>

                        <div class="form-group mb-3">
                            <label for="appVersion" class="form-label">Ott Version</label>
                            <input type="text" class="form-control" id="appVersion" name="appVersion" placeholder="1.0">
                        </div>

                        <div class="form-group mb-3">
                            <label for="author" class="form-label">Author</label>
                            <input type="text" class="form-control" id="author" name="author">
                        </div>

                        <div class="form-group mb-3">
                            <label for="contact" class="form-label">Contact</label>
                            <input type="text" class="form-control" id="contact" name="contact">
                        </div>

                        <div class="form-group mb-3">
                            <label for="email" class="form-label">Email</label>
                            <input type="email" class="form-control" id="email" name="email">
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="form-group mb-3">
                            <label for="appLogo" class="form-label">Ott Logo</label>
                            <div class="upload-area" id="logoUploadArea">
                                <i class="fas fa-image fa-3x"></i>
                                <p>Browse or Drag logo here..</p>
                                <input type="file" id="logoUpload" name="logo" accept="image/*" style="display: none;">
                            </div>
                        </div>

                        <div class="form-group mb-3">
                            <label for="website" class="form-label">Website</label>
                            <input type="url" class="form-control" id="website" name="website" placeholder="http://localhost:8080/Escape/index.jsp">
                        </div>

                        <div class="form-group mb-3">
                            <label for="developedBy" class="form-label">Developed By</label>
                            <input type="text" class="form-control" id="developedBy" name="developedBy" placeholder="Group 3">
                        </div>
                    </div>
                </div>

                <div class="form-group mb-3">
                    <label for="description" class="form-label">Ott Description</label>
                    <div class="editor-toolbar">
                        <button type="button"><i class="fas fa-undo"></i></button>
                        <button type="button"><i class="fas fa-redo"></i></button>
                        <button type="button"><i class="fas fa-bold"></i></button>
                        <button type="button"><i class="fas fa-italic"></i></button>
                        <button type="button"><i class="fas fa-underline"></i></button>
                        <button type="button"><i class="fas fa-list-ul"></i></button>
                        <button type="button"><i class="fas fa-list-ol"></i></button>
                        <button type="button"><i class="fas fa-align-left"></i></button>
                        <button type="button"><i class="fas fa-align-center"></i></button>
                        <button type="button"><i class="fas fa-align-right"></i></button>
                    </div>
                    <textarea class="form-control" id="description" name="description" rows="6"></textarea>
                </div>

                <button type="submit" class="btn btn-primary">Save Settings</button>
            </form>
        </div>
    </div>

    <script>
        // Logo upload handling
        const logoUploadArea = document.getElementById('logoUploadArea');
        const logoUpload = document.getElementById('logoUpload');

        logoUploadArea.addEventListener('click', () => {
            logoUpload.click();
        });

        logoUploadArea.addEventListener('dragover', (e) => {
            e.preventDefault();
            logoUploadArea.classList.add('dragging');
        });

        logoUploadArea.addEventListener('dragleave', () => {
            logoUploadArea.classList.remove('dragging');
        });

        logoUploadArea.addEventListener('drop', (e) => {
            e.preventDefault();
            logoUploadArea.classList.remove('dragging');
            const files = e.dataTransfer.files;
            if (files.length) {
                logoUpload.files = files;
                handleLogoPreview(files[0]);
            }
        });

        logoUpload.addEventListener('change', (e) => {
            if (e.target.files.length) {
                handleLogoPreview(e.target.files[0]);
            }
        });

        function handleLogoPreview(file) {
            const reader = new FileReader();
            reader.onload = function(e) {
                const preview = document.createElement('img');
                preview.src = e.target.result;
                preview.style.maxWidth = '100%';
                preview.style.maxHeight = '200px';
                preview.style.marginTop = '15px';
                preview.style.borderRadius = '8px';
                
                // Remove existing preview if any
                const existingPreview = logoUploadArea.querySelector('img');
                if (existingPreview) {
                    existingPreview.remove();
                }
                
                logoUploadArea.appendChild(preview);
            }
            reader.readAsDataURL(file);
        }
    </script>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
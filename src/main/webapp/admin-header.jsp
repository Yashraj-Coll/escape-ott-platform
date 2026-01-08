<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
// Check if user is logged in and is an admin
String userRole = (String) session.getAttribute("userRole");
if (userRole == null || !"admin".equals(userRole)) {
    response.sendRedirect("index.jsp");
    return;
}
String userName = (String) session.getAttribute("userName");
String userInitial = userName != null ? userName.substring(0, 1).toUpperCase() : "A";
%>

<!-- Admin Navigation Header -->
<div class="admin-header">
    <!-- Sidebar -->
    <div class="admin-sidebar">
        <div class="admin-logo">
            <img src="images/logo.png" alt="Escape" class="main-logo">
            <button class="toggle-sidebar-btn" id="toggleSidebar">
                <i class="fas fa-bars"></i>
            </button>
        </div>
        <nav class="admin-nav">
            <a href="admin.jsp" class="nav-item ${param.currentPage eq 'dashboard' ? 'active' : ''}">
                <div class="nav-icon"><i class="fas fa-home"></i></div>
                <span class="nav-label">Dashboard</span>
            </a>
            <a href="movies.jsp" class="nav-item ${param.currentPage eq 'movies' ? 'active' : ''}">
                <div class="nav-icon"><i class="fas fa-film"></i></div>
                <span class="nav-label">Movies</span>
            </a>
            <a href="banner.jsp" class="nav-item ${param.currentPage eq 'banner' ? 'active' : ''}">
                <div class="nav-icon"><i class="fas fa-image"></i></div>
                <span class="nav-label">Banner</span>
            </a>
            <a href="users.jsp" class="nav-item ${param.currentPage eq 'users' ? 'active' : ''}">
                <div class="nav-icon"><i class="fas fa-users"></i></div>
                <span class="nav-label">Users</span>
            </a>
            <a href="notification.jsp" class="nav-item ${param.currentPage eq 'notification' ? 'active' : ''}">
                <div class="nav-icon"><i class="fas fa-bell"></i></div>
                <span class="nav-label">Notification</span>
            </a>
            <a href="settings.jsp" class="nav-item ${param.currentPage eq 'settings' ? 'active' : ''}">
                <div class="nav-icon"><i class="fas fa-cog"></i></div>
                <span class="nav-label">Settings</span>
            </a>
        </nav>
    </div>

    <!-- Top Header -->
    <div class="top-header">
        <div class="page-header d-flex justify-content-between align-items-center">
            <div class="header-title">   
            </div>
            
                <div class="user-profile-dropdown">
                    <div class="dropdown">
                        <div class="user-profile" data-bs-toggle="dropdown" aria-expanded="false">
                            <div class="user-avatar">
                                <%= userInitial %>
                                <span class="status-indicator online"></span>
                            </div>
                            <div class="user-info d-none d-md-block">
                                <span class="user-name"><%= userName %></span>
                                <span class="user-role">Administrator</span>
                            </div>
                        </div>
                        <ul class="dropdown-menu dropdown-menu-end">
                            <li class="dropdown-header">
                                <div class="d-flex align-items-center">
                                    <div class="user-avatar larger"><%= userInitial %></div>
                                    <div class="ms-3">
                                        <h6 class="mb-0"><%= userName %></h6>
                                        <small class="text-muted">Administrator</small>
                                    </div>
                                </div>
                            </li>
                            <li>
                                <a class="dropdown-item" href="index.jsp">
                                    <i class="fas fa-home me-2"></i>Go to Home
                                </a>
                            </li>
                            <li><hr class="dropdown-divider"></li>
                            <li>
                                <a class="dropdown-item text-danger" href="logout">
                                    <i class="fas fa-sign-out-alt me-2"></i>Sign Out
                                </a>
                            </li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>

<!-- Add this script at the bottom of admin-header.jsp -->
<script>
document.addEventListener('DOMContentLoaded', function() {
    // Toggle Sidebar
    const toggleBtn = document.getElementById('toggleSidebar');
    const sidebar = document.querySelector('.admin-sidebar');
    const content = document.querySelector('.admin-content');
    
    toggleBtn.addEventListener('click', function() {
        sidebar.classList.toggle('collapsed');
        content.classList.toggle('expanded');
});
});
</script>
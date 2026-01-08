<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.escape.util.DatabaseConnection" %>
<%@ page import="java.util.*" %>
<%
// Check if user is logged in and is an admin
String userRole = (String) session.getAttribute("userRole");
if (userRole == null || !"admin".equals(userRole)) {
    response.sendRedirect("index.jsp");
    return;
}

    // Get stats from database
    int totalCategories = 0;
    int totalMovies = 0;
    int totalSeries = 0;
    int totalTVShows = 0;
    int moviesViews = 0;
    int seriesViews = 0;
    int tvShowsViews = 0;
    Map<Integer, Map<String, Object>> mostViewedByCategory = new HashMap<>();

    try (Connection conn = DatabaseConnection.getConnection()) {
        // Get total categories
        String categorySql = "SELECT COUNT(*) as total FROM categories";
        try (PreparedStatement stmt = conn.prepareStatement(categorySql)) {
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                totalCategories = rs.getInt("total");
            }
        }

        // Get total movies where category_id = 1 (PopularMovies)
        String movieSql = "SELECT COUNT(*) as total FROM movies WHERE category_id = 1";
        try (PreparedStatement stmt = conn.prepareStatement(movieSql)) {
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                totalMovies = rs.getInt("total");
            }
        }

        // Get total series where category_id = 3 (PopularSeries)
        String seriesSql = "SELECT COUNT(*) as total FROM movies WHERE category_id = 3";
        try (PreparedStatement stmt = conn.prepareStatement(seriesSql)) {
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                totalSeries = rs.getInt("total");
            }
        }

        // Get total TV Shows where category_id = 4 (PopularTVShows)
        String tvShowsSql = "SELECT COUNT(*) as total FROM movies WHERE category_id = 4";
        try (PreparedStatement stmt = conn.prepareStatement(tvShowsSql)) {
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                totalTVShows = rs.getInt("total");
            }
        }

        // Get views by category
        String viewsSql = "SELECT m.category_id, c.name as category_name, SUM(m.views) as total_views " +
                         "FROM movies m " +
                         "JOIN categories c ON m.category_id = c.category_id " +
                         "GROUP BY m.category_id, c.name";
        try (PreparedStatement stmt = conn.prepareStatement(viewsSql)) {
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                int categoryId = rs.getInt("category_id");
                int views = rs.getInt("total_views");
                switch (categoryId) {
                    case 1: moviesViews = views; break;      // PopularMovies
                    case 3: seriesViews = views; break;      // PopularSeries
                    case 4: tvShowsViews = views; break;     // PopularTVShows
                }
            }
        }
        
        // Get most viewed content for each category
        String mostViewedSql = 
            "SELECT m.*, c.name as category_name " +
            "FROM movies m " +
            "JOIN categories c ON m.category_id = c.category_id " +
            "WHERE m.category_id = ? " +
            "ORDER BY m.views DESC LIMIT 1";

        // Get most viewed for Movies (category_id = 1)
        try (PreparedStatement stmt = conn.prepareStatement(mostViewedSql)) {
            stmt.setInt(1, 1); // PopularMovies
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                Map<String, Object> content = new HashMap<>();
                content.put("title", rs.getString("title"));
                content.put("views", rs.getInt("views"));
                content.put("posterPath", rs.getString("poster_path"));
                mostViewedByCategory.put(1, content);
            }
        }

        // Get most viewed for Series (category_id = 3)
        try (PreparedStatement stmt = conn.prepareStatement(mostViewedSql)) {
            stmt.setInt(1, 3); // PopularSeries
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                Map<String, Object> content = new HashMap<>();
                content.put("title", rs.getString("title"));
                content.put("views", rs.getInt("views"));
                content.put("posterPath", rs.getString("poster_path"));
                mostViewedByCategory.put(3, content);
            }
        }

        // Get most viewed for TV Shows (category_id = 4)
        try (PreparedStatement stmt = conn.prepareStatement(mostViewedSql)) {
            stmt.setInt(1, 4); // PopularTVShows
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                Map<String, Object> content = new HashMap<>();
                content.put("title", rs.getString("title"));
                content.put("views", rs.getInt("views"));
                content.put("posterPath", rs.getString("poster_path"));
                mostViewedByCategory.put(4, content);
            }
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
    <title>Admin Dashboard - Escape</title>
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

        .stats-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            height: 100%;
        }

        .stats-number {
            font-size: 24px;
            font-weight: bold;
            color: var(--primary-color);
            margin-bottom: 8px;
        }

        .stats-label {
            color: var(--text-dark);
            font-size: 14px;
        }

        .chart-container {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            height: 400px;
        }

        .content-card {
            position: relative;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .content-card img {
            width: 100%;
            height: 300px;
            object-fit: cover;
        }

        .content-overlay {
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            padding: 15px;
            background: linear-gradient(to top, rgba(0,0,0,0.8), transparent);
            color: white;
        }

        .content-overlay h4 {
            margin: 0;
            font-size: 18px;
            font-weight: 500;
        }

        .content-overlay .views {
            font-size: 14px;
            opacity: 0.9;
        }

        .no-data-container {
            text-align: center;
            padding: 30px 20px;
        }

        .no-data-icon {
            width: 60px;
            height: 60px;
            background: #f8f9fa;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto;
        }

        .no-data-icon i {
            font-size: 24px;
            color: #333;
        }

        .stats-card h3 {
            font-size: 18px;
            color: var(--text-dark);
            margin-bottom: 10px;
        }

        .stats-card p.text-muted {
            color: #6c757d;
            font-size: 14px;
        }
    </style>
</head>
<body>

<!-- Include the admin header -->
    <jsp:include page="admin-header.jsp">
        <jsp:param name="pageTitle" value="Dashboard" />
        <jsp:param name="currentPage" value="dashboard" />
    </jsp:include>
    
    <!-- Sidebar -->
    <div class="admin-sidebar">
        <div class="admin-logo">
    <a href="#">Escape</a>
</div>
        <nav class="admin-nav">
            <a href="#" class="nav-item active">
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
            <h1>Dashboard</h1>
        </div>

        <!-- Stats Cards -->
        <div class="row">
            <div class="col-md-3">
                <div class="stats-card">
                    <div class="stats-number"><%= totalCategories %></div>
                    <div class="stats-label">Categories</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stats-card">
                    <div class="stats-number"><%= totalMovies %></div>
                    <div class="stats-label">Movies</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stats-card">
                    <div class="stats-number"><%= totalSeries %></div>
                    <div class="stats-label">Series</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="stats-card">
                    <div class="stats-number"><%= totalTVShows %></div>
                    <div class="stats-label">TV Shows</div>
                </div>
            </div>
        </div>

        <!-- Charts -->
        <div class="row mt-4">
            <div class="col-md-6">
                <div class="chart-container">
                    <h3>Views</h3>
                    <canvas id="viewsChart"></canvas>
                </div>
            </div>
            <div class="col-md-6">
                <div class="chart-container">
                    <h3>User Analysis</h3>
                    <canvas id="userChart"></canvas>
                </div>
            </div>
        </div>

        <!-- Most Viewed Content Section -->
<div class="row mt-4">
    <div class="col-md-4">
        <div class="stats-card">
            <h3 class="mb-3">Most Viewed Series</h3>
            <p class="text-muted mb-4">Series with more views</p>
            <% if (mostViewedByCategory.containsKey(3)) { %>
                <div class="most-viewed-item">
                    <div class="content-card">
                        <img src="<%= mostViewedByCategory.get(3).get("posterPath") %>" 
                             alt="<%= mostViewedByCategory.get(3).get("title") %>" 
                             class="w-100 rounded">
                        <div class="content-overlay">
    <h4><%= mostViewedByCategory.get(3).get("title") %></h4>
    <span class="views">
        <% 
        int seriesViewCount = (Integer)mostViewedByCategory.get(3).get("views");
        if (seriesViewCount >= 1000) {
            out.print((seriesViewCount/1000) + "k views");
        } else {
            out.print(seriesViewCount + " views");
        }
        %>
    </span>
</div>
                    </div>
                </div>
            <% } else { %>
                <div class="no-data-container">
                    <div class="no-data-icon">
                        <i class="fas fa-minus"></i>
                    </div>
                    <p class="mt-3">No Data Available!</p>
                </div>
            <% } %>
        </div>
    </div>
    
    <div class="col-md-4">
        <div class="stats-card">
            <h3 class="mb-3">Most Viewed Movies</h3>
            <p class="text-muted mb-4">Movies with more views</p>
            <% if (mostViewedByCategory.containsKey(1)) { %>
                <div class="most-viewed-item">
                    <div class="content-card">
                        <img src="<%= mostViewedByCategory.get(1).get("posterPath") %>" 
                             alt="<%= mostViewedByCategory.get(1).get("title") %>" 
                             class="w-100 rounded">
                        <div class="content-overlay">
                            <h4><%= mostViewedByCategory.get(1).get("title") %></h4>
                            <span class="views">
                                <% 
                                int movieViews = (Integer)mostViewedByCategory.get(1).get("views");
                                if (movieViews >= 1000) {
                                    out.print((movieViews/1000) + "k views");
                                } else {
                                    out.print(movieViews + " views");
                                }
                                %>
                            </span>
                        </div>
                    </div>
                </div>
            <% } else { %>
                <div class="no-data-container">
                    <div class="no-data-icon">
                        <i class="fas fa-minus"></i>
                    </div>
                    <p class="mt-3">No Data Available!</p>
                </div>
            <% } %>
        </div>
    </div>
    
    <div class="col-md-4">
        <div class="stats-card">
            <h3 class="mb-3">Most Viewed TV Shows</h3>
            <p class="text-muted mb-4">TV Shows with more views</p>
            <% if (mostViewedByCategory.containsKey(4)) { %>
                <div class="most-viewed-item">
                    <div class="content-card">
                        <img src="<%= mostViewedByCategory.get(4).get("posterPath") %>" 
                             alt="<%= mostViewedByCategory.get(4).get("title") %>" 
                             class="w-100 rounded">
                        <div class="content-overlay">
                            <h4><%= mostViewedByCategory.get(4).get("title") %></h4>
                            <span class="views">
                                <% 
                                int tvShowViews = (Integer)mostViewedByCategory.get(4).get("views");
                                if (tvShowViews >= 1000) {
                                    out.print((tvShowViews/1000) + "k views");
                                } else {
                                    out.print(tvShowViews + " views");
                                }
                                %>
                            </span>
                        </div>
                    </div>
                </div>
            <% } else { %>
                <div class="no-data-container">
                    <div class="no-data-icon">
                        <i class="fas fa-minus"></i>
                    </div>
                    <p class="mt-3">No Data Available!</p>
                </div>
            <% } %>
        </div>
    </div>
</div>
</div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script>
        // Views Chart
        const viewsCtx = document.getElementById('viewsChart').getContext('2d');
        new Chart(viewsCtx, {
            type: 'doughnut',
            data: {
                labels: ['Movies', 'Series', 'TV Shows'],
                datasets: [{
                    data: [<%= moviesViews %>, <%= seriesViews %>, <%= tvShowsViews %>],
                    backgroundColor: [
                        '#e50914',
                        '#ff4d4d',
                        '#ff8080'
                    ]
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'bottom',
                        padding: {
                            bottom: 20,
                            top: 10
                        },
                        labels: {
                            padding: 20,
                            boxWidth: 15,
                            font: {
                                size: 14
                            }
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                let value = context.raw;
                                if (value >= 1000) {
                                    return context.label + ': ' + (value/1000).toFixed(1) + 'k views';
                                }
                                return context.label + ': ' + value + ' views';
                            }
                        }
                    }
                },
                layout: {
                    padding: {
                        bottom: 20,
                        top: 20,
                        left: 20,
                        right: 20
                    }
                }
            }
        });

        // User Analysis Chart
        const userCtx = document.getElementById('userChart').getContext('2d');
        new Chart(userCtx, {
            type: 'line',
            data: {
                labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
                datasets: [{
                    label: 'New Registrations',
                    data: [200, 400, 600, 800, 500, 700, 900, 1100, 800, 1200, 1000, 1400],
                    borderColor: '#e50914',
                    backgroundColor: 'rgba(229, 9, 20, 0.1)',
                    tension: 0.4
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'top'
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true
                    }
                }
            }
        });

        // Initialize tooltips
        const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
        const tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl);
        });
    </script>
</body>
</html>
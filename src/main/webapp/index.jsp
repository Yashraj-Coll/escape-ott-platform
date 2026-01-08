<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ page import="java.util.*" %>
<%@ page import="com.escape.service.MovieService" %>

<%
    // Get user session data
    String userName = (String) session.getAttribute("userName");
    String userInitial = userName != null ? userName.substring(0, 1).toUpperCase() : null;
    String userEmail = (String) session.getAttribute("userEmail");
    String userMobile = (String) session.getAttribute("userMobile");
    String userLastName = (String) session.getAttribute("userLastName");
    String userRole = (String) session.getAttribute("userRole");
    String subscriptionPlan = (String) session.getAttribute("subscriptionPlan");
    
    // Initialize MovieService and get data
    MovieService movieService = new MovieService();
    Integer userId = (Integer) session.getAttribute("userId");
    Map<String, Object> homeData = movieService.getHomePageData(userId != null ? userId : 0);
    
    // Set attributes for JSP
    pageContext.setAttribute("banners", homeData.get("banners"));
    pageContext.setAttribute("moviesByCategory", homeData.get("moviesByCategory"));
    pageContext.setAttribute("continueWatching", homeData.get("continueWatching"));
    pageContext.setAttribute("myList", homeData.get("myList"));
    pageContext.setAttribute("likedMovies", homeData.get("likedMovies"));
    pageContext.setAttribute("userAuthenticated", userName != null);
    pageContext.setAttribute("userSubscribed", subscriptionPlan != null && !subscriptionPlan.equals("Free"));
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ESCAPE - Premium Entertainment</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="style.css" rel="stylesheet">
    <script>
        // Make these variables available to script.js
        var isUserAuthenticated = <%= userName != null %>;
        var isUserSubscribed = <%= subscriptionPlan != null && !subscriptionPlan.equals("Free") %>;
        var userRole = '<%= userRole != null ? userRole : "free" %>';
        var subscriptionPlan = '<%= subscriptionPlan != null ? subscriptionPlan : "Free" %>';
    </script>
</head>
<body>
     <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark fixed-top">
        <div class="container-fluid">
            <a class="navbar-brand" href="#">Escape</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto mb-2 mb-lg-0">
    <li class="nav-item"><a class="nav-link active" href="#home">Home</a></li>
    <li class="nav-item"><a class="nav-link" href="#popularmovies">Movies</a></li>
    <li class="nav-item"><a class="nav-link" href="#popularseries">Series</a></li>
    <li class="nav-item"><a class="nav-link" href="#populartvshows">TV Shows</a></li>
</ul>
                <div class="d-flex align-items-center">
                    <form class="search-form d-flex me-3">
                        <input class="form-control search-trigger" type="search" placeholder="Search" aria-label="Search">
                        <i class="fas fa-search search-icon"></i>
                    </form>
                    <% if (userName != null) { %>
                        <div class="user-profile-dropdown">
                            <div class="dropdown">
                                <div class="user-profile" data-bs-toggle="dropdown" aria-expanded="false">
                                    <div class="user-avatar"><%= userInitial %></div>
                                    <span class="user-name">
                                        <%= userName %>
                                        <% if (subscriptionPlan != null && !subscriptionPlan.equals("Free")) { %>
                                            <span class="premium-badge" data-plan="<%= subscriptionPlan.toUpperCase() %>">
                                                <%= subscriptionPlan.toUpperCase() %>
                                            </span>
                                        <% } %>
                                    </span>
                                </div>
                                <ul class="dropdown-menu dropdown-menu-dark">
                                    <li><a class="dropdown-item" href="account.jsp">
                                        <i class="fas fa-user-cog me-2"></i>Manage Account
                                    </a></li>
                                    <% if (userRole != null && userRole.equals("admin")) { %>
                                    <li><a class="dropdown-item" href="admin.jsp">
                                        <i class="fas fa-shield-alt me-2"></i>Admin Dashboard
                                    </a></li>
                                    <% } %>
                                    <li><hr class="dropdown-divider"></li>
                                    <li><a class="dropdown-item" href="logout">
                                        <i class="fas fa-sign-out-alt me-2"></i>Sign Out
                                    </a></li>
                                </ul>
                            </div>
                        </div>
                    <% } else { %>
                        <a href="login.jsp" class="btn btn-danger">Sign In</a>
                    <% } %>
                </div>
            </div>
        </div>
    </nav>

    <!-- Hero Section with Carousel -->
    <section id="home" class="hero-section">
        <div id="bannerCarousel" class="carousel slide" data-bs-ride="carousel">
            <div class="carousel-inner">
                <c:forEach items="${banners}" var="banner" varStatus="status">
                    <div class="carousel-item ${status.first ? 'active' : ''}">
                        <img src="${banner.posterPath}" alt="${banner.title}" class="hero-bg">
                        <div class="hero-content">
                            <h1 class="hero-title">${banner.title}</h1>
                            <p class="hero-description">${banner.description}</p>
                            <div class="hero-buttons">
                                <button class="btn btn-light" data-video="${banner.videoPath}">
                                    <i class="fas fa-play me-2"></i>Play
                                </button>
                                <button class="btn btn-outline-light">
                                    <i class="fas fa-info-circle me-2"></i>More Info
                                </button>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </section>

    <!-- Dynamic Categories -->
    <c:forEach items="${moviesByCategory}" var="category">
        <section id="${fn:toLowerCase(fn:replace(category.key, ' ', ''))}" class="category-section" data-category="${category.key}">
            <div class="category-header">
                <h2 class="category-title">${category.key}</h2>
                <a href="#" class="see-all">See All</a>
            </div>
            
            <!-- Only show genre pills for PopularMovies (category_id = 1) -->
            <c:if test="${category.value[0].categoryId == 1}">
                <div class="genre-pills">
                    <span class="genre-pill active" data-genre="All">All</span>
                    <span class="genre-pill" data-genre="Action">Action</span>
                    <span class="genre-pill" data-genre="Comedy">Comedy</span>
                    <span class="genre-pill" data-genre="Drama">Drama</span>
                    <span class="genre-pill" data-genre="Sci-Fi">Sci-Fi</span>
                    <span class="genre-pill" data-genre="Animation">Animation</span>
                </div>
                <script>
        window.addEventListener('genreAdded', function(e) {
            if (e.detail && e.detail.newGenre) {
                const genrePills = document.querySelector('.genre-pills');
                if (genrePills) {
                    // Check if pill already exists
                    if (!genrePills.querySelector(`[data-genre="${e.detail.newGenre}"]`)) {
                        const pill = document.createElement('span');
                        pill.className = 'genre-pill';
                        pill.setAttribute('data-genre', e.detail.newGenre);
                        pill.textContent = e.detail.newGenre;
                        
                        // Add click handler
                        pill.addEventListener('click', function() {
                            const pills = this.closest('.genre-pills').querySelectorAll('.genre-pill');
                            pills.forEach(p => p.classList.remove('active'));
                            this.classList.add('active');
                            filterMoviesByGenre(e.detail.newGenre);
                        });
                        
                        genrePills.appendChild(pill);
                    }
                }
            }
        });
    </script>
            </c:if>

            <div class="movie-row-container">
                <button class="nav-button prev"><i class="fas fa-chevron-left"></i></button>
                <div class="movie-row">
                    <c:forEach items="${category.value}" var="movie">
                        <div class="movie-card" data-movie-id="${movie.movieId}" data-genre="${movie.genre}" data-category-id="${movie.categoryId}">
                            <img src="${movie.posterPath}" alt="${movie.title}" class="movie-poster">
                            <div class="movie-info">
                                <h3 class="movie-title">${movie.title}</h3>
                                <p class="movie-meta">
                                    ${movie.year} | ${movie.genre} | ${movie.duration}
                                </p>
                                <div class="movie-buttons">
                                    <button class="btn btn-sm btn-light play-btn" data-video="${movie.videoPath}">
                                        <i class="fas fa-play"></i>
                                    </button>
                                    <button class="btn btn-sm btn-outline-light toggle-mylist-btn">
                                        <i class="fas ${fn:contains(myList, movie.movieId) ? 'fa-minus' : 'fa-plus'}"></i>
                                    </button>
                                    <button class="btn btn-sm btn-outline-light like-btn ${fn:contains(likedMovies, movie.movieId) ? 'liked' : ''}">
                                        <i class="fas fa-heart"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
                <button class="nav-button next"><i class="fas fa-chevron-right"></i></button>
            </div>
        </section>
    </c:forEach>

    <!-- Video Player -->
    <div id="videoPlayer" class="video-player">
       <video id="mainVideo" src=""></video>
       <div class="video-controls">
           <button id="playPauseBtn" class="control-btn"><i class="fas fa-play"></i></button>
           <button id="rewindBtn" class="control-btn"><i class="fas fa-undo-alt"></i>10</button>
           <button id="forwardBtn" class="control-btn"><i class="fas fa-redo-alt"></i>10</button>
           <div id="volumeControl">
               <button id="muteBtn" class="control-btn"><i class="fas fa-volume-up"></i></button>
               <input type="range" id="volumeSlider" min="0" max="1" step="0.1" value="1">
           </div>
           <div id="progressBar">
               <div id="progress"></div>
           </div>
           <span id="currentTime">00:00</span> / <span id="duration">00:00</span>
           <button id="captionsBtn" class="control-btn"><i class="fas fa-closed-captioning"></i></button>
           <button id="settingsBtn" class="control-btn"><i class="fas fa-cog"></i></button>
           <button id="fullscreenBtn" class="control-btn"><i class="fas fa-expand"></i></button>
       </div>
       <button id="backBtn" class="back-btn"><i class="fas fa-arrow-left"></i></button>
    </div>

    <!-- Search Overlay -->
    <div class="search-overlay" style="display: none;">
        <div class="search-header">
            <div class="container-fluid">
                <div class="d-flex align-items-center">
                    <button class="search-close-btn">
                        <i class="fas fa-arrow-right"></i>
                    </button>
                    <div class="search-input-wrapper">
                        <i class="fas fa-search search-icon"></i>
                        <input type="text" class="search-input" placeholder="Movies, shows and more">
                        <button class="search-clear-btn" style="display: none;">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                </div>
            </div>
        </div>
        <div class="search-content">
            <div class="container-fluid">
                <div class="recent-searches">
                    <!-- Recent searches will be dynamically added here -->
                </div>
                <div class="search-suggestions">
                    <!-- Search suggestions will be dynamically added here -->
                </div>
                <div class="search-results" style="display: none;">
                    <h2 class="category-title" style="display: none;">TOP RESULTS</h2>
                    <div class="movie-row">
                        <!-- Search results will be dynamically added here -->
                    </div>
                </div>
                <div class="no-results" style="display: none;">
                    <div class="no-results-icon">
                        <i class="fas fa-search"></i>
                    </div>
                    <h3></h3>
                    <p>Try searching for something else or try with a different spelling</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Footer Section -->
<footer class="site-footer">
    <div class="footer-content">
        <div class="footer-section">
            <h3>Company</h3>
            <ul>
                <li><a href="#">About Us</a></li>
                <li><a href="#">Careers</a></li>
            </ul>
        </div>

        <div class="footer-section">
            <h3>Need Help?</h3>
            <ul>
                <li><a href="#">Visit Help Center</a></li>
                <li><a href="#">Share Feedback</a></li>
            </ul>
        </div>

        <div class="footer-section">
            <h3>Connect with Us</h3>
            <div class="social-links">
                <a href="#" aria-label="Facebook">
                    <i class="fab fa-facebook-f"></i>
                </a>
                <a href="#" aria-label="X (Twitter)">
                    <svg width="16" height="16" viewBox="0 0 24 24">
                        <path fill="currentColor" d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
                    </svg>
                </a>
                <a href="#" aria-label="Instagram">
                    <i class="fab fa-instagram"></i>
                </a>
                <a href="#" aria-label="YouTube">
                    <i class="fab fa-youtube"></i>
                </a>
            </div>
        </div>
    </div>
    
    <div class="footer-bottom">
        <div class="copyright">
            © 2024 ESCAPE. All Rights Reserved.
        </div>
        <div class="footer-legal">
            <a href="#">Terms Of Use</a>
            <a href="#">Privacy Policy</a>
            <a href="#">FAQ</a>
        </div>
    </div>
</footer>
    <!-- Scripts -->
    <script>
        var movieData = ${moviesByCategory != null ? moviesByCategory : '{}'};
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    <script src="script.js"></script>
</body>
</html>
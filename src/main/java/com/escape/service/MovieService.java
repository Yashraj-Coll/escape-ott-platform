package com.escape.service;

import com.escape.util.DatabaseConnection;
import com.escape.util.DatabaseHandler;
import com.escape.util.ErrorHandler;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;

public class MovieService {
    
    // Home Page Data
    public static Map<String, Object> getHomePageData(int userId) {
        Map<String, Object> homeData = new HashMap<>();
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            // Get banner data
            homeData.put("banners", DatabaseHandler.getBannerData(conn));
            
            // Get movies by categories
            homeData.put("moviesByCategory", DatabaseHandler.getMoviesByCategories(conn));
            
            // If user is logged in, get user-specific data
            if (userId > 0) {
                homeData.put("continueWatching", DatabaseHandler.getContinueWatching(conn, userId));
                homeData.put("myList", DatabaseHandler.getMyList(conn, userId));
                homeData.put("likedMovies", DatabaseHandler.getLikedMovies(conn, userId));
            }
            
        } catch (SQLException e) {
            ErrorHandler.logError("Error fetching home page data", e);
            homeData.put("error", "Failed to load content. Please try again later.");
        }
        
        return homeData;
    }

    // Movie Management
    public static List<Map<String, Object>> getMoviesByCategory(int categoryId) {
        List<Map<String, Object>> movies = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            String query = "SELECT m.*, c.name as category_name FROM movies m " +
                          "JOIN categories c ON m.category_id = c.category_id " +
                          "WHERE m.category_id = ? " +
                          "ORDER BY m.views DESC, m.created_at DESC";
            
            try (PreparedStatement pst = conn.prepareStatement(query)) {
                pst.setInt(1, categoryId);
                ResultSet rs = pst.executeQuery();
                
                while (rs.next()) {
                    Map<String, Object> movie = new HashMap<>();
                    movie.put("movieId", rs.getInt("movie_id"));
                    movie.put("title", rs.getString("title"));
                    movie.put("genre", rs.getString("genre"));
                    movie.put("year", rs.getInt("year"));
                    movie.put("duration", rs.getString("duration"));
                    movie.put("posterPath", rs.getString("poster_path"));
                    movie.put("videoPath", rs.getString("video_path"));
                    movie.put("views", rs.getInt("views"));
                    movie.put("categoryId", categoryId);
                    movie.put("categoryName", rs.getString("category_name"));
                    movies.add(movie);
                }
            }
            
        } catch (SQLException e) {
            ErrorHandler.logError("Error fetching movies by category", e);
        }
        
        return movies;
    }

    private static String getCategoryName(Connection conn, int categoryId) throws SQLException {
        String query = "SELECT name FROM categories WHERE category_id = ?";
        try (PreparedStatement pst = conn.prepareStatement(query)) {
            pst.setInt(1, categoryId);
            ResultSet rs = pst.executeQuery();
            if (rs.next()) {
                return rs.getString("name");
            }
        }
        return "";
    }

    // Continue Watching Management
    public static boolean updateMovieProgress(int userId, int movieId, float progress) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                DatabaseHandler.updateContinueWatching(conn, userId, movieId, progress);
                
                if (progress < 10) {
                    DatabaseHandler.incrementViews(conn, movieId);
                }
                
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            ErrorHandler.logError("Error updating movie progress", e);
            return false;
        }
    }

    public static boolean removeFromContinueWatching(int userId, int movieId) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            DatabaseHandler.removeFromContinueWatching(conn, userId, movieId);
            return true;
        } catch (SQLException e) {
            ErrorHandler.logError("Error removing from continue watching", e);
            return false;
        }
    }

    // My List Management
    public static boolean addToMyList(int userId, int movieId) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            DatabaseHandler.addToMyList(conn, userId, movieId);
            return true;
        } catch (SQLException e) {
            ErrorHandler.logError("Error adding to my list", e);
            return false;
        }
    }

    public static boolean removeFromMyList(int userId, int movieId) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            DatabaseHandler.removeFromMyList(conn, userId, movieId);
            return true;
        } catch (SQLException e) {
            ErrorHandler.logError("Error removing from my list", e);
            return false;
        }
    }

    // Like Management
    public static boolean toggleLike(int userId, int movieId) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            DatabaseHandler.toggleLike(conn, userId, movieId);
            return true;
        } catch (SQLException e) {
            ErrorHandler.logError("Error toggling movie like", e);
            return false;
        }
    }

    // Search Functionality
    public static List<Map<String, Object>> searchMovies(String query) {
        if (query == null || query.trim().isEmpty()) {
            return new ArrayList<>();
        }
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            return DatabaseHandler.searchMovies(conn, query.trim());
        } catch (SQLException e) {
            ErrorHandler.logError("Error searching movies", e);
            return new ArrayList<>();
        }
    }

    // Genre Management
    public static Set<String> getAllGenres() {
        Set<String> genres = new HashSet<>();
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            String query = "SELECT DISTINCT genre FROM movies WHERE genre IS NOT NULL AND genre != ''";
            try (PreparedStatement pst = conn.prepareStatement(query)) {
                ResultSet rs = pst.executeQuery();
                while (rs.next()) {
                    genres.add(rs.getString("genre"));
                }
            }
        } catch (SQLException e) {
            ErrorHandler.logError("Error fetching genres", e);
        }
        
        return genres;
    }

    // Banner Management
    public static List<Map<String, Object>> getActiveBanners() {
        try (Connection conn = DatabaseConnection.getConnection()) {
            return DatabaseHandler.getBannerData(conn);
        } catch (SQLException e) {
            ErrorHandler.logError("Error fetching active banners", e);
            return new ArrayList<>();
        }
    }

    // User Data Management
    public static Map<String, Object> getUserMovieData(int userId) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            return DatabaseHandler.getUserData(conn, userId);
        } catch (SQLException e) {
            ErrorHandler.logError("Error fetching user movie data", e);
            return new HashMap<>();
        }
    }

    // Validation Methods
    public static boolean isValidMovie(int movieId) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            String query = "SELECT COUNT(*) FROM movies WHERE movie_id = ?";
            try (PreparedStatement pst = conn.prepareStatement(query)) {
                pst.setInt(1, movieId);
                ResultSet rs = pst.executeQuery();
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            ErrorHandler.logError("Error validating movie", e);
        }
        return false;
    }

    public static boolean isValidProgress(float progress) {
        return progress >= 0 && progress <= 100;
    }

    // Stats Methods
    public static Map<String, Object> getMovieStats(int movieId) {
        Map<String, Object> stats = new HashMap<>();
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            String query = """
                SELECT 
                    m.views,
                    (SELECT COUNT(*) FROM user_likes WHERE movie_id = ?) as likes,
                    (SELECT COUNT(*) FROM user_mylist WHERE movie_id = ?) as list_adds
                FROM movies m
                WHERE m.movie_id = ?
                """;
                
            try (PreparedStatement pst = conn.prepareStatement(query)) {
                pst.setInt(1, movieId);
                pst.setInt(2, movieId);
                pst.setInt(3, movieId);
                
                ResultSet rs = pst.executeQuery();
                if (rs.next()) {
                    stats.put("views", rs.getInt("views"));
                    stats.put("likes", rs.getInt("likes"));
                    stats.put("listAdds", rs.getInt("list_adds"));
                }
            }
        } catch (SQLException e) {
            ErrorHandler.logError("Error fetching movie stats", e);
        }
        
        return stats;
    }

    // Movie Details
    public static Map<String, Object> getMovieDetails(int movieId) {
        Map<String, Object> details = new HashMap<>();
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            String query = """
                SELECT m.*, c.name as category_name 
                FROM movies m 
                JOIN categories c ON m.category_id = c.category_id 
                WHERE m.movie_id = ?
                """;
                
            try (PreparedStatement pst = conn.prepareStatement(query)) {
                pst.setInt(1, movieId);
                ResultSet rs = pst.executeQuery();
                
                if (rs.next()) {
                    details.put("movieId", rs.getInt("movie_id"));
                    details.put("title", rs.getString("title"));
                    details.put("genre", rs.getString("genre"));
                    details.put("year", rs.getInt("year"));
                    details.put("duration", rs.getString("duration"));
                    details.put("posterPath", rs.getString("poster_path"));
                    details.put("videoPath", rs.getString("video_path"));
                    details.put("category", rs.getString("category_name"));
                    details.put("views", rs.getInt("views"));
                    details.put("categoryId", rs.getInt("category_id"));
                }
            }
        } catch (SQLException e) {
            ErrorHandler.logError("Error fetching movie details", e);
            return null;
        }
        
        return details;
    }

    public static boolean incrementMovieViews(int movieId) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            String query = "UPDATE movies SET views = views + 1 WHERE movie_id = ?";
            try (PreparedStatement pst = conn.prepareStatement(query)) {
                pst.setInt(1, movieId);
                return pst.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            ErrorHandler.logError("Error incrementing movie views", e);
            return false;
        }
    }
}
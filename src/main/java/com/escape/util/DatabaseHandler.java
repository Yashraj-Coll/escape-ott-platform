package com.escape.util;

import java.sql.*;
import java.util.*;

public class DatabaseHandler {
    
    // Banner Methods
    public static List<Map<String, Object>> getBannerData(Connection conn) throws SQLException {
        List<Map<String, Object>> banners = new ArrayList<>();
        String query = "SELECT * FROM banner WHERE active = 1 ORDER BY created_at DESC";
        
        try (PreparedStatement pst = conn.prepareStatement(query);
             ResultSet rs = pst.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> banner = new HashMap<>();
                banner.put("bannerId", rs.getInt("banner_id"));
                banner.put("title", rs.getString("title"));
                banner.put("description", rs.getString("description"));
                banner.put("posterPath", rs.getString("poster_path"));
                banner.put("videoPath", rs.getString("video_path"));
                banners.add(banner);
            }
        }
        return banners;
    }

    // Category Methods
    public static List<Map<String, Object>> getAllCategories(Connection conn) throws SQLException {
        List<Map<String, Object>> categories = new ArrayList<>();
        String query = "SELECT * FROM categories ORDER BY category_id";
        
        try (PreparedStatement pst = conn.prepareStatement(query);
             ResultSet rs = pst.executeQuery()) {
            
            while (rs.next()) {
                Map<String, Object> category = new HashMap<>();
                category.put("categoryId", rs.getInt("category_id"));
                category.put("name", rs.getString("name"));
                categories.add(category);
            }
        }
        return categories;
    }

    // Movie Methods - Using LinkedHashMap to maintain order
    public static Map<String, List<Map<String, Object>>> getMoviesByCategories(Connection conn) throws SQLException {
        Map<String, List<Map<String, Object>>> moviesByCategory = new LinkedHashMap<>();
        
        // First get Popular Movies (category_id = 1)
        String query = "SELECT * FROM categories WHERE category_id = 1";
        PreparedStatement pst = conn.prepareStatement(query);
        ResultSet rs = pst.executeQuery();
        
        if (rs.next()) {
            String popularMoviesName = rs.getString("name");
            List<Map<String, Object>> popularMovies = getMoviesForCategory(conn, 1);
            moviesByCategory.put(popularMoviesName, popularMovies);
        }
        
        // Then get other categories
        query = "SELECT * FROM categories WHERE category_id != 1 ORDER BY category_id";
        pst = conn.prepareStatement(query);
        rs = pst.executeQuery();
        
        while (rs.next()) {
            String categoryName = rs.getString("name");
            int categoryId = rs.getInt("category_id");
            List<Map<String, Object>> movies = getMoviesForCategory(conn, categoryId);
            moviesByCategory.put(categoryName, movies);
        }
        
        return moviesByCategory;
    }
    
    private static List<Map<String, Object>> getMoviesForCategory(Connection conn, int categoryId) throws SQLException {
        List<Map<String, Object>> movies = new ArrayList<>();
        String query = "SELECT * FROM movies WHERE category_id = ? ORDER BY views DESC, created_at DESC";
        
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
                movies.add(movie);
            }
        }
        
        return movies;
    }

    // User's Continue Watching Methods
    public static List<Map<String, Object>> getContinueWatching(Connection conn, int userId) throws SQLException {
        List<Map<String, Object>> continueWatching = new ArrayList<>();
        String query = """
            SELECT m.*, cw.progress, cw.last_watched 
            FROM movies m 
            JOIN continue_watching cw ON m.movie_id = cw.movie_id 
            WHERE cw.id = ? 
            ORDER BY cw.last_watched DESC
            """;
        
        try (PreparedStatement pst = conn.prepareStatement(query)) {
            pst.setInt(1, userId);
            try (ResultSet rs = pst.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> movie = new HashMap<>();
                    movie.put("movieId", rs.getInt("movie_id"));
                    movie.put("title", rs.getString("title"));
                    movie.put("posterPath", rs.getString("poster_path"));
                    movie.put("videoPath", rs.getString("video_path"));
                    movie.put("progress", rs.getFloat("progress"));
                    movie.put("lastWatched", rs.getTimestamp("last_watched"));
                    movie.put("duration", rs.getString("duration"));
                    movie.put("genre", rs.getString("genre"));
                    movie.put("year", rs.getInt("year"));
                    continueWatching.add(movie);
                }
            }
        }
        return continueWatching;
    }

    public static void updateContinueWatching(Connection conn, int userId, int movieId, float progress) throws SQLException {
        String query = """
            INSERT INTO continue_watching (id, movie_id, progress, last_watched) 
            VALUES (?, ?, ?, CURRENT_TIMESTAMP) 
            ON DUPLICATE KEY UPDATE 
            progress = ?, last_watched = CURRENT_TIMESTAMP
            """;
        
        try (PreparedStatement pst = conn.prepareStatement(query)) {
            pst.setInt(1, userId);
            pst.setInt(2, movieId);
            pst.setFloat(3, progress);
            pst.setFloat(4, progress);
            pst.executeUpdate();
        }
    }

    public static void removeFromContinueWatching(Connection conn, int userId, int movieId) throws SQLException {
        String query = "DELETE FROM continue_watching WHERE id = ? AND movie_id = ?";
        try (PreparedStatement pst = conn.prepareStatement(query)) {
            pst.setInt(1, userId);
            pst.setInt(2, movieId);
            pst.executeUpdate();
        }
    }

    // User's My List Methods
    public static List<Map<String, Object>> getMyList(Connection conn, int userId) throws SQLException {
        List<Map<String, Object>> myList = new ArrayList<>();
        String query = """
            SELECT m.* 
            FROM movies m 
            JOIN user_mylist uml ON m.movie_id = uml.movie_id 
            WHERE uml.id = ? 
            ORDER BY uml.created_at DESC
            """;
        
        try (PreparedStatement pst = conn.prepareStatement(query)) {
            pst.setInt(1, userId);
            try (ResultSet rs = pst.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> movie = new HashMap<>();
                    movie.put("movieId", rs.getInt("movie_id"));
                    movie.put("title", rs.getString("title"));
                    movie.put("genre", rs.getString("genre"));
                    movie.put("posterPath", rs.getString("poster_path"));
                    movie.put("videoPath", rs.getString("video_path"));
                    movie.put("duration", rs.getString("duration"));
                    movie.put("year", rs.getInt("year"));
                    myList.add(movie);
                }
            }
        }
        return myList;
    }

    public static void addToMyList(Connection conn, int userId, int movieId) throws SQLException {
        String query = "INSERT IGNORE INTO user_mylist (id, movie_id) VALUES (?, ?)";
        try (PreparedStatement pst = conn.prepareStatement(query)) {
            pst.setInt(1, userId);
            pst.setInt(2, movieId);
            pst.executeUpdate();
        }
    }

    public static void removeFromMyList(Connection conn, int userId, int movieId) throws SQLException {
        String query = "DELETE FROM user_mylist WHERE id = ? AND movie_id = ?";
        try (PreparedStatement pst = conn.prepareStatement(query)) {
            pst.setInt(1, userId);
            pst.setInt(2, movieId);
            pst.executeUpdate();
        }
    }

    // User's Likes Methods
    public static List<Integer> getLikedMovies(Connection conn, int userId) throws SQLException {
        List<Integer> likedMovies = new ArrayList<>();
        String query = "SELECT movie_id FROM user_likes WHERE id = ?";
        
        try (PreparedStatement pst = conn.prepareStatement(query)) {
            pst.setInt(1, userId);
            try (ResultSet rs = pst.executeQuery()) {
                while (rs.next()) {
                    likedMovies.add(rs.getInt("movie_id"));
                }
            }
        }
        return likedMovies;
    }

    public static void toggleLike(Connection conn, int userId, int movieId) throws SQLException {
        // First check if movie is already liked
        String checkQuery = "SELECT COUNT(*) FROM user_likes WHERE id = ? AND movie_id = ?";
        try (PreparedStatement checkPst = conn.prepareStatement(checkQuery)) {
            checkPst.setInt(1, userId);
            checkPst.setInt(2, movieId);
            ResultSet rs = checkPst.executeQuery();
            rs.next();
            boolean isLiked = rs.getInt(1) > 0;

            String query;
            if (isLiked) {
                query = "DELETE FROM user_likes WHERE id = ? AND movie_id = ?";
            } else {
                query = "INSERT INTO user_likes (id, movie_id) VALUES (?, ?)";
            }

            try (PreparedStatement pst = conn.prepareStatement(query)) {
                pst.setInt(1, userId);
                pst.setInt(2, movieId);
                pst.executeUpdate();
            }
        }
    }

    // View Count Methods
    public static void incrementViews(Connection conn, int movieId) throws SQLException {
        String query = "UPDATE movies SET views = views + 1 WHERE movie_id = ?";
        try (PreparedStatement pst = conn.prepareStatement(query)) {
            pst.setInt(1, movieId);
            pst.executeUpdate();
        }
    }

    // Search Methods
    public static List<Map<String, Object>> searchMovies(Connection conn, String searchTerm) throws SQLException {
        List<Map<String, Object>> results = new ArrayList<>();
        String query = """
            SELECT * FROM movies 
            WHERE LOWER(title) LIKE ? OR LOWER(genre) LIKE ? 
            ORDER BY views DESC, created_at DESC
            """;
        
        try (PreparedStatement pst = conn.prepareStatement(query)) {
            String searchPattern = "%" + searchTerm.toLowerCase() + "%";
            pst.setString(1, searchPattern);
            pst.setString(2, searchPattern);
            
            try (ResultSet rs = pst.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> movie = new HashMap<>();
                    movie.put("movieId", rs.getInt("movie_id"));
                    movie.put("title", rs.getString("title"));
                    movie.put("genre", rs.getString("genre"));
                    movie.put("year", rs.getInt("year"));
                    movie.put("duration", rs.getString("duration"));
                    movie.put("posterPath", rs.getString("poster_path"));
                    movie.put("videoPath", rs.getString("video_path"));
                    results.add(movie);
                }
            }
        }
        return results;
    }

    // Utility method to get all user data at once
    public static Map<String, Object> getUserData(Connection conn, int userId) throws SQLException {
        Map<String, Object> userData = new HashMap<>();
        userData.put("continueWatching", getContinueWatching(conn, userId));
        userData.put("myList", getMyList(conn, userId));
        userData.put("likedMovies", getLikedMovies(conn, userId));
        return userData;
    }
    
    public static boolean exists(Connection conn, String query, Map<String, Object> params) throws SQLException {
        try (PreparedStatement pst = conn.prepareStatement(query)) {
            if (params.containsKey("movieId")) {
                pst.setInt(1, (Integer) params.get("movieId"));
            }
            
            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
                return false;
            }
        }
    }

    public static int getIntValue(Connection conn, String query, Map<String, Object> params) throws SQLException {
        try (PreparedStatement pst = conn.prepareStatement(query)) {
            if (params.containsKey("movieId")) {
                pst.setInt(1, (Integer) params.get("movieId"));
            }
            
            try (ResultSet rs = pst.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
                return 0;
            }
        }
    }
}
package com.escape.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import com.escape.util.DatabaseConnection;
import com.google.gson.JsonObject;
import com.google.gson.JsonArray;

import java.io.File;
import java.io.IOException;
import java.sql.*;

@WebServlet("/MovieServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1 MB
    maxFileSize = 1024 * 1024 * 1000,     // 1000 MB
    maxRequestSize = 1024 * 1024 * 1000   // 1000 MB
)
public class MovieServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        JsonObject jsonResponse = new JsonObject();

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();
            
            // Handle new category if provided
            String newCategoryTitle = request.getParameter("newCategoryTitle");
            int categoryId;
            
            if (newCategoryTitle != null && !newCategoryTitle.trim().isEmpty()) {
                // Insert new category
                pstmt = conn.prepareStatement("INSERT INTO categories (name) VALUES (?)", 
                                           Statement.RETURN_GENERATED_KEYS);
                pstmt.setString(1, newCategoryTitle.trim());
                pstmt.executeUpdate();
                
                rs = pstmt.getGeneratedKeys();
                if (rs.next()) {
                    categoryId = rs.getInt(1);
                } else {
                    throw new Exception("Failed to create new category");
                }
            } else {
                categoryId = Integer.parseInt(request.getParameter("categoryId"));
            }
            
            // Get category name from database
            pstmt = conn.prepareStatement("SELECT name FROM categories WHERE category_id = ?");
            pstmt.setInt(1, categoryId);
            rs = pstmt.executeQuery();
            
            if (!rs.next()) {
                throw new Exception("Invalid category ID");
            }

            // Get proper folder name based on category
            String categoryFolderName;
            switch(categoryId) {
                case 1:
                    categoryFolderName = "PopularMovies";
                    break;
                case 2:
                    categoryFolderName = "TrendingNow";
                    break;
                case 3:
                    categoryFolderName = "PopularSeries";
                    break;
                case 4:
                    categoryFolderName = "PopularTvShows";
                    break;
                default:
                    categoryFolderName = rs.getString("name").replaceAll("\\s+", "");
            }

            // Set up paths for webapp
            String webappPath = getServletContext().getRealPath("");
            
            // Create directories if they don't exist
            String imagesPath = webappPath + File.separator + "images" + File.separator + categoryFolderName;
            String videosPath = webappPath + File.separator + "videos" + File.separator + categoryFolderName;
            
            new File(imagesPath).mkdirs();
            new File(videosPath).mkdirs();

            // Handle file uploads
            Part posterPart = request.getPart("posterImage");
            Part videoPart = request.getPart("videoPath");

            // Get genre (handle new genre if provided)
            String genre = request.getParameter("genre");
            String newGenre = request.getParameter("newGenre");
            if (newGenre != null && !newGenre.trim().isEmpty()) {
                genre = newGenre.trim();
            }

            // Get movie title
            String movieTitle = request.getParameter("title").replaceAll("\\s+", "");

            // Generate filenames
            String posterFileName = "card" + nextMovieId(conn) + getFileExtension(posterPart);
            String videoFileName = movieTitle + getFileExtension(videoPart);

            // Save files to respective directories
            posterPart.write(imagesPath + File.separator + posterFileName);
            videoPart.write(videosPath + File.separator + videoFileName);

            // Set relative paths for database
            String posterPath = "images/" + categoryFolderName + "/" + posterFileName;
            String videoPath = "videos/" + categoryFolderName + "/" + videoFileName;

            // Save to database
            String sql = "INSERT INTO movies (title, genre, year, duration, poster_path, video_path, category_id, views) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, 0)";
            
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            
            pstmt.setString(1, request.getParameter("title"));
            pstmt.setString(2, genre);
            pstmt.setInt(3, Integer.parseInt(request.getParameter("year")));
            pstmt.setString(4, request.getParameter("duration"));
            pstmt.setString(5, posterPath);
            pstmt.setString(6, videoPath);
            pstmt.setInt(7, categoryId);
            
            int affectedRows = pstmt.executeUpdate();
            
            if (affectedRows > 0) {
                rs = pstmt.getGeneratedKeys();
                if (rs.next()) {
                    jsonResponse.addProperty("success", true);
                    jsonResponse.addProperty("movieId", rs.getInt(1));
                    jsonResponse.addProperty("posterPath", posterPath);
                    jsonResponse.addProperty("videoPath", videoPath);
                    jsonResponse.addProperty("message", "Movie added successfully!");
                }
            }

        } catch (SQLException e) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Database error: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        response.getWriter().write(jsonResponse.toString());
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        JsonObject jsonResponse = new JsonObject();

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();
            
            int movieId = Integer.parseInt(request.getParameter("movieId"));
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));
            
            // First get old file paths and category
            pstmt = conn.prepareStatement("SELECT poster_path, video_path, category_id FROM movies WHERE movie_id = ?");
            pstmt.setInt(1, movieId);
            rs = pstmt.executeQuery();
            
            String oldPosterPath = "";
            String oldVideoPath = "";
            int oldCategoryId = 0;
            if (rs.next()) {
                oldPosterPath = rs.getString("poster_path");
                oldVideoPath = rs.getString("video_path");
                oldCategoryId = rs.getInt("category_id");
            }

            // Get new category folder name
            pstmt = conn.prepareStatement("SELECT name FROM categories WHERE category_id = ?");
            pstmt.setInt(1, categoryId);
            rs = pstmt.executeQuery();
            
            if (!rs.next()) {
                throw new Exception("Invalid category ID");
            }

            // Get proper folder name based on category
            String categoryFolderName;
            switch(categoryId) {
                case 1:
                    categoryFolderName = "PopularMovies";
                    break;
                case 2:
                    categoryFolderName = "TrendingNow";
                    break;
                case 3:
                    categoryFolderName = "PopularSeries";
                    break;
                case 4:
                    categoryFolderName = "PopularTvShows";
                    break;
                default:
                    categoryFolderName = rs.getString("name").replaceAll("\\s+", "");
            }

            String webappPath = getServletContext().getRealPath("");
            String imagesPath = webappPath + File.separator + "images" + File.separator + categoryFolderName;
            String videosPath = webappPath + File.separator + "videos" + File.separator + categoryFolderName;
            
            new File(imagesPath).mkdirs();
            new File(videosPath).mkdirs();

            // Handle file updates if new files are provided
            Part posterPart = request.getPart("posterImage");
            Part videoPart = request.getPart("videoPath");
            
            String posterPath = oldPosterPath;
            String videoPath = oldVideoPath;
            String movieTitle = request.getParameter("title").replaceAll("\\s+", "");

            // Handle genre update
            String genre = request.getParameter("genre");
            String newGenre = request.getParameter("newGenre");
            if (newGenre != null && !newGenre.trim().isEmpty()) {
                genre = newGenre.trim();
            }

            // Update poster if new one is provided
            if (posterPart != null && posterPart.getSize() > 0) {
                // Delete old poster if it exists
                if (!oldPosterPath.isEmpty()) {
                    new File(webappPath + File.separator + oldPosterPath).delete();
                }
                
                // Save new poster
                String posterFileName = "card" + movieId + getFileExtension(posterPart);
                posterPart.write(imagesPath + File.separator + posterFileName);
                posterPath = "images/" + categoryFolderName + "/" + posterFileName;
            } else if (categoryId != oldCategoryId) {
                // Move poster to new category folder if category changed
                String oldFile = webappPath + File.separator + oldPosterPath;
                String newFile = imagesPath + File.separator + new File(oldPosterPath).getName();
                new File(oldFile).renameTo(new File(newFile));
                posterPath = "images/" + categoryFolderName + "/" + new File(oldPosterPath).getName();
            }

            // Update video if new one is provided
            if (videoPart != null && videoPart.getSize() > 0) {
                // Delete old video if it exists
                if (!oldVideoPath.isEmpty()) {
                    new File(webappPath + File.separator + oldVideoPath).delete();
                }
                
                // Save new video
                String videoFileName = movieTitle + getFileExtension(videoPart);
                videoPart.write(videosPath + File.separator + videoFileName);
                videoPath = "videos/" + categoryFolderName + "/" + videoFileName;
            } else if (categoryId != oldCategoryId) {
                // Move video to new category folder if category changed
                String oldFile = webappPath + File.separator + oldVideoPath;
                String newFile = videosPath + File.separator + new File(oldVideoPath).getName();
                new File(oldFile).renameTo(new File(newFile));
                videoPath = "videos/" + categoryFolderName + "/" + new File(oldVideoPath).getName();
            }

            // Update database record
            String sql = "UPDATE movies SET title=?, genre=?, year=?, duration=?, " +
                        "poster_path=?, video_path=?, category_id=? WHERE movie_id=?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, request.getParameter("title"));
            pstmt.setString(2, genre);
            pstmt.setInt(3, Integer.parseInt(request.getParameter("year")));
            pstmt.setString(4, request.getParameter("duration"));
            pstmt.setString(5, posterPath);
            pstmt.setString(6, videoPath);
            pstmt.setInt(7, categoryId);
            pstmt.setInt(8, movieId);
            
            int affectedRows = pstmt.executeUpdate();
            
            if (affectedRows > 0) {
                jsonResponse.addProperty("success", true);
                jsonResponse.addProperty("message", "Movie updated successfully!");
                jsonResponse.addProperty("posterPath", posterPath);
                jsonResponse.addProperty("videoPath", videoPath);
            } else {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "No movie found with the given ID");
            }

        } catch (SQLException e) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Database error: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        response.getWriter().write(jsonResponse.toString());
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        JsonArray jsonArray = new JsonArray();
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(
                 "SELECT m.*, c.name as category_name " +
                 "FROM movies m " +
                 "JOIN categories c ON m.category_id = c.category_id " +
                 "ORDER BY m.movie_id DESC");
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                JsonObject movie = new JsonObject();
                movie.addProperty("movieId", rs.getInt("movie_id"));
                movie.addProperty("title", rs.getString("title"));
                movie.addProperty("genre", rs.getString("genre"));
                movie.addProperty("year", rs.getInt("year"));
                movie.addProperty("duration", rs.getString("duration"));
                movie.addProperty("posterPath", rs.getString("poster_path"));
                movie.addProperty("videoPath", rs.getString("video_path"));
                movie.addProperty("categoryId", rs.getInt("category_id"));
                movie.addProperty("categoryName", rs.getString("category_name"));
                movie.addProperty("views", rs.getInt("views"));
                jsonArray.add(movie);
            }
            
        } catch (SQLException e) {
            JsonObject error = new JsonObject();
            error.addProperty("error", "Error fetching movies: " + e.getMessage());
            jsonArray.add(error);
            e.printStackTrace();
        }
        
        response.getWriter().write(jsonArray.toString());
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        JsonObject jsonResponse = new JsonObject();

        String movieId = request.getParameter("movieId");
        if (movieId == null || movieId.trim().isEmpty()) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Movie ID is required");
            response.getWriter().write(jsonResponse.toString());
            return;
        }

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);  // Start transaction

            // First get the file paths and category info
            pstmt = conn.prepareStatement(
                "SELECT m.poster_path, m.video_path, m.category_id, c.name as category_name " +
                "FROM movies m " +
                "JOIN categories c ON m.category_id = c.category_id " +
                "WHERE m.movie_id = ?"
            );
            pstmt.setInt(1, Integer.parseInt(movieId));
            rs = pstmt.executeQuery();

            if (rs.next()) {
                String posterPath = rs.getString("poster_path");
                String videoPath = rs.getString("video_path");
                int categoryId = rs.getInt("category_id");
                String categoryName = rs.getString("category_name");

                // Delete files
                String webappPath = getServletContext().getRealPath("");
                new File(webappPath + File.separator + posterPath).delete();
                new File(webappPath + File.separator + videoPath).delete();

                try {
                	// First delete user_likes entries for this movie
                	pstmt = conn.prepareStatement("DELETE FROM user_likes WHERE movie_id = ?");
                    pstmt.setInt(1, Integer.parseInt(movieId));
                    pstmt.executeUpdate();
                    
                    // Then delete user_mylist entries for this movie
                    pstmt = conn.prepareStatement("DELETE FROM user_mylist WHERE movie_id = ?");
                    pstmt.setInt(1, Integer.parseInt(movieId));
                    pstmt.executeUpdate();

                    // Then delete continue_watching entries for this movie
                    pstmt = conn.prepareStatement("DELETE FROM continue_watching WHERE movie_id = ?");
                    pstmt.setInt(1, Integer.parseInt(movieId));
                    pstmt.executeUpdate();

                    // Then delete user notifications for this movie's notifications
                    pstmt = conn.prepareStatement(
                        "DELETE un FROM user_notifications un " +
                        "INNER JOIN notifications n ON un.notification_id = n.notification_id " +
                        "WHERE n.movie_id = ?"
                    );
                    pstmt.setInt(1, Integer.parseInt(movieId));
                    pstmt.executeUpdate();

                    // Then delete the notifications for this movie
                    pstmt = conn.prepareStatement("DELETE FROM notifications WHERE movie_id = ?");
                    pstmt.setInt(1, Integer.parseInt(movieId));
                    pstmt.executeUpdate();

                    // Delete the movie
                    pstmt = conn.prepareStatement("DELETE FROM movies WHERE movie_id = ?");
                    pstmt.setInt(1, Integer.parseInt(movieId));
                    int affectedRows = pstmt.executeUpdate();

                    if (affectedRows > 0) {
                        // Check if category is now empty after movie deletion
                        pstmt = conn.prepareStatement(
                            "SELECT COUNT(*) as movie_count FROM movies WHERE category_id = ?"
                        );
                        pstmt.setInt(1, categoryId);
                        rs = pstmt.executeQuery();
                        
                        if (rs.next() && rs.getInt("movie_count") == 0 && categoryId > 4) {
                            // Category is empty and not a default category (ID > 4)
                            // Delete the category folders
                            String categoryFolderName = categoryName.replaceAll("\\s+", "");
                            File imagesDir = new File(webappPath + File.separator + "images" + 
                                                    File.separator + categoryFolderName);
                            File videosDir = new File(webappPath + File.separator + "videos" + 
                                                    File.separator + categoryFolderName);
                            
                            // Delete the category from database
                            pstmt = conn.prepareStatement("DELETE FROM categories WHERE category_id = ?");
                            pstmt.setInt(1, categoryId);
                            pstmt.executeUpdate();
                            
                            // Delete the folders
                            if (imagesDir.exists()) deleteDirectory(imagesDir);
                            if (videosDir.exists()) deleteDirectory(videosDir);
                            
                            jsonResponse.addProperty("categoryDeleted", true);
                            jsonResponse.addProperty("message", "Movie and empty category deleted successfully");
                        } else {
                            jsonResponse.addProperty("message", "Movie deleted successfully");
                        }
                        
                        conn.commit();  // Commit the transaction
                        jsonResponse.addProperty("success", true);
                    } else {
                        conn.rollback();  // Rollback if no rows affected
                        jsonResponse.addProperty("success", false);
                        jsonResponse.addProperty("message", "Movie not found");
                    }
                } catch (SQLException ex) {
                    conn.rollback();  // Rollback on any SQL error
                    throw ex;
                }
            } else {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Movie not found");
            }

        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Database error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);  // Reset auto-commit
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        response.getWriter().write(jsonResponse.toString());
    }

    private int nextMovieId(Connection conn) throws SQLException {
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT MAX(movie_id) + 1 AS next_id FROM movies")) {
            if (rs.next()) {
                int nextId = rs.getInt("next_id");
                return nextId > 0 ? nextId : 1;
            }
            return 1;
        }
    }

    private String getFileExtension(Part part) {
        String fileName = part.getSubmittedFileName();
        int lastDot = fileName.lastIndexOf('.');
        return lastDot > 0 ? fileName.substring(lastDot) : "";
    }
    
    private boolean deleteDirectory(File directoryToBeDeleted) {
        File[] allContents = directoryToBeDeleted.listFiles();
        if (allContents != null) {
            for (File file : allContents) {
                deleteDirectory(file);
            }
        }
        return directoryToBeDeleted.delete();
    }
}
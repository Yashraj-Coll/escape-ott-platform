package com.escape.servlet;

import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.escape.util.DatabaseConnection;
import com.escape.util.NotificationEmailSender;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/send-notification")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,    // 1 MB
    maxFileSize = 1024 * 1024 * 10,     // 10 MB
    maxRequestSize = 1024 * 1024 * 15    // 15 MB
)
public class SendNotificationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private String getBase64Image(String imagePath, ServletContext context) {
        try {
            // Get the real path from web app context
            String realPath = context.getRealPath("/" + imagePath.replace("\\", "/").replaceAll("^/+", ""));
            System.out.println("Real path for image: " + realPath);
            
            // Read the image file
            java.nio.file.Path path = java.nio.file.Paths.get(realPath);
            byte[] imageBytes = java.nio.file.Files.readAllBytes(path);
            
            // Detect MIME type
            String mimeType = context.getMimeType(realPath);
            if (mimeType == null) {
                mimeType = "image/jpeg";
            }
            
            System.out.println("Image size: " + imageBytes.length + " bytes");
            System.out.println("MIME type: " + mimeType);

            // Check file size
            if (imageBytes.length > 1024 * 1024) { // If larger than 1MB
                System.out.println("Warning: Large image file: " + imageBytes.length + " bytes");
            }
            
            // Convert to Base64
            String base64Image = java.util.Base64.getEncoder().encodeToString(imageBytes);
            System.out.println("Base64 length: " + base64Image.length());
            
            // Return complete Data URL
            return "data:" + mimeType + ";base64," + base64Image;
            
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("Error processing image: " + imagePath);
            return null;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // Get form parameters
            String categoryId = request.getParameter("notificationType");
            String movieId = request.getParameter("movie");
            
            // Validate required fields
            if (categoryId == null || categoryId.trim().isEmpty() || 
                movieId == null || movieId.trim().isEmpty()) {
                response.sendRedirect("notification.jsp?error=Please select category and movie");
                return;
            }

            // Get category name
            String categoryName = null;
            try (Connection conn = DatabaseConnection.getConnection();
                 PreparedStatement pstmt = conn.prepareStatement("SELECT name FROM categories WHERE category_id = ?")) {
                pstmt.setInt(1, Integer.parseInt(categoryId));
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    categoryName = rs.getString("name");
                }
            }

            // Get movie details
            String movieTitle = null;
            String moviePosterPath = null;
            try (Connection conn = DatabaseConnection.getConnection();
                 PreparedStatement pstmt = conn.prepareStatement("SELECT title, poster_path FROM movies WHERE movie_id = ?")) {
                pstmt.setInt(1, Integer.parseInt(movieId));
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    movieTitle = rs.getString("title");
                    String dbPosterPath = rs.getString("poster_path");
                    
                    if (dbPosterPath != null && !dbPosterPath.trim().isEmpty()) {
                        // Convert image to Base64
                        moviePosterPath = getBase64Image(dbPosterPath, request.getServletContext());
                        
                        // Debug logging
                        System.out.println("Movie ID: " + movieId);
                        System.out.println("Original poster path: " + dbPosterPath);
                        System.out.println("Converted to Base64 image");
                    }
                }
            }

            // Get form parameters with default values
            String title = request.getParameter("title");
            if (title == null || title.trim().isEmpty()) {
                title = "New on Escape: " + movieTitle;
            }

            String message = request.getParameter("message");
            if (message == null || message.trim().isEmpty()) {
                message = "Watch " + movieTitle + " now on Escape";
            }

            // Get all non-admin users
            List<UserInfo> users = new ArrayList<>();
            try (Connection conn = DatabaseConnection.getConnection();
                 PreparedStatement pstmt = conn.prepareStatement(
                     "SELECT id, CONCAT(first_name, ' ', last_name) as name, email FROM users WHERE user_role != 'admin'")) {
                ResultSet rs = pstmt.executeQuery();
                while (rs.next()) {
                    users.add(new UserInfo(
                        rs.getInt("id"),
                        rs.getString("name"),
                        rs.getString("email")
                    ));
                }
            }

            // Get server URL for links
            String serverUrl = request.getScheme() + "://" + request.getServerName();
            int port = request.getServerPort();
            if ((request.getScheme().equals("http") && port != 80) || 
                (request.getScheme().equals("https") && port != 443)) {
                serverUrl += ":" + port;
            }
            serverUrl += request.getContextPath();

            // Save notification
            int notificationId = saveNotification(title, message, categoryId, movieId, moviePosterPath);

            if (notificationId != -1) {
                // Save user notifications
                saveUserNotifications(notificationId, users);

                // Send emails to all users
                for (UserInfo user : users) {
                    NotificationEmailSender.sendNotificationEmail(
                        user.email,
                        user.name,
                        title,
                        message,
                        categoryName,
                        movieTitle,
                        moviePosterPath,
                        serverUrl
                    );
                }

                response.sendRedirect("notification.jsp?success=true");
            } else {
                throw new Exception("Failed to save notification");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("notification.jsp?error=" + e.getMessage());
        }
    }

    private int saveNotification(String title, String message, String categoryId, 
            String movieId, String moviePosterPath) throws SQLException {
        int notificationId = -1;
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(
                 "INSERT INTO notifications (title, message, category_id, movie_id, image_path, created_at) " +
                 "VALUES (?, ?, ?, ?, ?, NOW())", Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setString(1, title);
            pstmt.setString(2, message);
            pstmt.setInt(3, Integer.parseInt(categoryId));
            pstmt.setInt(4, Integer.parseInt(movieId));
            
            // Set image path with maximum length check
            if (moviePosterPath != null && moviePosterPath.length() > 16777215) { // MySQL MEDIUMTEXT limit
                System.out.println("Warning: Image path too long, truncating");
                pstmt.setString(5, moviePosterPath.substring(0, 16777215));
            } else {
                pstmt.setString(5, moviePosterPath);
            }
            
            pstmt.executeUpdate();
            
            try (ResultSet rs = pstmt.getGeneratedKeys()) {
                if (rs.next()) {
                    notificationId = rs.getInt(1);
                }
            }
        }
        
        return notificationId;
    }

    private void saveUserNotifications(int notificationId, List<UserInfo> users) throws SQLException {
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(
                 "INSERT INTO user_notifications (user_id, notification_id, is_read, created_at) " +
                 "VALUES (?, ?, false, NOW())")) {
            
            for (UserInfo user : users) {
                pstmt.setInt(1, user.userId);
                pstmt.setInt(2, notificationId);
                pstmt.addBatch();
            }
            pstmt.executeBatch();
        }
    }

    private static class UserInfo {
        int userId;
        String name;
        String email;

        UserInfo(int userId, String name, String email) {
            this.userId = userId;
            this.name = name;
            this.email = email;
        }
    }
}
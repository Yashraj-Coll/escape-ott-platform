package com.escape.servlet;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.sql.*;
import com.google.gson.JsonObject;
import com.escape.util.DatabaseConnection;

@WebServlet("/AddBannerServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1 MB
    maxFileSize = 1024 * 1024 * 1000,     // 1000 MB
    maxRequestSize = 1024 * 1024 * 1000   // 1000 MB
)
public class AddBannerServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private static final String IMAGE_DIRECTORY = "images/Banner";
    private static final String VIDEO_DIRECTORY = "videos/Banner";

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

            // Get the real paths for image and video directories
            String webappPath = getServletContext().getRealPath("");
            String imagesPath = webappPath + File.separator + IMAGE_DIRECTORY;
            String videosPath = webappPath + File.separator + VIDEO_DIRECTORY;
            
            // Create directories if they don't exist
            new File(imagesPath).mkdirs();
            new File(videosPath).mkdirs();

            // Get form fields
            String title = request.getParameter("bannerTitle");
            String description = request.getParameter("bannerDescription");

            // Handle file uploads
            Part posterPart = request.getPart("bannerPoster");
            Part videoPart = request.getPart("bannerVideo");

            if (posterPart == null || videoPart == null) {
                throw new ServletException("Please upload both poster and video files");
            }

            // Generate unique filenames
            String posterFileName = System.currentTimeMillis() + "_" + getFileName(posterPart);
            String videoFileName = System.currentTimeMillis() + "_" + getFileName(videoPart);

            // Save files to respective directories
            posterPart.write(imagesPath + File.separator + posterFileName);
            videoPart.write(videosPath + File.separator + videoFileName);

            // Set relative paths for database
            String posterPath = IMAGE_DIRECTORY + "/" + posterFileName;
            String videoPath = VIDEO_DIRECTORY + "/" + videoFileName;

            // Save to database
            String sql = "INSERT INTO banner (title, description, poster_path, video_path) VALUES (?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            
            pstmt.setString(1, title);
            pstmt.setString(2, description);
            pstmt.setString(3, posterPath);
            pstmt.setString(4, videoPath);
            
            int affectedRows = pstmt.executeUpdate();
            
            if (affectedRows > 0) {
                rs = pstmt.getGeneratedKeys();
                if (rs.next()) {
                    jsonResponse.addProperty("success", true);
                    jsonResponse.addProperty("bannerId", rs.getInt(1));
                    jsonResponse.addProperty("posterPath", posterPath);
                    jsonResponse.addProperty("videoPath", videoPath);
                    jsonResponse.addProperty("message", "Banner added successfully!");
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

    private String getFileName(Part part) {
        String fileName = part.getSubmittedFileName();
        return fileName.substring(fileName.lastIndexOf('/') + 1).substring(fileName.lastIndexOf('\\') + 1);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JsonObject jsonResponse = new JsonObject();
        com.google.gson.JsonArray bannerArray = new com.google.gson.JsonArray();
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM banner ORDER BY banner_id DESC");
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                JsonObject banner = new JsonObject();
                banner.addProperty("bannerId", rs.getInt("banner_id"));
                banner.addProperty("title", rs.getString("title") != null ? rs.getString("title") : "");
                banner.addProperty("description", rs.getString("description") != null ? rs.getString("description") : "");
                banner.addProperty("posterPath", rs.getString("poster_path") != null ? rs.getString("poster_path") : "");
                banner.addProperty("videoPath", rs.getString("video_path") != null ? rs.getString("video_path") : "");
                bannerArray.add(banner);
            }
            
            jsonResponse.addProperty("success", true);
            jsonResponse.add("banners", bannerArray);

        } catch (SQLException e) {
            e.printStackTrace();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Error fetching banners: " + e.getMessage());
        }
        
        // Write the response with proper error handling
        try {
            out.print(jsonResponse.toString());
            out.flush();
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error generating response");
        }
    }
}
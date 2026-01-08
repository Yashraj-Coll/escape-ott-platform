package com.escape.servlet;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.sql.*;
import com.google.gson.JsonObject;
import com.escape.util.DatabaseConnection;

@WebServlet("/UpdateBannerServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1 MB
    maxFileSize = 1024 * 1024 * 1000,     // 1000 MB
    maxRequestSize = 1024 * 1024 * 1000   // 1000 MB
)
public class UpdateBannerServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private static final String IMAGE_DIRECTORY = "images/Banner";
    private static final String VIDEO_DIRECTORY = "videos/Banner";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        JsonObject jsonResponse = new JsonObject();

        String bannerId = request.getParameter("bannerId");
        String title = request.getParameter("bannerTitle");
        String description = request.getParameter("bannerDescription");

        if (bannerId == null || bannerId.trim().isEmpty()) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Banner ID is required");
            response.getWriter().write(jsonResponse.toString());
            return;
        }

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

            // Start building the SQL query dynamically
            StringBuilder sqlBuilder = new StringBuilder("UPDATE banner SET ");
            StringBuilder setClause = new StringBuilder();
            java.util.List<Object> params = new java.util.ArrayList<>();

            // Add title and description if provided
            if (title != null && !title.trim().isEmpty()) {
                setClause.append("title = ?, ");
                params.add(title);
            }
            if (description != null && !description.trim().isEmpty()) {
                setClause.append("description = ?, ");
                params.add(description);
            }

            // Handle file uploads
            Part posterPart = request.getPart("bannerPoster");
            Part videoPart = request.getPart("bannerVideo");

            String posterPath = null;
            String videoPath = null;

            // Handle poster upload if provided
            if (posterPart != null && posterPart.getSize() > 0) {
                String posterFileName = System.currentTimeMillis() + "_" + getFileName(posterPart);
                posterPart.write(imagesPath + File.separator + posterFileName);
                posterPath = IMAGE_DIRECTORY + "/" + posterFileName;
                setClause.append("poster_path = ?, ");
                params.add(posterPath);
            }

            // Handle video upload if provided
            if (videoPart != null && videoPart.getSize() > 0) {
                String videoFileName = System.currentTimeMillis() + "_" + getFileName(videoPart);
                videoPart.write(videosPath + File.separator + videoFileName);
                videoPath = VIDEO_DIRECTORY + "/" + videoFileName;
                setClause.append("video_path = ?, ");
                params.add(videoPath);
            }

            // Remove trailing comma and space
            if (setClause.length() > 0) {
                setClause.setLength(setClause.length() - 2);
                sqlBuilder.append(setClause);
                sqlBuilder.append(" WHERE banner_id = ?");
                params.add(Integer.parseInt(bannerId));

                String sql = sqlBuilder.toString();
                pstmt = conn.prepareStatement(sql);

                // Set parameters
                for (int i = 0; i < params.size(); i++) {
                    pstmt.setObject(i + 1, params.get(i));
                }

                int affectedRows = pstmt.executeUpdate();

                if (affectedRows > 0) {
                    jsonResponse.addProperty("success", true);
                    jsonResponse.addProperty("message", "Banner updated successfully!");
                    if (posterPath != null) jsonResponse.addProperty("posterPath", posterPath);
                    if (videoPath != null) jsonResponse.addProperty("videoPath", videoPath);
                } else {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "No banner found with ID: " + bannerId);
                }
            } else {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "No changes provided for update");
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
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "";
    }
}
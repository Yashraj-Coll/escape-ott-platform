package com.escape.servlet;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.sql.*;
import com.google.gson.JsonObject;
import com.escape.util.DatabaseConnection;

@WebServlet("/DeleteBannerServlet")
public class DeleteBannerServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        JsonObject jsonResponse = new JsonObject();
        
        try {
            // Get banner ID
            String bannerId = request.getParameter("bannerId");
            if (bannerId == null || bannerId.trim().isEmpty()) {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Banner ID is required");
                response.getWriter().write(jsonResponse.toString());
                return;
            }

            // Parse banner ID
            int bannerIdInt = Integer.parseInt(bannerId.trim());
            
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                conn = DatabaseConnection.getConnection();
                
                // First, get the file paths
                pstmt = conn.prepareStatement("SELECT poster_path, video_path FROM banner WHERE banner_id = ?");
                pstmt.setInt(1, bannerIdInt);
                rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    String posterPath = rs.getString("poster_path");
                    String videoPath = rs.getString("video_path");
                    
                    // Delete files
                    String webappPath = getServletContext().getRealPath("");
                    if (posterPath != null) {
                        new File(webappPath + File.separator + posterPath).delete();
                    }
                    if (videoPath != null) {
                        new File(webappPath + File.separator + videoPath).delete();
                    }

                    // Delete from database
                    pstmt = conn.prepareStatement("DELETE FROM banner WHERE banner_id = ?");
                    pstmt.setInt(1, bannerIdInt);
                    
                    int affectedRows = pstmt.executeUpdate();
                    if (affectedRows > 0) {
                        jsonResponse.addProperty("success", true);
                        jsonResponse.addProperty("message", "Banner deleted successfully!");
                    } else {
                        jsonResponse.addProperty("success", false);
                        jsonResponse.addProperty("message", "Banner not found");
                    }
                } else {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Banner not found");
                }
            } finally {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            }
        } catch (NumberFormatException e) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Invalid banner ID format");
        } catch (SQLException e) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Database error: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Error: " + e.getMessage());
            e.printStackTrace();
        }
        
        // Write the response
        out.print(jsonResponse.toString());
        out.flush();
    }
    }
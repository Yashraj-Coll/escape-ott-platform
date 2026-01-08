package com.escape.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.escape.util.DatabaseConnection;
import com.google.gson.JsonObject;
import com.google.gson.JsonArray;
import com.google.gson.JsonParser;

import java.io.IOException;
import java.io.File;
import java.io.BufferedReader;
import java.sql.*;

@WebServlet("/CategoryServlet")
public class CategoryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        JsonArray jsonArray = new JsonArray();
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(
                 "SELECT c.category_id, c.name, " +
                 "(SELECT COUNT(*) FROM movies m WHERE m.category_id = c.category_id) as movie_count " +
                 "FROM categories c ORDER BY c.name")) {
            
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                JsonObject category = new JsonObject();
                category.addProperty("categoryId", rs.getInt("category_id"));
                category.addProperty("name", rs.getString("name"));
                category.addProperty("movieCount", rs.getInt("movie_count"));
                jsonArray.add(category);
            }
            
        } catch (SQLException e) {
            JsonObject error = new JsonObject();
            error.addProperty("error", "Error fetching categories: " + e.getMessage());
            jsonArray.add(error);
            e.printStackTrace();
        }
        
        response.getWriter().write(jsonArray.toString());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        JsonObject jsonResponse = new JsonObject();
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            String categoryName = request.getParameter("categoryName");
            
            if (categoryName == null || categoryName.trim().isEmpty()) {
                throw new Exception("Category name is required");
            }
            
            categoryName = categoryName.trim();
            
            // Check if category already exists
            PreparedStatement checkStmt = conn.prepareStatement(
                "SELECT category_id FROM categories WHERE name = ?");
            checkStmt.setString(1, categoryName);
            ResultSet rs = checkStmt.executeQuery();
            
            if (rs.next()) {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Category already exists");
            } else {
                // Create folder for the new category
                String webappPath = getServletContext().getRealPath("");
                String categoryFolderName = categoryName.replaceAll("\\s+", "");
                
                // Create images and videos directories
                File imagesDir = new File(webappPath + File.separator + "images" + 
                                        File.separator + categoryFolderName);
                File videosDir = new File(webappPath + File.separator + "videos" + 
                                        File.separator + categoryFolderName);
                
                imagesDir.mkdirs();
                videosDir.mkdirs();
                
                // Insert new category
                PreparedStatement pstmt = conn.prepareStatement(
                    "INSERT INTO categories (name) VALUES (?)",
                    Statement.RETURN_GENERATED_KEYS);
                pstmt.setString(1, categoryName);
                
                int affectedRows = pstmt.executeUpdate();
                if (affectedRows > 0) {
                    ResultSet generatedKeys = pstmt.getGeneratedKeys();
                    if (generatedKeys.next()) {
                        jsonResponse.addProperty("success", true);
                        jsonResponse.addProperty("categoryId", generatedKeys.getInt(1));
                        jsonResponse.addProperty("name", categoryName);
                        jsonResponse.addProperty("message", "Category added successfully");
                    }
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
        }
        
        response.getWriter().write(jsonResponse.toString());
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        JsonObject jsonResponse = new JsonObject();
        
        try {
            // Read JSON data from request body
            BufferedReader reader = request.getReader();
            JsonObject jsonRequest = JsonParser.parseReader(reader).getAsJsonObject();
            
            int categoryId = jsonRequest.get("categoryId").getAsInt();
            String newName = jsonRequest.get("newName").getAsString().trim();
            
            if (newName.isEmpty()) {
                throw new Exception("New category name cannot be empty");
            }
            
            try (Connection conn = DatabaseConnection.getConnection()) {
                // First get the old category name
                PreparedStatement getStmt = conn.prepareStatement(
                    "SELECT name FROM categories WHERE category_id = ?");
                getStmt.setInt(1, categoryId);
                ResultSet rs = getStmt.executeQuery();
                
                if (!rs.next()) {
                    throw new Exception("Category not found");
                }
                
                String oldName = rs.getString("name");
                String oldFolderName = oldName.replaceAll("\\s+", "");
                String newFolderName = newName.replaceAll("\\s+", "");
                
                // Check if new name already exists for different category
                PreparedStatement checkStmt = conn.prepareStatement(
                    "SELECT category_id FROM categories WHERE name = ? AND category_id != ?");
                checkStmt.setString(1, newName);
                checkStmt.setInt(2, categoryId);
                rs = checkStmt.executeQuery();
                
                if (rs.next()) {
                    throw new Exception("A category with this name already exists");
                }
                
                // Rename category folders if name changed
                if (!oldFolderName.equals(newFolderName)) {
                    String webappPath = getServletContext().getRealPath("");
                    
                    // Rename images folder
                    File oldImagesFolder = new File(webappPath + File.separator + "images" + 
                                                  File.separator + oldFolderName);
                    File newImagesFolder = new File(webappPath + File.separator + "images" + 
                                                  File.separator + newFolderName);
                    if (oldImagesFolder.exists()) {
                        oldImagesFolder.renameTo(newImagesFolder);
                    }
                    
                    // Rename videos folder
                    File oldVideosFolder = new File(webappPath + File.separator + "videos" + 
                                                  File.separator + oldFolderName);
                    File newVideosFolder = new File(webappPath + File.separator + "videos" + 
                                                  File.separator + newFolderName);
                    if (oldVideosFolder.exists()) {
                        oldVideosFolder.renameTo(newVideosFolder);
                    }
                    
                    // Update file paths in database
                    PreparedStatement updatePathsStmt = conn.prepareStatement(
                        "UPDATE movies SET " +
                        "poster_path = REPLACE(poster_path, ?, ?), " +
                        "video_path = REPLACE(video_path, ?, ?) " +
                        "WHERE category_id = ?");
                    updatePathsStmt.setString(1, "images/" + oldFolderName);
                    updatePathsStmt.setString(2, "images/" + newFolderName);
                    updatePathsStmt.setString(3, "videos/" + oldFolderName);
                    updatePathsStmt.setString(4, "videos/" + newFolderName);
                    updatePathsStmt.setInt(5, categoryId);
                    updatePathsStmt.executeUpdate();
                }
                
                // Update category name
                PreparedStatement updateStmt = conn.prepareStatement(
                    "UPDATE categories SET name = ? WHERE category_id = ?");
                updateStmt.setString(1, newName);
                updateStmt.setInt(2, categoryId);
                
                int affectedRows = updateStmt.executeUpdate();
                if (affectedRows > 0) {
                    jsonResponse.addProperty("success", true);
                    jsonResponse.addProperty("message", "Category updated successfully");
                } else {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Category not found");
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
        }
        
        response.getWriter().write(jsonResponse.toString());
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        JsonObject jsonResponse = new JsonObject();

        String categoryId = request.getParameter("categoryId");
        if (categoryId == null || categoryId.trim().isEmpty()) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Category ID is required");
            response.getWriter().write(jsonResponse.toString());
            return;
        }

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();
            
            // Check if category has movies
            pstmt = conn.prepareStatement(
                "SELECT COUNT(*) as movie_count FROM movies WHERE category_id = ?");
            pstmt.setInt(1, Integer.parseInt(categoryId));
            rs = pstmt.executeQuery();
            
            if (rs.next() && rs.getInt("movie_count") > 0) {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Cannot delete category that contains movies");
                response.getWriter().write(jsonResponse.toString());
                return;
            }
            
            // Get category name for folder deletion
            pstmt = conn.prepareStatement("SELECT name FROM categories WHERE category_id = ?");
            pstmt.setInt(1, Integer.parseInt(categoryId));
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                String categoryName = rs.getString("name");
                String folderName = categoryName.replaceAll("\\s+", "");
                
                // Delete category folders
                String webappPath = getServletContext().getRealPath("");
                deleteDirectory(new File(webappPath + File.separator + "images" + 
                                      File.separator + folderName));
                deleteDirectory(new File(webappPath + File.separator + "videos" + 
                                      File.separator + folderName));
                
                // Delete from database
                pstmt = conn.prepareStatement("DELETE FROM categories WHERE category_id = ?");
                pstmt.setInt(1, Integer.parseInt(categoryId));
                
                int affectedRows = pstmt.executeUpdate();
                
                if (affectedRows > 0) {
                    jsonResponse.addProperty("success", true);
                    jsonResponse.addProperty("message", "Category deleted successfully");
                } else {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Category not found");
                }
            } else {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Category not found");
            }

        } catch (SQLException e) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Database error: " + e.getMessage());
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
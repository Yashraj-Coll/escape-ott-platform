package com.escape.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.escape.util.DatabaseConnection;
import com.google.gson.JsonObject;
import com.google.gson.JsonArray;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/getMoviesByCategory")
public class GetMoviesByCategoryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JsonArray jsonArray = new JsonArray();
        
        String categoryId = request.getParameter("categoryId");
        
        if (categoryId == null || categoryId.trim().isEmpty()) {
            out.write(jsonArray.toString());
            return;
        }

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Query to get movies based on category
            String sql = "SELECT m.movie_id, m.title " +
                        "FROM movies m " +
                        "WHERE m.category_id = ? " +
                        "ORDER BY m.title";
                        
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(categoryId.trim()));
            
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                JsonObject movie = new JsonObject();
                movie.addProperty("movieId", rs.getInt("movie_id"));
                movie.addProperty("title", rs.getString("title"));
                jsonArray.add(movie);
            }
            
        } catch (NumberFormatException e) {
            JsonObject error = new JsonObject();
            error.addProperty("error", "Invalid category ID format");
            jsonArray.add(error);
            System.err.println("Invalid category ID: " + e.getMessage());
        } catch (SQLException e) {
            JsonObject error = new JsonObject();
            error.addProperty("error", "Database error: " + e.getMessage());
            jsonArray.add(error);
            e.printStackTrace();
        } catch (Exception e) {
            JsonObject error = new JsonObject();
            error.addProperty("error", "Error: " + e.getMessage());
            jsonArray.add(error);
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
            
            // Write the response
            out.write(jsonArray.toString());
            out.flush();
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Just call doGet since we're only retrieving data
        doGet(request, response);
    }
}
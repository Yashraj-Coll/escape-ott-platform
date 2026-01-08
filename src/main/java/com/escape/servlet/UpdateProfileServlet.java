package com.escape.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;
import com.escape.util.DatabaseConnection;
import com.google.gson.JsonObject;

@WebServlet("/updateProfile")
public class UpdateProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        JsonObject jsonResponse = new JsonObject();
        
        // Get user ID from session
        Integer userId = (Integer) request.getSession().getAttribute("userId");
        if (userId == null) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Not logged in");
            response.getWriter().write(jsonResponse.toString());
            return;
        }
        
        // Get form data and validate
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String mobile = request.getParameter("mobile");
        
        // Basic validation
        if (firstName == null || firstName.trim().isEmpty() ||
            lastName == null || lastName.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            mobile == null || mobile.trim().isEmpty()) {
            
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "All fields are required");
            response.getWriter().write(jsonResponse.toString());
            return;
        }

        // Email format validation
        if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Invalid email format");
            response.getWriter().write(jsonResponse.toString());
            return;
        }

        // Mobile number validation (assuming Indian format)
        if (!mobile.matches("^[6-9]\\d{9}$")) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Invalid mobile number format");
            response.getWriter().write(jsonResponse.toString());
            return;
        }
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            
            // Check if email already exists for another user
            String checkEmailSql = "SELECT id FROM users WHERE email = ? AND id != ?";
            try (PreparedStatement checkEmailStmt = conn.prepareStatement(checkEmailSql)) {
                checkEmailStmt.setString(1, email);
                checkEmailStmt.setInt(2, userId);
                ResultSet rs = checkEmailStmt.executeQuery();
                
                if (rs.next()) {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("error", "Email already in use by another account");
                    response.getWriter().write(jsonResponse.toString());
                    return;
                }
            }
            
            // Check if mobile already exists for another user
            String checkMobileSql = "SELECT id FROM users WHERE mobile_number = ? AND id != ?";
            try (PreparedStatement checkMobileStmt = conn.prepareStatement(checkMobileSql)) {
                checkMobileStmt.setString(1, mobile);
                checkMobileStmt.setInt(2, userId);
                ResultSet rs = checkMobileStmt.executeQuery();
                
                if (rs.next()) {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("error", "Mobile number already in use by another account");
                    response.getWriter().write(jsonResponse.toString());
                    return;
                }
            }
            
            // Update user profile
            String sql = "UPDATE users SET first_name = ?, last_name = ?, " +
                        "email = ?, mobile_number = ? WHERE id = ?";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, firstName.trim());
            pstmt.setString(2, lastName.trim());
            pstmt.setString(3, email.trim());
            pstmt.setString(4, mobile.trim());
            pstmt.setInt(5, userId);
            
            int rowsUpdated = pstmt.executeUpdate();
            
            if (rowsUpdated > 0) {
                // Update session attributes
                request.getSession().setAttribute("userName", firstName.trim());
                request.getSession().setAttribute("userEmail", email.trim());
                request.getSession().setAttribute("userMobile", mobile.trim());
                request.getSession().setAttribute("userLastName", lastName.trim());
                
                jsonResponse.addProperty("success", true);
                jsonResponse.addProperty("message", "Profile updated successfully");
            } else {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("error", "No changes made");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            jsonResponse.addProperty("success", false);
            if (e.getSQLState().equals("23000")) { // Duplicate entry
                jsonResponse.addProperty("error", "Email or mobile number already registered");
            } else {
                jsonResponse.addProperty("error", "Database error occurred. Please try again.");
            }
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        // Write JSON response
        response.getWriter().write(jsonResponse.toString());
    }
}
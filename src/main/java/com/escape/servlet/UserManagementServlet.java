package com.escape.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import com.escape.util.DatabaseConnection;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonArray;

@WebServlet("/api/users/*")
public class UserManagementServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        String pathInfo = request.getPathInfo();

        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                getAllUsers(response);
            } else {
                String userId = pathInfo.substring(1);
                getUserById(userId, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            sendError(response, "Error: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        String pathInfo = request.getPathInfo();

        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                addUser(request, response);
            } else if (pathInfo.endsWith("/delete")) {
                String userId = pathInfo.substring(1, pathInfo.lastIndexOf("/delete"));
                deleteUser(userId, response);
            } else if (pathInfo.endsWith("/update")) {
                String userId = pathInfo.substring(1, pathInfo.lastIndexOf("/update"));
                updateUser(userId, request, response);
            } else if (pathInfo.equals("/bulk-delete")) {
                bulkDeleteUsers(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            sendError(response, "Error: " + e.getMessage());
        }
    }

    private void getAllUsers(HttpServletResponse response) throws IOException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT * FROM users ORDER BY created_at DESC";
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();

            JsonObject result = new JsonObject();
            JsonArray users = new JsonArray();

            while (rs.next()) {
                JsonObject user = new JsonObject();
                user.addProperty("id", rs.getInt("id"));
                user.addProperty("first_name", rs.getString("first_name"));
                user.addProperty("last_name", rs.getString("last_name"));
                user.addProperty("email", rs.getString("email"));
                user.addProperty("mobile_number", rs.getString("mobile_number"));
                user.addProperty("user_role", rs.getString("user_role"));
                user.addProperty("account_status", rs.getString("account_status"));
                user.addProperty("created_at", rs.getTimestamp("created_at").toString());
                users.add(user);
            }

            result.addProperty("status", "success");
            result.add("users", users);
            response.getWriter().write(gson.toJson(result));

        } catch (SQLException e) {
            e.printStackTrace();
            sendError(response, "Database error: " + e.getMessage());
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    private void getUserById(String userId, HttpServletResponse response) throws IOException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT * FROM users WHERE id = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, userId);
            rs = stmt.executeQuery();

            JsonObject result = new JsonObject();
            if (rs.next()) {
                JsonObject user = new JsonObject();
                user.addProperty("id", rs.getInt("id"));
                user.addProperty("first_name", rs.getString("first_name"));
                user.addProperty("last_name", rs.getString("last_name"));
                user.addProperty("email", rs.getString("email"));
                user.addProperty("mobile_number", rs.getString("mobile_number"));
                user.addProperty("user_role", rs.getString("user_role"));
                user.addProperty("account_status", rs.getString("account_status"));
                
                result.addProperty("status", "success");
                result.add("user", user);
            } else {
                result.addProperty("status", "error");
                result.addProperty("message", "User not found");
            }
            
            response.getWriter().write(gson.toJson(result));
            
        } catch (SQLException e) {
            e.printStackTrace();
            sendError(response, "Database error: " + e.getMessage());
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    private void addUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            String firstName = request.getParameter("firstName");
            String lastName = request.getParameter("lastName");
            String email = request.getParameter("email");
            String mobileNumber = request.getParameter("mobileNumber");
            String password = request.getParameter("password");
            String userRole = request.getParameter("userRole");

            // Validate required fields
            if (firstName == null || lastName == null || email == null || 
                mobileNumber == null || password == null) {
                sendError(response, "All fields are required");
                return;
            }

            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            // Check for existing email/mobile
            String checkSql = "SELECT id FROM users WHERE email = ? OR mobile_number = ?";
            stmt = conn.prepareStatement(checkSql);
            stmt.setString(1, email);
            stmt.setString(2, mobileNumber);
            
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                sendError(response, "Email or mobile number already exists");
                return;
            }

            // Insert new user
            String sql = "INSERT INTO users (first_name, last_name, email, mobile_number, password, user_role) " +
                        "VALUES (?, ?, ?, ?, ?, ?)";
            stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            
            stmt.setString(1, firstName);
            stmt.setString(2, lastName);
            stmt.setString(3, email);
            stmt.setString(4, mobileNumber);
            stmt.setString(5, password);
            stmt.setString(6, userRole != null ? userRole : "user");

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                ResultSet generatedKeys = stmt.getGeneratedKeys();
                JsonObject result = new JsonObject();
                result.addProperty("status", "success");
                result.addProperty("message", "User added successfully");
                
                if (generatedKeys.next()) {
                    result.addProperty("userId", generatedKeys.getLong(1));
                }
                
                conn.commit();
                response.getWriter().write(gson.toJson(result));
            } else {
                conn.rollback();
                sendError(response, "Failed to add user");
            }

        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            if (e instanceof SQLIntegrityConstraintViolationException) {
                sendError(response, "Email or mobile number already exists");
            } else {
                sendError(response, "Database error: " + e.getMessage());
            }
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    private void updateUser(String userId, HttpServletRequest request, HttpServletResponse response) throws IOException {
        Connection conn = null;
        PreparedStatement stmt = null;
        
        try {
            String firstName = request.getParameter("firstName");
            String lastName = request.getParameter("lastName");
            String email = request.getParameter("email");
            String mobileNumber = request.getParameter("mobileNumber");
            String userRole = request.getParameter("userRole");
            String accountStatus = request.getParameter("accountStatus");

            // Validate required fields
            if (firstName == null || lastName == null || email == null || 
                mobileNumber == null || userRole == null || accountStatus == null) {
                sendError(response, "All fields are required");
                return;
            }

            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            // Check for duplicate email/mobile
            String checkSql = "SELECT id FROM users WHERE (email = ? OR mobile_number = ?) AND id != ?";
            stmt = conn.prepareStatement(checkSql);
            stmt.setString(1, email);
            stmt.setString(2, mobileNumber);
            stmt.setString(3, userId);
            
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                sendError(response, "Email or mobile number already exists");
                return;
            }

            // Update user
            String sql = "UPDATE users SET first_name=?, last_name=?, email=?, mobile_number=?, " +
                        "user_role=?, account_status=?, updated_at=CURRENT_TIMESTAMP WHERE id=?";
            stmt = conn.prepareStatement(sql);
            
            stmt.setString(1, firstName);
            stmt.setString(2, lastName);
            stmt.setString(3, email);
            stmt.setString(4, mobileNumber);
            stmt.setString(5, userRole);
            stmt.setString(6, accountStatus);
            stmt.setString(7, userId);

            int affected = stmt.executeUpdate();
            
            if (affected > 0) {
                JsonObject result = new JsonObject();
                result.addProperty("status", "success");
                result.addProperty("message", "User updated successfully");
                conn.commit();
                response.getWriter().write(gson.toJson(result));
            } else {
                conn.rollback();
                sendError(response, "User not found");
            }

        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            if (e instanceof SQLIntegrityConstraintViolationException) {
                sendError(response, "Email or mobile number already exists");
            } else {
                sendError(response, "Database error: " + e.getMessage());
            }
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    private void deleteUser(String userId, HttpServletResponse response) throws IOException {
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            // First delete from user_notifications
            String deleteNotifSql = "DELETE FROM user_notifications WHERE user_id = ?";
            stmt = conn.prepareStatement(deleteNotifSql);
            stmt.setString(1, userId);
            stmt.executeUpdate();

            // Then delete the user
            String sql = "DELETE FROM users WHERE id = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, userId);

            int affected = stmt.executeUpdate();
            
            JsonObject result = new JsonObject();
            if (affected > 0) {
                result.addProperty("status", "success");
                result.addProperty("message", "User deleted successfully");
                conn.commit();
            } else {
                result.addProperty("status", "error");
                result.addProperty("message", "User not found");
                conn.rollback();
            }
            response.getWriter().write(gson.toJson(result));

        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            sendError(response, "Database error: " + e.getMessage());
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    private void bulkDeleteUsers(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            JsonObject body = gson.fromJson(request.getReader(), JsonObject.class);
            JsonArray userIds = body.getAsJsonArray("userIds");
            
            if (userIds == null || userIds.size() == 0) {
                sendError(response, "No users selected for deletion");
                return;
            }

            List<String> ids = new ArrayList<>();
            userIds.forEach(id -> ids.add(id.getAsString()));

            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            String sql = "DELETE FROM users WHERE id IN (" + 
                       String.join(",", Collections.nCopies(ids.size(), "?")) + ")";
            
            stmt = conn.prepareStatement(sql);
            for (int i = 0; i < ids.size(); i++) {
                stmt.setString(i + 1, ids.get(i));
            }

            int affected = stmt.executeUpdate();
            JsonObject result = new JsonObject();
            
            if (affected > 0) {
                result.addProperty("status", "success");
                result.addProperty("message", affected + " users deleted successfully");
                conn.commit();
            } else {
                result.addProperty("status", "error");
                result.addProperty("message", "No users were deleted");
                conn.rollback();
            }
            response.getWriter().write(gson.toJson(result));

        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            sendError(response, "Database error: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            sendError(response, "Error processing request: " + e.getMessage());
        } finally {
            try {
                if (stmt != null) stmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    private void sendError(HttpServletResponse response, String message) throws IOException {
        JsonObject error = new JsonObject();
        error.addProperty("status", "error");
        error.addProperty("message", message);
        response.getWriter().write(gson.toJson(error));
    }

    private void sendSuccess(HttpServletResponse response, String message) throws IOException {
        JsonObject success = new JsonObject();
        success.addProperty("status", "success");
        success.addProperty("message", message);
        response.getWriter().write(gson.toJson(success));
    }
}
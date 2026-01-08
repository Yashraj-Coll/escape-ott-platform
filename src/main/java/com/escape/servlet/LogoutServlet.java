package com.escape.servlet;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import com.escape.util.DatabaseConnection;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
            
        HttpSession session = request.getSession(false);
        if (session != null) {
            Integer userId = (Integer) session.getAttribute("userId");
            if (userId != null) {
                try (Connection conn = DatabaseConnection.getConnection()) {
                    // Clear remember token
                    clearRememberToken(conn, userId);
                    
                    // Log the logout attempt
                    String sql = "INSERT INTO login_attempts (user_id, success, ip_address, error_message, attempt_time) VALUES (?, true, ?, 'User logged out', CURRENT_TIMESTAMP)";
                    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                        stmt.setInt(1, userId);
                        stmt.setString(2, request.getRemoteAddr());
                        stmt.executeUpdate();
                    }
                    
                    // Update last_login timestamp
                    updateLastLogin(conn, userId);
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            session.invalidate();
        }
        
        // Remove all auth-related cookies
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (cookie.getName().equals("userEmail") || 
                    cookie.getName().equals("rememberToken") || 
                    cookie.getName().equals("deviceId")) {
                    cookie.setMaxAge(0);
                    cookie.setPath("/");
                    response.addCookie(cookie);
                }
            }
        }
        
        response.sendRedirect("login.jsp");
    }
    
    private void clearRememberToken(Connection conn, int userId) {
        String sql = "UPDATE users SET remember_token = NULL WHERE id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    private void updateLastLogin(Connection conn, int userId) {
        String sql = "UPDATE users SET last_login = CURRENT_TIMESTAMP WHERE id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
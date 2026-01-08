package com.escape.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.stream.Collectors;
import com.escape.util.DatabaseConnection;
import com.escape.util.SubscriptionEmailSender;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

@WebServlet("/changePlan")
public class ChangePlanServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Plan prices in rupees
    private static final int BASIC_PRICE = 199;
    private static final int STANDARD_PRICE = 499;
    private static final int PREMIUM_PRICE = 699;
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.setContentType("application/json");
        JsonObject jsonResponse = new JsonObject();
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", "Please login to continue");
            response.getWriter().write(jsonResponse.toString());
            return;
        }
        
        Connection conn = null;
        
        try {
            // Read JSON data from request
            String requestBody = request.getReader().lines().collect(Collectors.joining());
            JsonObject paymentData = JsonParser.parseString(requestBody).getAsJsonObject();
            
            int userId = (int) session.getAttribute("userId");
            String userName = (String) session.getAttribute("userName");
            String userEmail = (String) session.getAttribute("userEmail");
            String newPlan = paymentData.get("plan").getAsString();
            double amount = paymentData.get("amount").getAsDouble();
            String transactionId = paymentData.get("transactionId").getAsString();
            
            // Validate plan and amount
            if (!validatePlanAndAmount(newPlan, amount)) {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("error", "Invalid plan or amount");
                response.getWriter().write(jsonResponse.toString());
                return;
            }
            
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);
            
            try {
                // Get current plan
                String currentPlan = getCurrentPlan(conn, userId);
                
                // If same plan, return error
                if (currentPlan.equals(newPlan)) {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("error", "Already subscribed to this plan");
                    response.getWriter().write(jsonResponse.toString());
                    return;
                }
                
                // Deactivate current subscription if exists
                deactivateCurrentSubscription(conn, userId);
                
                // Create new subscription
                LocalDateTime now = LocalDateTime.now();
                LocalDateTime endDate = now.plusMonths(1);
                createNewSubscription(conn, userId, newPlan, transactionId, amount);
                
                // Update user details
                updateUserDetails(conn, userId, newPlan);
                
                // Record payment transaction
                recordPaymentTransaction(conn, transactionId, userId, amount, newPlan);
                
                // Record transaction history
                recordTransactionHistory(conn, transactionId, "SUCCESS", "Plan changed successfully");
                
                // Record subscription history
                recordSubscriptionHistory(conn, userId, "CHANGE_PLAN", currentPlan, newPlan, 
                    transactionId, amount, now.plusMonths(1));
                
                // Get next billing date for email
                LocalDateTime nextBillingDate = LocalDateTime.now().plusMonths(1);
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd MMMM yyyy");
                String formattedNextBillingDate = nextBillingDate.format(formatter);

                // Commit the database changes
                conn.commit();
                System.out.println("Database transaction committed");

                // Update session
                session.setAttribute("subscriptionPlan", newPlan);
                session.setAttribute("userRole", newPlan.equals("Free") ? "user" : "premium");
                System.out.println("Session attributes updated");

                // Send email in a separate thread to not block the response
                new Thread(() -> {
                    try {
                        SubscriptionEmailSender.sendSubscriptionEmail(
                            userEmail,
                            userName,
                            newPlan,
                            amount,
                            transactionId,
                            formattedNextBillingDate
                        );
                    } catch (Exception e) {
                        System.err.println("Error sending email: " + e.getMessage());
                        e.printStackTrace();
                    }
                }).start();
                
                jsonResponse.addProperty("success", true);
                jsonResponse.addProperty("message", "Plan changed successfully");
                
            } catch (Exception e) {
                conn.rollback();
                // Record failed transaction in history
                try {
                    recordTransactionHistory(conn, transactionId, "FAILED", e.getMessage());
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
                throw e;
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("error", e.getMessage());
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        
        response.getWriter().write(jsonResponse.toString());
    }
    
    private boolean validatePlanAndAmount(String plan, double amount) {
        if (!isValidPlan(plan)) return false;
        
        return switch(plan) {
            case "Basic" -> amount == BASIC_PRICE;
            case "Standard" -> amount == STANDARD_PRICE;
            case "Premium" -> amount == PREMIUM_PRICE;
            case "Free" -> amount == 0;
            default -> false;
        };
    }
    
    private boolean isValidPlan(String plan) {
        if (plan == null) return false;
        return plan.equals("Free") || plan.equals("Basic") || 
               plan.equals("Standard") || plan.equals("Premium");
    }
    
    private String getCurrentPlan(Connection conn, int userId) throws SQLException {
        String sql = """
            SELECT COALESCE(
                (SELECT plan_type 
                 FROM user_subscriptions 
                 WHERE user_id = ? 
                 AND status = 'ACTIVE' 
                 AND end_date > CURRENT_TIMESTAMP
                 ORDER BY created_at DESC 
                 LIMIT 1),
                'Free'
            ) as current_plan
        """;
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            return rs.next() ? rs.getString("current_plan") : "Free";
        }
    }
    
    private void deactivateCurrentSubscription(Connection conn, int userId) throws SQLException {
        String sql = """
            UPDATE user_subscriptions 
            SET status = 'INACTIVE',
                end_date = CURRENT_TIMESTAMP,
                updated_at = CURRENT_TIMESTAMP 
            WHERE user_id = ? 
            AND status = 'ACTIVE'
        """;
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.executeUpdate();
        }
    }
    
    private void createNewSubscription(Connection conn, int userId, String plan, 
                                     String transactionId, double amount) throws SQLException {
        String sql = """
            INSERT INTO user_subscriptions (
                user_id, plan_type, status, start_date, end_date,
                next_billing_date, last_payment_date, last_payment_amount,
                last_transaction_id
            ) VALUES (?, ?, 'ACTIVE', CURRENT_TIMESTAMP, 
                DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 1 MONTH),
                DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 1 MONTH),
                CURRENT_TIMESTAMP, ?, ?)
        """;
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setString(2, plan);
            pstmt.setDouble(3, amount);
            pstmt.setString(4, transactionId);
            pstmt.executeUpdate();
        }
    }
    
    private void updateUserDetails(Connection conn, int userId, String plan) throws SQLException {
        String sql = """
            UPDATE users 
            SET subscription_plan = ?,
                updated_at = CURRENT_TIMESTAMP 
            WHERE id = ?
        """;
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, plan);
            pstmt.setInt(2, userId);
            pstmt.executeUpdate();
        }
    }
    
    private void recordPaymentTransaction(Connection conn, String transactionId, int userId,
                                        double amount, String plan) throws SQLException {
        String sql = """
            INSERT INTO payment_transactions (
                transaction_id, user_id, amount, payment_method, 
                plan_type, status, created_at
            ) VALUES (?, ?, ?, 'razorpay', ?, 'SUCCESS', CURRENT_TIMESTAMP)
        """;
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, transactionId);
            pstmt.setInt(2, userId);
            pstmt.setDouble(3, amount);
            pstmt.setString(4, plan);
            pstmt.executeUpdate();
        }
    }

    private void recordTransactionHistory(Connection conn, String transactionId, 
                                        String status, String message) throws SQLException {
        String sql = """
            INSERT INTO transaction_history (
                transaction_id, status, message, created_at
            ) VALUES (?, ?, ?, CURRENT_TIMESTAMP)
        """;
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, transactionId);
            pstmt.setString(2, status);
            pstmt.setString(3, message);
            pstmt.executeUpdate();
        }
    }
    
    private void recordSubscriptionHistory(Connection conn, int userId, String actionType,
                                         String oldPlan, String newPlan, String transactionId,
                                         double amountPaid, LocalDateTime nextBillingDate) 
                                         throws SQLException {
        String sql = """
            INSERT INTO subscription_history (
                user_id, action_type, old_plan, new_plan, transaction_id,
                next_billing_date, amount_paid, action_date
            ) VALUES (?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
        """;
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setString(2, actionType);
            pstmt.setString(3, oldPlan);
            pstmt.setString(4, newPlan);
            pstmt.setString(5, transactionId);
            pstmt.setObject(6, nextBillingDate);
            pstmt.setDouble(7, amountPaid);
            pstmt.executeUpdate();
        }
    }
}
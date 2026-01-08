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
import java.util.UUID;
import java.util.stream.Collectors;
import com.escape.util.DatabaseConnection;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

@WebServlet("/processPayment")
public class ProcessPaymentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
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
        String transactionId = null;
        
        try {
            // Parse JSON request
            String requestBody = request.getReader().lines().collect(Collectors.joining());
            JsonObject paymentData = JsonParser.parseString(requestBody).getAsJsonObject();
            int userId = (int) session.getAttribute("userId");
            String plan = paymentData.get("plan").getAsString();
            double amount = paymentData.get("amount").getAsDouble();
            String paymentMethod = paymentData.get("paymentMethod").getAsString();
            
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);
            
            // Check if transaction ID exists in request
            if (paymentData.has("transactionId")) {
                transactionId = paymentData.get("transactionId").getAsString();
                
                // Verify if transaction already exists and is successful
                String checkSql = "SELECT status FROM payment_transactions WHERE transaction_id = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(checkSql)) {
                    pstmt.setString(1, transactionId);
                    ResultSet rs = pstmt.executeQuery();
                    if (rs.next() && "SUCCESS".equals(rs.getString("status"))) {
                        jsonResponse.addProperty("success", true);
                        jsonResponse.addProperty("transactionId", transactionId);
                        jsonResponse.addProperty("message", "Payment already processed");
                        response.getWriter().write(jsonResponse.toString());
                        return;
                    }
                }
            } else {
                transactionId = generateTransactionId();
            }
            
            // Lock user record
            String lockSql = "SELECT id FROM users WHERE id = ? FOR UPDATE";
            try (PreparedStatement pstmt = conn.prepareStatement(lockSql)) {
                pstmt.setInt(1, userId);
                pstmt.executeQuery();
            }
            
            // Record payment attempt
            recordPaymentTransaction(conn, transactionId, userId, amount, paymentMethod, plan, paymentData);
            
            // Process payment based on method
            boolean paymentSuccess = processPaymentByMethod(paymentMethod, paymentData);
            
            if (paymentSuccess) {
                updateTransactionStatus(conn, transactionId, "SUCCESS", null);
                recordTransactionHistory(conn, transactionId, "SUCCESS", "Payment processed successfully");
                conn.commit();
                
                jsonResponse.addProperty("success", true);
                jsonResponse.addProperty("transactionId", transactionId);
                jsonResponse.addProperty("message", "Payment processed successfully");
            } else {
                throw new Exception("Payment processing failed");
            }
            
        } catch (Exception e) {
            try {
                if (conn != null) {
                    conn.rollback();
                    
                    if (transactionId != null) {
                        updateTransactionStatus(conn, transactionId, "FAILED", e.getMessage());
                        recordTransactionHistory(conn, transactionId, "FAILED", e.getMessage());
                        conn.commit();
                    }
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            
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
    
    private String generateTransactionId() {
        return String.format("TXN_%s_%s",
            LocalDateTime.now().format(java.time.format.DateTimeFormatter.BASIC_ISO_DATE),
            UUID.randomUUID().toString().substring(0, 8).toUpperCase()
        );
    }
    
    private void recordPaymentTransaction(Connection conn, String transactionId, int userId,
                                        double amount, String paymentMethod, String plan,
                                        JsonObject paymentData) throws SQLException {
        String sql = """
            INSERT INTO payment_transactions 
            (transaction_id, user_id, amount, payment_method, plan_type, status,
             card_number, card_type, upi_id, bank_name, wallet_name, created_at)
            VALUES (?, ?, ?, ?, ?, 'INITIATED', ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
        """;
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, transactionId);
            pstmt.setInt(2, userId);
            pstmt.setDouble(3, amount);
            pstmt.setString(4, paymentMethod);
            pstmt.setString(5, plan);
            
            // Set payment method specific details
            switch(paymentMethod) {
                case "card":
                    pstmt.setString(6, maskCardNumber(paymentData.get("cardNumber").getAsString()));
                    pstmt.setString(7, getCardType(paymentData.get("cardNumber").getAsString()));
                    pstmt.setNull(8, java.sql.Types.VARCHAR);
                    pstmt.setNull(9, java.sql.Types.VARCHAR);
                    pstmt.setNull(10, java.sql.Types.VARCHAR);
                    break;
                    
                case "upi":
                    pstmt.setNull(6, java.sql.Types.VARCHAR);
                    pstmt.setNull(7, java.sql.Types.VARCHAR);
                    pstmt.setString(8, paymentData.get("upiId").getAsString());
                    pstmt.setNull(9, java.sql.Types.VARCHAR);
                    pstmt.setNull(10, java.sql.Types.VARCHAR);
                    break;
                    
                case "netbanking":
                    pstmt.setNull(6, java.sql.Types.VARCHAR);
                    pstmt.setNull(7, java.sql.Types.VARCHAR);
                    pstmt.setNull(8, java.sql.Types.VARCHAR);
                    pstmt.setString(9, paymentData.get("bank").getAsString());
                    pstmt.setNull(10, java.sql.Types.VARCHAR);
                    break;
                    
                case "wallet":
                    pstmt.setNull(6, java.sql.Types.VARCHAR);
                    pstmt.setNull(7, java.sql.Types.VARCHAR);
                    pstmt.setNull(8, java.sql.Types.VARCHAR);
                    pstmt.setNull(9, java.sql.Types.VARCHAR);
                    pstmt.setString(10, paymentData.get("wallet").getAsString());
                    break;
                    
                default:
                    pstmt.setNull(6, java.sql.Types.VARCHAR);
                    pstmt.setNull(7, java.sql.Types.VARCHAR);
                    pstmt.setNull(8, java.sql.Types.VARCHAR);
                    pstmt.setNull(9, java.sql.Types.VARCHAR);
                    pstmt.setNull(10, java.sql.Types.VARCHAR);
            }
            
            pstmt.executeUpdate();
        }
    }
    
    private void updateTransactionStatus(Connection conn, String transactionId,
                                       String status, String errorMessage) throws SQLException {
        String sql = """
            UPDATE payment_transactions 
            SET status = ?,
                error_message = ?,
                updated_at = CURRENT_TIMESTAMP 
            WHERE transaction_id = ?
        """;
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, status);
            pstmt.setString(2, errorMessage);
            pstmt.setString(3, transactionId);
            pstmt.executeUpdate();
        }
    }
    
    private void recordTransactionHistory(Connection conn, String transactionId,
                                        String status, String message) throws SQLException {
        String sql = """
            INSERT INTO transaction_history 
            (transaction_id, status, message, created_at)
            VALUES (?, ?, ?, CURRENT_TIMESTAMP)
        """;
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, transactionId);
            pstmt.setString(2, status);
            pstmt.setString(3, message);
            pstmt.executeUpdate();
        }
    }
    
    private boolean processPaymentByMethod(String paymentMethod, JsonObject paymentData) {
        try {
            // Simulate payment processing delay
            Thread.sleep(1500);
            
            switch(paymentMethod) {
                case "card":
                    return validateCardPayment(paymentData);
                case "upi":
                    return validateUPIPayment(paymentData);
                case "netbanking":
                    return validateNetbankingPayment(paymentData);
                case "wallet":
                    return validateWalletPayment(paymentData);
                default:
                    return false;
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            return false;
        }
    }
    
    private boolean validateCardPayment(JsonObject paymentData) {
        String cardNumber = paymentData.get("cardNumber").getAsString();
        String expiry = paymentData.get("cardExpiry").getAsString();
        String cvv = paymentData.get("cardCvv").getAsString();
        
        return validateCardNumber(cardNumber) && 
               validateExpiry(expiry) && 
               validateCVV(cvv);
    }
    
    private boolean validateUPIPayment(JsonObject paymentData) {
        String upiId = paymentData.get("upiId").getAsString();
        return validateUPIId(upiId);
    }
    
    private boolean validateNetbankingPayment(JsonObject paymentData) {
        return paymentData.has("bank") && 
               !paymentData.get("bank").getAsString().trim().isEmpty();
    }
    
    private boolean validateWalletPayment(JsonObject paymentData) {
        return paymentData.has("wallet") && 
               !paymentData.get("wallet").getAsString().trim().isEmpty();
    }
    
    private boolean validateCardNumber(String cardNumber) {
        return cardNumber.replaceAll("\\s", "").matches("\\d{16}");
    }
    
    private boolean validateExpiry(String expiry) {
        if (!expiry.matches("\\d{2}/\\d{2}")) return false;
        
        String[] parts = expiry.split("/");
        int month = Integer.parseInt(parts[0]);
        int year = Integer.parseInt(parts[1]) + 2000;
        
        if (month < 1 || month > 12) return false;
        
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime cardExpiry = LocalDateTime.of(year, month, 1, 0, 0);
        
        return cardExpiry.isAfter(now);
    }
    
    private boolean validateCVV(String cvv) {
        return cvv.matches("\\d{3}");
    }
    
    private boolean validateUPIId(String upiId) {
        return upiId.matches("[a-zA-Z0-9._-]+@[a-zA-Z]{3,}");
    }
    
    private String maskCardNumber(String cardNumber) {
        String cleanNumber = cardNumber.replaceAll("\\s", "");
        return "**** **** **** " + cleanNumber.substring(12);
    }
    
    private String getCardType(String cardNumber) {
        String firstDigit = cardNumber.replaceAll("\\s", "").substring(0, 1);
        return switch(firstDigit) {
            case "4" -> "VISA";
            case "5" -> "MASTERCARD";
            case "3" -> "AMEX";
            default -> "UNKNOWN";
        };
    }
}
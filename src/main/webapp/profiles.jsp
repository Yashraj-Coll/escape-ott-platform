<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.escape.util.DatabaseConnection" %>
<%
    // Get user information from session
    String userName = (String) session.getAttribute("userName");
    int userId = 0;
    
    if (userName == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    if (session.getAttribute("userId") != null) {
        userId = (int) session.getAttribute("userId");
    }

    // Get user details from database
    String firstName = "";
    String lastName = "";
    String email = "";
    String mobile = "";
    String memberSince = "";
    Connection conn = null;
    
    try {
        conn = DatabaseConnection.getConnection();
        
        String userSql = "SELECT first_name, last_name, email, mobile_number, " +
                        "DATE_FORMAT(created_at, '%d %M %Y') as member_since " +
                        "FROM users WHERE id = ?";
        
        try (PreparedStatement pstmt = conn.prepareStatement(userSql)) {
            pstmt.setInt(1, userId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                firstName = rs.getString("first_name");
                lastName = rs.getString("last_name");
                email = rs.getString("email");
                mobile = rs.getString("mobile_number");
                memberSince = rs.getString("member_since");
            }
        }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile Settings - Escape</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f3f3f3;
            color: #333;
        }
        
        .account-nav {
            background: white;
            border-right: 1px solid #ddd;
            height: 100vh;
            position: fixed;
            width: 250px;
            padding: 20px 0;
        }
        
        .account-nav .nav-link {
            color: #333;
            padding: 12px 24px;
            display: flex;
            align-items: center;
            gap: 12px;
            transition: all 0.3s ease;
        }
        
        .account-nav .nav-link:hover {
            background-color: #f8f8f8;
            color: #e50914;
        }
        
        .account-nav .nav-link.active {
            background-color: #f3f3f3;
            color: #e50914;
            font-weight: 500;
        }

        .account-nav .nav-link i {
            width: 20px;
            text-align: center;
        }
        
        .account-content {
            margin-left: 250px;
            padding: 40px;
        }
        
        .back-button {
            color: #333;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 24px;
            font-weight: 500;
            transition: color 0.3s ease;
        }
        
        .back-button:hover {
            color: #e50914;
        }

        .section-card {
            background: white;
            border-radius: 12px;
            padding: 32px;
            margin-bottom: 24px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.08);
        }

        .section-title {
            color: #111;
            font-size: 2rem;
            font-weight: 600;
            margin-bottom: 24px;
        }

        .subsection-title {
            color: #333;
            font-size: 1.2rem;
            font-weight: 500;
            margin-bottom: 20px;
            padding-bottom: 12px;
            border-bottom: 2px solid #f0f0f0;
        }

        .membership-badge {
            background: #7b3dbd;
            color: white;
            padding: 6px 16px;
            border-radius: 6px;
            display: inline-block;
            margin-bottom: 16px;
            font-size: 0.9rem;
            font-weight: 500;
        }

        .form-label {
            font-weight: 500;
            color: #444;
            margin-bottom: 8px;
        }

        .form-control {
            border: 1px solid #ddd;
            border-radius: 6px;
            padding: 12px;
            font-size: 0.95rem;
        }

        .form-control:focus {
            border-color: #e50914;
            box-shadow: 0 0 0 0.2rem rgba(229, 9, 20, 0.25);
        }

        .btn-save {
            background: #e50914;
            color: white;
            border: none;
            padding: 12px 32px;
            border-radius: 6px;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .btn-save:hover {
            background: #cc0812;
            transform: translateY(-2px);
            color: white;
        }

        .btn-cancel {
            background: #6c757d;
            color: white;
            border: none;
            padding: 12px 32px;
            border-radius: 6px;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .btn-cancel:hover {
            background: #5a6268;
            transform: translateY(-2px);
            color: white;
        }

        .form-group {
            margin-bottom: 24px;
        }

        .success-message {
            display: none;
            background-color: #d4edda;
            color: #155724;
            padding: 12px;
            border-radius: 6px;
            margin-bottom: 20px;
            animation: fadeIn 0.3s ease-in-out;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @media (max-width: 768px) {
            .account-nav {
                width: 100%;
                height: auto;
                position: relative;
                margin-bottom: 20px;
            }
            
            .account-content {
                margin-left: 0;
                padding: 20px;
            }
            
            .section-card {
                padding: 20px;
            }
        }
    </style>
</head>
<body>
    <div class="account-nav">
        <a href="index.jsp" class="back-button px-4 py-2">
            <i class="fas fa-arrow-left"></i>
            Back to Escape
        </a>
        <div class="nav flex-column nav-pills">
            <a class="nav-link" href="account.jsp">
                <i class="fas fa-home"></i>
                Overview
            </a>
            <a class="nav-link" href="membership.jsp">
                <i class="fas fa-credit-card"></i>
                Membership
            </a>
            <a class="nav-link" href="security.jsp">
                <i class="fas fa-shield-alt"></i>
                Security
            </a>
            <a class="nav-link" href="devices.jsp">
                <i class="fas fa-tablet-alt"></i>
                Devices
            </a>
            <a class="nav-link active" href="profiles.jsp">
                <i class="fas fa-user-circle"></i>
                Profiles
            </a>
        </div>
    </div>

    <div class="account-content">
        <h1 class="section-title">Profile Settings</h1>
        
        <div class="section-card">
            <div class="membership-badge">Member since <%= memberSince != null ? memberSince : "N/A" %></div>
            
            <div id="successMessage" class="success-message">
                Profile updated successfully!
            </div>

            <form id="profileForm" action="updateProfile" method="POST">
                <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                            <label class="form-label" for="firstName">First Name</label>
                            <input type="text" class="form-control" id="firstName" name="firstName" 
                                   value="<%= firstName %>" required>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                            <label class="form-label" for="lastName">Last Name</label>
                            <input type="text" class="form-control" id="lastName" name="lastName" 
                                   value="<%= lastName %>" required>
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label" for="email">Email Address</label>
                    <input type="email" class="form-control" id="email" name="email" 
                           value="<%= email %>" required>
                </div>

                <div class="form-group">
                    <label class="form-label" for="mobile">Mobile Number</label>
                    <input type="tel" class="form-control" id="mobile" name="mobile" 
                           value="<%= mobile %>" required>
                </div>

                <div class="d-flex gap-3 mt-4">
                    <button type="submit" class="btn-save">Save Changes</button>
                    <button type="reset" class="btn-cancel">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.getElementById('profileForm').addEventListener('submit', function(e) {
            e.preventDefault();
            
            // Create FormData object
            const formData = new FormData(this);
            
            // Send AJAX request
            fetch('updateProfile', {
                method: 'POST',
                body: new URLSearchParams(formData)
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // Show success message
                    const successMessage = document.getElementById('successMessage');
                    successMessage.style.display = 'block';
                    
                    // Hide message after 3 seconds
                    setTimeout(() => {
                        successMessage.style.display = 'none';
                    }, 3000);

                    // Update the session data by reloading the page after a short delay
                    setTimeout(() => {
                        window.location.reload();
                    }, 1000);
                } else {
                    alert(data.error || 'Failed to update profile. Please try again.');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('An error occurred. Please try again.');
            });
        });

        // Reset form handler
        document.querySelector('.btn-cancel').addEventListener('click', function(e) {
            e.preventDefault();
            if (confirm('Are you sure you want to cancel? All changes will be lost.')) {
                document.getElementById('profileForm').reset();
            }
        });
    </script>
</body>
</html>
<%
    } catch(SQLException e) {
        e.printStackTrace();
        out.println("<script>alert('Failed to load profile details. Please try again.');</script>");
        return;
    } finally {
        if(conn != null) {
            try { conn.close(); } catch(SQLException e) { }
        }
    }
%>
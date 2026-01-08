<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.escape.util.DatabaseConnection" %>
<%
    // Get user information from session
    String userName = (String) session.getAttribute("userName");
    String userEmail = (String) session.getAttribute("userEmail");
    String userMobile = (String) session.getAttribute("userMobile");
    String userLastName = (String) session.getAttribute("userLastName");
    String memberSince = null;
    String subscriptionPlan = (String) session.getAttribute("subscriptionPlan");
    
    if (userName == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Get member since date and subscription plan from database
    try (Connection conn = DatabaseConnection.getConnection()) {
        String sql = "SELECT DATE_FORMAT(created_at, '%M %Y') as signup_date, " +
                    "COALESCE(subscription_plan, 'Free') as plan " +
                    "FROM users WHERE email = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userEmail);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    memberSince = rs.getString("signup_date");
                    // Only update subscriptionPlan if it's null (not set in session)
                    if (subscriptionPlan == null) {
                        subscriptionPlan = rs.getString("plan");
                    }
                }
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
        memberSince = "Unknown";
        if (subscriptionPlan == null) {
            subscriptionPlan = "Free";
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Account Settings - Escape</title>
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
        }
        
        .account-nav .nav-link.active {
            background-color: #f3f3f3;
            color: #e50914;
        }
        
        .account-content {
            margin-left: 250px;
            padding: 40px;
        }
        
        .section-card {
            background: white;
            border-radius: 8px;
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        .membership-badge {
            background: #7b3dbd;
            color: white;
            padding: 8px 16px;
            border-radius: 4px;
            display: inline-block;
            margin-bottom: 16px;
        }
        
        .back-button {
            color: #333;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 24px;
        }
        
        .back-button:hover {
            color: #e50914;
        }
        
        .action-link {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 16px;
            border-bottom: 1px solid #ddd;
            color: #333;
            text-decoration: none;
        }
        
        .action-link:last-child {
            border-bottom: none;
        }
        
        .action-link:hover {
            background-color: #f8f8f8;
        }
        
        .text-muted-custom {
            color: #737373;
            font-size: 0.9rem;
        }

        /* Success Animation Styles */
        .success-checkmark {
            width: 80px;
            height: 80px;
            margin: 0 auto;
            margin-bottom: 20px;
        }

        .check-icon {
            width: 80px;
            height: 80px;
            position: relative;
            background-color: #ffffff;
            border-radius: 50%;
        }

        .check-icon::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%) rotate(45deg);
            width: 14px;
            height: 28px;
            border-bottom: 3px solid #28a745;
            border-right: 3px solid #28a745;
        }

        .success-message {
            text-align: center;
            color: #28a745;
            margin-bottom: 20px;
        }

        /* Modal Animation */
        .modal.fade .modal-dialog {
            transition: transform 0.3s ease-out;
            transform: scale(0.9);
        }

        .modal.show .modal-dialog {
            transform: scale(1);
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
            <a class="nav-link active" href="#overview">
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
            <a class="nav-link" href="profiles.jsp">
                <i class="fas fa-user-circle"></i>
                Profiles
            </a>
        </div>
    </div>

    <div class="account-content">
        <h1 class="mb-4">Account</h1>
        
        <div class="section-card">
            <div class="membership-badge">Member since <%= memberSince %></div>
            <h2 class="mb-4">Membership details</h2>
            
            <div class="row mb-4">
                <div class="col-md-3">
                    <strong>Name</strong>
                </div>
                <div class="col-md-9">
                    <%= userName %> <%= userLastName %>
                </div>
            </div>
            
            <div class="row mb-4">
                <div class="col-md-3">
                    <strong>Email</strong>
                </div>
                <div class="col-md-9">
                    <%= userEmail %>
                </div>
            </div>
            
            <div class="row mb-4">
                <div class="col-md-3">
                    <strong>Mobile</strong>
                </div>
                <div class="col-md-9">
                    <%= userMobile %>
                </div>
            </div>
            
            <div class="row mb-4">
                <div class="col-md-3">
                    <strong>Plan</strong>
                </div>
                <div class="col-md-9 <%= subscriptionPlan.equals("Free") ? "text-muted" : "" %>">
                    <%= subscriptionPlan %>
                </div>
            </div>
        </div>

        <div class="section-card">
            <h3 class="mb-4">Quick links</h3>
            
            <a href="changePlan.jsp" class="action-link">
                <div>
                    <div class="d-flex align-items-center gap-2">
                        <i class="fas fa-film"></i>
                        <span>Change plan</span>
                    </div>
                </div>
                <i class="fas fa-chevron-right"></i>
            </a>
            
            <a href="updatePassword.jsp" class="action-link">
                <div>
                    <div class="d-flex align-items-center gap-2">
                        <i class="fas fa-lock"></i>
                        <span>Update password</span>
                    </div>
                </div>
                <i class="fas fa-chevron-right"></i>
            </a>
            
            <a href="deviceManagement.jsp" class="action-link">
                <div>
                    <div class="d-flex align-items-center gap-2">
                        <i class="fas fa-tablet-alt"></i>
                        <span>Manage devices</span>
                    </div>
                </div>
                <i class="fas fa-chevron-right"></i>
            </a>
            
            <a href="#" class="action-link" data-bs-toggle="modal" data-bs-target="#deleteAccountModal">
                <div>
                    <div class="d-flex align-items-center gap-2">
                        <i class="fas fa-trash-alt"></i>
                        <span>Delete account</span>
                    </div>
                </div>
                <i class="fas fa-chevron-right"></i>
            </a>
        </div>
    </div>

    <!-- Delete Account Modal -->
    <div class="modal fade" id="deleteAccountModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Delete Account</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to delete your account? This action cannot be undone.</p>
                    <form id="deleteAccountForm">
                        <div class="mb-3">
                            <label for="password" class="form-label">Enter your password to confirm</label>
                            <input type="password" class="form-control" id="password" name="password" required>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" form="deleteAccountForm" class="btn btn-danger">Delete Account</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Success Modal -->
    <div class="modal fade" id="successModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-body text-center p-4">
                    <div class="success-checkmark">
                        <div class="check-icon"></div>
                    </div>
                    <div class="success-message">
                        <h5 class="mb-3">Action Completed Successfully</h5>
                        <p id="successMessage"></p>
                    </div>
                    <button type="button" class="btn btn-success" data-bs-dismiss="modal">Continue</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Function to show success modal
        function showSuccessModal(message, callback) {
            const successModal = new bootstrap.Modal(document.getElementById('successModal'));
            document.getElementById('successMessage').textContent = message;
            
            const modalElement = document.getElementById('successModal');
            modalElement.addEventListener('hidden.bs.modal', function() {
                if (callback) callback();
            });
            
            successModal.show();
        }

        document.getElementById('deleteAccountForm').onsubmit = function(e) {
            e.preventDefault();
            const deleteAccountModal = bootstrap.Modal.getInstance(document.getElementById('deleteAccountModal'));
            
            fetch('deleteAccount', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'password=' + encodeURIComponent(document.getElementById('password').value)
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok: ' + response.statusText);
                }
                return response.json();
            })
            .then(data => {
                if (data.success) {
                    deleteAccountModal.hide(); // Hide the delete account modal
                    showSuccessModal(data.message, () => {
                        window.location.href = 'login.jsp';
                    });
                } else {
                    alert(data.error || 'An error occurred while deleting the account');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('An error occurred while processing your request. Please try again later.');
            });
        };

        // Handle plan updates from other pages
        window.addEventListener('load', function() {
            const urlParams = new URLSearchParams(window.location.search);
            const successMessage = urlParams.get('success');
            if (successMessage) {
                showSuccessModal(decodeURIComponent(successMessage));
                window.history.replaceState({}, document.title, window.location.pathname);
            }
        });

        // Automatically update plan display when changed
        function updatePlanDisplay(newPlan) {
            const planDisplay = document.querySelector('.col-md-9:last-child');
            if (planDisplay) {
                planDisplay.textContent = newPlan;
            }
        }

        // Handle success messages from different actions
        window.handleActionSuccess = function(action, message) {
            switch(action) {
                case 'plan_update':
                    updatePlanDisplay(message);
                    showSuccessModal('Your plan has been updated successfully.');
                    break;
                case 'password_update':
                    showSuccessModal('Your password has been updated successfully.');
                    break;
                case 'profile_update':
                    showSuccessModal('Your profile has been updated successfully.');
                    break;
                default:
                    showSuccessModal(message || 'Action completed successfully.');
            }
        };

        // Handle form submissions
        document.querySelectorAll('form').forEach(form => {
            form.addEventListener('submit', function(e) {
                if (this.dataset.prevent) {
                    e.preventDefault();
                }
            });
        });
        // Show notification function
        function showNotification(message, type = 'success') {
            const notification = document.createElement('div');
            notification.className = `alert alert-${type} position-fixed top-0 end-0 m-3`;
            notification.style.zIndex = '9999';
            notification.innerHTML = message;
            
            document.body.appendChild(notification);
            
            setTimeout(() => {
                notification.remove();
            }, 3000);
        }
    </script>
</body>
</html>
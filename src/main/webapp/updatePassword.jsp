<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    Integer userId = (Integer) userSession.getAttribute("userId");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Update Password - Escape</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f3f3f3;
            color: #333;
        }
        
        .main-container {
            max-width: 600px;
            margin: 40px auto;
            padding: 0 20px;
        }
        
        .password-card {
            background: white;
            border-radius: 8px;
            padding: 24px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
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
        
        .form-control:focus {
            border-color: #e50914;
            box-shadow: 0 0 0 0.2rem rgba(229, 9, 20, 0.25);
        }
        
        .password-strength {
            margin-top: 5px;
            font-size: 0.9rem;
        }
        
        .strength-weak { color: #dc3545; }
        .strength-medium { color: #ffc107; }
        .strength-strong { color: #28a745; }
        
        .password-requirements {
            font-size: 0.9rem;
            color: #666;
            margin-top: 20px;
        }
        
        .password-requirements ul {
            padding-left: 20px;
            margin-top: 10px;
        }
        
        .password-toggle {
            cursor: pointer;
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            color: #666;
        }
        
        .form-floating {
            position: relative;
        }
        
        .btn-update {
            background-color: #e50914;
            border: none;
            color: white;
            padding: 12px 24px;
            font-weight: 600;
        }
        
        .btn-update:hover {
            background-color: #bd070f;
            color: white;
        }
    </style>
</head>
<body>
    <div class="main-container">
        <a href="account.jsp" class="back-button">
            <i class="fas fa-arrow-left"></i>
            Back to Account
        </a>
        
        <div class="password-card">
            <h2 class="mb-4">Update Password</h2>
            
            <form id="updatePasswordForm" onsubmit="return validateForm()">
                <div class="mb-4 form-floating">
                    <input type="password" class="form-control" id="currentPassword" name="currentPassword" required>
                    <label for="currentPassword">Current Password</label>
                    <i class="fas fa-eye password-toggle" onclick="togglePassword('currentPassword')"></i>
                </div>
                
                <div class="mb-2 form-floating">
                    <input type="password" class="form-control" id="newPassword" name="newPassword" 
                           onkeyup="checkPasswordStrength()" required>
                    <label for="newPassword">New Password</label>
                    <i class="fas fa-eye password-toggle" onclick="togglePassword('newPassword')"></i>
                </div>
                
                <div class="password-strength" id="passwordStrength"></div>
                
                <div class="mb-4 form-floating">
                    <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
                    <label for="confirmPassword">Confirm New Password</label>
                    <i class="fas fa-eye password-toggle" onclick="togglePassword('confirmPassword')"></i>
                </div>
                
                <div class="password-requirements">
                    <div><i class="fas fa-info-circle"></i> Password requirements:</div>
                    <ul>
                        <li>At least 8 characters long</li>
                        <li>Contains at least one uppercase letter</li>
                        <li>Contains at least one lowercase letter</li>
                        <li>Contains at least one number</li>
                        <li>Contains at least one special character</li>
                    </ul>
                </div>
                
                <div class="d-grid gap-2 mt-4">
                    <button type="submit" class="btn btn-update">Update Password</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function togglePassword(inputId) {
            const input = document.getElementById(inputId);
            const icon = input.nextElementSibling.nextElementSibling;
            
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            }
        }
        
        function checkPasswordStrength() {
            const password = document.getElementById('newPassword').value;
            const strengthDiv = document.getElementById('passwordStrength');
            
            // Reset strength indicator
            strengthDiv.className = 'password-strength';
            
            if (password.length === 0) {
                strengthDiv.textContent = '';
                return;
            }
            
            const hasUpperCase = /[A-Z]/.test(password);
            const hasLowerCase = /[a-z]/.test(password);
            const hasNumbers = /\d/.test(password);
            const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(password);
            const isLengthValid = password.length >= 8;
            
            let strength = 0;
            if (hasUpperCase) strength++;
            if (hasLowerCase) strength++;
            if (hasNumbers) strength++;
            if (hasSpecialChar) strength++;
            if (isLengthValid) strength++;
            
            if (strength < 3) {
                strengthDiv.textContent = 'Weak password';
                strengthDiv.classList.add('strength-weak');
            } else if (strength < 5) {
                strengthDiv.textContent = 'Medium strength password';
                strengthDiv.classList.add('strength-medium');
            } else {
                strengthDiv.textContent = 'Strong password';
                strengthDiv.classList.add('strength-strong');
            }
        }
        
        function validateForm() {
            const newPassword = document.getElementById('newPassword').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            const currentPassword = document.getElementById('currentPassword').value;
            
            if (newPassword !== confirmPassword) {
                alert('New passwords do not match');
                return false;
            }
            
            // Check password requirements
            const hasUpperCase = /[A-Z]/.test(newPassword);
            const hasLowerCase = /[a-z]/.test(newPassword);
            const hasNumbers = /\d/.test(newPassword);
            const hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(newPassword);
            const isLengthValid = newPassword.length >= 8;
            
            if (!hasUpperCase || !hasLowerCase || !hasNumbers || !hasSpecialChar || !isLengthValid) {
                alert('Please make sure your password meets all requirements');
                return false;
            }
            
            // Submit the form
            const formData = new URLSearchParams();
            formData.append('currentPassword', currentPassword);
            formData.append('newPassword', newPassword);
            formData.append('userId', '<%= userId %>');
            
            fetch('updatePassword', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: formData.toString()
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('Password updated successfully');
                    window.location.href = 'account.jsp';
                } else {
                    alert(data.error || 'Failed to update password');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('An error occurred while updating password');
            });
            
            return false;
        }
    </script>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
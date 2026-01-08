<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up - Escape</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --bg-dark: #000;
            --text-light: #fff;
            --primary-color: #e50914;
        }

        body {
            background-color: #000;
            font-family: 'Arial', sans-serif;
            margin: 0;
            padding: 0;
            min-height: 100vh;
            color: #fff;
            background-image: linear-gradient(to top,
                rgba(0, 0, 0, 0.9) 0,
                rgba(0, 0, 0, 0.5) 60%,
                rgba(0, 0, 0, 0.9) 100%);
        }

        .logo {
            color: #e50914;
            font-size: 2rem;
            font-weight: bold;
            text-decoration: none;
            padding: 20px;
            display: inline-block;
            text-transform: uppercase;
            letter-spacing: 1px;
            position: absolute;
            top: 0;
            left: 0;
        }

        .auth-container {
            width: 100%;
            max-width: 314px;
            margin: 0 auto;
            padding: 0 40px;
            background: transparent;
            position: relative;
            top: 60px;
        }

        h1 {
            color: #fff;
            font-size: 32px;
            font-weight: 500;
            margin-bottom: 28px;
        }

        .form-group {
            margin-bottom: 16px;
            position: relative;
        }

        input[type="text"],
        input[type="email"],
        input[type="password"],
        input[type="tel"] {
            width: 100%;
            height: 50px;
            background: #333;
            border: none;
            border-radius: 4px;
            padding: 16px 20px;
            color: #fff;
            font-size: 16px;
            box-sizing: border-box;
        }

        input:focus {
            outline: none;
            background: #454545;
        }

        .password-field {
            position: relative;
        }

        .password-toggle {
            position: absolute;
            right: 12px;
            top: 10px;
            color: #8c8c8c;
            cursor: pointer;
            padding: 8px;
            background: none;
            border: none;
            font-size: 16px;
        }

        .password-toggle:hover {
            color: #fff;
        }

        .auth-button {
            width: 100%;
            height: 48px;
            background: #e50914;
            color: #fff;
            border: none;
            border-radius: 4px;
            font-size: 16px;
            font-weight: 500;
            cursor: pointer;
            margin: 24px 0 12px;
        }

        .auth-button:hover {
            background: #f40612;
        }

        .signin-text {
            text-align: center;
            color: #737373;
            margin-top: 16px;
            font-size: 16px;
        }

        .signin-link {
            color: #fff;
            text-decoration: none;
            margin-left: 4px;
        }

        .signin-link:hover {
            text-decoration: underline;
        }

        .terms {
            color: #737373;
            font-size: 13px;
            margin-top: 16px;
            text-align: center;
        }

        .error-message {
            color: #e87c03;
            font-size: 13px;
            margin-top: 6px;
            display: none;
            animation: fadeIn 0.3s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .password-strength {
            height: 4px;
            background: #333;
            margin-top: 8px;
            border-radius: 2px;
            width: 100%;
        }

        .strength-bar {
            height: 100%;
            width: 0;
            background: #e50914;
            border-radius: 2px;
            transition: width 0.3s ease;
        }

        .password-strength-text {
            color: #737373;
            font-size: 13px;
            margin-top: 6px;
            display: block;
        }

        /* Footer Styles */
        .site-footer {
            background-color: var(--bg-dark);
            padding: 2rem 4rem;
            color: var(--text-light);
            margin-top: 4rem;
        }

        .footer-content {
            display: flex;
            justify-content: space-between;
            margin-bottom: 2rem;
            padding-bottom: 2rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .footer-section h3 {
            color: var(--text-light);
            font-size: 1.1rem;
            margin-bottom: 1rem;
        }

        .footer-section ul {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .footer-section ul li {
            margin-bottom: 0.5rem;
        }

        .footer-section ul li a {
            color: #808080;
            text-decoration: none;
            transition: color 0.3s ease;
        }

        .footer-section ul li a:hover {
            color: var(--text-light);
        }

        .social-links {
            display: flex;
            gap: 1rem;
        }

        .social-links a {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background-color: #333;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--text-light);
            text-decoration: none;
            transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        }

        .social-links a:hover {
            background-color: var(--primary-color);
            transform: translateY(-2px);
        }

        .social-links a svg {
            width: 16px;
            height: 16px;
        }

        .footer-bottom {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .copyright {
            color: #808080;
        }

        .footer-legal {
            display: flex;
            gap: 2rem;
        }

        .footer-legal a {
            color: #808080;
            text-decoration: none;
            transition: color 0.3s ease;
        }

        .footer-legal a:hover {
            color: var(--text-light);
        }

        @media (max-width: 768px) {
            .site-footer {
                padding: 2rem;
            }
            
            .footer-content {
                flex-direction: column;
                gap: 2rem;
            }
            
            .footer-bottom {
                flex-direction: column;
                gap: 1rem;
                text-align: center;
            }
            
            .footer-legal {
                justify-content: center;
                flex-wrap: wrap;
            }
        }

        @media (max-width: 480px) {
            .site-footer {
                padding: 1.5rem;
            }
            
            .social-links {
                justify-content: center;
            }
        }
    </style>
</head>
<body>
    <a href="index.jsp" class="logo">ESCAPE</a>

    <div class="auth-container">
        <h1>Sign Up</h1>
        
        <form action="signup" method="POST" id="signupForm">
            <div class="form-group">
                <input type="text" name="firstName" required
                       placeholder="First name">
                <span class="error-message" id="firstNameError"></span>
            </div>

            <div class="form-group">
                <input type="text" name="lastName" required
                       placeholder="Last name">
                <span class="error-message" id="lastNameError"></span>
            </div>

            <div class="form-group">
                <input type="email" name="email" required
                       placeholder="Email address">
                <span class="error-message" id="emailError"></span>
            </div>

            <div class="form-group">
                <input type="tel" name="mobileNumber" required
                       placeholder="Mobile number">
                <span class="error-message" id="mobileError"></span>
            </div>

            <div class="form-group password-field">
                <input type="password" name="password" id="passwordField" required
                       placeholder="Password">
                <i class="fas fa-eye password-toggle" onclick="togglePassword()"></i>
                <div class="password-strength">
                    <div class="strength-bar"></div>
                </div>
                <span class="password-strength-text" id="strengthText">Password Strength: Weak</span>
                <span class="error-message" id="passwordError"></span>
            </div>

            <button type="submit" class="auth-button">Sign Up</button>

            <div class="signin-text">
                Already have an account? <a href="login.jsp" class="signin-link">Sign in now</a>
            </div>

            <div class="terms">
                By signing up, you agree to our Terms of Use and Privacy Policy.
            </div>
        </form>
    </div>

    <!-- Footer Section -->
    <footer class="site-footer">
        <div class="footer-content">
            <div class="footer-section">
                <h3>Company</h3>
                <ul>
                    <li><a href="#">About Us</a></li>
                    <li><a href="#">Careers</a></li>
                </ul>
            </div>

            <div class="footer-section">
                <h3>Need Help?</h3>
                <ul>
                    <li><a href="#">Visit Help Center</a></li>
                    <li><a href="#">Share Feedback</a></li>
                </ul>
            </div>

            <div class="footer-section">
                <h3>Connect with Us</h3>
                <div class="social-links">
                    <a href="#" aria-label="Facebook">
                        <i class="fab fa-facebook-f"></i>
                    </a>
                    <a href="#" aria-label="X (Twitter)">
                        <svg width="16" height="16" viewBox="0 0 24 24">
                            <path fill="currentColor" d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
                        </svg>
                    </a>
                    <a href="#" aria-label="Instagram">
                        <i class="fab fa-instagram"></i>
                    </a>
                    <a href="#" aria-label="YouTube">
                        <i class="fab fa-youtube"></i>
                    </a>
                </div>
            </div>
        </div>

        <div class="footer-bottom">
            <div class="copyright">
                © 2024 ESCAPE. All Rights Reserved.
            </div>
            <div class="footer-legal">
                <a href="#">Terms Of Use</a>
                <a href="#">Privacy Policy</a>
                <a href="#">FAQ</a>
            </div>
        </div>
    </footer>

    <script>
        function togglePassword() {
            const input = document.getElementById('passwordField');
            const icon = document.querySelector('.password-toggle');
            
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

        function showError(elementId, message) {
            const errorElement = document.getElementById(elementId);
            errorElement.textContent = message;
            errorElement.style.display = 'block';
            
            // Hide error message after 3 seconds
            setTimeout(() => {
                hideError(elementId);
            }, 3000);
        }

        function hideError(elementId) {
            const errorElement = document.getElementById(elementId);
            if (errorElement) {
                errorElement.style.display = 'none';
            }
        }

        // Password strength checker
        const passwordInput = document.getElementById('passwordField');
        const strengthBar = document.querySelector('.strength-bar');
        const strengthText = document.getElementById('strengthText');

        passwordInput.addEventListener('input', function() {
            const password = this.value;
            let strength = 0;
            
            // Length check
            if (password.length >= 6) strength += 20;
            if (password.length >= 8) strength += 20;
            
            // Uppercase check
            if (/[A-Z]/.test(password)) strength += 20;
            
            // Number check
            if (/[0-9]/.test(password)) strength += 20;
            
            // Special character check
            if (/[^A-Za-z0-9]/.test(password)) strength += 20;
            
            // Update strength bar
            strengthBar.style.width = strength + '%';
            
            // Update color and text based on strength
            if (strength <= 40) {
                strengthBar.style.background = '#e50914';
                strengthText.style.color = '#e50914';
                strengthText.textContent = 'Password Strength: Weak';
            } else if (strength <= 80) {
                strengthBar.style.background = '#ffa534';
                strengthText.style.color = '#ffa534';
                strengthText.textContent = 'Password Strength: Good';
            } else {
                strengthBar.style.background = '#2ecc71';
                strengthText.style.color = '#2ecc71';
                strengthText.textContent = 'Password Strength: Strong';
            }
        });

        const form = document.getElementById('signupForm');
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            let hasError = false;

            // Validate first name (only letters and spaces)
            const firstName = form.firstName.value.trim();
            if (!/^[A-Za-z\s]+$/.test(firstName)) {
                showError('firstNameError', 'Please enter a valid first name (letters only)');
                hasError = true;
            }

            // Validate last name (only letters and spaces)
            const lastName = form.lastName.value.trim();
            if (!/^[A-Za-z\s]+$/.test(lastName)) {
                showError('lastNameError', 'Please enter a valid last name (letters only)');
                hasError = true;
            }

            // Validate email
            const email = form.email.value.trim();
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                showError('emailError', 'Please enter a valid email address');
                hasError = true;
            }

            // Validate mobile number
            const mobile = form.mobileNumber.value.trim();
            const mobileRegex = /^[0-9]{10}$/;
            if (!mobileRegex.test(mobile)) {
                showError('mobileError', 'Please enter a valid 10-digit mobile number');
                hasError = true;
            }

            // Validate password
            const password = form.password.value;
            if (password.length < 6) {
                showError('passwordError', 'Password must be at least 6 characters long');
                hasError = true;
            }

            if (!hasError) {
                // Make signup request
                fetch('signup', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: new URLSearchParams(new FormData(form))
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        window.location.href = data.redirect || 'index.jsp';
                    } else {
                        if (data.error === 'ALREADY_REGISTERED') {
                            const message = 'Account already exists with this email/mobile. Please try logging in.';
                            showError('emailError', message);
                            
                            // After 3 seconds, redirect to login page
                            setTimeout(() => {
                                window.location.href = 'login.jsp';
                            }, 3000);
                        } else {
                            showError('emailError', data.message || 'An error occurred. Please try again.');
                        }
                    }
                })
                .catch(error => {
                    showError('emailError', 'An error occurred. Please try again.');
                    console.error('Error:', error);
                });
            }
        });
    </script>
</body>
</html>
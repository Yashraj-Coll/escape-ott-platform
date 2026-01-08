<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
    // Get user information from session
    String userName = (String) session.getAttribute("userName");
    String subscriptionPlan = (String) session.getAttribute("subscriptionPlan");
    
    if (userName == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Devices - Escape</title>
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

        .section-title {
            font-size: 2.5rem;
            margin-bottom: 1.5rem;
            color: #111;
            font-weight: 600;
            text-align: center;
            margin-top: 20px;
            padding: 0 20px;
            line-height: 1.3;
        }

        .device-section {
            background: white;
            border-radius: 12px;
            padding: 32px;
            margin-bottom: 24px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.1);
        }

        .device-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
        }

        .device-header h2 {
            font-size: 1.5rem;
            font-weight: 600;
            color: #111;
            margin: 0;
        }

        .device-list {
            display: flex;
            flex-direction: column;
        }

        .device-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px;
            border-bottom: 1px solid #eee;
            transition: all 0.3s ease;
            cursor: pointer;
        }

        .device-item:last-child {
            border-bottom: none;
        }

        .device-item:hover {
            background-color: #f8f8f8;
            transform: translateX(4px);
        }

        .device-info {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .device-icon {
            width: 48px;
            height: 48px;
            background: #f8f9fa;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.4rem;
            color: #666;
            transition: all 0.3s ease;
        }

        .device-item:hover .device-icon {
            background: #e5091408;
            color: #e50914;
        }

        .device-details h4 {
            margin: 0;
            font-size: 1.1rem;
            font-weight: 500;
            color: #111;
        }

        .device-meta {
            color: #666;
            font-size: 0.95rem;
            margin-top: 6px;
        }

        .current-device {
            background-color: #f8f9fa;
        }

        .current-badge {
            background: #28a745;
            color: white;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 500;
            margin-left: 12px;
        }

        .btn-sign-out {
            color: #e50914;
            background: none;
            border: 1px solid #e50914;
            padding: 8px 16px;
            cursor: pointer;
            font-weight: 500;
            border-radius: 4px;
            transition: all 0.3s ease;
        }

        .btn-sign-out:hover {
            background-color: #e50914;
            color: white;
        }

        .shield-icon {
            width: 120px;
            height: 120px;
            margin: 0 auto 32px;
            display: block;
            filter: drop-shadow(0 8px 16px rgba(229, 9, 20, 0.2));
            animation: shieldFloat 3s ease-in-out infinite;
        }

        @keyframes shieldFloat {
            0%, 100% {
                transform: translateY(0);
            }
            50% {
                transform: translateY(-10px);
            }
        }

        .security-text {
            max-width: 600px;
            margin: 0 auto 40px;
            line-height: 1.8;
            color: #666;
            font-size: 1.1rem;
            text-align: center;
        }

        .password-link {
            color: #e50914;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
        }

        .password-link:hover {
            text-decoration: underline;
        }

        .modal-content {
            border-radius: 12px;
            border: none;
        }

        .modal-header {
            border-bottom: 1px solid #eee;
            padding: 20px 24px;
        }

        .modal-body {
            padding: 24px;
        }

        .modal-footer {
            border-top: 1px solid #eee;
            padding: 16px 24px;
        }

        .btn-danger {
            background-color: #e50914;
            border: none;
            padding: 8px 20px;
            font-weight: 500;
        }

        .btn-danger:hover {
            background-color: #cc0812;
        }

        .title-emphasis {
            color: #e50914;
            font-weight: 700;
        }

        @media (max-width: 768px) {
            .account-nav {
                position: static;
                width: 100%;
                height: auto;
                margin-bottom: 20px;
            }
            
            .account-content {
                margin-left: 0;
                padding: 20px;
            }

            .device-section {
                padding: 20px;
            }

            .section-title {
                font-size: 2rem;
            }

            .shield-icon {
                width: 100px;
                height: 100px;
            }
        }
    </style>
</head>
<body>
    <div class="account-nav">
        <a href="account.jsp" class="back-button px-4 py-2">
            <i class="fas fa-arrow-left"></i>
            Back to Account
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
            <a class="nav-link active" href="devices.jsp">
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
        <div class="text-center mb-5">
            <svg class="shield-icon" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg">
                <defs>
                    <linearGradient id="shieldGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                        <stop offset="0%" style="stop-color:#e50914;stop-opacity:1" />
                        <stop offset="100%" style="stop-color:#b20710;stop-opacity:1" />
                    </linearGradient>
                    <filter id="shadow">
                        <feDropShadow dx="0" dy="4" stdDeviation="8" flood-opacity="0.2"/>
                    </filter>
                </defs>
                <g fill="url(#shieldGradient)" filter="url(#shadow)">
                    <path d="M466.5 83.7l-192-80a48.15 48.15 0 0 0-36.9 0l-192 80C27.7 91.1 16 108.6 16 128c0 198.5 114.5 335.7 221.5 380.3 11.8 4.9 25.1 4.9 36.9 0C360.1 472.6 496 349.3 496 128c0-19.4-11.7-36.9-29.5-44.3zM262.2 478.8c-4 1.6-8.4 1.6-12.3 0C152 440 48 304 48 128c0-6.5 3.9-12.3 9.8-14.8l192-80c3.9-1.6 8.4-1.6 12.3 0l192 80c6 2.5 9.8 8.3 9.8 14.8.1 176-103.9 312-201.7 350.8z"/>
                    <path d="M256 411c-95.2 0-172.7-77.5-172.7-172.7S160.8 65.6 256 65.6s172.7 77.5 172.7 172.7S351.2 411 256 411zm0-313.5c-77.7 0-140.8 63.1-140.8 140.8S178.3 379.1 256 379.1s140.8-63.1 140.8-140.8S333.7 97.5 256 97.5z"/>
                    <path d="M256 351.3c-62.2 0-112.9-50.7-112.9-112.9S193.8 125.4 256 125.4s112.9 50.7 112.9 112.9S318.2 351.3 256 351.3zm0-193.9c-44.7 0-81 36.3-81 81s36.3 81 81 81 81-36.3 81-81-36.3-81-81-81z"/>
                    <circle cx="256" cy="238.3" r="48.6"/>
                </g>
            </svg>
            <h1 class="section-title">
                <span class="title-emphasis">Manage</span> Access and Devices
            </h1>
            <p class="security-text">
                These signed-in devices have recently been active on this account. You can sign out
                any unfamiliar devices or <a href="updatePassword.jsp" class="password-link">change your password</a> for added security.
            </p>
        </div>

        <div class="device-section">
            <div class="device-header">
                <h2>Account access</h2>
            </div>
            <div class="device-list" id="devicesList">
                <!-- Devices will be loaded here via JavaScript -->
            </div>
        </div>
    </div>

    <!-- Sign Out Confirmation Modal -->
    <div class="modal fade" id="signOutModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Sign Out Device</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to sign out this device? You'll need to sign in again to use Escape on this device.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-danger" onclick="confirmSignOut()">Sign Out</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let currentDeviceId = null;
        
        document.addEventListener('DOMContentLoaded', function() {
            loadDevices();
        });
        
        function loadDevices() {
            fetch('getDevices')
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    displayDevices(data.devices);
                }
            })
            .catch(error => {
                console.error('Error:', error);
            });
        }
        
        function displayDevices(devices) {
            const devicesList = document.getElementById('devicesList');
            devicesList.innerHTML = '';
            
            devices.forEach(function(device) {
                const deviceEl = document.createElement('div');
                deviceEl.className = 'device-item' + (device.isCurrent ? ' current-device' : '');
                            
                let deviceIcon = 'laptop';
                if (device.type === 'mobile') deviceIcon = 'mobile-alt';
                else if (device.type === 'tablet') deviceIcon = 'tablet-alt';
                else if (device.type === 'tv') deviceIcon = 'tv';
                            
                let html = '<div class="device-info">';
                html += '<div class="device-icon">';
                html += '<i class="fas fa-' + deviceIcon + '"></i>';
                html += '</div>';
                html += '<div class="device-details">';
                html += '<h4>' + device.name + '</h4>';
                html += '<div class="device-meta">';
                html += device.location + ' · ' + device.browser;
                if (device.isCurrent) {
                    html += '<span class="current-badge">Current device</span>';
                }
                html += '</div>';
                html += '<div class="device-meta">';
                html += device.isCurrent ? 'Currently active' : 'Last active ' + device.lastActive;
                html += '</div>';
                html += '</div>';
                html += '</div>';
                            
                if (!device.isCurrent) {
                    html += '<button class="btn-sign-out" onclick="signOutDevice(\'' + device.id + '\')">';
                    html += 'Sign Out';
                    html += '</button>';
                }
                            
                deviceEl.innerHTML = html;
                devicesList.appendChild(deviceEl);
            });
                    }
                    
                    function signOutDevice(deviceId) {
                        currentDeviceId = deviceId;
                        new bootstrap.Modal(document.getElementById('signOutModal')).show();
                    }
                    
                    function confirmSignOut() {
                        if (!currentDeviceId) return;
                        
                        fetch('signOutDevice', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/x-www-form-urlencoded',
                            },
                            body: 'deviceId=' + currentDeviceId
                        })
                        .then(response => response.json())
                        .then(data => {
                            if (data.success) {
                                bootstrap.Modal.getInstance(document.getElementById('signOutModal')).hide();
                                loadDevices();
                            }
                        })
                        .catch(error => {
                            console.error('Error:', error);
                        });
                    }
                </script>
            </body>
            </html>
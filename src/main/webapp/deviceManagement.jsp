<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%
    String userName = (String) session.getAttribute("userName");
    String subscriptionPlan = (String) session.getAttribute("subscriptionPlan");
    if (userName == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Define device limits based on plan
    int deviceLimit = 1; // Default for Basic plan
    if ("Premium".equals(subscriptionPlan)) {
        deviceLimit = 4;
    } else if ("Standard".equals(subscriptionPlan)) {
        deviceLimit = 2;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Devices - Escape</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f3f3f3;
            color: #333;
        }
        
        .main-container {
            max-width: 900px;
            margin: 40px auto;
            padding: 0 20px;
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
        
        .devices-card {
            background: white;
            border-radius: 8px;
            padding: 24px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        
        .device-info {
            display: flex;
            align-items: center;
            padding: 15px;
            border-bottom: 1px solid #eee;
            position: relative;
        }
        
        .device-icon {
            font-size: 24px;
            width: 40px;
            color: #666;
        }
        
        .device-details {
            flex-grow: 1;
            margin-left: 15px;
        }
        
        .device-name {
            font-weight: 600;
            margin-bottom: 4px;
        }
        
        .device-meta {
            font-size: 0.9rem;
            color: #666;
        }
        
        .device-actions {
            display: flex;
            gap: 10px;
        }
        
        .btn-sign-out {
            color: #e50914;
            background: none;
            border: none;
            padding: 5px 10px;
            cursor: pointer;
            font-weight: 500;
        }
        
        .btn-sign-out:hover {
            background-color: rgba(229, 9, 20, 0.1);
            border-radius: 4px;
        }
        
        .current-device {
            background-color: #e5091408;
        }
        
        .current-device-badge {
            position: absolute;
            top: 10px;
            right: 10px;
            background-color: #28a745;
            color: white;
            padding: 2px 8px;
            border-radius: 12px;
            font-size: 0.8rem;
        }
        
        .device-limit {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-top: 20px;
            padding: 15px;
            background-color: #f8f9fa;
            border-radius: 8px;
        }
        
        .device-limit-icon {
            font-size: 24px;
            color: #666;
        }
        
        .device-limit-info {
            flex-grow: 1;
        }
        
        .device-limit-bar {
            height: 8px;
            background-color: #e9ecef;
            border-radius: 4px;
            margin-top: 8px;
            overflow: hidden;
        }
        
        .device-limit-progress {
            height: 100%;
            background-color: #28a745;
            transition: width 0.3s ease;
        }
        
        .warning-card {
            background-color: #fff3cd;
            border: 1px solid #ffeeba;
            color: #856404;
            padding: 15px;
            border-radius: 8px;
            margin-top: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .warning-icon {
            font-size: 24px;
            color: #856404;
        }
        
        .device-type-icon {
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: #f8f9fa;
            border-radius: 50%;
        }
        
        .last-active {
            font-size: 0.85rem;
            color: #28a745;
            margin-top: 4px;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .animated {
            animation: fadeIn 0.3s ease;
        }
    </style>
</head>
<body>
    <div class="main-container">
        <a href="account.jsp" class="back-button">
            <i class="fas fa-arrow-left"></i>
            Back to Account
        </a>
        
        <h2 class="mb-4">Manage Devices</h2>
        
        <div class="devices-card">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="mb-0">Your Devices</h3>
                <button class="btn btn-outline-danger" onclick="signOutAllDevices()">
                    Sign out all devices
                </button>
            </div>
            
            <div id="devicesList">
                <!-- Devices will be loaded here -->
            </div>
            
            <div class="device-limit">
                <div class="device-limit-icon">
                    <i class="fas fa-devices"></i>
                </div>
                <div class="device-limit-info">
                    <div class="d-flex justify-content-between">
                        <span>Device usage</span>
                        <span id="deviceCount">0/<%= deviceLimit %> devices</span>
                    </div>
                    <div class="device-limit-bar">
                        <div class="device-limit-progress" id="deviceProgress"></div>
                    </div>
                </div>
            </div>
            
            <% if ("Basic".equals(subscriptionPlan)) { %>
            <div class="warning-card">
                <div class="warning-icon">
                    <i class="fas fa-info-circle"></i>
                </div>
                <div>
                    <strong>Want to use more devices?</strong>
                    <p class="mb-0">Upgrade to Standard or Premium plan to watch on multiple devices.</p>
                </div>
                <a href="changePlan.jsp" class="btn btn-warning btn-sm">Upgrade Plan</a>
            </div>
            <% } %>
        </div>
        
        <div class="devices-card">
            <h3 class="mb-4">Recent Activity</h3>
            <div id="activityList">
                <!-- Activity will be loaded here -->
            </div>
        </div>
    </div>

    <!-- Sign Out Confirmation Modal -->
    <div class="modal fade" id="signOutModal" tabindex="-1">
        <div class="modal-dialog">
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

    <!-- Sign Out All Confirmation Modal -->
    <div class="modal fade" id="signOutAllModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Sign Out All Devices</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to sign out all devices? You'll need to sign in again on each device to use Escape.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-danger" onclick="confirmSignOutAll()">Sign Out All</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let currentDeviceId = null;
        const deviceLimit = <%= deviceLimit %>;
        
        document.addEventListener('DOMContentLoaded', function() {
            loadDevices();
            loadActivity();
        });
        
        function loadDevices() {
            fetch('getDevices')
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    displayDevices(data.devices);
                    updateDeviceCount(data.devices.length);
                } else {
                    alert(data.error || 'Failed to load devices');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('An error occurred while loading devices');
            });
        }
        
        function displayDevices(devices) {
            const devicesList = document.getElementById('devicesList');
            devicesList.innerHTML = '';
            
            devices.forEach(device => {
                const deviceEl = document.createElement('div');
                deviceEl.className = 'device-info animated ' + (device.isCurrent ? 'current-device' : '');
                
                let deviceIcon = 'laptop';
                if (device.type === 'mobile') deviceIcon = 'mobile-alt';
                else if (device.type === 'tablet') deviceIcon = 'tablet-alt';
                else if (device.type === 'tv') deviceIcon = 'tv';
                
                let deviceHtml = '';
                
                if (device.isCurrent) {
                    deviceHtml += '<div class="current-device-badge">Current Device</div>';
                }
                
                deviceHtml += '<div class="device-type-icon">' +
                    '<i class="fas fa-' + deviceIcon + '"></i>' +
                    '</div>' +
                    '<div class="device-details">' +
                    '<div class="device-name">' + device.name + '</div>' +
                    '<div class="device-meta">' +
                    device.location + ' · ' + device.browser +
                    '</div>';
                
                if (device.isCurrent) {
                    deviceHtml += '<div class="last-active">Currently active</div>';
                } else {
                    deviceHtml += '<div class="device-meta">Last active ' + device.lastActive + '</div>';
                }
                
                deviceHtml += '</div>';
                
                if (!device.isCurrent) {
                    deviceHtml += '<div class="device-actions">' +
                        '<button class="btn-sign-out" onclick="signOutDevice(\'' + device.id + '\')">' +
                        'Sign Out' +
                        '</button>' +
                        '</div>';
                }
                
                deviceEl.innerHTML = deviceHtml;
                devicesList.appendChild(deviceEl);
            });
        }
        
        function updateDeviceCount(count) {
            document.getElementById('deviceCount').textContent = count + '/' + deviceLimit + ' devices';
            const progress = (count / deviceLimit) * 100;
            document.getElementById('deviceProgress').style.width = progress + '%';
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
                    loadActivity();
                } else {
                    alert(data.error || 'Failed to sign out device');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('An error occurred while signing out device');
            });
        }
        
        function signOutAllDevices() {
            new bootstrap.Modal(document.getElementById('signOutAllModal')).show();
        }
        
        function confirmSignOutAll() {
            fetch('signOutAllDevices', {
                method: 'POST'
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    bootstrap.Modal.getInstance(document.getElementById('signOutAllModal')).hide();
                    loadDevices();
                    loadActivity();
                } else {
                    alert(data.error || 'Failed to sign out all devices');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('An error occurred while signing out all devices');
            });
        }
        
        function loadActivity() {
            fetch('getDeviceActivity')
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    displayActivity(data.activities);
                } else {
                    alert(data.error || 'Failed to load activity');
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('An error occurred while loading activity');
            });
        }
        
        function displayActivity(activities) {
        	const activityList = document.getElementById('activityList');
            activityList.innerHTML = '';
            
            if (activities.length === 0) {
                activityList.innerHTML = '<p class="text-muted">No recent activity</p>';
                return;
            }
            
            activities.forEach(activity => {
                const activityEl = document.createElement('div');
                activityEl.className = 'device-info animated';
                
                const activityHtml = '<div class="device-type-icon">' +
                    '<i class="fas fa-' + (activity.type === 'sign_in' ? 'sign-in-alt' : 'sign-out-alt') + '"></i>' +
                    '</div>' +
                    '<div class="device-details">' +
                    '<div class="device-name">' +
                    (activity.type === 'sign_in' ? 'Sign in' : 'Sign out') + ' - ' + activity.deviceName +
                    '</div>' +
                    '<div class="device-meta">' +
                    activity.location + ' · ' + activity.browser + ' · ' + activity.timestamp +
                    '</div>' +
                    '</div>';
                
                activityEl.innerHTML = activityHtml;
                activityList.appendChild(activityEl);
            });
        }
    </script>
</body>
</html>
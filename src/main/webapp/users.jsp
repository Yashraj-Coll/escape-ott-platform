<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.escape.util.DatabaseConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Users - Escape</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="admin-styles.css" rel="stylesheet">
    <style>
        :root {
            --primary-color: #e50914;
            --bg-dark: #0f0f0f;
            --bg-light: #f3f3f3;
            --text-dark: #333;
            --text-light: #fff;
        }

        body {
            background-color: var(--bg-light);
            font-family: 'Arial', sans-serif;
        }

        .admin-sidebar {
            width: 250px;
            height: 100vh;
            position: fixed;
            left: 0;
            top: 0;
            background: white;
            border-right: 1px solid #ddd;
            z-index: 1000;
        }

        .admin-logo {
    padding: 20px;
    border-bottom: 1px solid #ddd;
}

.admin-logo a {
    color: var(--primary-color);
    font-size: 24px;
    font-weight: bold;
    text-decoration: none;
    font-family: 'Arial', sans-serif;
    text-transform: uppercase;
    letter-spacing: 1px;
}

        .admin-nav {
            padding: 20px 0;
        }

        .nav-item {
            padding: 12px 20px;
            display: flex;
            align-items: center;
            color: var(--text-dark);
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .nav-item:hover, .nav-item.active {
            background-color: #f8f9fa;
            color: var(--primary-color);
        }

        .nav-item i {
            margin-right: 10px;
            width: 20px;
            text-align: center;
        }

        .admin-content {
            margin-left: 250px;
            padding: 20px;
        }

        .content-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }

        .content-title {
            font-size: 24px;
            font-weight: 500;
            margin: 0;
            color: #344767;
        }

        .add-user-btn {
            background-color: var(--primary-color);
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 4px;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
        }

        .add-user-btn:hover {
            opacity: 0.9;
            color: white;
            text-decoration: none;
        }

        /* Bulk Actions Styling */
        .bulk-actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: white;
            padding: 12px 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }

        .bulk-actions-left {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .bulk-actions-right {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .action-select {
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            min-width: 150px;
            background-color: white;
        }

        .ok-button {
            background-color: var(--primary-color);
            color: white;
            border: none;
            padding: 8px 20px;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .ok-button:hover {
            background-color: #cc0812;
        }

        /* Table Styling */
        .users-table {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            overflow: hidden;
        }

        .table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
        }

        .table th {
            background-color: #f8f9fa;
            font-weight: 600;
            text-align: left;
            padding: 15px;
            border-bottom: 2px solid #dee2e6;
            color: #344767;
        }

        .table td {
            padding: 15px;
            vertical-align: middle;
            border-bottom: 1px solid #eee;
            color: #344767;
        }

        .table tr:hover {
            background-color: #f8f9fa;
        }

        .checkbox-container {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .user-checkbox {
            width: 16px;
            height: 16px;
            cursor: pointer;
        }

        .user-name {
            font-weight: 500;
            color: #344767;
        }

        .user-email {
            color: #607d8b;
        }

        .user-phone {
            font-family: monospace;
            color: #607d8b;
        }

        .user-role {
            text-transform: capitalize;
            font-weight: 500;
        }

        .user-date {
            color: #607d8b;
            font-size: 0.9em;
        }

        .status-badge {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 500;
            display: inline-block;
            text-align: center;
            min-width: 80px;
        }

        .status-active {
            background-color: #e8f5e9;
            color: #2e7d32;
        }

        .status-inactive {
            background-color: #ffebee;
            color: #c62828;
        }

        .action-buttons {
            display: flex;
            gap: 8px;
            justify-content: flex-end;
        }

        .action-btn {
            width: 32px;
            height: 32px;
            border: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 4px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .edit-btn {
            background-color: #e3f2fd;
            color: #1976d2;
        }

        .edit-btn:hover {
            background-color: #bbdefb;
        }

        .delete-btn {
            background-color: #ffebee;
            color: #e50914;
        }

        .delete-btn:hover {
            background-color: #ffcdd2;
        }

        /* Modal Styling */
        .modal-content {
            border-radius: 8px;
            border: none;
        }

        .modal-header {
            background-color: #f8f9fa;
            border-bottom: 1px solid #dee2e6;
            padding: 15px 20px;
        }

        .modal-title {
            font-weight: 500;
            color: #344767;
        }

        .modal-body {
            padding: 20px;
        }

        .form-label {
            font-weight: 500;
            color: #344767;
        }

        .form-control, .form-select {
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 8px 12px;
        }

        .form-control:focus, .form-select:focus {
            border-color: var(--primary-color);
            box-shadow: none;
        }

        .modal-footer {
            border-top: 1px solid #dee2e6;
            padding: 15px 20px;
        }

        .btn-secondary {
            background-color: #6c757d;
            border: none;
        }

        .btn-primary {
            background-color: var(--primary-color);
            border: none;
        }

        .btn-primary:hover {
            background-color: #cc0812;
        }

        /* Pagination Styling */
        .pagination {
	  	display: flex;
	    justify-content: flex-end;  /* Changed from center to flex-end */
	    gap: 5px;
	    margin-top: 20px;
	    margin-right: 20px;        /* Added margin-right */
	    margin-bottom: 20px;       /* Added margin-bottom */
		}

        .pagination button {
    padding: 8px 12px;
    border: 1px solid #dee2e6;
    background: white;
    color: #344767;
    cursor: pointer;
    border-radius: 4px;
    transition: all 0.3s ease;
    min-width: 40px;          /* Added min-width for consistent button sizes */
}

.pagination button.active {
    background-color: var(--primary-color);
    color: white;
    border-color: var(--primary-color);
}

        .pagination button:hover:not(.active) {
    background-color: #f8f9fa;
}

.pagination button:disabled {
    opacity: 0.5;
    cursor: not-allowed;
}
    </style>
</head>
<body>

<!-- Include the admin header -->
    <jsp:include page="admin-header.jsp">
        <jsp:param name="pageTitle" value="Users" />
        <jsp:param name="currentPage" value="users" />
    </jsp:include>
    
    <!-- Sidebar -->
    <div class="admin-sidebar">
        <div class="admin-logo">
    <a href="#">Escape</a>
</div>
        <nav class="admin-nav">
            <a href="admin.jsp" class="nav-item">
                <i class="fas fa-home"></i>
                Dashboard
            </a>
            <a href="movies.jsp" class="nav-item">
                <i class="fas fa-film"></i>
                Movies
            </a>
            <a href="banner.jsp" class="nav-item">
                <i class="fas fa-image"></i>
                Banner
            </a>
            <a href="users.jsp" class="nav-item active">
                <i class="fas fa-users"></i>
                Users
            </a>
            <a href="notification.jsp" class="nav-item">
                <i class="fas fa-bell"></i>
                Notification
            </a>
            <a href="#" class="nav-item">
                <i class="fas fa-cog"></i>
                Settings
            </a>
        </nav>
    </div>

    <!-- Main Content -->
    <div class="admin-content">
        <div class="content-header">
            <h1 class="content-title">Manage Users</h1>
            <button class="add-user-btn" onclick="openAddUserModal()">
                <i class="fas fa-plus"></i>
                Add User
            </button>
        </div>

        <!-- Bulk Actions -->
        <div class="bulk-actions">
            <div class="bulk-actions-left">
                <div class="checkbox-container">
                    <input type="checkbox" id="selectAll" onchange="toggleSelectAll(this)">
                    <label for="selectAll">Select All</label>
                </div>
            </div>
            <div class="bulk-actions-right">
                <select class="action-select" id="bulkAction">
                    <option value="">Select Action</option>
                    <option value="delete">Delete</option>
                    <option value="edit">Edit</option>
                </select>
                <button class="ok-button" onclick="executeBulkAction()">OK</button>
            </div>
        </div>

        <!-- Users Table -->
        <div class="users-table">
            <table class="table">
                <thead>
                    <tr>
                        <th style="width: 20%">Name</th>
                        <th style="width: 25%">Email</th>
                        <th style="width: 15%">Phone</th>
                        <th style="width: 10%">Role</th>
                        <th style="width: 15%">Registered on</th>
                        <th style="width: 8%">Status</th>
                        <th style="width: 7%">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                    try {
                        Connection conn = DatabaseConnection.getConnection();
                        
                        // Get total count
                        String countQuery = "SELECT COUNT(*) as total FROM users";
                        PreparedStatement countStmt = conn.prepareStatement(countQuery);
                        ResultSet countRs = countStmt.executeQuery();
                        countRs.next();
                        int totalRecords = countRs.getInt("total");
                        
                        // Pagination
                        int recordsPerPage = 10;
                        int totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);
                        
                        // Get current page
                        String pageStr = request.getParameter("page");
                        int currentPage = (pageStr != null) ? Integer.parseInt(pageStr) : 1;
                        
                        // Calculate offset
                        int offset = (currentPage - 1) * recordsPerPage;
                        
                        String query = "SELECT * FROM users ORDER BY created_at DESC LIMIT ? OFFSET ?";
                        PreparedStatement pstmt = conn.prepareStatement(query);
                        pstmt.setInt(1, recordsPerPage);
                        pstmt.setInt(2, offset);
                        
                        ResultSet rs = pstmt.executeQuery();
                        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                        
                        
                        while(rs.next()) {
                            String fullName = rs.getString("first_name") + " " + rs.getString("last_name");
                            String status = rs.getString("account_status");
                            String statusClass = status.equals("active") ? "status-active" : "status-inactive";
                            Timestamp createdAt = rs.getTimestamp("created_at");
                            String formattedDate = sdf.format(createdAt);
                    %>
                    <tr>
                        <td>
                            <div class="checkbox-container">
                                <input type="checkbox" class="user-checkbox" value="<%= rs.getInt("id") %>">
                                <span class="user-name"><%= fullName %></span>
                            </div>
                        </td>
                        <td><span class="user-email"><%= rs.getString("email") %></span></td>
                        <td><span class="user-phone"><%= rs.getString("mobile_number") %></span></td>
                        <td><span class="user-role"><%= rs.getString("user_role") %></span></td>
                        <td><span class="user-date"><%= formattedDate %></span></td>
                        <td><span class="status-badge <%= statusClass %>"><%= status %></span></td>
                        <td>
                            <div class="action-buttons">
                                <button class="action-btn edit-btn" onclick="openEditModal(<%= rs.getInt("id") %>)">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button class="action-btn delete-btn" onclick="deleteUser(<%= rs.getInt("id") %>)">
                                    <i class="fas fa-trash-alt"></i>
                                </button>
                            </div>
                        </td>
                    </tr>
                    <%
                        }
                        request.setAttribute("totalPages", totalPages);
                        request.setAttribute("currentPage", currentPage);
                        
                        rs.close();
                        pstmt.close();
                        conn.close();
                    } catch(Exception e) {
                        e.printStackTrace();
                    }
                    %>
                </tbody>
            </table>
        </div>

        <!-- Pagination -->
        <div class="pagination">
            <button onclick="changePage(<%= Math.max(1, ((Integer)request.getAttribute("currentPage")) - 1) %>)" 
                    <%= ((Integer)request.getAttribute("currentPage")) == 1 ? "disabled" : "" %>>
                Previous
            </button>
            
            <% 
            int totalPages = (Integer)request.getAttribute("totalPages");
            int currentPage = (Integer)request.getAttribute("currentPage");
            
            for(int i = 1; i <= totalPages; i++) { 
            %>
                <button onclick="changePage(<%= i %>)" 
                        class="<%= currentPage == i ? "active" : "" %>">
                    <%= i %>
                </button>
            <% } %>
            
            <button onclick="changePage(<%= Math.min(totalPages, currentPage + 1) %>)"
                    <%= currentPage == totalPages ? "disabled" : "" %>>
                Next
            </button>
        </div>

        <!-- Add User Modal -->
        <div class="modal fade" id="addUserModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Add New User</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <form id="addUserForm">
                            <div class="mb-3">
                                <label class="form-label">First Name</label>
                                <input type="text" class="form-control" name="firstName" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Last Name</label>
                                <input type="text" class="form-control" name="lastName" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Email</label>
                                <input type="email" class="form-control" name="email" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Mobile Number</label>
                                <input type="tel" class="form-control" name="mobileNumber" required>
                            </div>
                           <div class="mb-3">
                                <label class="form-label">Password</label>
                                <div class="position-relative">
                                    <input type="password" class="form-control" name="password" required>
                                    <button type="button" class="btn position-absolute top-50 end-0 translate-middle-y me-2" onclick="togglePassword(this)" style="background: none; border: none;">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Role</label>
                                <select class="form-select" name="userRole">
                                    <option value="user">User</option>
                                    <option value="premium">Premium</option>
                                    <option value="admin">Admin</option>
                                </select>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-primary" onclick="addUser()">Add User</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Edit User Modal -->
        <div class="modal fade" id="editUserModal" tabindex="-1">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Edit User</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <form id="editUserForm">
                            <input type="hidden" name="userId">
                            <div class="mb-3">
                                <label class="form-label">First Name</label>
                                <input type="text" class="form-control" name="firstName" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Last Name</label>
                                <input type="text" class="form-control" name="lastName" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Email</label>
                                <input type="email" class="form-control" name="email" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Mobile Number</label>
                                <input type="tel" class="form-control" name="mobileNumber" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Role</label>
                                <select class="form-select" name="userRole">
                                    <option value="user">User</option>
                                    <option value="premium">Premium</option>
                                    <option value="admin">Admin</option>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label">Status</label>
                                <select class="form-select" name="accountStatus">
                                    <option value="active">Active</option>
                                    <option value="inactive">Inactive</option>
                                    <option value="suspended">Suspended</option>
                                </select>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="button" class="btn btn-primary" onclick="updateUser()">Update User</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Initialize modals
        const addUserModal = new bootstrap.Modal(document.getElementById('addUserModal'));
        const editUserModal = new bootstrap.Modal(document.getElementById('editUserModal'));

        // Toggle Select All
        function toggleSelectAll(checkbox) {
            const userCheckboxes = document.querySelectorAll('.user-checkbox');
            userCheckboxes.forEach(box => {
                box.checked = checkbox.checked;
            });
        }

        // Open Add User Modal
        function openAddUserModal() {
            document.getElementById('addUserForm').reset();
            addUserModal.show();
        }
        
        // Password toggle function
        function togglePassword(button) {
            const input = button.parentElement.querySelector('input');
            const icon = button.querySelector('i');
            
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

        // Add User
        async function addUser() {
    const form = document.getElementById('addUserForm');
    if (!form.checkValidity()) {
        form.reportValidity();
        return;
    }
    
    try {
        const response = await fetch('api/users', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams(new FormData(form))
        });
        
        const data = await response.json();
        if (data.status === 'success') {
            addUserModal.hide();
            window.location.reload();
        } else {
            alert(data.message || 'Failed to add user');
        }
    } catch (error) {
        console.error('Error:', error);
        alert('Error adding user');
    }
}

        // Open Edit Modal
        async function openEditModal(userId) {
    try {
        const response = await fetch('api/users/' + userId);
        const data = await response.json();
        
        if (data.status === 'success') {
            const form = document.getElementById('editUserForm');
            const user = data.user;
            
            form.querySelector('[name="userId"]').value = user.id;
            form.querySelector('[name="firstName"]').value = user.first_name;
            form.querySelector('[name="lastName"]').value = user.last_name;
            form.querySelector('[name="email"]').value = user.email;
            form.querySelector('[name="mobileNumber"]').value = user.mobile_number;
            form.querySelector('[name="userRole"]').value = user.user_role;
            form.querySelector('[name="accountStatus"]').value = user.account_status;
            
            editUserModal.show();
        } else {
            alert(data.message || 'Failed to fetch user details');
        }
    } catch (error) {
        console.error('Error:', error);
        alert('Error fetching user details');
    }
}


        // Update User
        async function updateUser() {
    const form = document.getElementById('editUserForm');
    if (!form.checkValidity()) {
        form.reportValidity();
        return;
    }
    
    const userId = form.querySelector('[name="userId"]').value;
    
    try {
        const response = await fetch('api/users/' + userId + '/update', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: new URLSearchParams(new FormData(form))
        });
        
        const data = await response.json();
        if (data.status === 'success') {
            editUserModal.hide();
            window.location.reload();
        } else {
            alert(data.message || 'Failed to update user');
        }
    } catch (error) {
        console.error('Error:', error);
        alert('Error updating user');
    }
}

        // Delete User
        async function deleteUser(userId) {
    if (!confirm('Are you sure you want to delete this user?')) {
        return;
    }
    
    try {
        const response = await fetch('api/users/' + userId + '/delete', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            }
        });
        
        const data = await response.json();
        if (data.status === 'success') {
            window.location.reload();
        } else {
            alert(data.message || 'Failed to delete user');
        }
    } catch (error) {
        console.error('Error:', error);
        alert('Error deleting user');
    }
}

        // Execute Bulk Action
        async function executeBulkAction() {
            const action = document.getElementById('bulkAction').value;
            if (!action) {
                alert('Please select an action');
                return;
            }
            
            const selectedCheckboxes = document.querySelectorAll('.user-checkbox:checked');
            const selectedUsers = Array.from(selectedCheckboxes).map(checkbox => checkbox.value);
            
            if (selectedUsers.length === 0) {
                alert('Please select users');
                return;
            }
            
            if (action === 'delete') {
                if (confirm(`Are you sure you want to delete ${selectedUsers.length} users?`)) {
                    try {
                        const response = await fetch('api/users/bulk-delete', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json'
                            },
                            body: JSON.stringify({ userIds: selectedUsers })
                        });
                        
                        const data = await response.json();
                        if (data.status === 'success') {
                            window.location.reload();
                        } else {
                            alert(data.message || 'Failed to delete users');
                        }
                    } catch (error) {
                        console.error('Error:', error);
                        alert('Error deleting users');
                    }
                }
            } else if (action === 'edit') {
                alert('Bulk edit functionality coming soon');
            }
        }

        // Pagination
        function changePage(page) {
            window.location.href = `users.jsp?page=${page}`;
        }

        // Update pagination active state
        document.addEventListener('DOMContentLoaded', function() {
            const currentPage = new URLSearchParams(window.location.search).get('page') || 1;
            document.querySelectorAll('.pagination button').forEach(button => {
                if (button.textContent.trim() === currentPage.toString()) {
                    button.classList.add('active');
                }
            });
        });
    </script>
</body>
</html>
\# ESCAPE - OTT Streaming Platform 🎬



Complete OTT (Over-The-Top) streaming platform with video streaming, subscription management, payment processing, multi-device support, and comprehensive admin controls.



\[!\[Java](https://img.shields.io/badge/Java-17-orange)](https://www.oracle.com/java/)

\[!\[Servlet](https://img.shields.io/badge/Jakarta%20Servlet-6.1-blue)](https://jakarta.ee/)

\[!\[MySQL](https://img.shields.io/badge/MySQL-8.0-blue)](https://www.mysql.com/)

\[!\[Razorpay](https://img.shields.io/badge/Payment-Razorpay-3395FF)](https://razorpay.com/)



\## 🚀 Quick Start



\### Prerequisites

\- Java 17+

\- Apache Tomcat 10+

\- MySQL 8.0+

\- Eclipse IDE (or any Java IDE)



\### Installation

```bash

\# Clone repository

git clone https://github.com/Yashraj-Coll/escape-ott-platform

cd escape-ott-platform



\# Create database

mysql -u root -p

CREATE DATABASE escape\_db;

exit;



\# Configure database credentials

\# Edit: src/main/java/com/escape/util/DatabaseConnection.java



\# Import to Eclipse and run on Tomcat server

```



Application will start at: `http://localhost:8080/Escape/`



\## 📁 Project Architecture



\### Technology Stack

\- \*\*Backend:\*\* Java Servlets (JSP/Servlet Architecture)

\- \*\*Database:\*\* MySQL 8.0

\- \*\*Server:\*\* Apache Tomcat 10+

\- \*\*Payment:\*\* Razorpay Integration

\- \*\*Email:\*\* Jakarta Mail API



\### Key Components

\- \*\*Servlets\*\* - 25+ servlets handling all backend logic

\- \*\*JSP Pages\*\* - Dynamic frontend rendering

\- \*\*MySQL Database\*\* - Relational data storage

\- \*\*Session Management\*\* - User authentication \& device tracking



\## ✨ Complete Feature Set



\### 🎥 Video Streaming Features

\- \*\*Multi-Category Content\*\* 

&nbsp; - Popular Movies

&nbsp; - Popular Series

&nbsp; - Popular TV Shows

&nbsp; - Trending Now

\- \*\*Continue Watching\*\* - Resume from where you left off with progress tracking

\- \*\*My List\*\* - Personal watchlist management

\- \*\*Like/Unlike System\*\* - Rate your favorite content

\- \*\*Advanced Search\*\* - Find content quickly across all categories

\- \*\*View Tracking\*\* - Monitor content popularity and engagement

\- \*\*Category Management\*\* - Organized content browsing



\### 💳 Subscription Management

\- \*\*Multiple Subscription Plans\*\*

&nbsp; - \*\*Free Plan\*\* - ₹0/month - 1 device, 480p, Limited content

&nbsp; - \*\*Basic Plan\*\* - ₹199/month - 1 device, 480p, Full catalog

&nbsp; - \*\*Standard Plan\*\* - ₹499/month - 2 devices, 1080p, Download support

&nbsp; - \*\*Premium Plan\*\* - ₹699/month - 4 devices, 4K, All features

\- \*\*Plan Upgrades/Downgrades\*\* - Seamless plan transitions

\- \*\*Subscription History\*\* - Complete transaction tracking

\- \*\*Auto-renewal Management\*\* - Automatic billing on next billing date

\- \*\*Billing Date Tracking\*\* - Clear next payment information



\### 💰 Payment Features

\- \*\*Razorpay Gateway Integration\*\* - Secure payment processing

\- \*\*Multiple Payment Methods\*\*

&nbsp; - Credit/Debit Cards (VISA, Mastercard, AMEX)

&nbsp; - UPI (Google Pay, PhonePe, Paytm)

&nbsp; - Net Banking (All major banks)

&nbsp; - Digital Wallets

\- \*\*Transaction Management\*\* - Complete audit trail with status tracking

\- \*\*Payment History\*\* - View all past transactions

\- \*\*Failed Payment Handling\*\* - Automatic retry and error logging

\- \*\*Transaction Verification\*\* - Secure payment validation



\### 👤 User Management

\- \*\*Secure Authentication\*\* - Login/Signup with email and mobile validation

\- \*\*OTP Verification\*\* - Email-based account verification

\- \*\*Password Reset Flow\*\* - Secure password recovery with OTP

\- \*\*Profile Management\*\* - Update personal information

\- \*\*Session Management\*\* - Secure session handling with timeout

\- \*\*Remember Me\*\* - Optional persistent login

\- \*\*Activity Logging\*\* - Track user actions and login attempts



\### 📱 Multi-Device Support

\- \*\*Device Tracking\*\* - Monitor all logged-in devices with details

\- \*\*Device Management\*\* - View and remove devices remotely

\- \*\*Device Limits\*\* - Plan-based restrictions (1-4 devices)

\- \*\*Session Control\*\* - Manage active sessions across devices

\- \*\*Browser Detection\*\* - Identify Chrome, Firefox, Safari, Edge, Brave

\- \*\*Device Type Recognition\*\* - Desktop, Mobile, Tablet detection

\- \*\*Location Tracking\*\* - IP-based device location



\### 👨‍💼 Admin Panel Features

\- \*\*User Management\*\* - View, edit, and delete user accounts

\- \*\*Content Management\*\* - CRUD operations for movies/shows

\- \*\*Banner Management\*\* - Homepage slider control (Add, Update, Delete)

\- \*\*Category Management\*\* - Organize content into categories

\- \*\*Notification System\*\* - Send targeted emails to users with movie posters

\- \*\*Analytics Dashboard\*\* - User statistics and engagement metrics

\- \*\*Payment Tracking\*\* - Monitor all transactions and revenue



\### 📧 Email Notification System

\- \*\*Subscription Confirmation\*\* - Automated payment receipts with plan details

\- \*\*Content Notifications\*\* - New movie/show alerts with embedded posters

\- \*\*OTP Emails\*\* - Verification codes for signup and password reset

\- \*\*Password Reset\*\* - Secure recovery link emails

\- \*\*Transactional Emails\*\* - Payment confirmations and failures

\- \*\*Professional Templates\*\* - Branded HTML email designs



\### 🔐 Security Features

\- \*\*Login Attempt Logging\*\* - Track failed authentication attempts

\- \*\*Device Authentication\*\* - Verify and manage trusted devices

\- \*\*Session Security\*\* - HttpOnly cookies and secure sessions

\- \*\*SQL Injection Prevention\*\* - Prepared statements throughout

\- \*\*Transaction Verification\*\* - Multi-level payment validation

\- \*\*Password Security\*\* - Secure password storage (Note: Consider bcrypt)

\- \*\*CSRF Protection\*\* - Session-based security measures



\## 🛠️ Technology Stack



\### Backend Technologies

```

Language:              Java 17

Framework:             Jakarta Servlet API 6.1

Architecture:          JSP/Servlet MVC Pattern

Server Container:      Apache Tomcat 10+

Database:              MySQL 8.0

Database Access:       JDBC (Plain SQL with PreparedStatements)

```



\### Payment \& Communication

```

Payment Gateway:       Razorpay Java SDK 1.4.8

Email Service:         Jakarta Mail API 2.0.1

SMTP Provider:         Gmail SMTP

Email Sender:          escapeott.team@gmail.com

```



\### Frontend Technologies

```

View Technology:       JSP (JavaServer Pages)

Templating:            JSTL 3.0.1

Styling:               Custom CSS3

Scripting:             Vanilla JavaScript

UI Components:         Custom HTML/CSS components

```



\### External Libraries

```

JSON Processing:       Gson 2.8.9, org.json 20230618

HTTP Client:           OkHttp 4.9.1

Persistence API:       Jakarta Persistence 3.2.0

Kotlin Support:        Kotlin Stdlib 1.4.10

Database Driver:       MySQL Connector/J 8.0.29

```



\## 📦 Installation \& Setup



\### Step 1: Clone Repository

```bash

git clone https://github.com/Yashraj-Coll/escape-ott-platform

cd escape-ott-platform

```



\### Step 2: Database Setup

```sql

-- Create database

CREATE DATABASE escape\_db;

USE escape\_db;



-- Create users table

CREATE TABLE users (

&nbsp;   id INT PRIMARY KEY AUTO\_INCREMENT,

&nbsp;   first\_name VARCHAR(100) NOT NULL,

&nbsp;   last\_name VARCHAR(100) NOT NULL,

&nbsp;   email VARCHAR(255) UNIQUE NOT NULL,

&nbsp;   mobile\_number VARCHAR(15) UNIQUE NOT NULL,

&nbsp;   password VARCHAR(255) NOT NULL,

&nbsp;   user\_role ENUM('user', 'admin', 'premium') DEFAULT 'user',

&nbsp;   subscription\_plan VARCHAR(50) DEFAULT 'Free',

&nbsp;   remember\_token VARCHAR(255),

&nbsp;   created\_at TIMESTAMP DEFAULT CURRENT\_TIMESTAMP,

&nbsp;   last\_login TIMESTAMP NULL,

&nbsp;   updated\_at TIMESTAMP DEFAULT CURRENT\_TIMESTAMP ON UPDATE CURRENT\_TIMESTAMP

);



-- Create subscriptions table

CREATE TABLE user\_subscriptions (

&nbsp;   subscription\_id INT PRIMARY KEY AUTO\_INCREMENT,

&nbsp;   user\_id INT NOT NULL,

&nbsp;   plan\_type ENUM('Free', 'Basic', 'Standard', 'Premium') NOT NULL,

&nbsp;   status ENUM('ACTIVE', 'INACTIVE', 'EXPIRED') DEFAULT 'ACTIVE',

&nbsp;   start\_date TIMESTAMP NOT NULL,

&nbsp;   end\_date TIMESTAMP NOT NULL,

&nbsp;   next\_billing\_date DATE,

&nbsp;   last\_payment\_date TIMESTAMP,

&nbsp;   last\_payment\_amount DECIMAL(10,2),

&nbsp;   last\_transaction\_id VARCHAR(100),

&nbsp;   created\_at TIMESTAMP DEFAULT CURRENT\_TIMESTAMP,

&nbsp;   updated\_at TIMESTAMP DEFAULT CURRENT\_TIMESTAMP ON UPDATE CURRENT\_TIMESTAMP,

&nbsp;   FOREIGN KEY (user\_id) REFERENCES users(id) ON DELETE CASCADE

);



-- Create payment transactions table

CREATE TABLE payment\_transactions (

&nbsp;   transaction\_id VARCHAR(100) PRIMARY KEY,

&nbsp;   user\_id INT NOT NULL,

&nbsp;   amount DECIMAL(10,2) NOT NULL,

&nbsp;   payment\_method VARCHAR(50),

&nbsp;   plan\_type VARCHAR(50),

&nbsp;   status ENUM('INITIATED', 'SUCCESS', 'FAILED') DEFAULT 'INITIATED',

&nbsp;   card\_number VARCHAR(20),

&nbsp;   card\_type VARCHAR(20),

&nbsp;   upi\_id VARCHAR(100),

&nbsp;   bank\_name VARCHAR(100),

&nbsp;   wallet\_name VARCHAR(50),

&nbsp;   error\_message TEXT,

&nbsp;   created\_at TIMESTAMP DEFAULT CURRENT\_TIMESTAMP,

&nbsp;   updated\_at TIMESTAMP DEFAULT CURRENT\_TIMESTAMP ON UPDATE CURRENT\_TIMESTAMP,

&nbsp;   FOREIGN KEY (user\_id) REFERENCES users(id) ON DELETE CASCADE

);



-- Create movies table

CREATE TABLE movies (

&nbsp;   movie\_id INT PRIMARY KEY AUTO\_INCREMENT,

&nbsp;   title VARCHAR(255) NOT NULL,

&nbsp;   genre VARCHAR(100),

&nbsp;   year INT,

&nbsp;   duration VARCHAR(50),

&nbsp;   category\_id INT,

&nbsp;   poster\_path VARCHAR(500),

&nbsp;   video\_path VARCHAR(500),

&nbsp;   views INT DEFAULT 0,

&nbsp;   created\_at TIMESTAMP DEFAULT CURRENT\_TIMESTAMP

);



-- Create categories table

CREATE TABLE categories (

&nbsp;   category\_id INT PRIMARY KEY AUTO\_INCREMENT,

&nbsp;   name VARCHAR(100) NOT NULL UNIQUE,

&nbsp;   display\_order INT DEFAULT 0,

&nbsp;   created\_at TIMESTAMP DEFAULT CURRENT\_TIMESTAMP

);



-- Create user devices table

CREATE TABLE user\_devices (

&nbsp;   device\_id VARCHAR(100) PRIMARY KEY,

&nbsp;   user\_id INT NOT NULL,

&nbsp;   device\_name VARCHAR(100),

&nbsp;   device\_type VARCHAR(50),

&nbsp;   browser VARCHAR(50),

&nbsp;   location VARCHAR(100),

&nbsp;   session\_id VARCHAR(100),

&nbsp;   active BOOLEAN DEFAULT TRUE,

&nbsp;   last\_active TIMESTAMP DEFAULT CURRENT\_TIMESTAMP,

&nbsp;   created\_at TIMESTAMP DEFAULT CURRENT\_TIMESTAMP,

&nbsp;   FOREIGN KEY (user\_id) REFERENCES users(id) ON DELETE CASCADE

);



-- Create my list table

CREATE TABLE user\_mylist (

&nbsp;   id INT PRIMARY KEY AUTO\_INCREMENT,

&nbsp;   user\_id INT NOT NULL,

&nbsp;   movie\_id INT NOT NULL,

&nbsp;   added\_at TIMESTAMP DEFAULT CURRENT\_TIMESTAMP,

&nbsp;   FOREIGN KEY (user\_id) REFERENCES users(id) ON DELETE CASCADE,

&nbsp;   FOREIGN KEY (movie\_id) REFERENCES movies(movie\_id) ON DELETE CASCADE,

&nbsp;   UNIQUE KEY unique\_user\_movie (user\_id, movie\_id)

);



-- Create likes table

CREATE TABLE user\_likes (

&nbsp;   id INT PRIMARY KEY AUTO\_INCREMENT,

&nbsp;   user\_id INT NOT NULL,

&nbsp;   movie\_id INT NOT NULL,

&nbsp;   liked\_at TIMESTAMP DEFAULT CURRENT\_TIMESTAMP,

&nbsp;   FOREIGN KEY (user\_id) REFERENCES users(id) ON DELETE CASCADE,

&nbsp;   FOREIGN KEY (movie\_id) REFERENCES movies(movie\_id) ON DELETE CASCADE,

&nbsp;   UNIQUE KEY unique\_user\_movie\_like (user\_id, movie\_id)

);



-- Create continue watching table

CREATE TABLE continue\_watching (

&nbsp;   id INT PRIMARY KEY AUTO\_INCREMENT,

&nbsp;   user\_id INT NOT NULL,

&nbsp;   movie\_id INT NOT NULL,

&nbsp;   progress FLOAT DEFAULT 0,

&nbsp;   last\_watched TIMESTAMP DEFAULT CURRENT\_TIMESTAMP ON UPDATE CURRENT\_TIMESTAMP,

&nbsp;   FOREIGN KEY (user\_id) REFERENCES users(id) ON DELETE CASCADE,

&nbsp;   FOREIGN KEY (movie\_id) REFERENCES movies(movie\_id) ON DELETE CASCADE,

&nbsp;   UNIQUE KEY unique\_user\_movie\_watch (user\_id, movie\_id)

);



-- Create banners table

CREATE TABLE banners (

&nbsp;   banner\_id INT PRIMARY KEY AUTO\_INCREMENT,

&nbsp;   title VARCHAR(255),

&nbsp;   image\_path VARCHAR(500),

&nbsp;   video\_path VARCHAR(500),

&nbsp;   display\_order INT DEFAULT 0,

&nbsp;   active BOOLEAN DEFAULT TRUE,

&nbsp;   created\_at TIMESTAMP DEFAULT CURRENT\_TIMESTAMP

);



-- Create login attempts table

CREATE TABLE login\_attempts (

&nbsp;   attempt\_id INT PRIMARY KEY AUTO\_INCREMENT,

&nbsp;   user\_id INT,

&nbsp;   success BOOLEAN,

&nbsp;   ip\_address VARCHAR(50),

&nbsp;   error\_message VARCHAR(255),

&nbsp;   attempt\_time TIMESTAMP DEFAULT CURRENT\_TIMESTAMP,

&nbsp;   FOREIGN KEY (user\_id) REFERENCES users(id) ON DELETE SET NULL

);



-- Create activity log table

CREATE TABLE user\_activity\_log (

&nbsp;   log\_id INT PRIMARY KEY AUTO\_INCREMENT,

&nbsp;   user\_id INT NOT NULL,

&nbsp;   activity\_type VARCHAR(50),

&nbsp;   ip\_address VARCHAR(50),

&nbsp;   activity\_time TIMESTAMP DEFAULT CURRENT\_TIMESTAMP,

&nbsp;   FOREIGN KEY (user\_id) REFERENCES users(id) ON DELETE CASCADE

);



-- Create subscription history table

CREATE TABLE subscription\_history (

&nbsp;   history\_id INT PRIMARY KEY AUTO\_INCREMENT,

&nbsp;   user\_id INT NOT NULL,

&nbsp;   action\_type VARCHAR(50),

&nbsp;   old\_plan VARCHAR(50),

&nbsp;   new\_plan VARCHAR(50),

&nbsp;   transaction\_id VARCHAR(100),

&nbsp;   next\_billing\_date DATE,

&nbsp;   amount\_paid DECIMAL(10,2),

&nbsp;   action\_date TIMESTAMP DEFAULT CURRENT\_TIMESTAMP,

&nbsp;   FOREIGN KEY (user\_id) REFERENCES users(id) ON DELETE CASCADE

);



-- Create transaction history table

CREATE TABLE transaction\_history (

&nbsp;   id INT PRIMARY KEY AUTO\_INCREMENT,

&nbsp;   transaction\_id VARCHAR(100) NOT NULL,

&nbsp;   status VARCHAR(50),

&nbsp;   message TEXT,

&nbsp;   created\_at TIMESTAMP DEFAULT CURRENT\_TIMESTAMP,

&nbsp;   FOREIGN KEY (transaction\_id) REFERENCES payment\_transactions(transaction\_id) ON DELETE CASCADE

);



-- Insert sample categories

INSERT INTO categories (name, display\_order) VALUES

('Popular Movies', 1),

('Popular Series', 2),

('Popular TV Shows', 3),

('Trending Now', 4);



-- Create admin user (password: admin123)

INSERT INTO users (first\_name, last\_name, email, mobile\_number, password, user\_role, subscription\_plan) 

VALUES ('Admin', 'User', 'admin@escape.com', '9999999999', 'admin123', 'admin', 'Premium');

```



\### Step 3: Configure Database Connection



Edit `src/main/java/com/escape/util/DatabaseConnection.java`:

```java

private static final String URL = "jdbc:mysql://localhost:3306/escape\_db";

private static final String USER = "your\_mysql\_username";

private static final String PASSWORD = "your\_mysql\_password";

```



\### Step 4: Configure Email Settings



Edit email sender files with your Gmail credentials:



\*\*`src/main/java/com/escape/util/NotificationEmailSender.java`:\*\*

```java

private static final String USERNAME = "your\_email@gmail.com";

private static final String PASSWORD = "your\_gmail\_app\_password";

```



\*\*`src/main/java/com/escape/util/SubscriptionEmailSender.java`:\*\*

```java

private static final String USERNAME = "your\_email@gmail.com";

private static final String PASSWORD = "your\_gmail\_app\_password";

```



\*\*Gmail App Password Setup:\*\*

1\. Enable 2-Factor Authentication on your Gmail account

2\. Go to: Google Account → Security → 2-Step Verification → App Passwords

3\. Generate app password for "Mail"

4\. Use the generated 16-character password



\### Step 5: Deploy to Tomcat



\#### Using Eclipse:

1\. \*\*Import Project:\*\*

&nbsp;  - File → Import → General → Existing Projects into Workspace

&nbsp;  - Select project root directory

2\. \*\*Add Tomcat Server:\*\*

&nbsp;  - Window → Preferences → Server → Runtime Environments → Add

&nbsp;  - Select Apache Tomcat v10.x

3\. \*\*Run Project:\*\*

&nbsp;  - Right-click project → Run As → Run on Server

&nbsp;  - Select Tomcat server



\#### Manual Deployment:

```bash

\# Export as WAR file from Eclipse

\# Or build manually and copy to Tomcat



\# Copy WAR to Tomcat

cp Escape.war /path/to/tomcat/webapps/



\# Start Tomcat

cd /path/to/tomcat/bin

./startup.sh    # Linux/Mac

startup.bat     # Windows

```



\### Step 6: Access Application

```

Application URL: http://localhost:8080/Escape/

Admin Panel:     http://localhost:8080/Escape/admin.jsp

```



\*\*Default Admin Login:\*\*

```

Email: admin@escape.com

Password: admin123

```



\## 📁 Project Structure

```

Escape/

├── src/main/

│   ├── java/com/escape/

│   │   ├── model/

│   │   │   ├── Category.java           - Category entity

│   │   │   └── User.java                - User entity

│   │   ├── service/

│   │   │   └── MovieService.java        - Business logic for movies

│   │   ├── servlet/

│   │   │   ├── LoginServlet.java        - User authentication

│   │   │   ├── SignupServlet.java       - User registration

│   │   │   ├── LogoutServlet.java       - Session termination

│   │   │   ├── ProcessPaymentServlet.java  - Payment processing

│   │   │   ├── ChangePlanServlet.java   - Plan upgrades/downgrades

│   │   │   ├── UpdateSubscriptionServlet.java  - Subscription updates

│   │   │   ├── MovieServlet.java        - Movie CRUD operations

│   │   │   ├── CategoryServlet.java     - Category management

│   │   │   ├── GetMoviesByCategoryServlet.java  - Filter movies

│   │   │   ├── AddBannerServlet.java    - Add homepage banners

│   │   │   ├── UpdateBannerServlet.java - Modify banners

│   │   │   ├── DeleteBannerServlet.java - Remove banners

│   │   │   ├── DeviceManagementServlet.java  - Device control

│   │   │   ├── ForgotPasswordServlet.java  - Password recovery

│   │   │   ├── ResetPasswordServlet.java   - Reset password

│   │   │   ├── SendVerificationCodeServlet.java  - OTP generation

│   │   │   ├── VerifyOTPServlet.java    - OTP validation

│   │   │   ├── ResendOTPServlet.java    - Resend verification

│   │   │   ├── SendNotificationServlet.java  - Admin notifications

│   │   │   ├── UpdateAccountServlet.java  - Profile updates

│   │   │   ├── UpdatePasswordServlet.java  - Password change

│   │   │   ├── UpdateProfileServlet.java   - Profile editing

│   │   │   ├── UpdateContactServlet.java   - Contact info

│   │   │   ├── DeleteAccountServlet.java   - Account deletion

│   │   │   ├── UserManagementServlet.java  - Admin user control

│   │   │   └── FilesServlet.java        - File serving

│   │   ├── servlets/api/

│   │   │   ├── AddToMyListServlet.java  - Watchlist management

│   │   │   ├── RemoveFromMyListServlet.java  - Remove from list

│   │   │   ├── LikeMovieServlet.java    - Like/unlike movies

│   │   │   ├── GetMovieDetailsServlet.java  - Movie info API

│   │   │   ├── SearchMovieServlet.java  - Search functionality

│   │   │   ├── UpdateContinueWatchingServlet.java  - Progress tracking

│   │   │   ├── RemoveFromContinueWatchingServlet.java  - Clear history

│   │   │   ├── UpdateViewsServlet.java  - View count tracking

│   │   │   └── GetUserDataServlet.java  - User info API

│   │   └── util/

│   │       ├── DatabaseConnection.java  - Database connectivity

│   │       ├── DatabaseHandler.java     - Database operations

│   │       ├── ErrorHandler.java        - Error logging

│   │       ├── NotificationEmailSender.java  - Notification emails

│   │       └── SubscriptionEmailSender.java  - Subscription emails

│   └── webapp/

│       ├── WEB-INF/

│       │   ├── web.xml                  - Servlet configuration

│       │   └── lib/                     - JAR dependencies

│       │       ├── gson-2.8.9.jar

│       │       ├── jakarta.servlet-api-6.1.0.jar

│       │       ├── jakarta.mail-2.0.1.jar

│       │       ├── mysql-connector-java-8.0.29.jar

│       │       ├── razorpay-java-1.4.8.jar

│       │       └── ... (other JARs)

│       ├── images/                      - Movie posters

│       │   ├── Banner/

│       │   ├── PopularMovies/

│       │   ├── PopularSeries/

│       │   ├── PopularTvShows/

│       │   └── TrendingNow/

│       ├── videos/                      - Video content

│       │   ├── Banner/

│       │   ├── Popular Movies/

│       │   ├── Popular Series/

│       │   ├── Popular Tv Shows/

│       │   └── Trending Now/

│       ├── index.jsp                    - Homepage

│       ├── login.jsp                    - Login page

│       ├── signup.jsp                   - Registration page

│       ├── verifyOTP.jsp                - OTP verification

│       ├── forgotPassword.jsp           - Password recovery

│       ├── resetPassword.jsp            - New password page

│       ├── admin.jsp                    - Admin dashboard

│       ├── admin-header.jsp             - Admin navigation

│       ├── membership.jsp               - Subscription plans

│       ├── changePlan.jsp               - Plan change page

│       ├── account.jsp                  - User profile

│       ├── settings.jsp                 - Account settings

│       ├── security.jsp                 - Security settings

│       ├── updatePassword.jsp           - Password change

│       ├── devices.jsp                  - Device management

│       ├── deviceManagement.jsp         - Device control

│       ├── profiles.jsp                 - User profiles

│       ├── movies.jsp                   - Movie browsing

│       ├── banner.jsp                   - Banner management

│       ├── users.jsp                    - User management (admin)

│       ├── notification.jsp             - Send notifications (admin)

│       ├── style.css                    - Main stylesheet

│       ├── admin-styles.css             - Admin styles

│       └── script.js                    - Client-side JavaScript

└── build/                               - Compiled classes

&nbsp;   └── classes/com/escape/

```



\## 🔐 Environment Variables



Create `.env` file (not committed to Git):

```env

\# ===================================

\# ESCAPE OTT Platform Configuration

\# ===================================



\# Database Configuration

DB\_HOST=localhost

DB\_PORT=3306

DB\_NAME=escape\_db

DB\_USER=your\_mysql\_username

DB\_PASSWORD=your\_mysql\_password

DB\_URL=jdbc:mysql://localhost:3306/escape\_db



\# Email Configuration (Gmail SMTP)

MAIL\_HOST=smtp.gmail.com

MAIL\_PORT=587

MAIL\_USERNAME=your\_email@gmail.com

MAIL\_PASSWORD=your\_gmail\_app\_password

MAIL\_FROM=noreply@escape.com



\# Razorpay Payment Gateway

RAZORPAY\_KEY\_ID=rzp\_test\_your\_key\_id\_here

RAZORPAY\_KEY\_SECRET=your\_razorpay\_secret\_here



\# Application Settings

APP\_NAME=ESCAPE

APP\_URL=http://localhost:8080/Escape

SESSION\_TIMEOUT=30



\# Subscription Plans (in INR)

PRICE\_BASIC=199

PRICE\_STANDARD=499

PRICE\_PREMIUM=699



\# Device Limits

MAX\_DEVICES\_FREE=1

MAX\_DEVICES\_BASIC=1

MAX\_DEVICES\_STANDARD=2

MAX\_DEVICES\_PREMIUM=4

```



\## 📚 API Endpoints



\### Authentication APIs

```

POST   /login              - User authentication

POST   /signup             - User registration

GET    /logout             - Session termination

POST   /forgotPassword     - Request password reset

POST   /sendVerificationCode - Send OTP email

POST   /verifyOTP          - Verify OTP code

POST   /resendOTP          - Resend verification code

POST   /resetPassword      - Reset user password

```



\### Subscription \& Payment APIs

```

POST   /processPayment           - Process subscription payment

POST   /updateSubscription       - Update user subscription

POST   /changePlan               - Change subscription plan

```



\### Movie \& Content APIs

```

GET    /api/getMoviesByCategory  - Fetch movies by category

GET    /api/getMovieDetails      - Get detailed movie info

GET    /api/searchMovie          - Search across content

POST   /api/updateViews          - Increment view count

POST   /movie                    - Add/update movie (admin)

POST   /category                 - Manage categories (admin)

```



\### User Feature APIs

```

POST   /api/addToMyList                  - Add to watchlist

POST   /api/removeFromMyList             - Remove from watchlist

POST   /api/likeMovie                    - Like/unlike content

POST   /api/updateContinueWatching       - Update watch progress

POST   /api/removeFromContinueWatching   - Clear watch history

GET    /api/getUserData                  - Get user profile data

```



\### Admin APIs

```

POST   /addBanner              - Add homepage banner

POST   /updateBanner           - Update banner

POST   /deleteBanner           - Delete banner

POST   /sendNotification       - Send email to users

GET    /userManagement         - Manage platform users

```



\### Device Management APIs

```

GET    /devices                - List user devices

POST   /deviceManagement       - Remove device

```



\### Account Management APIs

```

POST   /updateAccount          - Update profile info

POST   /updateProfile          - Edit user profile

POST   /updateContact          - Update contact details

POST   /updatePassword         - Change password

POST   /deleteAccount          - Delete user account

```



\## 💳 Subscription Plans \& Pricing



| Feature | Free | Basic | Standard | Premium |

|---------|------|-------|----------|---------|

| \*\*Price\*\* | ₹0/month | ₹199/month | ₹499/month | ₹699/month |

| \*\*Devices\*\* | 1 | 1 | 2 | 4 |

| \*\*Video Quality\*\* | 480p | 480p | 1080p | 4K |

| \*\*Content\*\* | Limited | Full Catalog | Full Catalog | Full Catalog |

| \*\*Download\*\* | ❌ | ❌ | ✅ | ✅ |

| \*\*Ads\*\* | ✅ | ❌ | ❌ | ❌ |

| \*\*Spatial Audio\*\* | ❌ | ❌ | ❌ | ✅ |



\## 🗄️ Database Schema



\### Key Tables



\*\*users\*\* - User accounts and authentication

```sql

id, first\_name, last\_name, email, mobile\_number, 

password, user\_role, subscription\_plan, remember\_token,

created\_at, last\_login, updated\_at

```



\*\*user\_subscriptions\*\* - Active subscriptions

```sql

subscription\_id, user\_id, plan\_type, status, start\_date,

end\_date, next\_billing\_date, last\_payment\_amount,

last\_transaction\_id, created\_at, updated\_at

```



\*\*payment\_transactions\*\* - Payment records

```sql

transaction\_id, user\_id, amount, payment\_method, plan\_type,

status, card\_number, upi\_id, bank\_name, error\_message,

created\_at, updated\_at

```



\*\*movies\*\* - Video content library

```sql

movie\_id, title, genre, year, duration, category\_id,

poster\_path, video\_path, views, created\_at

```



\*\*categories\*\* - Content organization

```sql

category\_id, name, display\_order, created\_at

```



\*\*user\_devices\*\* - Device tracking

```sql

device\_id, user\_id, device\_name, device\_type, browser,

location, session\_id, active, last\_active, created\_at

```



\*\*user\_mylist\*\* - Personal watchlists

```sql

id, user\_id, movie\_id, added\_at

```



\*\*user\_likes\*\* - Liked content

```sql

id, user\_id, movie\_id, liked\_at

```



\*\*continue\_watching\*\* - Resume progress

```sql

id, user\_id, movie\_id, progress, last\_watched

```



\*\*banners\*\* - Homepage carousel

```sql

banner\_id, title, image\_path, video\_path, 

display\_order, active, created\_at

```



\*\*login\_attempts\*\* - Security audit

```sql

attempt\_id, user\_id, success, ip\_address, 

error\_message, attempt\_time

```



\*\*subscription\_history\*\* - Plan changes

```sql

history\_id, user\_id, action\_type, old\_plan, new\_plan,

transaction\_id, amount\_paid, action\_date

```



\## 📸 Screenshots



\### 🏠 Homepage

!\[Homepage](docs/screenshots/homepage.png)

\*Modern landing page with banner carousel and categorized content\*



---



\### 👤 User Portal



\#### Login Page

!\[Login](docs/screenshots/login.png)

\*Secure user authentication with remember me functionality\*



\#### Signup Page

!\[Signup](docs/screenshots/signup.png)

\*User registration with email and mobile verification\*



\#### OTP Verification

!\[OTP Verification](docs/screenshots/verify-otp.png)

\*Email-based OTP verification for account security\*



\#### Content Browsing

!\[Movies](docs/screenshots/movies.png)

\*Browse movies and shows with search and filters\*



\#### Video Player

!\[Video Player](docs/screenshots/video-player.png)

\*High-quality video streaming with controls\*



\#### My List

!\[My List](docs/screenshots/mylist.png)

\*Personal watchlist management\*



\#### Continue Watching

!\[Continue Watching](docs/screenshots/continue-watching.png)

\*Resume movies from where you left off\*



---



\### 💳 Subscription Management



\#### Membership Plans

!\[Membership](docs/screenshots/membership.png)

\*Choose from Free, Basic, Standard, or Premium plans\*



\#### Change Plan

!\[Change Plan](docs/screenshots/change-plan.png)

\*Upgrade or downgrade subscription seamlessly\*



\#### Payment Processing

!\[Payment](docs/screenshots/payment.png)

\*Secure Razorpay payment gateway integration\*



> 💡 \*\*Email Confirmation:\*\* Automated subscription confirmation emails sent after successful payment



---



\### ⚙️ Account Settings



\#### Account Management

!\[Account](docs/screenshots/account.png)

\*Manage personal information and subscription details\*



\#### Security Settings

!\[Security](docs/screenshots/security.png)

\*Password change and security options\*



\#### Device Management

!\[Devices](docs/screenshots/devices.png)

\*View and manage all logged-in devices\*



---



\### 👨‍💼 Admin Panel



\#### Admin Dashboard

!\[Admin Dashboard](docs/screenshots/admin-dashboard.png)

\*Comprehensive admin control panel with analytics\*



\#### User Management

!\[User Management](docs/screenshots/user-management.png)

\*View, edit, and delete user accounts\*



\#### Banner Management

!\[Banner Management](docs/screenshots/banner-management.png)

\*Manage homepage carousel banners\*



\#### Send Notifications

!\[Send Notifications](docs/screenshots/send-notification.png)

\*Send targeted email notifications to users with movie posters\*



---



\### 🔐 Security Features



\#### Password Reset

!\[Forgot Password](docs/screenshots/forgot-password.png)

\*Secure password recovery with OTP verification\*



\#### Reset Password

!\[Reset Password](docs/screenshots/reset-password.png)

\*Set new password after verification\*



> 🔒 \*\*Security Measures:\*\*

> - Login attempt tracking and logging

> - Device authentication and management

> - OTP-based verification for critical actions

> - Session timeout and security

> - Secure payment processing



---



\## 🧪 Testing



\### Test Credentials



\*\*Admin Account:\*\*

```

Email: admin@escape.com

Password: admin123

```



\*\*Test User:\*\*

```

Email: test@escape.com

Password: test123

```



\### Payment Testing (Razorpay Test Mode)



\*\*Test Cards:\*\*

```

Success: 4111 1111 1111 1111

CVV: Any 3 digits

Expiry: Any future date

```



\*\*Test UPI:\*\*

```

UPI ID: success@razorpay

```



\*\*Test Net Banking:\*\*

```

Select any bank from dropdown

Use test credentials provided by Razorpay

```



\## 🌐 Deployment



\### Production Deployment



\*\*Backend (Tomcat):\*\*

```bash

\# Build WAR file

mvn clean package



\# Deploy to production server

scp target/Escape.war user@server:/opt/tomcat/webapps/



\# Restart Tomcat

ssh user@server 'sudo systemctl restart tomcat'

```



\*\*Database:\*\*

\- Use managed MySQL (AWS RDS, Google Cloud SQL)

\- Enable automated backups

\- Configure replication for high availability



\*\*File Storage:\*\*

\- Move videos/images to CDN (AWS S3, Cloudflare)

\- Update paths in database



\## 🤝 For Recruiters \& Engineers



\### Quick Demo Setup (10 minutes)

1\. Clone repository

2\. Import SQL schema to MySQL

3\. Configure database credentials in `DatabaseConnection.java`

4\. Update email settings in email sender classes

5\. Import project to Eclipse

6\. Run on Tomcat server

7\. Access at `http://localhost:8080/Escape/`



\### Project Highlights

\- \*\*Built:\*\* Independent BCA project at Techno Main Salt Lake, Kolkata (2024-2025)

\- \*\*Problem Solved:\*\* Netflix-like streaming platform with complete subscription management

\- \*\*Scale:\*\* Handles multiple users, devices, payments, and content delivery

\- \*\*Architecture:\*\* MVC pattern with Servlet/JSP, session-based authentication



\### Technical Decisions

\- \*\*Java Servlets over Spring Boot:\*\* Lightweight, direct control, deeper understanding of Java EE fundamentals

\- \*\*JDBC over ORM:\*\* Fine-grained SQL control, optimized queries, better performance for read-heavy operations

\- \*\*Session-based Authentication:\*\* Simple, effective for monolithic architecture, easier debugging

\- \*\*Razorpay Integration:\*\* Best payment gateway for Indian market with UPI support

\- \*\*Gmail SMTP:\*\* Reliable email delivery with HTML templates

\- \*\*MySQL:\*\* Proven reliability, ACID compliance, excellent for relational data



\### Code Quality

\- Prepared statements throughout (SQL injection prevention)

\- Comprehensive error handling and logging

\- Transaction management for payment operations

\- Clean separation of concerns (Model-View-Controller)

\- Reusable utility classes for common operations



\## 🐛 Known Issues \& Roadmap



\### Current Limitations

\- Video upload via admin panel not implemented (manual file placement)

\- Limited video format support (MP4 primary)

\- Basic search functionality (no advanced filters)

\- Email delivery may go to spam folder (configure SPF/DKIM)

\- Password storage uses plain text (implement bcrypt hashing)



\### Planned Features

\- \[ ] \*\*Video Upload System\*\* - Admin panel video upload functionality

\- \[ ] \*\*Advanced Search\*\* - Filters by genre, year, rating

\- \[ ] \*\*User Reviews\*\* - Rating and review system

\- \[ ] \*\*Recommendations Engine\*\* - AI-powered content suggestions

\- \[ ] \*\*Watchlist Sharing\*\* - Share lists with friends

\- \[ ] \*\*Parental Controls\*\* - Content restrictions for kids

\- \[ ] \*\*Offline Downloads\*\* - Download content for offline viewing

\- \[ ] \*\*Mobile Applications\*\* - Native Android and iOS apps

\- \[ ] \*\*Social Features\*\* - Share, like, comment on content

\- \[ ] \*\*Live TV\*\* - Live streaming channels

\- \[ ] \*\*Multi-language\*\* - Content in multiple languages

\- \[ ] \*\*Subtitle Support\*\* - Multi-language subtitles

\- \[ ] \*\*4K Streaming\*\* - Ultra HD content delivery

\- \[ ] \*\*Chromecast Support\*\* - Cast to TV devices



\### Security Improvements

\- \[ ] Implement bcrypt password hashing

\- \[ ] Add CSRF token validation

\- \[ ] Rate limiting for APIs

\- \[ ] Two-factor authentication

\- \[ ] Email verification on signup

\- \[ ] Stronger session management



\## 👨‍💻 Developer



\*\*Yashraj\*\*

\- \*\*Education:\*\* BCA Graduate, Techno Main Salt Lake (2025)

\- \*\*LinkedIn:\*\* https://linkedin.com/in/yashraj-singh-dev

\- \*\*Email:\*\* yashrajsingh.mail@gmail.com

\- \*\*Portfolio:\*\* 



\### Other Projects

\- \*\*MediConnect\*\* - AI-powered healthcare platform

&nbsp; - Video consultations with doctors

&nbsp; - AI health assistant for symptom checking

&nbsp; - Payment integration (Razorpay, Stripe)

&nbsp; - Medical records management

&nbsp; - \[Main Docs](https://github.com/Yashraj-Coll/mediconnect) | \[Backend](https://github.com/Yashraj-Coll/mediconnect-backend) | \[Frontend](https://github.com/Yashraj-Coll/mediconnect-frontend)



\## 📄 License



This project is licensed under the MIT License - see the LICENSE file for details.



\## 🙏 Acknowledgments



\- \*\*Jakarta EE Community\*\* - Excellent servlet documentation

\- \*\*Razorpay\*\* - Seamless payment integration and support

\- \*\*MySQL\*\* - Robust database management system

\- \*\*Apache Tomcat\*\* - Reliable servlet container

\- \*\*Techno Main Salt Lake Faculty\*\* - Guidance and support throughout development

\- \*\*Open Source Community\*\* - Libraries and tools that made this possible



\*\*⭐ If you find this project helpful, please star the repository! ⭐\*\*



\*\*Built with ❤️ by Yashraj\*\*

---



\*\*© 2025 ESCAPE OTT Platform. All Rights Reserved.\*\*



</div>


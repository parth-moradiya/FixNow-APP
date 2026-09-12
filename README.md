# 🔧 FixNow – Home Service Booking Application

FixNow is a Flutter-based service booking application designed to connect customers with local service providers through a simple and organised digital platform.

The application allows customers to browse different home-service categories, find suitable service providers, view provider information, request bookings, manage their bookings, provide ratings and reviews, and maintain their profile.

Service providers can create and manage their service profiles, receive customer booking requests, accept or decline requests, manage jobs, view earnings, receive customer feedback, and update their availability.

The system also includes an administrative section that allows administrators to monitor users, bookings, service categories, reports, and overall platform activity.

---

## 📌 Project Overview

Finding reliable home-service professionals can often require customers to contact multiple providers individually.

FixNow is designed to simplify this process by providing a single application where customers can discover service providers and request services such as:

- Plumbing
- Electrical work
- Cleaning
- Painting
- Carpentry
- Appliance repair

The application supports three main user roles:

1. Customer
2. Service Provider
3. Administrator

Each role receives a different interface and functionality depending on their responsibilities within the system.

---

# 🎯 Project Objectives

The main objectives of FixNow are to:

- Provide customers with an easy way to discover home-service providers.
- Allow customers to request and manage service bookings.
- Allow service providers to manage incoming service requests.
- Support provider profile creation and service information.
- Allow customers to review and rate completed services.
- Allow service providers to monitor their jobs and earnings.
- Provide administrators with tools to monitor the overall platform.
- Maintain a clear and user-friendly interface.
- Separate application functionality based on user roles.
- Provide a structured and maintainable Flutter application architecture.

---

# 👥 User Roles

## 👤 Customer

Customers use FixNow to find and book service providers.

Customer functionality includes:

- Account registration
- User login
- Browse service categories
- Discover available service providers
- View service provider profiles
- View provider ratings
- View service pricing
- Request a service booking
- Select preferred booking date
- Select preferred booking time
- Enter service address
- Track booking status
- View booking details
- Cancel eligible bookings
- Rate completed services
- Write service reviews
- View notifications
- Edit profile information
- View payment history

---

## 🧰 Service Provider

Service providers use FixNow to manage the services they offer and handle customer requests.

Provider functionality includes:

- Provider registration and login
- Service profile setup
- Select service category
- Add professional biography or experience
- Set service price
- Manage availability
- Receive booking requests
- Review booking information
- Accept customer requests
- Decline customer requests
- Manage active jobs
- View completed jobs
- Monitor earnings
- View customer ratings
- View customer feedback
- Edit service profile
- Receive notifications

---

## 🛡️ Administrator

The administrator is responsible for monitoring and managing the FixNow platform.

Administrator functionality includes:

- Admin dashboard
- Platform overview
- Manage registered customers
- Manage service providers
- Monitor service bookings
- View booking information
- Manage service categories
- Add new service categories
- Monitor platform activity
- View reports
- View booking statistics
- Send announcements to users

---

# ✨ Main Features

## 🔐 Authentication

FixNow includes authentication functionality to support registered users.

The authentication interface provides:

- Login
- Registration
- Role-based account creation
- Password reset interface
- Authentication state management
- Role-based navigation

Firebase Authentication is used as part of the authentication architecture.

---

## 👥 Role-Based Access

After authentication, users are directed to different areas of the application depending on their role.

The application supports:

```text
Customer
Service Provider
Administrator

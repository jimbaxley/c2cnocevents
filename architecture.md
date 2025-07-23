# Gatherings - Event Notifications App Architecture

## Overview
A native Flutter app that displays event cards with notification capabilities, requiring no user sign-in. The app will recreate the Framer design aesthetics with a modern, beautiful interface.

## Core Requirements
- Display event cards with modern, mind-blowing design
- Send notifications to any user (no authentication required)
- Use local storage for user preferences
- Support both light and dark themes
- Integrate with Coda.io API for event data

## Technical Architecture

### 1. Data Layer
- **Models**: Event, Notification, UserPreferences
- **Services**: EventService (API integration), NotificationService, LocalStorageService
- **Sample Data**: Realistic events with images, dates, locations, descriptions

### 2. UI Layer (10 files max)
- **Screens**: 
  - HomeScreen (event list)
  - EventDetailScreen (detailed event view)
  - NotificationSettingsScreen (user preferences)
- **Components**:
  - EventCard (reusable card component)
  - NotificationPanel (notification management)
- **Widgets**: Custom animations, transitions, and UI elements

### 3. Business Logic
- Event data fetching and caching
- Notification scheduling and delivery
- User preference management (stored locally)
- Event filtering and search

### 4. Key Features
- **Modern Event Cards**: Gradient backgrounds, rounded corners, engaging visuals
- **Notification System**: Local notifications with customizable preferences
- **Responsive Design**: Adaptive layout for different screen sizes
- **Smooth Animations**: Page transitions, card animations, loading states
- **Dark/Light Theme**: Automatic theme switching based on system preference

### 5. Dependencies
- http: API integration
- shared_preferences: Local storage
- flutter_local_notifications: Notification system
- cached_network_image: Image caching
- intl: Date formatting

### 6. Implementation Steps
1. Update app metadata and dependencies
2. Create data models and services
3. Implement event card components with modern design
4. Build home screen with event list
5. Add event detail screen
6. Implement notification system
7. Add user preferences screen
8. Polish animations and transitions
9. Add sample data and images
10. Test and compile the complete app

## Visual Design Goals
- Card-based layout with gradient backgrounds
- Generous whitespace and modern typography
- Engaging icons and emojis
- Smooth animations and transitions
- High contrast for accessibility
- Minimal, flat design aesthetic
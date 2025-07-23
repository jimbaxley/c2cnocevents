# Coda Integration Setup Guide

Your Flutter Events app now supports dynamic event data from Coda! This guide shows you how to set up and use the Coda integration.

## ✅ What's New

### Web-Only Coda Integration
- **Coda settings** only appear on the web version (perfect for admin use)
- **Mobile apps** continue to show events seamlessly
- **Data source indicator** shows whether you're viewing Coda or sample data

### Dynamic Event Population
- Events automatically populate from your Coda table
- **Fallback to sample data** if Coda is unavailable
- **Live refresh** capability to sync latest events
- **Schema-aware parsing** handles various Coda column formats

## 🚀 Quick Setup

### 1. Create Your Coda Table

Create a new Coda document with a table containing these columns:

| Column Name | Type | Required | Description |
|-------------|------|----------|-------------|
| Title | Text | ✅ | Event name |
| Description | Text | ✅ | Event details |
| Start Date | Date | ✅ | When event starts |
| End Date | Date | ✅ | When event ends |
| Location | Text | ✅ | Event location |
| Category | Text | ✅ | Event type (PHONE BANK, CANVASS, etc.) |
| Organizer | Text | ✅ | Who's organizing |
| Image URL | URL | ⚠️ | Event image (optional) |
| Price | Number | ⚠️ | Ticket price (optional) |
| Max Attendees | Number | ⚠️ | Capacity (optional) |
| Current Attendees | Number | ⚠️ | Current registrations (optional) |
| Tags | Text | ⚠️ | Comma-separated tags (optional) |

### 2. Get API Credentials

1. **API Token**: Go to [Coda Account Settings](https://coda.io/account) → API → Generate Token
2. **Document ID**: Copy from your Coda URL: `coda.io/d/Your-Doc_dABC123XYZ` → ID is `ABC123XYZ`
3. **Table ID**: Use Coda API or inspect network requests to find your table ID

### 3. Configure in App

1. Open your web app at http://localhost:3000
2. Click the settings gear (⚙️) in the top right
3. Select **"Coda Integration"**
4. Enter your credentials
5. Click **"Test Connection"** to verify
6. **Enable Coda Integration** toggle
7. Click **"Save Settings"**

## 🔧 Features

### Smart Data Handling
- **Auto-fallback**: If Coda fails, shows sample data
- **Column flexibility**: Handles various Coda column naming patterns
- **Default images**: Provides beautiful defaults if no image URL
- **Error handling**: Graceful error messages for connection issues

### Development-Friendly
- **Data source indicator**: See at a glance what data you're viewing
- **Live refresh**: Update events without app restart
- **Test connection**: Verify setup before enabling
- **Web-only admin**: Keep mobile simple, manage from web

### Schema Mapping
The integration handles multiple column name formats:
- Standard: `Title`, `Description`, `Start Date`, etc.
- Column IDs: `c-title`, `c-description`, etc.
- Case variations and spacing differences

## 📱 Usage Patterns

### For Development
1. **Web interface**: Configure Coda, manage events, test changes
2. **Mobile preview**: View events as users will see them
3. **Live updates**: Change data in Coda, refresh in app

### For Production
1. **Content managers**: Update events in Coda
2. **App automatically syncs**: No code changes needed
3. **Fallback protection**: App works even if Coda is down

## 🛠 Troubleshooting

### Connection Issues
- **401 Unauthorized**: Check API token
- **404 Not Found**: Verify document/table IDs
- **Rate limits**: Coda API has usage limits
- **CORS errors**: Only affects web version, mobile unaffected

### Data Issues
- **Missing events**: Check table column names match expected format
- **Image not showing**: Ensure Image URL column contains valid URLs
- **Date parsing errors**: Use standard date formats (YYYY-MM-DD)

### App Issues
- **Settings not saving**: Check browser localStorage permissions
- **Hot reload issues**: Restart Flutter if changes don't appear
- **Build errors**: Run `flutter clean && flutter pub get`

## 📊 Sample Data

### Example Coda Row
```
Title: Summer Community Festival
Description: Join us for a day of music, food, and fun at the annual community festival
Start Date: 2025-08-15
End Date: 2025-08-15
Location: Central Park Pavilion
Category: COMMUNITY
Organizer: Parks & Recreation Department
Image URL: https://images.unsplash.com/photo-1506905925346-21bda4d32df4
Price: 0
Max Attendees: 500
Current Attendees: 150
Tags: festival,community,outdoor,family-friendly
```

## 🔄 Data Flow

```
Coda Table → CodaService → EventService → UI Components
     ↓
Sample Data (fallback) → EventService → UI Components
```

1. **User opens app** → EventService checks if Coda enabled
2. **If Coda enabled** → Attempts to fetch from CodaService
3. **If successful** → Displays Coda events
4. **If failed** → Falls back to sample data
5. **Data source indicator** → Shows current source to user

## 🎯 Next Steps

### Enhance the Integration
- Add more event fields (contact info, RSVP links, etc.)
- Implement event creation from the app
- Add image upload to Coda
- Sync attendee counts back to Coda

### Scale the App
- Add user authentication
- Implement push notifications
- Add event favoriting/bookmarking
- Create admin dashboard features

The foundation is now in place for a fully dynamic, Coda-powered event management system! 🚀

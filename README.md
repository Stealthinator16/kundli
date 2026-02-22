# Kundli

A comprehensive Vedic astrology (Kundli) iOS application with AI-powered analysis. Kundli generates accurate birth charts using the Swiss Ephemeris, provides detailed astrological reports through Claude AI, and offers a full suite of traditional Jyotish tools -- from divisional charts and Dasha timelines to Panchang, Muhurta, and compatibility matching.

## Features

**Birth Chart Generation**
- Accurate planetary positions via Swiss Ephemeris integration
- Support for multiple ayanamsa systems (Lahiri, Raman, Krishnamurti)
- North Indian, South Indian, and Western circular chart styles
- Interactive charts with tap-to-inspect, pinch-to-zoom, and pan gestures
- Aspect line overlays with color-coded display

**Divisional Charts**
- All 16 divisional charts from D1 (Rashi) through D60 (Shashtiamsa)
- Includes D9 Navamsa, D10 Dasamsa, and all standard Varga charts
- Side-by-side comparison between any two charts

**Dasha Systems**
- Vimshottari Dasha with Maha, Antar, Pratyantar, Sookshma, and Prana sub-periods
- Yogini Dasha (36-year cycle)
- Chara Dasha (Jaimini system)
- Ashtottari Dasha (108-year cycle)

**Yoga and Dosha Detection**
- Benefic yogas: Raj Yoga, Dhana Yoga, Gaja Kesari, Panch Mahapurush, and more
- Malefic doshas: Manglik, Kaal Sarp, Pitra Dosha, Kemdrum, and others
- Detailed explanations and remedial measures for each detection

**AI-Powered Reports**
- 16 report types covering personality, career, finance, health, relationships, marriage, family, education, spirituality, travel, legal, longevity, lucky factors, year ahead, remedies, and comprehensive overview
- Streaming report generation using Claude AI
- Conversational AI chat with birth chart context for personalized Q&A
- Response caching for offline access

**Kundli Matching**
- Ashtakoot (8-gun) compatibility scoring with 36-point Gun Milan
- Manglik, Nadi, and Bhakoot Dosha checks
- Synastry aspect analysis between two charts
- Composite (midpoint) chart generation
- Marriage Muhurta recommendations

**Transit Tracking and Shadbala**
- Real-time planetary transit positions
- Sade Sati and Ashtama Shani detection
- Ashtakavarga analysis with bindus
- Shadbala (six-fold planetary strength) calculations

**Panchang and Muhurta**
- Daily Panchang with Tithi, Nakshatra, Yoga, Karana timings
- Rahu Kaal, Yamaganda, and Gulika Kaal
- Hora (planetary hour) display with 24-hour timeline
- Muhurta calculator for weddings, Griha Pravesh, business, travel, and custom events

**Festival Calendar**
- Approximately 25 Hindu festivals with dates and details
- Calendar and list view modes
- Graha Pravesh (house-warming) date calculations

**Additional Features**
- Daily, weekly, monthly, and yearly horoscope views
- Custom date reminders with push notification scheduling
- Birthday reminders for saved Kundlis
- iCloud sync across devices via CloudKit
- Onboarding carousel for new users
- Light, dark, and system theme support

## Tech Stack

- **Language:** Swift
- **UI Framework:** SwiftUI
- **Data Persistence:** SwiftData
- **Astronomical Calculations:** Swiss Ephemeris
- **AI Integration:** Claude API (Anthropic)
- **Cloud Sync:** CloudKit / iCloud
- **Secure Storage:** Keychain (for API keys)
- **Minimum Target:** iOS 17+

## Prerequisites

- Xcode 15 or later
- iOS 17.0+ deployment target
- A Claude API key (configured in-app under AI Settings)

## Setup

1. Clone the repository:
   ```
   git clone https://github.com/Stealthinator16/kundli.git
   ```
2. Open `Kundli.xcodeproj` in Xcode.
3. Build and run on a simulator or device (iOS 17+).
4. On first launch, enter your Claude API key in Settings to enable AI features.

## Project Structure

```
Kundli/
  Models/          Data models (Kundli, Planet, BirthDetails, Panchang, etc.)
  Services/
    AI/            Claude API integration, prompt building, response caching
    Calculations/  Swiss Ephemeris wrapper, Dasha, Yoga, Dosha, Transit, Shadbala
  ViewModels/      MVVM view models for each major screen
  Views/
    Chart/         Birth chart rendering and interactive overlays
    Comparison/    Synastry and composite chart views
    Dasha/         Dasha period timeline
    Matching/      Kundli matching and Gun Milan
    Calendar/      Festival calendar and Graha Pravesh
    Home/          Home screen with Panchang grid and horoscope card
    Settings/      App settings, notifications, iCloud sync
  Theme/           Colors, fonts, and style definitions
  Resources/       Ephemeris data files and education content
```

## License

This project is proprietary software. All rights reserved.

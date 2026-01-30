# Kundli App - Full Feature Roadmap

## Overview

A complete Vedic Astrology (Kundli) iOS app with AI-powered analysis, detailed reports, and conversational AI features. This document outlines all features for a production-ready app.

---

## Current State (Updated January 2026)

### Implementation Summary

| Week | Category | Status |
|------|----------|--------|
| Week 1 | Core Calculations | ✅ 100% Complete |
| Week 2 | AI Reports & Chat | ✅ 100% Complete (all 16 report types) |
| Week 3 | UI/UX Enhancements | ✅ 100% Complete |
| Week 4 | Advanced Features | ⏳ ~40% Complete |

---

### Already Implemented:

**Core Infrastructure:**
- [x] Basic project structure with SwiftUI + SwiftData
- [x] Theme system (colors, fonts, styles)
- [x] Data models (BirthDetails, Planet, Kundli, Panchang, DashaPeriod, KundliMatch)
- [x] Home screen with horoscope card, panchang grid, quick links
- [x] Birth details form with city search
- [x] Birth chart display (North & South Indian styles)
- [x] Planetary positions list
- [x] Dasha periods timeline view
- [x] Kundli matching with Gun Milan scoring (8-gun Ashtakoot)
- [x] Remedies screen with personalized recommendations
- [x] Onboarding carousel
- [x] Tab-based navigation
- [x] SwiftData persistence for saved kundlis

**Week 1 - Core Calculations:** ✅ COMPLETE
- [x] Swiss Ephemeris Integration (SwissEphemeris package)
- [x] Birth Chart Calculation Service (KundliGenerationService)
- [x] All 16 Divisional Charts (DivisionalChartService)
- [x] Vimshottari Dasha with all sub-periods (DashaCalculationService)
- [x] Yogini Dasha (YoginiDashaService)
- [x] Chara Dasha (CharaDashaService)
- [x] Ashtottari Dasha (AshtottariDashaService)
- [x] Yoga Detection (YogaDetectionService)
- [x] Dosha Detection (DoshaDetectionService)
- [x] Transit System (TransitService)
- [x] Shadbala calculations (ShadbalaService)
- [x] Ashtakavarga calculations (AshtakavargaService)

**Week 2 - AI Features:** ✅ COMPLETE
- [x] AI Integration (AIService with Claude API)
- [x] Report Generation (AIReportService with streaming support)
- [x] AI Chat Feature (AIChatService)
- [x] Chat History persistence (ChatConversation model)
- [x] AI Settings view (AISettingsView)
- [x] **All 16 AI Report Types** (AIReportType.swift):
  - personality, career, finance, health, relationships, marriage
  - family, education, spirituality, travel, legal, longevity
  - lucky, yearAhead, remedies, comprehensive
- [x] AI Response Caching (AIResponseCache.swift)
- [x] Report Section Views with markdown parsing

**Week 3 - UI & UX:** ✅ 100% COMPLETE
- [x] Panchang calculations (PanchangCalculationService)
- [x] Muhurta calculations (MuhurtaService)
- [x] Transit view (TransitView)
- [x] Settings views (SettingsView, NotificationSettingsView)
- [x] Notification system with user location support
- [x] Deep linking from notifications (DeepLink model)
- [x] Navigation coordinator (NavigationCoordinator)
- [x] App delegate with UNUserNotificationCenterDelegate
- [x] Transit notifications (Sade-Sati, Jupiter transit alerts)
- [x] **Interactive Charts** (Views/Chart/Interactions/):
  - Tap planets for quick info popup
  - Tap houses for house info popup
  - Pinch to zoom (1x-3x)
  - Pan when zoomed
  - Double-tap to reset
  - Staggered load animations
  - Haptic feedback
- [x] All 15 Divisional Chart Views (D1-D60)
- [x] Daily/Weekly/Monthly Horoscope Views (ExtendedHoroscopeView)
- [x] Fasting Day Recommendations (Remedy.swift)
- [x] **Hora Display** (HoraService, HoraView, HoraCard):
  - Current planetary hour display
  - 24-hour hora timeline
  - Day/night hora periods
  - Integration with PanchangGrid
- [x] **Aspect Lines on Charts** (AspectLinesOverlay, AspectLegendView):
  - Toggle aspect lines visibility
  - Color-coded by aspect type (trine, square, etc.)
  - Works with all chart styles
- [x] **Chart Color Themes** (AppTheme, adaptive Colors):
  - Light/Dark/System theme modes
  - Theme picker in Settings
  - Adaptive colors throughout app
- [x] **Festival Calendar** (FestivalService, FestivalCalendarView):
  - ~25 Hindu festivals
  - Calendar and list views
  - Festival details with traditions
- [x] **Western Circular Chart** (WesternCircularChart):
  - Circular zodiac wheel
  - Planet positions on wheel
  - Zodiac symbols with element colors
- [x] **Custom Date Reminders** (CustomReminder, RemindersListView):
  - SwiftData persistence
  - Create/edit/delete reminders
  - Push notification scheduling
  - Repeat intervals support
- [x] **Multi-Chart Comparison** (SynastryService, ChartComparisonView):
  - Side-by-side chart display
  - Synastry aspect calculations
  - Compatibility scoring
  - Aspect filtering by nature

**Week 4 - Advanced Features:** ⏳ ~40% COMPLETE
- [x] Local data persistence (SwiftData)
- [x] AI key secure storage (Keychain via AIKeyManager)
- [x] Horoscope views (daily/weekly/monthly/yearly)
- [x] Calculation settings (ayanamsa, house system)
- [x] Notification settings (comprehensive controls)
- [x] Performance optimizations (caching, async/await)
- [ ] iCloud sync - NOT implemented
- [ ] Premium features - NOT implemented
- [ ] Learning center - NOT implemented
- [ ] Accessibility - NOT implemented
- [ ] Localization - NOT implemented

---

## Feature Roadmap

### Week 1: Core Calculations & Data Layer

#### 1.1 Real Astronomical Calculations
- [x] **Swiss Ephemeris Integration**
  - Integrate Swiss Ephemeris library for accurate planetary positions
  - Calculate true planetary longitudes at birth time
  - Account for timezone and daylight saving
  - Support for different ayanamsa (Lahiri, Raman, Krishnamurti)

- [x] **Birth Chart Calculation Service**
  - Calculate ascendant (Lagna) based on birth time and location
  - Compute all 12 house cusps
  - Calculate planetary positions in signs and houses
  - Determine nakshatra pada for each planet
  - Calculate planetary aspects (drishti)
  - Compute planetary strengths (Shadbala)

- [x] **Divisional Charts (Varga)**
  - D-1: Rashi (Birth Chart) - already done
  - D-2: Hora (Wealth)
  - D-3: Drekkana (Siblings)
  - D-4: Chaturthamsa (Fortune, Property)
  - D-7: Saptamsa (Children)
  - D-9: Navamsa (Marriage, Dharma) - critical
  - D-10: Dasamsa (Career) - critical
  - D-12: Dwadasamsa (Parents)
  - D-16: Shodasamsa (Vehicles, Comforts)
  - D-20: Vimshamsa (Spiritual)
  - D-24: Chaturvimshamsa (Education)
  - D-27: Bhamsa (Strengths)
  - D-30: Trimshamsa (Misfortunes)
  - D-40: Khavedamsa (Auspicious effects)
  - D-45: Akshavedamsa (Character)
  - D-60: Shashtiamsa (Overall destiny)

#### 1.2 Dasha System Calculations
- [x] **Vimshottari Dasha** (120-year cycle)
  - Calculate Maha Dasha periods
  - Calculate Antar Dasha (sub-periods)
  - Calculate Pratyantar Dasha (sub-sub-periods)
  - Calculate Sookshma Dasha
  - Calculate Prana Dasha

- [x] **Other Dasha Systems**
  - Yogini Dasha (36-year cycle)
  - Chara Dasha (Jaimini)
  - Ashtottari Dasha (108-year cycle)

#### 1.3 Yoga & Dosha Detection
- [x] **Benefic Yogas**
  - Raj Yoga (power, authority)
  - Dhana Yoga (wealth)
  - Gaja Kesari Yoga (wisdom, fame)
  - Budhaditya Yoga (intelligence)
  - Panch Mahapurush Yogas (5 great combinations)
  - Lakshmi Yoga (prosperity)
  - Saraswati Yoga (learning)
  - Hamsa Yoga (virtue)
  - Malavya Yoga (luxury)
  - Bhadra Yoga (communication)
  - Ruchaka Yoga (courage)
  - Sasa Yoga (authority)
  - Neechabhanga Raj Yoga (cancellation of debilitation)

- [x] **Malefic Doshas**
  - Manglik/Kuja Dosha (Mars affliction)
  - Kaal Sarp Dosha (all planets between Rahu-Ketu)
  - Pitra Dosha (ancestral karma)
  - Nadi Dosha (matching)
  - Guru Chandal Yoga
  - Grahan Yoga (eclipse yoga)
  - Kemdrum Yoga (Moon isolation)
  - Daridra Yoga (poverty)
  - Shrapit Dosha

#### 1.4 Transit System
- [x] **Gochara (Transits)**
  - Current planetary positions
  - Ashtakavarga analysis
  - Transit predictions
  - Sade Sati (Saturn's 7.5 year transit)
  - Ashtama Shani (8th house Saturn)
  - Jupiter transit effects
  - Rahu-Ketu transit effects

---

### Week 2: AI-Powered Analysis & Reports

#### 2.1 AI Report Generation Service
- [x] **AI Integration Architecture**
  - Claude/OpenAI API integration
  - Prompt engineering for Vedic astrology context
  - Response formatting and parsing
  - Error handling and fallbacks
  - Rate limiting and caching
  - Cost optimization strategies

- [x] **Report Generation Pipeline**
  - Convert kundli data to structured prompt
  - Generate section-by-section reports
  - Combine and format final report
  - Store generated reports for offline access

#### 2.2 Comprehensive Kundli Report Sections

**All 16 AI Report Types Implemented via AIReportType.swift with streaming support:**

**A. Personality & Self Analysis** ✅ IMPLEMENTED (AIReportType: `personality`)
- [x] Overall personality traits
- [x] Ascendant (Lagna) interpretation
- [x] Sun sign characteristics
- [x] Moon sign (emotional nature)
- [x] Nakshatra personality profile
- [x] Strengths and weaknesses
- [x] Inner motivations and drives
- [x] Physical appearance tendencies
- [x] Behavioral patterns

**B. Career & Professional Life** ✅ IMPLEMENTED (AIReportType: `career`)
- [x] Career aptitude analysis
- [x] 10th house interpretation
- [x] Best suited professions
- [x] Business vs job suitability
- [x] Career growth periods (Dasha-based)
- [x] Professional challenges
- [x] Work environment preferences
- [x] Leadership potential
- [x] Entrepreneurship potential
- [x] Government job prospects
- [x] Foreign work opportunities
- [x] Career timing recommendations

**C. Finance & Wealth** ✅ IMPLEMENTED (AIReportType: `finance`)
- [x] 2nd and 11th house analysis
- [x] Wealth potential
- [x] Income sources (earned vs inherited)
- [x] Investment aptitude
- [x] Financial stability periods
- [x] Risk of losses
- [x] Property acquisition potential
- [x] Dhana Yogas analysis
- [x] Best periods for investments
- [x] Lottery/speculation luck

**D. Health & Well-being** ✅ IMPLEMENTED (AIReportType: `health`)
- [x] 6th house analysis
- [x] Vulnerable body parts (sign-based)
- [x] Chronic health tendencies
- [x] Mental health indicators
- [x] Stress patterns
- [x] Vitality and energy levels
- [x] Best periods for health
- [x] Accident-prone periods
- [x] Recommended lifestyle changes
- [x] Favorable healing modalities

**E. Relationships & Love** ✅ IMPLEMENTED (AIReportType: `relationships`)
- [x] 7th house analysis
- [x] Venus placement interpretation
- [x] Romantic nature and style
- [x] Ideal partner characteristics
- [x] Love vs arranged marriage inclination
- [x] Relationship challenges
- [x] Multiple relationship potential
- [x] Timing of relationships
- [x] Love compatibility patterns

**F. Marriage & Partnership** ✅ IMPLEMENTED (AIReportType: `marriage`)
- [x] Marriage timing (Vivah Muhurta)
- [x] Spouse characteristics prediction
- [x] Marriage stability factors
- [x] Manglik Dosha analysis
- [x] Second marriage potential
- [x] Marital happiness indicators
- [x] Challenges in marriage
- [x] Post-marriage life changes
- [x] In-law relationships

**G. Children & Progeny** ✅ IMPLEMENTED (AIReportType: `family`)
- [x] 5th house analysis
- [x] Number of children potential
- [x] Gender prediction tendencies
- [x] Timing for childbirth
- [x] Putra Dosha analysis
- [x] Children's success potential
- [x] Relationship with children
- [x] Adoption indicators
- [x] Fertility challenges

**H. Education & Learning** ✅ IMPLEMENTED (AIReportType: `education`)
- [x] 4th and 5th house analysis
- [x] Academic potential
- [x] Best fields of study
- [x] Higher education prospects
- [x] Learning style
- [x] Memory and concentration
- [x] Competitive exam success
- [x] Foreign education potential
- [x] Research aptitude
- [x] Technical vs creative inclination

**I. Family & Home** ✅ IMPLEMENTED (AIReportType: `family`)
- [x] 4th house analysis
- [x] Relationship with parents
- [x] Mother's influence
- [x] Father's influence
- [x] Sibling relationships
- [x] Joint family vs nuclear preference
- [x] Property and real estate
- [x] Domestic happiness
- [x] Ancestral property inheritance

**J. Spirituality & Dharma** ✅ IMPLEMENTED (AIReportType: `spirituality`)
- [x] 9th and 12th house analysis
- [x] Spiritual inclinations
- [x] Religious practices
- [x] Guru/teacher influence
- [x] Meditation and yoga aptitude
- [x] Pilgrimage predictions
- [x] Past life karma
- [x] Moksha potential
- [x] Charitable nature

**K. Travel & Foreign Connections** ✅ IMPLEMENTED (AIReportType: `travel`)
- [x] 9th and 12th house analysis
- [x] Foreign travel potential
- [x] Immigration prospects
- [x] Foreign settlement
- [x] Travel frequency
- [x] Best directions for travel
- [x] Purpose of foreign connections

**L. Legal & Government** ✅ IMPLEMENTED (AIReportType: `legal`)
- [x] 9th house analysis
- [x] Legal battles potential
- [x] Government favor
- [x] Political inclination
- [x] Awards and recognition

**M. Longevity & Life Phases** ✅ IMPLEMENTED (AIReportType: `longevity`)
- [x] 8th house analysis
- [x] Life expectancy indicators
- [x] Critical periods (maraka dasha)
- [x] Accident/surgery risks
- [x] Recovery capabilities
- [x] Life transformation periods

**N. Lucky & Unlucky Factors** ✅ IMPLEMENTED (AIReportType: `lucky`)
- [x] Lucky numbers
- [x] Lucky colors
- [x] Lucky gemstones
- [x] Lucky days
- [x] Lucky directions
- [x] Favorable deities
- [x] Unlucky periods to avoid
- [x] Auspicious muhurtas

**O. Year-by-Year Predictions** ✅ IMPLEMENTED (AIReportType: `yearAhead`)
- [x] Current year analysis
- [x] Month-by-month breakdown
- [x] Key dates and events
- [x] Transit impacts
- [x] Dasha period effects
- [x] Recommendations for each period

**P. Remedial Measures** ✅ IMPLEMENTED (AIReportType: `remedies` + RemedyGenerationService)
- [x] Personalized gemstone recommendations
- [x] Specific mantras for planets
- [x] Charity recommendations
- [x] Fasting days
- [x] Puja and rituals
- [x] Yantra recommendations
- [x] Color therapy
- [x] Rudraksha recommendations

**Q. Comprehensive Report** ✅ IMPLEMENTED (AIReportType: `comprehensive`)
- [x] Complete Life Overview combining all sections

#### 2.3 AI Chat Feature
- [x] **Chat Interface**
  - Conversational UI for astrology Q&A
  - Context-aware responses based on user's kundli
  - Natural language understanding
  - Multi-turn conversations
  - Suggested follow-up questions

- [x] **Chat Capabilities**
  - "Why is my career not progressing?"
  - "When will I get married?"
  - "What gemstone should I wear?"
  - "Explain my Moon placement"
  - "What does Jupiter transit mean for me?"
  - "Is this month good for starting a business?"
  - General Vedic astrology education
  - Personalized insights on any topic

- [x] **Chat History**
  - Save conversation history
  - Resume previous chats
  - Bookmark important responses
  - Share chat excerpts

---

### Week 3: Enhanced UI & User Experience

#### 3.1 Chart Visualization Enhancements
- [x] **Interactive Charts** ✅ FULLY IMPLEMENTED (Views/Chart/Interactions/)
  - Tap planets for quick info (PlanetQuickInfoPopup.swift)
  - Pinch to zoom on charts (ChartGestureHandler.swift, 1x-3x)
  - Pan around large charts (drag gesture when zoomed)
  - Highlight specific houses (HouseInfoPopup.swift with selection)
  - [x] Show/hide aspect lines (AspectLinesOverlay.swift with toggle)
  - Animation on chart load (ChartLoadAnimation.swift, staggered house animations)

- [x] **Chart Styles** ✅ FULLY IMPLEMENTED
  - North Indian (diamond) ✅ (NorthIndianChart.swift)
  - South Indian (grid) ✅ (SouthIndianChart.swift)
  - East Indian style - falls back to North Indian
  - [x] Western circular chart ✅ (WesternCircularChart.swift)
  - [x] Chart color themes ✅ (AppTheme.swift, light/dark/system)

- [x] **Divisional Chart Views** ✅ FULLY IMPLEMENTED
  - Grid view of all 16 vargas (DivisionalChartPicker.swift)
  - Quick comparison between D-1 and D-9 (toggle in BirthChartView)
  - Planetary dignity comparison across charts (DivisionalChartView.swift)
  - 15 divisional charts: D1, D2, D3, D4, D7, D9, D10, D12, D16, D20, D24, D27, D30, D40, D45, D60

#### 3.2 Enhanced Matching Features
- [x] **Advanced Compatibility Analysis** ✅ IMPLEMENTED (KundliMatchingView.swift)
  - Detailed Ashtakoot analysis (all 8 guns with scores)
  - Manglik compatibility ✅
  - Nadi Dosha check ✅
  - Bhakoot Dosha analysis ✅
  - Mental compatibility score ✅
  - Physical compatibility score ✅
  - Financial compatibility ✅
  - Family compatibility ✅

- [x] **Matching Report** ✅ PARTIALLY IMPLEMENTED
  - [x] AI-generated compatibility narrative (via Gun Milan display)
  - [x] Strengths of the match
  - [x] Areas of concern
  - [x] Remedies for doshas (framework in place)
  - [ ] Recommended muhurtas for marriage (not integrated in matching)

- [x] **Multi-Chart Comparison** ✅ IMPLEMENTED (Views/Comparison/)
  - [x] Side-by-side chart view (ChartComparisonView.swift)
  - [x] Synastry aspects (SynastryService.swift, SynastryAspectList.swift)
  - [ ] Composite chart - NOT implemented

#### 3.3 Panchang Features
- [x] **Daily Panchang View** ✅ FULLY IMPLEMENTED
  - Tithi with timing
  - Nakshatra with timing
  - Yoga with timing
  - Karana with timing
  - Sunrise/Sunset
  - Moonrise/Moonset
  - Rahu Kaal
  - Yamaganda
  - Gulika Kaal
  - Abhijit Muhurta
  - Brahma Muhurta
  - Durmuhurta

- [x] **Muhurta Calculator** ✅ FULLY IMPLEMENTED (MuhurtaService.swift)
  - Wedding muhurta
  - Griha Pravesh muhurta
  - Vehicle purchase muhurta
  - Business start muhurta
  - Travel muhurta
  - Custom event muhurta finder

- [x] **Hora (Planetary Hours)** ✅ FULLY IMPLEMENTED
  - Hora implemented as D-2 (Hora) Divisional Chart for wealth analysis
  - [x] Current hora time display (HoraCard.swift on home screen)
  - [x] Full hora timeline (HoraView.swift with day/night periods)
  - [x] HoraService.swift for calculating planetary hour periods

- [x] **Festival Calendar** ✅ FULLY IMPLEMENTED
  - [x] Hindu festivals with dates (FestivalService.swift with ~25 festivals)
  - [x] Festival calendar view (FestivalCalendarView.swift)
  - [x] Festival detail view (FestivalDetailView.swift)
  - [x] Calendar/list view toggle
  - [x] Fasting days (Ekadashi, Pradosh, etc.) - via Remedy.swift FastingDay struct
  - [x] Solar/Lunar eclipse alerts - via Grahan Dosha detection
  - [ ] Graha Pravesh dates - NOT implemented

#### 3.4 Notifications & Reminders
- [x] **Daily Notifications** ✅ FULLY IMPLEMENTED (NotificationService.swift)
  - Morning panchang summary
  - Rahu Kaal alert (with configurable minutes before: 5,10,15,30,60)
  - Lucky time of the day
  - Daily horoscope push

- [x] **Periodic Reminders** ✅ FULLY IMPLEMENTED
  - Dasha period change alerts (with days before: 1,3,7,14,30)
  - Transit alerts (major planets)
  - Sade Sati alerts
  - Festival reminders
  - Fasting day reminders

- [x] **Custom Alerts** ✅ FULLY IMPLEMENTED
  - [x] Muhurta alerts (Abhijit and Brahma Muhurta reminders)
  - [x] Custom date reminders (CustomReminder.swift model)
  - [x] Reminder creation UI (CreateReminderView.swift)
  - [x] Reminder list management (RemindersListView.swift)
  - [x] Push notification scheduling (NotificationService.swift)
  - [ ] Birthday kundli reminders - NOT implemented

---

### Week 4: Advanced Features & Polish

#### 4.1 User Account & Data
- [x] **Profile Management** ✅ PARTIALLY IMPLEMENTED
  - [ ] User registration (optional) - NOT implemented
  - [ ] iCloud sync for kundlis - NOT implemented
  - [x] Multiple profiles (family members) - via SavedKundli SwiftData
  - [ ] Profile photos - NOT implemented
  - [x] Nickname for each kundli - name field in BirthDetails

- [x] **Data Management** ✅ PARTIALLY IMPLEMENTED
  - [ ] Export all data - NOT implemented
  - [ ] Import kundli data - NOT implemented
  - [ ] Backup to iCloud - NOT implemented
  - [x] Share kundli with others - via AI report sharing
  - [ ] Delete account option - NOT implemented (no accounts)
  - [x] Local persistence via SwiftData (SavedKundli.swift)
  - [x] AI API key stored securely in Keychain (AIKeyManager.swift)

#### 4.2 Horoscope Features ✅ FULLY IMPLEMENTED
- [x] **Daily Horoscope** (ExtendedHoroscopeView.swift, HoroscopeDetailView.swift)
  - Personalized based on Moon sign ✅
  - Transit-based predictions ✅
  - Lucky factors of the day (lucky number, color) ✅
  - Do's and Don'ts ✅
  - Overall rating (1-5 stars) ✅
  - Love, Career, Health individual ratings ✅

- [x] **Weekly Horoscope** (via HoroscopePeriod enum)
  - Week overview ✅
  - Best days highlighted ✅
  - Key themes for the week ✅

- [x] **Monthly Horoscope** (via HoroscopePeriod enum)
  - Month-long predictions ✅
  - Important dates ✅
  - Career, love, health breakdown ✅

- [x] **Yearly Horoscope** (via AIReportType: yearAhead)
  - Annual forecast ✅
  - Month-by-month summary ✅
  - Major life themes ✅

#### 4.3 Learning & Education
- [ ] **Astrology Basics** - NOT IMPLEMENTED
  - [ ] Introduction to Vedic astrology
  - [ ] Understanding your chart
  - [ ] Planets explained
  - [ ] Signs explained
  - [ ] Houses explained
  - [ ] Nakshatras explained
  - [ ] Dashas explained
  - [ ] Yogas explained
  - Note: AI Chat provides conversational learning on these topics

- [ ] **Glossary** - NOT IMPLEMENTED
  - [ ] Searchable term dictionary
  - [ ] Sanskrit-English translations
  - [ ] Quick reference

#### 4.4 Settings & Preferences
- [x] **Calculation Settings** ✅ IMPLEMENTED (CalculationSettings.swift)
  - Ayanamsa selection (Lahiri, Raman, etc.) ✅
  - House system (Equal, Placidus, etc.) ✅
  - Time format (12h/24h) ✅
  - Date format preference ✅

- [x] **Display Settings** ✅ MOSTLY IMPLEMENTED
  - [x] Default chart style (North/South/Western picker)
  - [x] Color theme (dark/light/system) - AppTheme.swift
  - [x] Theme picker in Settings (SettingsView.swift)
  - [x] Adaptive colors (Colors.swift with light/dark variants)
  - [ ] Language preference (English/Hindi) - English only
  - [ ] Font size - NOT adjustable
  - [x] Theme system implemented (Colors.swift, Fonts.swift, Styles.swift)

- [x] **Notification Settings** ✅ FULLY IMPLEMENTED (NotificationSettingsView.swift)
  - Enable/disable categories ✅
  - Quiet hours ✅
  - Notification sound ✅
  - Individual toggles for each notification type ✅

- [ ] **Privacy Settings** - NOT IMPLEMENTED
  - [ ] Data collection preferences
  - [ ] Analytics opt-out
  - [ ] Delete all data

#### 4.5 Premium Features (Monetization) - NOT IMPLEMENTED
- [ ] **Free Tier**
  - Basic kundli generation
  - North Indian chart
  - Basic planetary positions
  - Daily panchang
  - Limited AI interactions (3/day)

- [ ] **Premium Subscription**
  - All divisional charts
  - Full AI report (all sections)
  - Unlimited AI chat
  - Advanced matching
  - Muhurta calculator
  - No ads
  - Priority support

- [ ] **One-time Purchases**
  - Detailed marriage report
  - Career guidance report
  - Child birth report
  - Year ahead report

**Note: Currently all features are free - no StoreKit/IAP integration**

#### 4.6 Technical Polish
- [x] **Performance** ✅ PARTIALLY IMPLEMENTED
  - [x] Lazy loading for charts (via SwiftUI's lazy views)
  - [x] Background calculation (async/await throughout)
  - [x] Image caching (via SwiftUI's default caching)
  - [x] Offline mode for saved kundlis (SwiftData local storage)
  - [x] AI response caching (AIResponseCache.swift)

- [ ] **Accessibility** - NOT IMPLEMENTED
  - [ ] VoiceOver support
  - [ ] Dynamic type
  - [ ] High contrast mode
  - [ ] Reduce motion option

- [ ] **Localization** - NOT IMPLEMENTED
  - [ ] Hindi language support
  - [ ] Regional Indian languages (future)
  - [ ] RTL support preparation

- [ ] **Analytics & Monitoring** - NOT IMPLEMENTED
  - [ ] Firebase Analytics integration
  - [ ] Crash reporting
  - User behavior tracking
  - A/B testing framework

---

## Technical Architecture

### Services Layer

```
Services/
├── AstrologyCalculationService.swift    # Core calculations
├── SwissEphemerisWrapper.swift          # Ephemeris integration
├── AIService.swift                       # Claude/OpenAI integration
├── ReportGenerationService.swift         # AI report builder
├── ChatService.swift                     # AI chat handler
├── TransitService.swift                  # Transit calculations
├── MuhurtaService.swift                  # Muhurta calculations
├── NotificationService.swift             # Push notifications
├── SyncService.swift                     # iCloud sync
├── AnalyticsService.swift                # Analytics
├── PurchaseService.swift                 # In-app purchases
└── LocationService.swift                 # Geocoding
```

### New Models

```
Models/
├── AIReport.swift                        # Generated report structure
├── ChatMessage.swift                     # Chat history
├── ChatSession.swift                     # Chat context
├── Transit.swift                         # Transit data
├── Muhurta.swift                         # Auspicious timing
├── Yoga.swift                            # Yoga combinations
├── Dosha.swift                           # Dosha definitions
├── Subscription.swift                    # Premium status
├── UserProfile.swift                     # Account data
└── Notification.swift                    # Notification config
```

### New Views

```
Views/
├── AI/
│   ├── AIReportView.swift               # Full report display
│   ├── ReportSectionView.swift          # Individual section
│   ├── ChatView.swift                   # AI chat interface
│   ├── ChatBubbleView.swift             # Message bubble
│   └── SuggestedQuestionsView.swift     # Quick prompts
├── Report/
│   ├── FullReportView.swift             # Complete report
│   ├── CareerReportView.swift           # Career section
│   ├── HealthReportView.swift           # Health section
│   ├── RelationshipReportView.swift     # Love/Marriage
│   ├── FinanceReportView.swift          # Wealth section
│   ├── FamilyReportView.swift           # Family section
│   ├── SpiritualityReportView.swift     # Dharma section
│   └── RemediesReportView.swift         # Personalized remedies
├── Transit/
│   ├── TransitView.swift                # Current transits
│   ├── SadeSatiView.swift               # Saturn transit
│   └── TransitCalendarView.swift        # Transit timeline
├── Muhurta/
│   ├── MuhurtaFinderView.swift          # Find muhurta
│   └── MuhurtaResultView.swift          # Muhurta details
├── Horoscope/
│   ├── DailyHoroscopeView.swift         # Daily predictions
│   ├── WeeklyHoroscopeView.swift        # Weekly overview
│   ├── MonthlyHoroscopeView.swift       # Monthly forecast
│   └── YearlyHoroscopeView.swift        # Annual predictions
├── Learn/
│   ├── LearnHubView.swift               # Learning center
│   ├── ArticleView.swift                # Educational content
│   └── GlossaryView.swift               # Term dictionary
├── Premium/
│   ├── SubscriptionView.swift           # Paywall
│   ├── PurchaseView.swift               # One-time purchases
│   └── RestorePurchasesView.swift       # Restore
└── Settings/
    ├── SettingsView.swift               # Main settings
    ├── CalculationSettingsView.swift    # Astro settings
    ├── NotificationSettingsView.swift   # Alert preferences
    └── PrivacySettingsView.swift        # Data & privacy
```

---

## AI Prompt Strategy

### Report Generation Prompts

Each report section will use a specialized prompt:

```
CAREER_PROMPT = """
You are an expert Vedic astrologer analyzing a birth chart for career insights.

Birth Details:
- Ascendant: {ascendant} at {degree}°
- 10th House Lord: {10th_lord} in {house} house
- 10th House Planets: {planets_in_10th}
- Sun Position: {sun_sign}, {sun_house} house
- Mercury Position: {mercury_sign}, {mercury_house} house
- Saturn Position: {saturn_sign}, {saturn_house} house
- Jupiter Position: {jupiter_sign}, {jupiter_house} house
- D-10 (Dasamsa) Summary: {dasamsa_summary}
- Current Dasha: {current_dasha}

Relevant Yogas: {career_yogas}

Provide a comprehensive career analysis covering:
1. Overall career aptitude
2. Best suited professions (top 5)
3. Career strengths
4. Potential challenges
5. Best periods for career growth (next 5 years)
6. Specific recommendations

Use professional yet accessible language.
"""
```

### Chat System Prompt

```
CHAT_SYSTEM_PROMPT = """
You are an expert Vedic astrologer assistant. You have access to the user's birth chart:

{full_kundli_data}

Guidelines:
1. Answer questions based on their actual chart data
2. Cite specific planetary positions when relevant
3. Be encouraging but honest about challenges
4. Suggest remedies when appropriate
5. If asked about timing, reference dasha periods
6. Use simple language, explain Sanskrit terms
7. Never make alarming predictions about death/severe illness
8. Encourage consultation with a professional for major decisions
"""
```

---

## Data Flow

```
User Input (Birth Details)
        ↓
Swiss Ephemeris Calculation
        ↓
Kundli Object (planets, houses, charts)
        ↓
    ┌───┴───┐
    ↓       ↓
UI Display  AI Analysis
    ↓       ↓
Chart Views Report Generation
    ↓       ↓
Save to DB  Display Report
    ↓       ↓
    └───┬───┘
        ↓
    AI Chat (contextual)
```

---

## Testing Strategy

### Core Principle
**Every feature must have unit tests written BEFORE or alongside implementation. No feature is considered complete until its tests pass.**

### Test-Driven Development (TDD) Approach
1. Write failing tests first (Red)
2. Implement minimum code to pass tests (Green)
3. Refactor while keeping tests passing (Refactor)
4. Verify all tests pass before moving to next feature

### Test Structure

```
KundliTests/
├── Services/
│   ├── AstrologyCalculationServiceTests.swift
│   ├── SwissEphemerisWrapperTests.swift
│   ├── AIServiceTests.swift
│   ├── ReportGenerationServiceTests.swift
│   ├── ChatServiceTests.swift
│   ├── TransitServiceTests.swift
│   ├── MuhurtaServiceTests.swift
│   ├── DashaCalculationServiceTests.swift
│   ├── YogaDetectionServiceTests.swift
│   └── DoshaDetectionServiceTests.swift
├── Models/
│   ├── KundliTests.swift
│   ├── PlanetTests.swift
│   ├── BirthDetailsTests.swift
│   ├── DashaPeriodTests.swift
│   ├── YogaTests.swift
│   ├── DoshaTests.swift
│   └── TransitTests.swift
├── Calculations/
│   ├── PlanetaryPositionTests.swift
│   ├── HouseCuspTests.swift
│   ├── NakshatraTests.swift
│   ├── DivisionalChartTests.swift
│   ├── AshtakavargaTests.swift
│   └── ShadBalaTests.swift
├── ViewModels/
│   ├── KundliViewModelTests.swift
│   ├── MatchingViewModelTests.swift
│   ├── PanchangViewModelTests.swift
│   └── ChatViewModelTests.swift
└── Integration/
    ├── KundliGenerationIntegrationTests.swift
    ├── AIReportIntegrationTests.swift
    └── MatchingIntegrationTests.swift
```

### Week 1 Testing Requirements

#### 1.1 Swiss Ephemeris Tests
```swift
// Test cases required:
- testPlanetaryPositionAccuracy()      // Compare against known ephemeris data
- testAscendantCalculation()           // Verify Lagna for known birth times
- testTimezoneHandling()               // DST and timezone edge cases
- testAyanamsaConversion()             // Lahiri, Raman, Krishnamurti values
- testHouseCuspCalculation()           // All 12 houses for sample charts
```

#### 1.2 Divisional Chart Tests
```swift
// Test cases required for EACH divisional chart (D-1 to D-60):
- testDivisionalChartCalculation()     // Correct planet placement
- testDivisionalChartAgainstReference() // Compare with standard software
- testEdgeCaseDegrees()                // 0°, 29°59' edge cases
```

#### 1.3 Dasha Calculation Tests
```swift
// Test cases required:
- testMahaDashaPeriods()               // Correct duration and sequence
- testAntarDashaPeriods()              // Sub-periods within Maha Dasha
- testPratyantarDashaPeriods()         // Sub-sub-periods
- testDashaStartDate()                 // Based on Moon nakshatra balance
- testDashaForKnownCharts()            // Verify against reference charts
```

#### 1.4 Yoga & Dosha Detection Tests
```swift
// Test cases required for EACH yoga/dosha:
- testRajYogaDetection()               // Various Raj Yoga combinations
- testDhanaYogaDetection()             // Wealth yoga detection
- testGajaKesariYogaDetection()        // Jupiter-Moon combination
- testManglikDoshaDetection()          // Mars in 1,4,7,8,12 houses
- testKaalSarpDoshaDetection()         // All planets between Rahu-Ketu
- testFalsePositiveYogas()             // Ensure no incorrect detections
- testFalsePositiveDoshas()            // Ensure no incorrect detections
```

### Week 2 Testing Requirements

#### 2.1 AI Service Tests
```swift
// Test cases required:
- testAPIConnectionSuccess()           // Successful API call
- testAPIConnectionFailure()           // Graceful error handling
- testRateLimiting()                   // Rate limit handling
- testResponseParsing()                // Correct parsing of AI response
- testPromptGeneration()               // Correct prompt from kundli data
- testCachingMechanism()               // Response caching works
```

#### 2.2 Report Generation Tests
```swift
// Test cases required for EACH report section:
- testCareerReportGeneration()         // Career section content
- testHealthReportGeneration()         // Health section content
- testRelationshipReportGeneration()   // Relationship content
- testReportPersonalization()          // Reports reflect actual chart
- testReportOfflineStorage()           // Reports persist correctly
- testReportSectionCompleteness()      // All sections have content
```

#### 2.3 Chat Service Tests
```swift
// Test cases required:
- testChatContextIncludesKundli()      // Kundli data in context
- testMultiTurnConversation()          // Context maintained
- testChatHistorySave()                // Messages persist
- testChatHistoryRetrieve()            // Messages load correctly
- testSuggestedQuestionsRelevance()    // Suggestions match chart
```

### Week 3 Testing Requirements

#### 3.1 Matching Tests
```swift
// Test cases required:
- testAshtakootScoreCalculation()      // 36-point Gun Milan
- testIndividualKootaScores()          // Each of 8 koota scores
- testManglikCompatibility()           // Manglik matching logic
- testNadiDoshaDetection()             // Nadi matching
- testMatchingReportGeneration()       // AI compatibility report
- testKnownCompatibleCharts()          // Verify against known matches
```

#### 3.2 Panchang Tests
```swift
// Test cases required:
- testTithiCalculation()               // Lunar day calculation
- testNakshatraCalculation()           // Current nakshatra
- testYogaCalculation()                // Panchang yoga (not chart yoga)
- testKaranaCalculation()              // Half-tithi calculation
- testRahuKaalCalculation()            // Rahu Kaal timing
- testMuhurtaFinder()                  // Auspicious time finding
- testSunriseSunset()                  // Accurate for location
```

#### 3.3 Transit Tests
```swift
// Test cases required:
- testCurrentTransitPositions()        // Real-time accuracy
- testSadeSatiDetection()              // Saturn transit over Moon
- testAshtakavargaCalculation()        // Bindus in each sign
- testTransitPredictions()             // Transit effect calculation
```

### Week 4 Testing Requirements

#### 4.1 Data Persistence Tests
```swift
// Test cases required:
- testKundliSaveAndLoad()              // SwiftData persistence
- testProfileManagement()              // Multiple profiles
- testiCloudSync()                     // Sync functionality
- testDataExport()                     // Export format correct
- testDataImport()                     // Import restores correctly
- testDataMigration()                  // App update handling
```

#### 4.2 Premium Feature Tests
```swift
// Test cases required:
- testFreeTierLimitations()            // Features correctly limited
- testPremiumUnlock()                  // Premium features enable
- testPurchaseFlow()                   // In-app purchase works
- testRestorePurchase()                // Restore functionality
```

### Reference Data for Testing

#### Known Birth Charts for Verification
Use these reference charts with known, verified planetary positions:

1. **Test Chart 1**: Jan 1, 2000, 12:00 PM, New Delhi
   - Expected positions documented
   - Expected Dasha periods documented
   - Expected Yogas documented

2. **Test Chart 2**: Jul 15, 1985, 5:30 AM, Mumbai
   - Known Manglik status
   - Known Sade Sati periods
   - Verified Navamsa positions

3. **Test Chart 3**: Dec 31, 1990, 11:59 PM, Chennai
   - Edge case: near midnight
   - Edge case: year boundary
   - Verified divisional charts

#### External Verification Sources
- Jagannatha Hora software (free, accurate)
- Astro-Sage online calculator
- Published ephemeris tables
- Standard astrological almanacs

### Test Coverage Requirements

| Component | Minimum Coverage |
|-----------|------------------|
| Calculation Services | 95% |
| Data Models | 90% |
| AI Services | 80% |
| View Models | 85% |
| Integration Tests | Key flows |

### Continuous Integration

- All tests must pass before merging any feature
- Run tests on every commit
- Automated test reporting
- Performance benchmarks for calculations

### Testing Commands

```bash
# Run all tests
xcodebuild test -scheme Kundli -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test class
xcodebuild test -scheme Kundli -only-testing:KundliTests/AstrologyCalculationServiceTests

# Run with coverage report
xcodebuild test -scheme Kundli -enableCodeCoverage YES
```

---

## Verification Checklist

### Core Functionality
- [ ] Accurate planetary calculations (verify against standard almanacs)
- [ ] Correct divisional chart generation
- [ ] Dasha period calculations match standard software
- [ ] Yoga/Dosha detection accuracy
- [ ] Transit calculations real-time
- [ ] **All calculation tests passing (95%+ coverage)**

### AI Features
- [ ] Report generation covers all sections
- [ ] Reports are personalized to chart data
- [ ] Chat responses are contextually relevant
- [ ] AI handles edge cases gracefully
- [ ] Response times are acceptable (<10s)
- [ ] **All AI service tests passing (80%+ coverage)**

### User Experience
- [ ] Smooth animations and transitions
- [ ] No lag on chart rendering
- [ ] Offline mode works for saved data
- [ ] Deep links work correctly
- [ ] Notifications fire at correct times
- [ ] **All ViewModel tests passing (85%+ coverage)**

### Data Integrity
- [ ] Kundlis save and load correctly
- [ ] iCloud sync works both ways
- [ ] Export/import maintains fidelity
- [ ] No data loss on app update
- [ ] **All persistence tests passing (90%+ coverage)**

### Testing Sign-off
- [ ] All unit tests written and passing
- [ ] Integration tests for critical paths
- [ ] Performance benchmarks met
- [ ] Edge cases covered
- [ ] Test coverage meets minimums

---

## Priority Order for Implementation

### Must Have (Week 1-2)
1. Real astronomical calculations (Swiss Ephemeris)
2. All divisional charts
3. AI report generation (at least 5 sections)
4. Basic AI chat

### Should Have (Week 3)
5. Full AI report (all sections)
6. Enhanced matching features
7. Muhurta calculator
8. Transit view
9. Advanced chat features

### Nice to Have (Week 4)
10. Premium subscription
11. iCloud sync
12. Push notifications
13. Horoscope features
14. Learning center

---

## Dependencies & Resources

### External Libraries
- Swiss Ephemeris (planetary calculations)
- Anthropic SDK / OpenAI SDK (AI features)
- Firebase (analytics, crash reporting)
- RevenueCat (subscriptions)

### APIs
- Claude API or OpenAI API (report generation, chat)
- Google Places API (city search enhancement)
- Firebase Cloud Messaging (push notifications)

### Design Assets
- Chart illustrations
- Planet symbols
- Zodiac icons
- App icons and splash

---

## Implementation Rules

### Mandatory Testing Protocol
1. **No feature is complete without tests** - Every service, model, and calculation MUST have corresponding unit tests
2. **Write tests first or alongside code** - Never move to the next feature until tests pass
3. **Verify against known data** - Use reference charts and standard software to validate calculations
4. **Test edge cases** - 0° positions, midnight births, timezone boundaries, leap years
5. **Run full test suite before each commit** - All tests must pass

### Definition of Done (For Each Feature)
- [ ] Feature implemented
- [ ] Unit tests written
- [ ] Unit tests passing
- [ ] Verified against reference data (for calculations)
- [ ] Edge cases tested
- [ ] Code reviewed
- [ ] Integrated with existing code
- [ ] No regressions in existing tests

### Weekly Testing Milestones

| Week | Testing Milestone |
|------|-------------------|
| Week 1 | All calculation services have 95%+ test coverage. Verified against Jagannatha Hora. |
| Week 2 | AI services have 80%+ coverage. Report generation tested with mock data. |
| Week 3 | Matching and Panchang services fully tested. UI ViewModels at 85%+ coverage. |
| Week 4 | Full integration tests. All persistence and sync tests passing. |

---

*This plan will be implemented incrementally. **Each feature MUST have unit tests written and verified against known reference data before moving to the next feature.** No exceptions.*

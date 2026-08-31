# Arcade Hub Application Guide

## 1. Business Context & Mental Model

The most important thing to understand about this application is:

> **Arcade Hub is an entertainment venue first, with food and beverage ordering as one of its services.**

It is **not a restaurant application**.

Arcade Hub has multiple physical experiences/areas:

1. **Playroom** — Sunny Yellow
2. **Party Room** — Signal Red
3. **Rooftop Restro** — White
4. **Sports Bar** — Neon Green
5. **Area 51** — Purple
6. **Easy Room** — Blue

These six areas are **venue experiences**, not food categories.

### Correct mental model

```text
                         ARCADE HUB
                              │
              ┌───────────────┴───────────────┐
              │                               │
         EXPERIENCES                       SERVICES
              │                               │
     ┌────────┼────────┐              ┌───────┴───────┐
     │        │        │              │               │
 Playroom  Party    Sports         Food &          Gaming/
           Room      Bar           Drinks          Rental
     │        │        │              │               │
 Rooftop   Area 51   Easy Room     Rebuzz POS       PS5*
```

`*` PS5 rental is a known business requirement, but the exact booking/fulfillment flow still needs confirmation.

### VERY IMPORTANT

Never treat the six experiences as POS/menu categories.

Incorrect:

```text
Playroom
 ├── Pizza
 ├── Burger
 └── Momo

Sports Bar
 ├── Coke
 └── Fries
```

Correct:

```text
Experiences
 ├── Playroom
 ├── Party Room
 ├── Rooftop Restro
 ├── Sports Bar
 ├── Area 51
 └── Easy Room

Order Food & Drinks
 └── Rebuzz POS
      ├── POS Category
      ├── POS Category
      └── Products
```

Food is available across the venue and is **not owned by a particular room**.

---

# 2. Application Purpose

The application acts as the **digital front door to Arcade Hub**.

A customer should be able to:

1. Discover what Arcade Hub offers.
2. Explore the six venue experiences.
3. Learn about individual areas.
4. Access available Arcade Hub services.
5. Browse food and drinks.
6. Add products to a cart.
7. Receive applicable app promotions.
8. Place orders through the existing Rebuzz POS integration.
9. Manage their account and orders.

The application should therefore balance:

**Discovery + Entertainment + Ordering**

rather than behaving like a standard restaurant menu.

---

# 3. Technical Stack

The application uses:

* **Flutter / Dart**
* **Riverpod** for state management
* **GoRouter** for navigation
* **Google Fonts**

  * Outfit
  * DM Sans
* Centralized Arcade Hub brand colors through `AppColors`

The existing Breaking Bread application/project should be used as the architectural skeleton where appropriate.

Do not rewrite existing functionality unnecessarily.

---

# 4. Core Application Structure

The application should conceptually contain these major areas:

```text
Authentication
     │
     ▼
Main Application
     │
     ├── Home / Discover
     │
     ├── Experiences
     │
     ├── Food & Drinks
     │
     ├── Cart
     │
     ├── Orders
     │
     └── Profile
```

The six experiences are a **discovery/content system**.

Food ordering is a **commerce system**.

These should remain logically separate.

---

# 5. Home Screen

The Home screen is the main entry point after authentication.

It should communicate:

> **What is Arcade Hub and what can I do here?**

### Home should contain:

## A. Header

Potential elements:

* Arcade Hub branding/logo
* Hamburger menu
* Cart access/badge

Reuse the existing header from the Breaking Bread skeleton where appropriate.

---

## B. Hero Slider

The hero carousel showcases the six Arcade Hub experiences.

Slides:

* Playroom
* Party Room
* Rooftop Restro
* Sports Bar
* Area 51
* Easy Room

The slider is primarily for **venue discovery/promotional storytelling**.

It is NOT a food carousel.

Each slide can contain:

* Experience name
* Image
* Short tagline/description
* Accent color
* CTA to explore the experience

---

## C. Experiences

Display the six experiences using an icon + name presentation.

Example:

```text
🎮        🎉        🏟️
Playroom  Party     Sports
          Room      Bar

🌃        👽        🔵
Rooftop   Area 51   Easy
Restro              Room
```

Each experience should be clickable.

---

# 6. Experience System

The six experiences should be represented through a centralized data model.

Example concept:

```dart
class ArcadeExperience {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final String? icon;
  final Color accentColor;
}
```

The six experiences should be stored in one source of truth, such as:

```text
kArcadeExperiences
```

This same dataset should power:

* Home experience grid
* Hero slider
* Hamburger navigation
* Experience detail screens
* Future promotional components

Do NOT duplicate the six experiences in multiple files.

---

# 7. Experience Detail Screen

Route:

```text
/experience/:id
```

The experience detail screen should primarily provide **information and discovery** about the selected area.

It may contain:

* Hero image
* Name
* Accent color
* Description
* Tagline
* Photos
* Available services
* Relevant CTA buttons

### IMPORTANT

Do NOT hardcode assumptions such as:

```text
Playroom → PS5
Area 51 → PS5
Rooftop → Food
Sports Bar → Food
Party Room → WhatsApp
Easy Room → Booking
```

unless these relationships have been explicitly confirmed by Arcade Hub.

The six experiences currently have names and visual identities, but the exact services offered by each area are not fully documented.

The architecture should therefore support configurable capabilities.

For example:

```dart
enum ExperienceCapability {
  foodOrdering,
  ps5Rental,
  booking,
  whatsappInquiry,
}
```

But only enable a capability once the business confirms it.

This prevents the UI from inventing business rules.

---

# 8. Food & Drinks

Food and beverage ordering is a **separate global feature**.

It is NOT nested under the six experiences.

Customers should be able to access:

```text
Order Food & Drinks
```

from the main application.

The menu should come from **Rebuzz POS**.

The app should not hardcode the actual Arcade Hub food catalogue.

Conceptually:

```text
Rebuzz POS
     │
     ▼
Categories
     │
     ▼
Products
     │
     ▼
Arcade Hub App
     │
     ▼
Customer Cart
     │
     ▼
Checkout
     │
     ▼
Order → Rebuzz POS
```

The existing Breaking Bread/Rebuzz integration should be inspected and reused.

---

# 9. POS Catalogue

The catalogue should dynamically consume data provided by Rebuzz.

Potential data may include:

* Product ID
* Product name
* Description
* Price
* Image
* Category
* Availability
* Variants
* Add-ons/modifiers

Do not assume the categories.

If Rebuzz provides:

```text
Munchies
Drinks
Burgers
```

then the app displays those.

If the POS changes them, the app should adapt accordingly.

The physical experiences must never become catalogue categories.

---

# 10. Ordering Flow

Expected ordering flow:

```text
Home
  ↓
Order Food & Drinks
  ↓
POS Categories
  ↓
Products
  ↓
Product Detail
  ↓
Add to Cart
  ↓
Cart
  ↓
Checkout
  ↓
Confirm Order
  ↓
Order Success
```

### Product Detail

Route:

```text
/product/:id
```

May contain:

* Product image
* Name
* Description
* Price
* Variants
* Add-ons/modifiers
* Quantity
* Add to Cart

Only display options that actually exist in the POS data.

---

# 11. Cart

Route:

```text
/cart
```

The cart should contain:

* Selected products
* Quantities
* Modifiers/add-ons
* Subtotal
* Applicable discount
* Tax
* Final total

The existing Breaking Bread cart implementation should be reused where possible.

Do not create a second cart system.

---

# 12. Discount System

Arcade Hub requires an app-specific promotional discount:

> **X% discount for purchases made through the app during A–B hours.**

The exact values of X, A and B are business-configurable.

Do not hardcode example values.

The system should support:

```text
discountPercentage
startTime
endTime
enabled
```

The discount should be evaluated using an appropriate authoritative time source.

Avoid relying solely on the customer's device clock for business-critical discount validation.

The final order amount should be validated by the backend/POS according to the existing Rebuzz architecture.

The frontend should not be considered the ultimate source of truth for pricing.

---

# 13. PS5 Rental

PS5 rental is a **service**, not a food/product category.

Known business information:

```text
PS5 Rental

Rental period:
9 PM → 9 AM

Base price:
NPR 2,000

Late return:
Additional charge per hour
```

The exact late hourly fee has not yet been provided.

Therefore:

* Do not invent the late fee.
* Do not hardcode an arbitrary amount.
* Keep the value configurable.
* Keep PS5 rental separate from the food catalogue.

The exact customer flow also needs confirmation.

Possible future flow:

```text
PS5 Rental
   ↓
View pricing/rules
   ↓
Check availability
   ↓
Book
   ↓
Confirmation
```

But **do not implement availability/reservation functionality unless the business confirms that customers should book through the app.**

---

# 14. Physical Location / Delivery Spot

Food can potentially be ordered to customers inside the venue.

However, the exact mechanism for identifying the customer's location has not yet been confirmed.

Do NOT hardcode examples such as:

```text
Rooftop Table #4
Playroom Couch
Sports Bar Barstool
```

unless Arcade Hub provides an actual list/system for these locations.

If the business confirms that staff need a delivery location, the application can support a configurable:

```text
Venue Location / Spot
```

system.

Possible structure:

```text
Venue
 ├── Rooftop Restro
 │    ├── Table 1
 │    ├── Table 2
 │    └── ...
 │
 ├── Sports Bar
 │    ├── Seat 1
 │    └── ...
 │
 └── Playroom
      ├── Area A
      └── ...
```

But this should only be implemented after the actual venue-location structure is provided.

---

# 15. Bottom Navigation

The current application uses:

```text
Home
Favourites
Cart
Profile
```

This can be retained if it fits the existing Breaking Bread architecture.

However, the navigation should be reviewed based on actual Arcade Hub requirements.

Potentially:

```text
Home
Explore
Cart
Profile
```

could be more natural because Arcade Hub is an experience/discovery application.

Do not change the navigation purely for aesthetic reasons if the existing project already has an established navigation pattern.

---

# 16. Hamburger Navigation

The hamburger menu should provide access to the six experiences.

Example:

```text
ARCADE HUB

Playroom
Party Room
Rooftop Restro
Sports Bar
Area 51
Easy Room

────────────

Order Food & Drinks
Cart
Orders
Profile
Contact
```

The experience list must use the centralized experience dataset.

Do not maintain a separate hardcoded navigation list.

---

# 17. Profile & Orders

### Profile

Can contain:

* User information
* Account settings
* Orders
* Favourites
* Contact/support

Only display loyalty points if an actual loyalty system exists.

Do not create a fake loyalty system simply because it existed in the Breaking Bread application.

---

### Orders

Route:

```text
/orders
```

Should show the user's previous orders if the existing backend supports order history.

Reuse the existing Breaking Bread implementation if compatible with Rebuzz.

---

# 18. Favourites

If the existing Breaking Bread application already has favourites functionality, it can be retained if it makes sense for Arcade Hub.

Favourites should primarily refer to **food/products**, unless the business explicitly wants users to favourite venue experiences.

Do not assume both.

---

# 19. WhatsApp

Arcade Hub contact:

**+977 9805855494**

WhatsApp can be exposed as a general contact/inquiry mechanism.

However:

**Do not automatically assume that every room booking must happen through WhatsApp.**

Only use WhatsApp for booking/inquiry flows where the business confirms that this is the intended process.

---

# 20. Unknown Business Information

The following information is currently incomplete and must not be invented:

### Area 51

Exact purpose/service is unknown.

### Easy Room

Exact purpose/service is unknown.

### PS5

Unknown:

* Exact late fee
* Whether price is per PS5/person/booking/room
* Whether app booking is required
* Availability system
* Payment flow

### Experiences

Unknown:

* Whether each room is bookable
* Pricing
* Capacity
* Opening hours
* Available services
* Availability

### Food ordering

Unknown until Rebuzz integration is inspected:

* Exact categories
* Exact products
* Modifier structure
* Tax behavior
* Discount behavior
* Order status behavior

### Promotions

Unknown:

* Exact discount percentage
* Start time
* End time
* Whether it stacks with POS discounts
* Whether it applies to every POS item
* Whether it applies to services such as PS5 rental

Do not fabricate any of these values.

---

# 21. State Management

Use Riverpod consistently.

Existing providers should be inspected before creating new ones.

### Cart

The cart should have a dedicated provider/notifier.

Conceptually:

```text
cartProvider
    ↓
CartNotifier
    ├── add()
    ├── remove()
    ├── updateQuantity()
    ├── clear()
    └── ...
```

All cart mutations must go through the notifier.

UI components should not directly mutate cart state.

---

### Favourites

Use a dedicated provider/notifier.

Conceptually:

```text
favouritesProvider
    ↓
FavouritesNotifier
    ├── add()
    ├── remove()
    └── toggle()
```

Again, UI should interact with the notifier rather than directly modifying state.

---

# 22. Avoid Over-Specifying State Models

Do not assume that the existing:

```dart
Map<String, int>
```

cart structure is sufficient.

A food order may contain:

* Product
* Quantity
* Variant
* Add-ons
* Notes
* Price snapshot

Therefore, first inspect the existing Breaking Bread/Rebuzz implementation.

If modifiers/add-ons exist, use a proper cart-line model rather than forcing everything into:

```dart
Map<String, int>
```

The existing application's state model should be adapted based on actual POS requirements.

---

# 23. Architecture Principle

Separate these concepts:

### Experience

```text
Playroom
Party Room
Sports Bar
Rooftop Restro
Area 51
Easy Room
```

### Product

```text
Burger
Momo
Drink
etc.
```

### Service

```text
PS5 Rental
```

### Order

```text
Products + quantities + pricing + customer/location information
```

These are different domain concepts and should not be mixed together.

---

# 24. Single Sources of Truth

Use one source of truth for:

### Experiences

```text
kArcadeExperiences
```

### Brand colors

```text
AppColors
```

### POS products

```text
Rebuzz POS / API
```

### Cart

```text
cartProvider
```

### User authentication

```text
existing auth provider
```

### Navigation

```text
GoRouter
```

Avoid duplicating the same information across multiple widgets/screens.

---

# 25. Breaking Bread Migration Strategy

The existing Breaking Bread JSX/application should be treated as the **technical skeleton**, not as the business model.

### Reuse where possible:

* Authentication
* Navigation architecture
* Product components
* Cart
* Checkout
* API service architecture
* POS integration
* State management patterns
* Loading states
* Error states
* Empty states
* Reusable UI components

### Replace:

* Breaking Bread branding
* Bakery terminology
* Bakery imagery
* Bakery-specific categories
* Bakery-specific promotions
* Bakery-specific business logic
* Bakery-specific navigation

### Add:

* Arcade Hub experience system
* Six venue experiences
* Experience-specific visual identities
* Arcade Hub promotional system
* PS5 rental service structure
* Arcade Hub-specific content
* Venue-aware functionality when confirmed

---

# 26. Golden Rule

Before implementing a feature, classify it as one of:

```text
EXPERIENCE
PRODUCT
SERVICE
ORDER
ACCOUNT
PROMOTION
```

If something belongs to an experience, it should not automatically become a product.

If something comes from Rebuzz, don't hardcode it.

If something has not been confirmed by Arcade Hub, don't invent the business rule.

The application should be designed to support the real Arcade Hub business rather than forcing Arcade Hub into the structure of the old Breaking Bread restaurant application.

---

# 27. Additional Backend & Endpoint Requirements

### A. Supported Core API Endpoints

The application integrates with the primary backend through these repository domains:

1. **Authentication (`/api/auth/*`)**: Handles customer registration, login, email verification, password reset, profile (`/auth/me`), password change, logout, and account deactivation.
2. **Business Configuration (`/api/businesses/*`)**: Business details, geo-filtering, tax configurations (VAT, service tax), and business-scoped product catalogs.
3. **Product & Catalogue (`/api/products/*` & `/api/businesses/{id}/products/*`)**: Category navigation, product details, popularity sorting, global keyword search, and recently purchased items.
4. **Cart Management (`/api/cart/*`)**: Synchronizing user active shopping cart, line-item add/update/delete, and bulk line clearing.
5. **Tickets & Orders (`/api/ticket/*`)**: Customer order creation, order history (`/ticket/my-orders`), ticket status tracking, and **Dine-In Table Requests** (waiter, water, bill, food status).
6. **Location Management (`/api/location/*`)**: Saved delivery addresses and customer spot management.

> *Note: Notification endpoints (`/api/notification/*`) are currently excluded until backend notification service is functional.*

---

### B. Required New Endpoints & Custom Backend Logic

The following features represent venue-specific requirements that are not covered by standard food POS endpoints and require custom backend routes or logic:

1. **PS5 Rental & Venue Service Endpoints (`/api/services/*`)**
   * **Missing Routes**:
     * `GET /api/services/ps5/availability`
     * `POST /api/services/ps5/book`
   * **Business Rules**: PS5 rental operates on a fixed time window (`9 PM → 9 AM`, base `NPR 2,000` + hourly late fee). The backend must manage console availability, rental slots, and late fee calculations separate from food products.

2. **Server-Side Promotional Discount Validation**
   * **Missing Route / Requirement**: Promo validation middleware or `POST /api/promotions/validate`.
   * **Business Rules**: The app features a time-bounded discount (e.g. `10% OFF` between `5 PM – 8 PM`). While the client previews the discount, the backend ticket route (`POST /api/ticket/`) must validate authoritative server time to prevent client clock manipulation.

3. **Digital Wallet Verification Webhooks (`/api/payment/*`)**
   * **Missing Route**: `POST /api/payment/verify`
   * **Business Rules**: Verification for eSewa / Khalti transaction tokens (`refId`) or Fonepay QR callbacks prior to marking ticket status as `PAID` on the kitchen terminal.

---

## Final Mental Model

```text
                    ARCADE HUB
                        │
             "Digital Front Door"
                        │
        ┌───────────────┼────────────────┐
        │               │                │
    DISCOVER          ORDER            SERVICES
        │               │                │
   Experiences      Rebuzz POS        PS5 Rental
        │               │                │
 ┌──────┼──────┐        │           Future services
 │      │      │        │
Play  Party  Sports     │
 │      │      │        │
Rooftop Area51 Easy     │
                        │
                 Food / Drinks
                        │
                      Cart
                        │
                    Checkout
                        │
                       Order
```

**The six rooms/experiences help customers understand Arcade Hub. Rebuzz provides the food catalogue. Services such as PS5 rental are separate. Do not merge these concepts.**

---

# 28. Single POS Business ID to Zone Product Mapping Strategy

### Problem Statement
Arcade Hub operates as an all-in-one entertainment venue featuring 6 distinct zones (Playroom, Party Room, Rooftop Restro, Sports Bar, Area 51, Easy Room). However, the Rebuzz POS system utilizes **1 single Business ID** (`/api/businesses/{businessId}/products`) containing the combined catalog of food, drinks, cocktails, snacks, and service passes.

### Architectural Solution & Data Flow

To separate and route products accurately to their respective venue zones without requiring multiple POS business registrations, the application uses a **Three-Tier Mapping Strategy**:

```text
                  Rebuzz POS Single API Endpoint
                /api/businesses/{businessId}/products
                                  │
                                  ▼
                 PosRepository / Product Catalogue
                                  │
            ┌─────────────────────┼─────────────────────┐
            ▼                     ▼                     ▼
     Category Filter       Zone Tag Filter       Default Fallback
  (e.g., "Sports Bar",  (e.g., tags: ["bar",   (Full Catalogue for
   "Rooftop Food")       "playroom_snack"])      Global Search/Menu)
            │                     │                     │
            └─────────────────────┼─────────────────────┘
                                  ▼
                       Zone Experience Screen
                  (Playroom, Sports Bar, Rooftop, etc.)
                                  │
                                  ▼
                       Order Creation Ticket
                   POST /api/ticket/table-request
                   { "zone_id": "sportsbar", ... }
```

#### 1. POS Product Category & Metadata Tag Mapping
Products in the POS catalog are tagged or assigned to standard category names (e.g. `Sports Bar Drinks`, `Rooftop Gourmet`, `Playroom Snacks`, `Draft Beer`, `Cocktails`). 

The app's `PosRepository` filters items dynamically when an Experience Zone screen is opened:
```dart
List<ProductModel> getProductsForZone(List<ProductModel> allProducts, String zoneId) {
  switch (zoneId) {
    case 'sportsbar':
      return allProducts.where((p) => 
        p.category.toLowerCase().contains('bar') || 
        p.category.toLowerCase().contains('drink') ||
        p.category.toLowerCase().contains('beer')
      ).toList();
    case 'rooftop':
      return allProducts.where((p) => 
        p.category.toLowerCase().contains('rooftop') || 
        p.category.toLowerCase().contains('food') ||
        p.category.toLowerCase().contains('main')
      ).toList();
    case 'playroom':
      return allProducts.where((p) => 
        p.category.toLowerCase().contains('snack') || 
        p.category.toLowerCase().contains('gaming')
      ).toList();
    default:
      return allProducts;
  }
}
```

#### 2. Kitchen & Station Ticket Routing (`zone_id` & `table_number`)
When a customer places an order from a specific zone or table, the checkout payload sends the `zone_id` and `table_number` inside the order ticket payload (`POST /api/ticket`):
```json
{
  "business_id": "arcade_hub_pos_1",
  "zone_id": "sportsbar",
  "table_number": "SB-04",
  "items": [
    { "product_id": "prod_beer_01", "quantity": 2 }
  ]
}
```
This enables the Rebuzz POS kitchen display and receipt printer to automatically route tickets to the correct preparation station (e.g., **Sports Bar Counter** vs **Main Kitchen**).


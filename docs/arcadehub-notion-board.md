# ArcadeHub — Customer App

Flutter customer ordering app for Arcade Hub, New Road, Pokhara. Menu + ordering run on the RebuzzPOS integration; zones, bookings and promos are new surface built for this venue.

| | |
| --- | --- |
| Platform | Flutter (Android + web) |
| Backend | RebuzzPOS (beta `6a8a87631d9c3a6661f3bb12`, prod `65db0f54d0199c9b3dc7ab15`) |
| Web deploy | Vercel — `flutter build web --release`, output `build/web` |
| WhatsApp (support line in app) | +977 9805855494 |
| Frontend | Sarip |
| Backend | Anil Ghimire |

---

## Brand kit — zone colours

| Zone | Colour |
| --- | --- |
| Play Room | Sunny yellow |
| Party Room | Signal red |
| Sports Bar | Neon green |
| Rooftop Restro | White |
| Area 51 | Purple |
| Easy Room | Blue |

> Rooftop Restro's white needs dark text on every chip, button and pill it fills. Handled in the app by picking ink from the fill's luminance.

---

## Blockers

Work that is stopped or at risk until someone else moves. Nothing below can be closed by frontend alone.

| # | Blocker | Blocks | Owner | Status |
| --- | --- | --- | --- | --- |
| B1 | No booking endpoint. Bookings are not stored anywhere. As a stopgap the app hands the request to the venue's WhatsApp with the date, time, headcount and note pre-filled, so a customer can book today — but there is no record, no availability check and no double-booking guard. | Confirmed bookings, availability, booking history | Backend | Worked around |
| B2 | Payment gateway not chosen. eSewa, Khalti and Fonepay need different SDKs, merchant onboarding and test credentials, so nothing starts until it's picked. Possible shortcut: if the venue sends a payment QR over WhatsApp, or gives us one static QR to show in the app, no gateway is needed at all — but then nothing links a payment to an order and someone reconciles by hand. Also note the three payment options at checkout today are labels only; none of them collect money. | Online payment, checkout | Client + Backend | Waiting on decision |
| B3 | Timed discount (x% off, valid hours a–b) has no backend. It's in the pipeline behind P0, so the app hard-codes the percentage and the order payload sends `discount: 0` — the POS never sees the discount. | Promo card, app-only discount, cart totals | Backend | Open (post-P0) |
| B4 | Real promo terms unknown: percentage, start hour, end hour, whether it applies to all items or food only. The card is switched off until all three values exist. | Promo card going live | Client | Open |
| B5 | Zone content is placeholder. Area 51 and Easy Room, the bookable services, durations, prices and rules were written by us as filler and have not been confirmed as real. | Zone pages, Book tab, anything the client would read as a promise | Client | Needs confirmation |
| B6 | No real venue photography. The zone carousel uses stock images, so the app doesn't look like the venue. | Home carousel, zone headers, marketing screenshots | Client | Open |
| B7 | POS categories drive the bar/restro split. Anything not categorised as a drink lands in the restro, and any drink the staff miscategorise shows up on the wrong menu. Items with no price render as "Ask at counter". | Sports Bar menu, Rooftop Restro menu, pricing accuracy | Client / venue staff | Needs a data pass |
| B8 | PS5 rental terms unclear — "9pm–9am, NPR 2000 + per hour if late" hasn't been written as a rule we can put on screen (what the hourly late fee is, deposit, ID). | Rental listing, rules text | Client | Open |
| B9 | No Play Store release path yet: no developer account, keystore or signing config on our side, so a production AAB can't be built or uploaded. | Release, Post-Release | Client + Frontend | Open |
| B10 | 50% off on some zones was asked for, but which zones, how much and for how long is unspecified — and it needs the same backend as B3. | Zone offers | Client | Open |

---

## Client requests from the last review

- [x] Zone features shown first, as icon + name, rather than the zones themselves
- [x] Bar and restro menus properly separated
- [x] Map in two sections — one exterior, one interior floor plan
- [x] To-the-point copy across the app
- [x] Brand kit implementation (zone colours, logo, type)
- [x] Better zone UI
- [x] Feature slider on Home, with the hamburger nav carrying the same zones
- [x] Menu pulled live from the RebuzzPOS integration
- [ ] x% app-only discount, valid hours a–b — *blocked, B3/B4*
- [ ] 50% off on selected zones — *blocked, B10*
- [ ] Online payment — *blocked, B2*
- [ ] Better light mode
- [ ] Better About us
- [ ] Awareness of what the app can do (first-run or in-app prompts)

---

## Research

- [x] ArcadeHub requirements
- [x] Existing POS/backend structure
- [x] Available API endpoints
- [x] Data the frontend needs
- [x] Which screens are backend-driven
- [x] Frontend scope finalised

## Frontend setup

- [x] Flutter project created
- [x] Project structure
- [x] Routing and navigation (GoRouter, five-tab shell)
- [x] State management (Riverpod)
- [x] API / service layer
- [x] Theme and reusable components
- [x] Dependencies
- [x] Git repository connected

## Frontend development

- [x] Home screen — order banner, feature carousel, promo, menu strip, bundles, zones, find us
- [x] Zone detail pages with the menu underneath
- [x] Menu screen — search, category pills, quantity steppers
- [x] Cart and checkout
- [x] Book tab — booking form with date, time, headcount and notes; requests go out over WhatsApp until B1 lands
- [x] Profile, orders, favourites, addresses
- [x] Reusable components
- [x] Loading states
- [x] Empty states
- [x] Error states, with retry
- [x] Responsive layout down to a 290px-wide phone
- [ ] Animations and micro-interactions — pass still to do

## API integration

- [x] Frontend wired to the live endpoints
- [x] Business data
- [x] Products and categories fetched dynamically
- [x] Category IDs mapped to names (the POS returns IDs, not names)
- [x] Responses mapped to models
- [x] Loading states
- [x] Error handling
- [x] Empty responses
- [x] Sample-product fallback removed — the app now shows an error instead of fake items
- [ ] Verify every menu item against the POS with the client — *B7*
- [ ] Booking endpoints — *B1*
- [ ] Payment endpoints — *B2*
- [ ] Discount endpoint — *B3*

## Testing and refinement

- [x] Navigation and back behaviour
- [x] Screen sizes (widget tests at 290 / 320 / 360px)
- [x] Overflow and layout bugs
- [x] Back-navigation crash from Saved Addresses
- [ ] All major user flows end to end
- [ ] Different backend responses
- [ ] Physical devices
- [ ] Final frontend review
- [ ] Light mode pass

## Release preparation

- [x] Booking requests go to the venue's WhatsApp (`AppConstants.whatsappTestNumber` is `null`; set it only while testing)
- [ ] Remove remaining placeholder content — *B5*
- [ ] Switch to the production business ID and verify
- [ ] Permissions and app config
- [ ] App version
- [ ] Release build
- [ ] Production AAB — *B9*
- [ ] Play Store deployment support — *B9*

## Post-release

- [ ] Monitor production issues
- [ ] Fix reported bugs
- [ ] Track UI improvements
- [ ] Prepare updates

---

## Open questions

1. **Payment gateway** — eSewa, Khalti or Fonepay? We need the merchant account and test credentials, not just the name.
2. **Discount** — exact percentage, start hour, end hour, and whether it covers everything or food only.
3. **Zones** — are Area 51 and Easy Room live, and what actually happens in each?
4. **Bookings** — which zones take reservations, how long a slot is, what it costs, and how the venue wants to receive them.
5. **PS5 rental** — the late fee, deposit and ID requirement, in the words we should put on screen.
6. **Photos** — can we get real photos of each zone?

# Questions for Arcade Hub

Everything below is either invented by us, guessed, or blocked. **★ marks what blocks real work right now** — without it we keep building against placeholders and rewriting later.

---

## 1. Zone by zone

Go through these six one at a time. Every row is something the app shows today with made-up content.

| | Play Room | Party Room | Rooftop Restro | Sports Bar | Area 51 | Easy Room |
|---|---|---|---|---|---|---|
| Real and open? | | | | | ★ | ★ |
| Name customers should see | | | | | | |
| What's actually in it | | | | | | |
| Opening hours | | | | | | |
| How many people fit | | | | | | |
| Can it be booked? | | | | | | |
| Photos supplied? | | | | | | |

**★ Are Area 51 and Easy Room real?** We wrote both from nothing. If they don't exist, they come out of the app.

**★ The real opening hours.** We invented per-zone hours — Play Room 10 AM–2 AM, Sports Bar 5 PM–2 AM, Rooftop 12 PM–2 AM. Bookings currently stop at 10 PM, so a customer can read "open till 2 AM" and find they can't book past ten. One venue-wide pair, or a real pair per zone.

Are you closed any day of the week? Any different hours at weekends or on holidays?

Every zone currently claims "Up to 20 Guests" because we had no number.

---

## 2. The actual features

This is what the app leads with — the home carousel is features, not zones, so a customer taps "Karaoke" and lands in the right room. **We need the real list, and which zone each one is in.**

What we've assumed exists, and where:

| Feature | We put it in | Right? |
|---|---|---|
| PS5 gaming | Play Room | |
| Racing (sim/arcade?) | Play Room | |
| Foosball | Play Room | |
| Darts | Play Room | |
| Table tennis | Play Room, Area 51 | |
| Karaoke | Party Room, Easy Room | |
| Movies | Party Room, Easy Room | |
| Mini golf | — | |
| Beer pong | Area 51 | |
| Live sports on big screens | Sports Bar | |
| Private parties / birthdays | Party Room | |

Questions on top of that:

- **Anything missing from this list?** Pool, bowling, arcade cabinets, board games, shisha, anything seasonal?
- **How many of each?** "4 PS5s", "2 karaoke rooms", "3 dart boards" — numbers make the app concrete, and right now we have none, so we say nothing or we guess.
- **Is anything pay-per-use rather than included?** A per-game or per-hour charge changes how the app lists it.
- **Is anything age-restricted?** The bar especially — see the alcohol question in section 9.

---

## 3. Photos we need

**★ This is the single biggest difference to how finished the app looks.** Every photo in the app right now is stock from the internet, so it doesn't look like Arcade Hub at all.

The list:

1. **One per zone — 6 photos.** Landscape, shot wide enough to show the room.
2. **One per feature — around 8.** A PS5 setup, the big screens with a match on, a karaoke room, the dart board, the table tennis table, the rooftop terrace, a party set up for a birthday, the racing rig. These fill the home carousel, which is the first thing anyone sees.
3. **The building from outside — 1 or 2.** Used in Find us, so someone can recognise the entrance from the street.
4. **The logo**, as a PNG with a transparent background, plus a square version for the app icon.
5. **Food and drink photos** — see the next question, this one matters more than it sounds.

**★ Do the menu items have photos in the POS?** The app pulls item images straight from the POS. Wherever there's no image the card falls back to a plain placeholder, so a menu of forty items with no photos looks broken. If they're missing, who is shooting and uploading them?

**Is the floor plan we have current?** And is the map pin on the right entrance — we've hardcoded the coordinates.

Practical notes to pass on: landscape, at least 1600px wide, decent light, nothing important near the edges (we crop), and no text burned into the image. Phone photos are fine if they're bright. If people are in shot, they need to be okay with it being in an app.

---

## 4. Bookings

**★ Which zones can actually be reserved?** We assume Play Room, Party Room, Area 51 and Easy Room, and that Rooftop Restro and Sports Bar are walk-in only.

**★ What exactly can be booked in each, and for how much?** Per item we need: name, price, how long it lasts, minimum and maximum people. Everything in the app today is our placeholder — "VR Battle Arena" at NPR 500 we made up entirely.

**★ PS5 rental — the exact terms.** We have "9 PM–9 AM, NPR 2000, plus per hour if late". What is the hourly late fee? Deposit? ID or card needed? This goes on screen word for word.

How far ahead can someone book? The app allows 8 weeks.

Can someone book for today, and how much notice do you need? Right now an 11 AM slot disappears at 11:00 sharp with no buffer.

**Cancellation:** how late can someone cancel, and does it cost anything?

**★ Who confirms bookings, and how fast?** Requests arrive on WhatsApp at +977 9805855494 — right number? Watched through opening hours? What should we promise customers: "we'll reply within an hour"?

**★ Do you want app bookings in the POS appointment calendar?** They can be, but the backend has to write them and needs one POS "employee" record per bookable zone. Otherwise staff keep entering them by hand from the chat. An operational decision, not a technical one.

Two customers can request the same slot before staff see either — both get "Requested" and staff catch the clash. Fine for now, or does that need a hard availability check before launch?

---

## 5. Payment — including the QR question

**★ Will you send a payment QR over WhatsApp yourselves?** If yes, that removes the whole payment-gateway dependency, which is currently the longest blocker on the project. Worth deciding in this meeting.

If the answer is yes:

- **Is it always the same QR, or do you generate one per amount?** If it's always the same, we can put it straight in the app and nobody has to send anything — the customer scans, pays, and sends the screenshot. If it's per-amount, staff have to send it each time and the customer waits.
- **Which account is it — eSewa, Khalti, or a bank's Fonepay QR?** A Fonepay QR is scannable from most Nepali apps, so it covers the most customers with one image.
- **Should the customer send a payment screenshot, and to whom?** Someone has to check it against the order.
- **Who reconciles it at the end of the day?** Nothing links a QR payment to an order automatically — the POS won't know it was paid.
- **Is payment required before an order is accepted, or on arrival?**
- **Do bookings need a deposit paid the same way?**

If the answer is no, and you want a real in-app gateway:

- **★ Which one: eSewa, Khalti or Fonepay?** Each is different work, so nothing starts until it's picked — and we need the merchant account and test credentials, not just the name.

Either way: **the app currently lists "Cash / Card at Table", "eSewa / Khalti Digital QR" and "Fonepay QR" at checkout, and none of them collect any money.** They're labels the customer picks, passed to the POS as text. So whichever way you go, those three options need to change to match what actually happens.

Until then, how does a customer pay — cash at the counter, card on arrival?

---

## 6. The discount

**★ Exact numbers:** what percentage, from what time, to what time, on which days? All three are blank, so the promo card is switched off entirely.

Everything, or food only? Anything excluded — bundles, alcohol?

App-only? Does it stack with any other offer?

**★ Must the discount show on the POS receipt?** If yes, this is blocked on Anil — the app sends the order with `discount: 0`, so the till total won't match what the customer was shown. If it's a marketing line and staff apply it manually, we can ship now.

**"50% off on some zones"** — which zones, how much, how long? Same dependency.

---

## 7. The menu

**★ Is every item in the POS with the right category?** The app splits the menu by category: drinks go to the Sports Bar, everything else to the Rooftop Restro. One miscategorised item shows on the wrong menu, and that's a fix at your end.

**What are all your drink category names?** We only match the word "drink", so "Beverages", "Cocktails" or "Shots" would land in the food menu.

Some items have no price in the POS and the app shows "Ask at counter". Deliberate, or missing data?

Should everything in the POS appear in the app, or is there a subset? Items can be hidden individually.

Are there real bundle deals? The bundles section stays hidden while there are none.

Does the POS track stock — should a sold-out item disappear from the app?

---

## 8. Orders and service

Are app orders for table service, takeaway, delivery, or all three? If delivery: what area, what fee, minimum order?

**The POS is built around tables.** Should a customer pick or scan their table number when ordering? Without it, staff won't know where to take the order. A QR sticker per table is the usual answer — do you want that?

Who watches incoming orders, on which device? Is a ticket printer set up?

Should a customer be able to order ahead for a set time, or is it always now?

What happens when a customer wants to cancel an order they just placed?

Do you want to notify customers when an order is ready? That needs extra backend work, so it's worth knowing if it matters.

---

## 9. Easy to miss

These haven't come up yet and each one can cost a rebuild or block the store listing.

**★ Do menu prices include VAT and service charge?** If the app shows NPR 250 and the bill comes to NPR 282.50, that becomes a complaint on day one. We need to know whether to show tax separately at checkout.

**★ Does the app sell alcohol?** If beer and cocktails are orderable, the Play Store listing needs a content rating and possibly an age gate, and there may be rules about ordering alcohol to a table through an app. Cheaper to know now than after a rejection.

**★ Privacy policy and terms.** Google Play will not publish an app with customer accounts without a privacy policy at a public URL. Someone has to write it and host it — us, you, or a template you approve.

**★ Account deletion.** Play Store also requires a way for customers to delete their account and data. Do you want in-app deletion, or a request by email?

Must customers create an account, or can they order as a guest? Forcing signup costs you orders; guest checkout means no order history for them.

If accounts use phone OTP, someone pays per SMS. Whose account and budget?

Do you want loyalty — stamps, points, a regulars discount? Not hard to add early, expensive to retrofit.

Should customers be able to rate items or leave feedback in the app?

Do you want the app in Nepali as well as English?

Where should the web version live — a link we host, or a subdomain of your own domain?

Who is the app publisher on the store: your company name or ours? This affects who owns the listing.

If a customer complains or wants a refund, what's the path, and should the app say so anywhere?

---

## 10. Launch

**★ Whose Google Play developer account?** If nobody has one, it has to be created and paid for before the app can go on the store at all.

Do you want an iPhone version? That needs an Apple developer account and a yearly fee.

Which business do we go live against — the test one we've been building on, or the live one? When do you want that switch?

What should the app be called on the store, and is the icon the logo as-is?

---

## The two for Anil, not the client

1. Can the backend create POS appointments server-side, or should app bookings sit in their own table with staff copying them across?
2. Timed discount — once P0 is done, will the order payload carry the discount so the POS total matches what the customer saw?

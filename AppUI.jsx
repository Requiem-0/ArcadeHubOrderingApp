import React, { useState, useEffect, useCallback, createContext, useContext } from "react";

/* ─────────────────────────────────────────────────────────────
   ARCADE HUB — POKHARA, NEPAL (BRAND CONFIG & DISCOUNTS)
   ───────────────────────────────────────────────────────────── */
const ARCADE_HUB_CONFIG = {
  appName: "Arcade Hub",
  location: "Lakeside, Pokhara, Nepal",
  whatsappNumber: "+9779805855494",
  whatsappFormatted: "+977 9805855494",
  discount: {
    enabled: true,
    percentage: 10, // 10% discount for orders via app
    startHour: 17, // 5:00 PM (A)
    endHour: 20,   // 8:00 PM (B)
    label: "App Special 10% OFF",
  },
  ps5Rental: {
    basePriceNPR: 2000,
    startTime: "9:00 PM",
    endTime: "9:00 AM",
    lateFeePerHourNPR: 300,
  },
};

/* ─────────────────────────────────────────────────────────────
   6 CORE ARCADE HUB EXPERIENCES & IDENTITY COLORS
   ───────────────────────────────────────────────────────────── */
const EXPERIENCES = [
  {
    id: "playroom",
    name: "Playroom",
    icon: "🎮",
    color: "#FFD700", // Sunny Yellow
    bgGradient: "linear-gradient(135deg, rgba(255, 215, 0, 0.25), rgba(255, 193, 7, 0.05))",
    subtitle: "Arcade Games, VR & Gaming Zone",
    tagline: "Immerse in retro classics, modern consoles & VR battles",
    description: "State-of-the-art gaming experience with racing simulators, fighting cabinets, and private console stations.",
    type: "gaming",
  },
  {
    id: "partyroom",
    name: "Party Room",
    icon: "🎉",
    color: "#FF355E", // Signal Red
    bgGradient: "linear-gradient(135deg, rgba(255, 53, 94, 0.25), rgba(229, 57, 53, 0.05))",
    subtitle: "Private Celebrations & Events",
    tagline: "Host unforgettable birthdays, victory bashes & reunions",
    description: "Soundproofed party hub equipped with surround sound, customizable ambient lighting, and dedicated service.",
    type: "lounge",
  },
  {
    id: "rooftop",
    name: "Rooftop Restro",
    icon: "🏙️",
    color: "#FFFFFF", // White / Clean Silver
    bgGradient: "linear-gradient(135deg, rgba(255, 255, 255, 0.22), rgba(200, 200, 220, 0.05))",
    subtitle: "Scenic Dining & Sky Lounge",
    tagline: "Panoramic Fewa Lake views, gourmet dining & chill beats",
    description: "Open-air restro experience combining chef-crafted dishes, signature cocktails, and vibrant Pokhara sunsets.",
    type: "dining",
  },
  {
    id: "sportsbar",
    name: "Sports Bar",
    icon: "🏟️",
    color: "#00E676", // Neon Green
    bgGradient: "linear-gradient(135deg, rgba(0, 230, 118, 0.25), rgba(57, 255, 20, 0.05))",
    subtitle: "Live Matches, Drinks & Bites",
    tagline: "Cheer your team on giant HD projectors with icy craft drinks",
    description: "High-energy sports venue serving cold draft beer, wings, sliders, and live match screenings on big screens.",
    type: "dining",
  },
  {
    id: "area51",
    name: "Area 51",
    icon: "🛸",
    color: "#D500F9", // Purple
    bgGradient: "linear-gradient(135deg, rgba(213, 0, 249, 0.25), rgba(156, 39, 176, 0.05))",
    subtitle: "Mystery Experience Room",
    tagline: "Top-secret futuristic hangout & immersive lounge zone",
    description: "Exclusive secret-theme chamber featuring laser visuals, futuristic chill pods, and mystery house specials.",
    type: "gaming",
  },
  {
    id: "easyroom",
    name: "Easy Room",
    icon: "🔵",
    color: "#00E5FF", // Blue
    bgGradient: "linear-gradient(135deg, rgba(0, 229, 255, 0.25), rgba(30, 136, 229, 0.05))",
    subtitle: "Lounge & Chill Space",
    tagline: "Relaxed sofa lounge, board games & smooth refreshers",
    description: "Ultra-comfortable relaxed space designed for casual conversations, board gaming sessions, and light snacks.",
    type: "lounge",
  },
];

/* ─────────────────────────────────────────────────────────────
   THEME SYSTEM (GAMER NEON DARK MODE DEFAULT)
   ───────────────────────────────────────────────────────────── */
const darkTheme = {
  scaffold: "#0B0B10",
  surface: "#151421",
  surfaceElevated: "#1E1D30",
  primary: "#00E5FF",
  secondary: "#D500F9",
  text: "#F5F5FA",
  textMuted: "#8F90A6",
  accent: "#FFD700",
  error: "#FF355E",
  border: "#262538",
  shadow: "rgba(0, 229, 255, 0.12)",
  success: "#00E676",
  onPrimary: "#0B0B10",
};

const lightTheme = {
  scaffold: "#F4F5FA",
  surface: "#FFFFFF",
  surfaceElevated: "#EAEBF5",
  primary: "#00B0FF",
  secondary: "#AA00FF",
  text: "#121324",
  textMuted: "#66688A",
  accent: "#FFA000",
  error: "#D50000",
  border: "#E0E2F0",
  shadow: "rgba(0, 0, 0, 0.08)",
  success: "#00C853",
  onPrimary: "#FFFFFF",
};

const ThemeContext = createContext();
const useTheme = () => useContext(ThemeContext);

const CartContext = createContext();
const useCart = () => useContext(CartContext);

/* ─────────────────────────────────────────────────────────────
   DESIGN TOKENS & HELPERS
   ───────────────────────────────────────────────────────────── */
const radii = { xs: 8, s: 10, sm: 12, m: 14, ml: 16, l: 18, xl: 20, xxl: 24, card: 20, pill: 50 };
const fonts = {
  heading: "'Outfit', 'DM Sans', sans-serif",
  body: "'Inter', 'DM Sans', sans-serif",
  mono: "'JetBrains Mono', monospace",
};

const formatPrice = (n) => `NPR ${Number(n || 0).toLocaleString()}`;

const isDiscountActiveNow = () => {
  const currentHour = new Date().getHours();
  return (
    ARCADE_HUB_CONFIG.discount.enabled &&
    currentHour >= ARCADE_HUB_CONFIG.discount.startHour &&
    currentHour < ARCADE_HUB_CONFIG.discount.endHour
  );
};

/* ─────────────────────────────────────────────────────────────
   ARCADE HUB SAMPLE DATA
   ───────────────────────────────────────────────────────────── */
const SAMPLE_PRODUCTS = [
  {
    id: "pos-1",
    name: "Arcade Hub Loaded Nachos",
    emoji: "🧀",
    price: 650,
    originalPrice: 750,
    category: "Munchies",
    tags: ["Chef Special", "Popular"],
    description: "Crispy tortilla chips loaded with melted cheese, jalapenos, salsa & sour cream",
    longDescription: "Freshly baked corn tortillas topped with house blend aged cheddar, pico de gallo, black olives, guac, and signature spicy dip.",
    variants: [
      { id: "v1", label: "Vegetarian", price: 650 },
      { id: "v2", label: "Grilled Chicken", price: 820 },
    ],
    addons: [
      { id: "a1", name: "Extra Guacamole", price: 150 },
      { id: "a2", name: "Extra Melted Cheese", price: 120 },
    ],
  },
  {
    id: "pos-2",
    name: "Fewa Sunset Mocktail",
    emoji: "🍹",
    price: 380,
    category: "Drinks",
    tags: ["Refreshing"],
    description: "Passion fruit, peach syrup, mint & sparkling soda over crushed ice",
    longDescription: "Inspired by the colors of Fewa Lake sunset. Layered passion fruit puree, blood orange syrup, fresh lime, and top splash of sprite.",
  },
  {
    id: "pos-3",
    name: "Cyberpunk Bacon Cheeseburger",
    emoji: "🍔",
    price: 890,
    originalPrice: 990,
    category: "Gourmet Burgers",
    tags: ["Must Try"],
    description: "Juicy beef patty, smoked bacon, caramelized onions & secret hub sauce",
    variants: [
      { id: "v1", label: "Single Patty", price: 890 },
      { id: "v2", label: "Double Patty Beast", price: 1190 },
    ],
    addons: [{ id: "a1", name: "Crispy Potato Wedges", price: 200 }],
  },
  {
    id: "pos-4",
    name: "Rooftop Woodfired Pizza",
    emoji: "🍕",
    price: 1150,
    category: "Pizza",
    tags: ["Woodfired"],
    description: "Artisanal crust, San Marzano tomato, fresh mozzarella & fresh basil",
    variants: [
      { id: "v1", label: "Margherita Gold", price: 1150 },
      { id: "v2", label: "Smoked Chicken Supreme", price: 1350 },
    ],
  },
  {
    id: "pos-5",
    name: "Neon Green Wings (10 pcs)",
    emoji: "🍗",
    price: 720,
    category: "Munchies",
    tags: ["Spicy"],
    description: "Jumbo wings tossed in spicy jalapeno cilantro lime glaze",
  },
  {
    id: "pos-6",
    name: "Area 51 Mystery Cocktail",
    emoji: "🧪",
    price: 650,
    category: "Drinks",
    tags: ["Signature"],
    description: "Served in smoke beaker - blue curaçao, vodka & exotic citrus blend",
  },
  {
    id: "pos-7",
    name: "Easy Room Herbal Shisha",
    emoji: "💨",
    price: 1200,
    category: "Shisha",
    tags: ["Chill"],
    description: "Nicotine-free double apple or blueberry mint flavor",
  },
  {
    id: "pos-8",
    name: "Party Platter Supreme",
    emoji: "🍱",
    price: 2400,
    originalPrice: 2750,
    category: "Platters",
    tags: ["Shareable"],
    description: "Assorted sliders, wings, onion rings, fries & 4 dip sauces",
  },
];

/* ─────────────────────────────────────────────────────────────
   SHARED UI WIDGETS
   ───────────────────────────────────────────────────────────── */
function PrimaryButton({ children, onClick, loading, disabled, style }) {
  const t = useTheme();
  return (
    <button
      onClick={onClick}
      disabled={disabled || loading}
      style={{
        width: "100%",
        maxWidth: 500,
        padding: "16px 24px",
        borderRadius: radii.l,
        border: "none",
        background: `linear-gradient(135deg, ${t.primary}, ${t.secondary})`,
        color: "#FFFFFF",
        fontFamily: fonts.body,
        fontSize: 16,
        fontWeight: 700,
        cursor: disabled ? "not-allowed" : "pointer",
        opacity: disabled ? 0.6 : 1,
        boxShadow: `0 4px 20px ${t.shadow}`,
        transition: "transform 0.15s ease, opacity 0.2s",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        gap: 8,
        ...style,
      }}
    >
      {loading ? <span className="spinner" /> : children}
    </button>
  );
}

function SecondaryButton({ children, onClick, style }) {
  const t = useTheme();
  return (
    <button
      onClick={onClick}
      style={{
        width: "100%",
        maxWidth: 500,
        padding: "14px 24px",
        borderRadius: radii.ml,
        border: `1.5px solid ${t.primary}`,
        background: "transparent",
        color: t.primary,
        fontFamily: fonts.body,
        fontSize: 15,
        fontWeight: 600,
        cursor: "pointer",
        transition: "all 0.2s ease",
        ...style,
      }}
    >
      {children}
    </button>
  );
}

function AppBackButton({ onClick }) {
  const t = useTheme();
  return (
    <button
      className="back-btn"
      onClick={onClick}
      style={{ fontSize: 24, color: t.text, width: 40, height: 40, background: `${t.surfaceElevated}` }}
    >
      ‹
    </button>
  );
}

function ServiceIcon({ emoji, bg, size = 44 }) {
  const t = useTheme();
  return (
    <div
      style={{
        width: size,
        height: size,
        borderRadius: radii.ml,
        background: bg || `${t.primary}1F`,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        fontSize: size * 0.48,
        flexShrink: 0,
      }}
    >
      {emoji}
    </div>
  );
}

function PriceText({ price, original, small }) {
  const t = useTheme();
  const size = small ? 14 : 16;
  return (
    <div style={{ display: "flex", alignItems: "baseline", gap: 6 }}>
      {original && original > price && (
        <span style={{ textDecoration: "line-through", color: t.textMuted, fontSize: size - 2 }}>
          {formatPrice(original)}
        </span>
      )}
      <span style={{ color: t.primary, fontFamily: fonts.heading, fontWeight: 700, fontSize: small ? 13 : size }}>
        {formatPrice(price)}
      </span>
    </div>
  );
}

function SectionHeader({ title, subtitle, trailing }) {
  const t = useTheme();
  return (
    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-end", marginBottom: 12 }}>
      <div>
        <h2 style={{ fontFamily: fonts.heading, fontSize: 20, fontWeight: 700, color: t.text, margin: 0, letterSpacing: -0.3 }}>{title}</h2>
        {subtitle && <p style={{ fontFamily: fonts.body, fontSize: 12, color: t.textMuted, margin: "2px 0 0" }}>{subtitle}</p>}
      </div>
      {trailing}
    </div>
  );
}

function EmptyState({ icon, title, subtitle, action }) {
  const t = useTheme();
  return (
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", padding: "48px 24px", gap: 12, textAlign: "center" }}>
      <span style={{ fontSize: 72, opacity: 0.6 }}>{icon}</span>
      <h3 style={{ fontFamily: fonts.heading, fontSize: 20, color: t.text, margin: 0 }}>{title}</h3>
      <p style={{ fontFamily: fonts.body, fontSize: 14, color: t.textMuted, margin: 0, maxWidth: 320 }}>{subtitle}</p>
      {action && <div style={{ marginTop: 8, width: "100%", maxWidth: 280 }}>{action}</div>}
    </div>
  );
}

/* ─────────────────────────────────────────────────────────────
   HERO CAROUSEL / SLIDER (6 EXPERIENCES)
   ───────────────────────────────────────────────────────────── */
function HeroSlider({ onSelectExperience }) {
  const t = useTheme();
  const [activeIndex, setActiveIndex] = useState(0);

  useEffect(() => {
    const timer = setInterval(() => {
      setActiveIndex((prev) => (prev + 1) % EXPERIENCES.length);
    }, 4500);
    return () => clearInterval(timer);
  }, []);

  const activeExp = EXPERIENCES[activeIndex];

  return (
    <div style={{ position: "relative", marginBottom: 24 }}>
      <div
        onClick={() => onSelectExperience(activeExp)}
        style={{
          background: activeExp.bgGradient,
          border: `1.5px solid ${activeExp.color}66`,
          borderRadius: radii.xxl,
          padding: "24px 20px",
          minHeight: 170,
          display: "flex",
          flexDirection: "column",
          justifyContent: "space-between",
          boxShadow: `0 8px 30px ${activeExp.color}25`,
          cursor: "pointer",
          transition: "all 0.4s ease",
          position: "relative",
          overflow: "hidden",
        }}
      >
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
          <div>
            <span
              style={{
                fontFamily: fonts.body,
                fontSize: 11,
                fontWeight: 700,
                color: activeExp.color,
                background: `${activeExp.color}20`,
                padding: "4px 10px",
                borderRadius: radii.pill,
                letterSpacing: 1,
                textTransform: "uppercase",
              }}
            >
              Featured Area
            </span>
            <h3 style={{ fontFamily: fonts.heading, fontSize: 26, color: t.text, margin: "8px 0 2px" }}>
              {activeExp.name}
            </h3>
            <p style={{ fontFamily: fonts.body, fontSize: 13, color: t.textMuted, margin: 0 }}>
              {activeExp.subtitle}
            </p>
          </div>
          <span style={{ fontSize: 44, filter: "drop-shadow(0 4px 8px rgba(0,0,0,0.3))" }}>{activeExp.icon}</span>
        </div>

        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginTop: 16 }}>
          <span style={{ fontFamily: fonts.body, fontSize: 12, color: t.text, fontWeight: 500 }}>
            {activeExp.tagline}
          </span>
          <button
            style={{
              padding: "8px 16px",
              borderRadius: radii.pill,
              background: activeExp.color,
              color: activeExp.color === "#FFFFFF" ? "#000000" : "#FFFFFF",
              border: "none",
              fontFamily: fonts.body,
              fontSize: 12,
              fontWeight: 700,
              cursor: "pointer",
              boxShadow: "0 2px 10px rgba(0,0,0,0.2)",
            }}
          >
            Explore →
          </button>
        </div>
      </div>

      {/* Carousel Indicators */}
      <div style={{ display: "flex", justifyContent: "center", gap: 6, marginTop: 10 }}>
        {EXPERIENCES.map((exp, i) => (
          <button
            key={exp.id}
            onClick={() => setActiveIndex(i)}
            style={{
              width: i === activeIndex ? 22 : 8,
              height: 8,
              borderRadius: 4,
              background: i === activeIndex ? exp.color : `${t.textMuted}40`,
              border: "none",
              cursor: "pointer",
              transition: "all 0.3s ease",
            }}
          />
        ))}
      </div>
    </div>
  );
}

/* ─────────────────────────────────────────────────────────────
   FEATURES SECTION (ICON + NAME BELOW ICON)
   ───────────────────────────────────────────────────────────── */
function FeaturesSection({ onNavigate }) {
  const t = useTheme();
  return (
    <div style={{ marginBottom: 24 }}>
      <SectionHeader title="Arcade Hub Experiences" subtitle="Explore our unique venues & activities" />
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(3, 1fr)",
          gap: 12,
        }}
      >
        {EXPERIENCES.map((exp) => {
          return (
            <button
              key={exp.id}
              onClick={() => onNavigate("experience-detail", exp)}
              style={{
                background: t.surface,
                border: `1.5px solid ${t.border}`,
                borderRadius: radii.l,
                padding: "16px 10px",
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
                gap: 8,
                cursor: "pointer",
                transition: "all 0.2s ease",
                boxShadow: `0 2px 8px ${t.shadow}`,
              }}
            >
              <div
                style={{
                  width: 48,
                  height: 48,
                  borderRadius: radii.m,
                  background: `${exp.color}1E`,
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                  fontSize: 24,
                }}
              >
                {exp.icon}
              </div>
              <span
                style={{
                  fontFamily: fonts.body,
                  fontSize: 13,
                  fontWeight: 600,
                  color: t.text,
                  textAlign: "center",
                }}
              >
                {exp.name}
              </span>
            </button>
          );
        })}
      </div>
    </div>
  );
}

/* ─────────────────────────────────────────────────────────────
   DISCOUNT PROMO BANNER
   ───────────────────────────────────────────────────────────── */
function DiscountBanner({ onNavigate }) {
  const t = useTheme();
  const active = isDiscountActiveNow();

  return (
    <div
      onClick={() => onNavigate("discounts")}
      style={{
        background: active
          ? "linear-gradient(135deg, rgba(0, 230, 118, 0.2), rgba(0, 229, 255, 0.2))"
          : `${t.surfaceElevated}`,
        border: `1px solid ${active ? t.success : t.border}`,
        borderRadius: radii.l,
        padding: "14px 16px",
        marginBottom: 20,
        display: "flex",
        alignItems: "center",
        gap: 12,
        cursor: "pointer",
      }}
    >
      <div
        style={{
          width: 40,
          height: 40,
          borderRadius: radii.m,
          background: active ? `${t.success}30` : `${t.accent}20`,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          fontSize: 20,
        }}
      >
        ⚡
      </div>
      <div style={{ flex: 1 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
          <span style={{ fontFamily: fonts.heading, fontSize: 14, fontWeight: 700, color: active ? t.success : t.accent }}>
            {ARCADE_HUB_CONFIG.discount.percentage}% App Order Discount
          </span>
          <span
            style={{
              fontFamily: fonts.body,
              fontSize: 10,
              fontWeight: 700,
              padding: "2px 6px",
              borderRadius: radii.pill,
              background: active ? t.success : t.textMuted,
              color: "#000",
            }}
          >
            {active ? "ACTIVE NOW" : "DAILY 5PM-8PM"}
          </span>
        </div>
        <div style={{ fontFamily: fonts.body, fontSize: 12, color: t.textMuted, marginTop: 2 }}>
          {active
            ? `Special ${ARCADE_HUB_CONFIG.discount.percentage}% discount applied automatically at checkout!`
            : `Order between ${ARCADE_HUB_CONFIG.discount.startHour}:00 - ${ARCADE_HUB_CONFIG.discount.endHour}:00 for ${ARCADE_HUB_CONFIG.discount.percentage}% OFF.`}
        </div>
      </div>
      <span style={{ color: t.textMuted, fontSize: 16 }}>›</span>
    </div>
  );
}

/* ─────────────────────────────────────────────────────────────
   PRODUCT CARD COMPONENTS
   ───────────────────────────────────────────────────────────── */
function ProductCard({ product, onAdd, onFav, qty = 0, onClick }) {
  const t = useTheme();
  const exp = EXPERIENCES.find((e) => e.id === product.areaId) || EXPERIENCES[0];

  return (
    <div
      onClick={onClick}
      style={{
        background: t.surface,
        border: `1px solid ${t.border}`,
        borderRadius: radii.card,
        padding: 14,
        boxShadow: `0 2px 10px ${t.shadow}`,
        display: "flex",
        gap: 14,
        alignItems: "center",
        position: "relative",
        cursor: "pointer",
      }}
    >
      <div
        style={{
          width: 84,
          height: 84,
          borderRadius: radii.m,
          background: `${exp.color}18`,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          fontSize: 38,
          flexShrink: 0,
          border: `1px solid ${exp.color}33`,
        }}
      >
        {product.emoji || "🍔"}
      </div>

      <div style={{ flex: 1, display: "flex", flexDirection: "column", justifyContent: "space-between", minHeight: 84 }}>
        <div>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", gap: 6 }}>
            <span style={{ fontFamily: fonts.heading, fontSize: 15, fontWeight: 700, color: t.text }}>{product.name}</span>
            <button
              className="fav-btn"
              onClick={(e) => {
                e.stopPropagation();
                onFav();
              }}
              style={{ fontSize: 16, color: product.fav ? t.error : t.textMuted }}
            >
              {product.fav ? "♥" : "♡"}
            </button>
          </div>
          <div style={{ display: "flex", alignItems: "center", gap: 6, marginTop: 2 }}>
            <span style={{ fontSize: 10, fontWeight: 700, color: exp.color, background: `${exp.color}20`, padding: "1px 6px", borderRadius: radii.pill }}>
              {exp.name}
            </span>
            <span style={{ fontFamily: fonts.body, fontSize: 12, color: t.textMuted }}>{product.category}</span>
          </div>
        </div>

        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginTop: 8 }}>
          <PriceText price={product.price} original={product.originalPrice} />
          <div onClick={(e) => e.stopPropagation()}>
            {qty > 0 ? (
              <div style={{ display: "flex", alignItems: "center", gap: 8, background: t.primary, borderRadius: radii.pill, padding: "4px 10px", color: t.onPrimary, fontWeight: 700, fontSize: 13 }}>
                <button className="icon-btn-ghost" onClick={() => onAdd(-1)} style={{ color: t.onPrimary, fontSize: 14, width: 22, height: 22 }}>−</button>
                <span>{qty}</span>
                <button className="icon-btn-ghost" onClick={() => onAdd(1)} style={{ color: t.onPrimary, fontSize: 14, width: 22, height: 22 }}>+</button>
              </div>
            ) : (
              <button
                className="icon-btn-solid"
                onClick={() => onAdd(1)}
                style={{
                  width: 32,
                  height: 32,
                  borderRadius: radii.pill,
                  background: `linear-gradient(135deg, ${t.primary}, ${t.secondary})`,
                  color: "#FFF",
                  fontSize: 18,
                  fontWeight: 700,
                }}
              >
                +
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

/* ─────────────────────────────────────────────────────────────
   HAMBURGER DRAWER MENU
   ───────────────────────────────────────────────────────────── */
function DrawerMenu({ isOpen, onClose, onNavigate }) {
  const t = useTheme();
  if (!isOpen) return null;

  return (
    <div style={{ position: "fixed", inset: 0, zIndex: 999, display: "flex" }}>
      {/* Backdrop */}
      <div onClick={onClose} style={{ flex: 1, background: "rgba(0,0,0,0.7)", backdropFilter: "blur(4px)" }} />

      {/* Slide-out Content */}
      <div
        style={{
          width: 310,
          background: t.surface,
          borderLeft: `1px solid ${t.border}`,
          height: "100%",
          padding: "24px 20px",
          display: "flex",
          flexDirection: "column",
          justifyContent: "space-between",
          boxShadow: "-8px 0 32px rgba(0,0,0,0.5)",
          overflowY: "auto",
        }}
      >
        <div>
          {/* Header */}
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 24 }}>
            <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
              <div style={{ width: 40, height: 40, borderRadius: radii.m, background: `linear-gradient(135deg, ${t.primary}, ${t.secondary})`, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 20 }}>
                🕹️
              </div>
              <div>
                <h3 style={{ fontFamily: fonts.heading, fontSize: 18, fontWeight: 700, color: t.text, margin: 0 }}>Arcade Hub</h3>
                <span style={{ fontFamily: fonts.body, fontSize: 11, color: t.textMuted }}>Pokhara, Nepal</span>
              </div>
            </div>
            <button className="icon-btn" onClick={onClose} style={{ color: t.textMuted, fontSize: 20 }}>✕</button>
          </div>

          {/* Experience Areas */}
          <div style={{ marginBottom: 24 }}>
            <div style={{ fontFamily: fonts.body, fontSize: 11, fontWeight: 700, color: t.textMuted, letterSpacing: 1, textTransform: "uppercase", marginBottom: 12 }}>
              Venue Experiences
            </div>
            {EXPERIENCES.map((exp) => (
              <button
                key={exp.id}
                onClick={() => {
                  onNavigate("experience-detail", exp);
                  onClose();
                }}
                style={{
                  width: "100%",
                  display: "flex",
                  alignItems: "center",
                  gap: 12,
                  padding: "12px 14px",
                  borderRadius: radii.m,
                  border: "none",
                  background: `${exp.color}10`,
                  color: t.text,
                  marginBottom: 8,
                  cursor: "pointer",
                  textAlign: "left",
                }}
              >
                <span style={{ fontSize: 20 }}>{exp.icon}</span>
                <span style={{ fontFamily: fonts.body, fontSize: 14, fontWeight: 600, flex: 1 }}>{exp.name}</span>
                <span style={{ width: 10, height: 10, borderRadius: "50%", background: exp.color }} />
              </button>
            ))}
          </div>

          {/* Quick Actions */}
          <div>
            <div style={{ fontFamily: fonts.body, fontSize: 11, fontWeight: 700, color: t.textMuted, letterSpacing: 1, textTransform: "uppercase", marginBottom: 12 }}>
              Special Services
            </div>
            <button
              onClick={() => { onNavigate("ps5-rental"); onClose(); }}
              style={{
                width: "100%",
                display: "flex",
                alignItems: "center",
                gap: 12,
                padding: "12px 14px",
                borderRadius: radii.m,
                border: `1px solid ${t.primary}40`,
                background: `${t.primary}12`,
                color: t.primary,
                fontWeight: 700,
                marginBottom: 8,
                cursor: "pointer",
              }}
            >
              <span>🎮</span> PS5 Rental (9PM-9AM)
            </button>
            <button
              onClick={() => { onNavigate("discounts"); onClose(); }}
              style={{
                width: "100%",
                display: "flex",
                alignItems: "center",
                gap: 12,
                padding: "12px 14px",
                borderRadius: radii.m,
                border: `1px solid ${t.success}40`,
                background: `${t.success}12`,
                color: t.success,
                fontWeight: 700,
                marginBottom: 8,
                cursor: "pointer",
              }}
            >
              <span>⚡</span> App 10% Discount Info
            </button>
          </div>
        </div>

        {/* WhatsApp Contact Footer */}
        <div style={{ borderTop: `1px solid ${t.border}`, paddingTop: 16, marginTop: 16 }}>
          <a
            href={`https://wa.me/${ARCADE_HUB_CONFIG.whatsappNumber.replace("+", "")}`}
            target="_blank"
            rel="noreferrer"
            style={{
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              gap: 8,
              padding: "12px",
              borderRadius: radii.m,
              background: "#25D366",
              color: "#FFFFFF",
              textDecoration: "none",
              fontFamily: fonts.body,
              fontSize: 14,
              fontWeight: 700,
            }}
          >
            💬 WhatsApp: {ARCADE_HUB_CONFIG.whatsappFormatted}
          </a>
        </div>
      </div>
    </div>
  );
}

/* ─────────────────────────────────────────────────────────────
   BOTTOM NAVIGATION BAR
   ───────────────────────────────────────────────────────────── */
function BottomNavBar({ current, onNavigate, cartCount }) {
  const t = useTheme();
  const tabs = [
    { key: "home", label: "Home", icon: "🏠" },
    { key: "ps5-rental", label: "PS5 Rental", icon: "🎮" },
    { key: "cart", label: "Cart", icon: "🛒" },
    { key: "profile", label: "Profile", icon: "👤" },
  ];

  return (
    <div
      style={{
        position: "fixed",
        bottom: 0,
        left: 0,
        right: 0,
        maxWidth: 480,
        margin: "0 auto",
        background: t.surface,
        borderTop: `1px solid ${t.border}`,
        boxShadow: `0 -4px 20px rgba(0,0,0,0.4)`,
        padding: "10px 16px 16px",
        display: "flex",
        justifyContent: "space-around",
        zIndex: 100,
      }}
    >
      {tabs.map((tab) => {
        const active = current === tab.key;
        return (
          <button
            key={tab.key}
            onClick={() => onNavigate(tab.key)}
            style={{
              display: "flex",
              flexDirection: "column",
              alignItems: "center",
              gap: 4,
              background: "transparent",
              border: "none",
              cursor: "pointer",
              position: "relative",
            }}
          >
            <span style={{ fontSize: 22, color: active ? t.primary : t.textMuted }}>{tab.icon}</span>
            <span style={{ fontFamily: fonts.body, fontSize: 11, color: active ? t.primary : t.textMuted, fontWeight: active ? 700 : 500 }}>
              {tab.label}
            </span>
            {tab.key === "cart" && cartCount > 0 && (
              <span
                style={{
                  position: "absolute",
                  top: -2,
                  right: -6,
                  width: 18,
                  height: 18,
                  borderRadius: "50%",
                  background: t.error,
                  color: "#FFF",
                  fontSize: 10,
                  fontWeight: 700,
                  display: "flex",
                  alignItems: "center",
                  justifyContent: "center",
                }}
              >
                {cartCount}
              </span>
            )}
          </button>
        );
      })}
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   SCREENS
   ═══════════════════════════════════════════════════════════════ */

/* ─────────────────────────────────────────────────────────────
   HOME SCREEN
   ───────────────────────────────────────────────────────────── */
function HomeScreen({ products, cart, setCart, favs, setFavs, onNavigate, onOpenDrawer }) {
  const t = useTheme();
  const [search, setSearch] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("All");

  const categories = ["All", ...new Set(products.map((p) => p.category))];

  const filteredProducts = products.filter((p) => {
    const matchSearch = !search || p.name.toLowerCase().includes(search.toLowerCase());
    const matchCat = selectedCategory === "All" || p.category === selectedCategory;
    return matchSearch && matchCat;
  });

  const toggleQty = (id, delta) => {
    setCart((prev) => {
      const cur = prev[id] || 0;
      const next = cur + delta;
      if (next <= 0) { const n = { ...prev }; delete n[id]; return n; }
      return { ...prev, [id]: next };
    });
  };

  return (
    <div style={{ padding: "16px 20px 100px", background: t.scaffold, minHeight: "100vh" }}>
      {/* Top Header */}
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 16 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
          <button className="icon-btn" onClick={onOpenDrawer} style={{ fontSize: 22, color: t.text, width: 40, height: 40, background: t.surfaceElevated }}>
            ☰
          </button>
          <div>
            <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
              <span style={{ fontFamily: fonts.heading, fontSize: 20, fontWeight: 800, color: t.text }}>Arcade Hub</span>
              <span style={{ fontSize: 10, fontWeight: 700, color: t.primary, background: `${t.primary}20`, padding: "2px 6px", borderRadius: radii.pill }}>POKHARA</span>
            </div>
            <span style={{ fontFamily: fonts.body, fontSize: 12, color: t.textMuted }}>Entertainment & Ordering</span>
          </div>
        </div>

        <button
          onClick={() => onNavigate("cart")}
          style={{
            position: "relative",
            width: 44,
            height: 44,
            borderRadius: radii.m,
            background: t.surfaceElevated,
            border: `1px solid ${t.border}`,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: 20,
            cursor: "pointer",
          }}
        >
          🛒
        </button>
      </div>

      {/* Hero Carousel */}
      <HeroSlider onSelectExperience={(exp) => onNavigate("experience-detail", exp)} />

      {/* Discount Banner */}
      <DiscountBanner onNavigate={onNavigate} />

      {/* Features Grid (6 Experiences) */}
      <FeaturesSection onNavigate={onNavigate} />

      {/* Area & Search Filter Bar */}
      <div style={{ marginBottom: 16 }}>
        <div style={{ position: "relative", marginBottom: 12 }}>
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search food, drinks & game passes..."
            style={{
              width: "100%",
              padding: "14px 16px 14px 44px",
              borderRadius: radii.m,
              border: `1.5px solid ${t.border}`,
              background: t.surface,
              fontFamily: fonts.body,
              fontSize: 14,
              color: t.text,
              outline: "none",
              boxSizing: "border-box",
            }}
          />
          <span style={{ position: "absolute", left: 14, top: "50%", transform: "translateY(-50%)", color: t.textMuted, fontSize: 16 }}>🔍</span>
          {search && (
            <button className="icon-btn" onClick={() => setSearch("")} style={{ position: "absolute", right: 12, top: "50%", transform: "translateY(-50%)", color: t.textMuted, fontSize: 16, width: 28, height: 28 }}>
              ✕
            </button>
          )}
        </div>

        {/* Category Pills */}
        <div style={{ display: "flex", gap: 8, overflowX: "auto", paddingBottom: 4 }}>
          {categories.map((cat) => (
            <button
              key={cat}
              onClick={() => setSelectedCategory(cat)}
              style={{
                padding: "8px 16px",
                borderRadius: radii.pill,
                border: `1px solid ${selectedCategory === cat ? t.primary : t.border}`,
                background: selectedCategory === cat ? t.primary : t.surface,
                color: selectedCategory === cat ? t.onPrimary : t.text,
                fontFamily: fonts.body,
                fontSize: 13,
                fontWeight: 600,
                whiteSpace: "nowrap",
                cursor: "pointer",
              }}
            >
              {cat}
            </button>
          ))}
        </div>
      </div>

      {/* Food / Items List */}
      <SectionHeader title="Food & Drinks Menu" subtitle="Order directly to your spot" />

      {filteredProducts.length === 0 ? (
        <EmptyState
          icon="🔍"
          title="No menu items found"
          subtitle="Try a different category or search query."
          action={<SecondaryButton onClick={() => { setSearch(""); setSelectedCategory("All"); }}>Reset Filters</SecondaryButton>}
        />
      ) : (
        <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
          {filteredProducts.map((product) => (
            <ProductCard
              key={product.id}
              product={{ ...product, fav: favs[product.id] }}
              qty={cart[product.id] || 0}
              onAdd={(d) => toggleQty(product.id, d)}
              onFav={() => setFavs((prev) => ({ ...prev, [product.id]: !prev[product.id] }))}
              onClick={() => onNavigate("product-detail", product)}
            />
          ))}
        </div>
      )}
    </div>
  );
}

/* ─────────────────────────────────────────────────────────────
   EXPERIENCE DETAIL SCREEN (Playroom, Rooftop, etc.)
   ───────────────────────────────────────────────────────────── */
function ExperienceDetailScreen({ experience, products, cart, setCart, onNavigate }) {
  const t = useTheme();
  if (!experience) return null;

  const toggleQty = (id, delta) => {
    setCart((prev) => {
      const cur = prev[id] || 0;
      const next = cur + delta;
      if (next <= 0) { const n = { ...prev }; delete n[id]; return n; }
      return { ...prev, [id]: next };
    });
  };

  return (
    <div style={{ minHeight: "100vh", background: t.scaffold, paddingBottom: 100 }}>
      {/* Banner */}
      <div
        style={{
          position: "relative",
          height: 220,
          background: experience.bgGradient,
          borderBottom: `2px solid ${experience.color}44`,
          display: "flex",
          flexDirection: "column",
          justifyContent: "space-between",
          padding: "16px 20px 24px",
        }}
      >
        <AppBackButton onClick={() => onNavigate("home")} />
        <div>
          <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
            <span style={{ fontSize: 44 }}>{experience.icon}</span>
            <div>
              <h1 style={{ fontFamily: fonts.heading, fontSize: 28, color: t.text, margin: 0 }}>{experience.name}</h1>
              <span style={{ fontFamily: fonts.body, fontSize: 13, color: experience.color, fontWeight: 700 }}>
                {experience.subtitle}
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* Body Content */}
      <div style={{ padding: "20px 20px" }}>
        <p style={{ fontFamily: fonts.body, fontSize: 14, color: t.textMuted, lineHeight: 1.6, marginBottom: 20 }}>
          {experience.description}
        </p>

        {experience.type === "gaming" && (
          <div style={{
            background: `linear-gradient(135deg, ${t.primary}15, ${t.secondary}15)`,
            borderRadius: radii.xl,
            border: `1.5px solid ${t.primary}40`,
            padding: 20,
            marginBottom: 24,
            textAlign: "center"
          }}>
            <div style={{ fontSize: 44, marginBottom: 12 }}>🎮</div>
            <h3 style={{ fontFamily: fonts.heading, fontSize: 20, color: t.text, margin: "0 0 8px" }}>Gaming Services</h3>
            <p style={{ fontFamily: fonts.body, fontSize: 14, color: t.textMuted, margin: "0 0 16px" }}>Book a PS5 station or VR session for your group.</p>
            <PrimaryButton onClick={() => onNavigate("ps5-rental")}>Book PS5 Rental</PrimaryButton>
          </div>
        )}

        {experience.type === "dining" && (
          <div style={{
            background: `${t.success}15`,
            borderRadius: radii.xl,
            border: `1.5px solid ${t.success}40`,
            padding: 20,
            marginBottom: 24,
            textAlign: "center"
          }}>
            <div style={{ fontSize: 44, marginBottom: 12 }}>🍔🍹</div>
            <h3 style={{ fontFamily: fonts.heading, fontSize: 20, color: t.text, margin: "0 0 8px" }}>Food & Drinks</h3>
            <p style={{ fontFamily: fonts.body, fontSize: 14, color: t.textMuted, margin: "0 0 16px" }}>Explore our gourmet menu and craft drinks available at the {experience.name}.</p>
            <PrimaryButton style={{ background: t.success }} onClick={() => onNavigate("home")}>Browse Menu & Order</PrimaryButton>
          </div>
        )}

        {/* WhatsApp Inquiry Button - Primary for Lounge, secondary for others */}
        <a
          href={`https://wa.me/${ARCADE_HUB_CONFIG.whatsappNumber.replace("+", "")}?text=Hi%20Arcade%20Hub!%20I%20want%20to%20inquire%20about%20booking%20the%20${encodeURIComponent(experience.name)}.`}
          target="_blank"
          rel="noreferrer"
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            gap: 8,
            padding: "14px",
            borderRadius: radii.l,
            background: `${experience.color}1F`,
            border: `1.5px solid ${experience.color}`,
            color: experience.color === "#FFFFFF" ? t.text : experience.color,
            textDecoration: "none",
            fontFamily: fonts.body,
            fontSize: 14,
            fontWeight: 700,
            marginBottom: 24,
          }}
        >
          💬 Reserve / Inquire via WhatsApp
        </a>

        {/* Secondary food menu CTA for non-dining areas */}
        {experience.type !== "dining" && (
          <div style={{
            background: t.surface,
            borderRadius: radii.xl,
            border: `1px solid ${t.border}`,
            padding: 20,
            textAlign: "center"
          }}>
            <div style={{ fontSize: 40, marginBottom: 12 }}>🍽️</div>
            <h3 style={{ fontFamily: fonts.heading, fontSize: 20, color: t.text, margin: "0 0 8px" }}>Hungry or Thirsty?</h3>
            <p style={{ fontFamily: fonts.body, fontSize: 14, color: t.textMuted, margin: "0 0 16px" }}>Order food & drinks directly to your spot in the {experience.name}.</p>
            <SecondaryButton onClick={() => onNavigate("home")}>Browse Food & Drinks</SecondaryButton>
          </div>
        )}
      </div>
    </div>
  );
}

/* ─────────────────────────────────────────────────────────────
   PS5 RENTAL SCREEN
   ───────────────────────────────────────────────────────────── */
function PS5RentalScreen({ onNavigate }) {
  const t = useTheme();
  const [controllers, setControllers] = useState(2);
  const [date, setDate] = useState(new Date().toISOString().split("T")[0]);
  const [booked, setBooked] = useState(false);

  const basePrice = ARCADE_HUB_CONFIG.ps5Rental.basePriceNPR;
  const extraControllerFee = (controllers - 2) * 300;
  const totalPrice = basePrice + Math.max(0, extraControllerFee);

  const handleBooking = () => {
    setBooked(true);
  };

  return (
    <div style={{ padding: "16px 20px 100px", background: t.scaffold, minHeight: "100vh" }}>
      <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 20 }}>
        <AppBackButton onClick={() => onNavigate("home")} />
        <div>
          <h1 style={{ fontFamily: fonts.heading, fontSize: 24, color: t.text, margin: 0 }}>PS5 Console Rental</h1>
          <span style={{ fontFamily: fonts.body, fontSize: 12, color: t.primary, fontWeight: 700 }}>Overnight Gaming Pass</span>
        </div>
      </div>

      {booked ? (
        <div style={{ background: t.surface, borderRadius: radii.xxl, padding: 24, border: `1.5px solid ${t.success}`, textAlign: "center" }}>
          <div style={{ fontSize: 56, marginBottom: 12 }}>🎮</div>
          <h2 style={{ fontFamily: fonts.heading, fontSize: 24, color: t.text, margin: "0 0 8px" }}>Rental Requested!</h2>
          <p style={{ fontFamily: fonts.body, fontSize: 14, color: t.textMuted, margin: "0 0 20px" }}>
            PS5 Console Slot reserved for <strong>9:00 PM → 9:00 AM</strong> on {date}.
          </p>
          <a
            href={`https://wa.me/${ARCADE_HUB_CONFIG.whatsappNumber.replace("+", "")}?text=Hi%20Arcade%20Hub!%20I%20booked%20a%20PS5%20Rental%20for%20${date}%20(${controllers}%20controllers).`}
            target="_blank"
            rel="noreferrer"
            style={{
              display: "inline-flex",
              alignItems: "center",
              gap: 8,
              padding: "14px 24px",
              borderRadius: radii.l,
              background: "#25D366",
              color: "#FFF",
              textDecoration: "none",
              fontFamily: fonts.body,
              fontWeight: 700,
            }}
          >
            💬 Confirm via WhatsApp
          </a>
        </div>
      ) : (
        <>
          {/* Card overview */}
          <div
            style={{
              background: "linear-gradient(135deg, rgba(0, 229, 255, 0.2), rgba(213, 0, 249, 0.2))",
              border: `1.5px solid ${t.primary}`,
              borderRadius: radii.xxl,
              padding: 20,
              marginBottom: 24,
            }}
          >
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 12 }}>
              <span style={{ fontSize: 40 }}>🎮</span>
              <span style={{ fontFamily: fonts.heading, fontSize: 24, fontWeight: 800, color: t.primary }}>
                {formatPrice(basePrice)}
              </span>
            </div>
            <h3 style={{ fontFamily: fonts.heading, fontSize: 20, color: t.text, margin: "0 0 4px" }}>Overnight PS5 Pass</h3>
            <p style={{ fontFamily: fonts.body, fontSize: 13, color: t.textMuted, margin: 0 }}>
              Fixed Period: <strong>9:00 PM → 9:00 AM</strong>
            </p>
          </div>

          {/* Form */}
          <div style={{ background: t.surface, borderRadius: radii.xl, padding: 20, border: `1px solid ${t.border}`, marginBottom: 24 }}>
            <div style={{ marginBottom: 16 }}>
              <label style={{ fontFamily: fonts.body, fontSize: 12, fontWeight: 700, color: t.textMuted, textTransform: "uppercase", display: "block", marginBottom: 6 }}>
                Rental Date
              </label>
              <input
                type="date"
                value={date}
                onChange={(e) => setDate(e.target.value)}
                style={{
                  width: "100%",
                  padding: "12px 14px",
                  borderRadius: radii.m,
                  border: `1px solid ${t.border}`,
                  background: t.scaffold,
                  color: t.text,
                  fontFamily: fonts.body,
                  fontSize: 14,
                }}
              />
            </div>

            <div style={{ marginBottom: 16 }}>
              <label style={{ fontFamily: fonts.body, fontSize: 12, fontWeight: 700, color: t.textMuted, textTransform: "uppercase", display: "block", marginBottom: 6 }}>
                Controllers Count
              </label>
              <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
                {[2, 3, 4].map((num) => (
                  <button
                    key={num}
                    onClick={() => setControllers(num)}
                    style={{
                      flex: 1,
                      padding: "10px",
                      borderRadius: radii.m,
                      border: `1.5px solid ${controllers === num ? t.primary : t.border}`,
                      background: controllers === num ? `${t.primary}20` : t.scaffold,
                      color: controllers === num ? t.primary : t.text,
                      fontFamily: fonts.body,
                      fontWeight: 700,
                      cursor: "pointer",
                    }}
                  >
                    {num} Controllers
                  </button>
                ))}
              </div>
            </div>

            {/* Terms / Late fee info */}
            <div style={{ background: `${t.error}15`, border: `1px solid ${t.error}33`, borderRadius: radii.m, padding: 12, fontSize: 12, color: t.textMuted }}>
              ⚠️ <strong>Late Return Policy:</strong> Rentals returned past 9:00 AM incur a configurable late fee of {formatPrice(ARCADE_HUB_CONFIG.ps5Rental.lateFeePerHourNPR)}/hour.
            </div>
          </div>

          <PrimaryButton onClick={handleBooking}>Book PS5 Console — {formatPrice(totalPrice)}</PrimaryButton>
        </>
      )}
    </div>
  );
}

/* ─────────────────────────────────────────────────────────────
   CART SCREEN
   ───────────────────────────────────────────────────────────── */
function CartScreen({ products, cart, setCart, onNavigate }) {
  const t = useTheme();
  const activeDiscount = isDiscountActiveNow();

  const cartEntries = Object.entries(cart)
    .map(([id, qty]) => ({ product: products.find((p) => p.id === id), qty }))
    .filter((e) => e.product);

  const subtotal = cartEntries.reduce((s, e) => s + e.product.price * e.qty, 0);
  const discountAmount = activeDiscount ? Math.round(subtotal * (ARCADE_HUB_CONFIG.discount.percentage / 100)) : 0;
  const taxableAmount = subtotal - discountAmount;
  const vat = Math.round(taxableAmount * 0.13);
  const total = taxableAmount + vat;

  const updateQty = (id, d) => {
    setCart((prev) => {
      const cur = prev[id] || 0;
      const next = cur + d;
      if (next <= 0) { const n = { ...prev }; delete n[id]; return n; }
      return { ...prev, [id]: next };
    });
  };

  const empty = cartEntries.length === 0;

  return (
    <div style={{ padding: "16px 20px 100px", background: t.scaffold, minHeight: "100vh" }}>
      <h1 style={{ fontFamily: fonts.heading, fontSize: 26, color: t.text, margin: "0 0 4px" }}>Your Order Cart</h1>
      <p style={{ fontFamily: fonts.body, fontSize: 13, color: t.textMuted, margin: "0 0 20px" }}>
        {empty ? "0 items in cart" : `${cartEntries.length} item types selected`}
      </p>

      {empty ? (
        <EmptyState icon="🛒" title="Your cart is empty" subtitle="Explore Arcade Hub experiences and add snacks or drinks!" action={<PrimaryButton onClick={() => onNavigate("home")}>Browse Menu</PrimaryButton>} />
      ) : (
        <>
          <div style={{ display: "flex", flexDirection: "column", gap: 12, marginBottom: 20 }}>
            {cartEntries.map(({ product, qty }) => (
              <ProductCard key={product.id} product={product} qty={qty} onAdd={(d) => updateQty(product.id, d)} onFav={() => {}} />
            ))}
          </div>

          {/* Discount Banner */}
          {activeDiscount && (
            <div style={{ background: `${t.success}18`, border: `1px solid ${t.success}`, borderRadius: radii.l, padding: 12, marginBottom: 20, display: "flex", alignItems: "center", gap: 10 }}>
              <span style={{ fontSize: 20 }}>⚡</span>
              <div style={{ fontFamily: fonts.body, fontSize: 13, color: t.success, fontWeight: 600 }}>
                {ARCADE_HUB_CONFIG.discount.percentage}% App Special Discount applied! (-{formatPrice(discountAmount)})
              </div>
            </div>
          )}

          {/* Price Breakdown */}
          <div style={{ background: t.surface, borderRadius: radii.xl, padding: 20, border: `1px solid ${t.border}`, marginBottom: 24 }}>
            <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 8, fontSize: 14, color: t.textMuted }}>
              <span>Subtotal</span><span>{formatPrice(subtotal)}</span>
            </div>
            {activeDiscount && (
              <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 8, fontSize: 14, color: t.success }}>
                <span>App Discount ({ARCADE_HUB_CONFIG.discount.percentage}%)</span><span>-{formatPrice(discountAmount)}</span>
              </div>
            )}
            <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 8, fontSize: 14, color: t.textMuted }}>
              <span>Govt VAT (13%)</span><span>{formatPrice(vat)}</span>
            </div>
            <div style={{ borderTop: `1px solid ${t.border}`, margin: "12px 0" }} />
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <span style={{ fontFamily: fonts.heading, fontSize: 18, color: t.text }}>Grand Total</span>
              <span style={{ fontFamily: fonts.heading, fontSize: 22, fontWeight: 800, color: t.primary }}>{formatPrice(total)}</span>
            </div>
          </div>

          <PrimaryButton onClick={() => onNavigate("checkout")}>Proceed to Checkout — {formatPrice(total)}</PrimaryButton>
        </>
      )}
    </div>
  );
}

/* ─────────────────────────────────────────────────────────────
   CHECKOUT SCREEN
   ───────────────────────────────────────────────────────────── */
function CheckoutScreen({ products, cart, onNavigate }) {
  const t = useTheme();
  const [selectedAreaSpot, setSelectedAreaSpot] = useState("Rooftop Table #4");
  const [paymentMethod, setPaymentMethod] = useState("Cash / POS Card");

  const cartEntries = Object.entries(cart)
    .map(([id, qty]) => ({ product: products.find((p) => p.id === id), qty }))
    .filter((e) => e.product);

  const activeDiscount = isDiscountActiveNow();
  const subtotal = cartEntries.reduce((s, e) => s + e.product.price * e.qty, 0);
  const discountAmount = activeDiscount ? Math.round(subtotal * (ARCADE_HUB_CONFIG.discount.percentage / 100)) : 0;
  const taxableAmount = subtotal - discountAmount;
  const vat = Math.round(taxableAmount * 0.13);
  const total = taxableAmount + vat;

  return (
    <div style={{ minHeight: "100vh", background: t.scaffold, paddingBottom: 100 }}>
      <div style={{ padding: "16px 20px", display: "flex", alignItems: "center", gap: 12, borderBottom: `1px solid ${t.border}` }}>
        <AppBackButton onClick={() => onNavigate("cart")} />
        <h1 style={{ fontFamily: fonts.heading, fontSize: 22, color: t.text, margin: 0 }}>Checkout Order</h1>
      </div>

      <div style={{ padding: 20 }}>
        {/* Table / Area Spot Selection */}
        <div style={{ marginBottom: 20 }}>
          <label style={{ fontFamily: fonts.body, fontSize: 11, fontWeight: 700, color: t.textMuted, textTransform: "uppercase", display: "block", marginBottom: 8 }}>
            Ordering Location / Spot in Venue
          </label>
          <select
            value={selectedAreaSpot}
            onChange={(e) => setSelectedAreaSpot(e.target.value)}
            style={{
              width: "100%",
              padding: "14px",
              borderRadius: radii.m,
              border: `1.5px solid ${t.border}`,
              background: t.surface,
              color: t.text,
              fontFamily: fonts.body,
              fontSize: 14,
            }}
          >
            <option value="Rooftop Table #4">Rooftop Restro — Table #4</option>
            <option value="Sports Bar Booth #2">Sports Bar — Booth #2</option>
            <option value="Playroom Couch">Playroom — Gaming Couch #1</option>
            <option value="Party Room">Private Party Room</option>
            <option value="Takeaway / Counter">Counter Pickup / Takeaway</option>
          </select>
        </div>

        {/* Payment Options */}
        <div style={{ marginBottom: 24 }}>
          <label style={{ fontFamily: fonts.body, fontSize: 11, fontWeight: 700, color: t.textMuted, textTransform: "uppercase", display: "block", marginBottom: 8 }}>
            Payment Method
          </label>
          <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
            {["Cash / POS Card at Table", "eSewa / Khalti Digital QR", "Fonepay QR"].map((pm) => (
              <button
                key={pm}
                onClick={() => setPaymentMethod(pm)}
                style={{
                  padding: "14px",
                  borderRadius: radii.m,
                  border: `1.5px solid ${paymentMethod === pm ? t.primary : t.border}`,
                  background: paymentMethod === pm ? `${t.primary}18` : t.surface,
                  color: t.text,
                  fontFamily: fonts.body,
                  fontSize: 14,
                  fontWeight: 600,
                  textAlign: "left",
                  cursor: "pointer",
                }}
              >
                {pm}
              </button>
            ))}
          </div>
        </div>

        {/* Order Receipt */}
        <div style={{ background: t.surface, borderRadius: radii.xl, border: `1px solid ${t.border}`, padding: 20, fontFamily: fonts.mono, marginBottom: 24 }}>
          <div style={{ textAlign: "center", fontWeight: 700, fontSize: 16, color: t.primary, marginBottom: 4 }}>Arcade Hub Pokhara</div>
          <div style={{ textAlign: "center", fontSize: 11, color: t.textMuted, marginBottom: 12 }}>Arcade Hub Order Summary</div>
          <div style={{ borderTop: "1px dashed " + t.border, margin: "8px 0" }} />

          {cartEntries.map(({ product, qty }) => (
            <div key={product.id} style={{ display: "flex", justifyContent: "space-between", fontSize: 13, color: t.text, marginBottom: 6 }}>
              <span>{product.name} × {qty}</span>
              <span>{formatPrice(product.price * qty)}</span>
            </div>
          ))}

          <div style={{ borderTop: "1px dashed " + t.border, margin: "10px 0" }} />
          <div style={{ display: "flex", justifyContent: "space-between", fontSize: 13, color: t.textMuted, marginBottom: 4 }}>
            <span>Subtotal</span><span>{formatPrice(subtotal)}</span>
          </div>
          {activeDiscount && (
            <div style={{ display: "flex", justifyContent: "space-between", fontSize: 13, color: t.success, marginBottom: 4 }}>
              <span>App Discount ({ARCADE_HUB_CONFIG.discount.percentage}%)</span><span>-{formatPrice(discountAmount)}</span>
            </div>
          )}
          <div style={{ display: "flex", justifyContent: "space-between", fontSize: 13, color: t.textMuted, marginBottom: 4 }}>
            <span>VAT (13%)</span><span>{formatPrice(vat)}</span>
          </div>
          <div style={{ display: "flex", justifyContent: "space-between", fontSize: 16, fontWeight: 700, color: t.text, marginTop: 8 }}>
            <span>Total Payable</span><span style={{ color: t.primary }}>{formatPrice(total)}</span>
          </div>
        </div>

        <PrimaryButton onClick={() => onNavigate("order-success")}>Place Order</PrimaryButton>
      </div>
    </div>
  );
}

/* ─────────────────────────────────────────────────────────────
   ORDER SUCCESS SCREEN
   ───────────────────────────────────────────────────────────── */
function OrderSuccessScreen({ onNavigate }) {
  const t = useTheme();
  return (
    <div style={{ minHeight: "100vh", background: t.scaffold, display: "flex", flexDirection: "column", alignItems: "center", padding: "60px 20px 32px", textAlign: "center" }}>
      <div
        style={{
          width: 96,
          height: 96,
          borderRadius: 32,
          background: `linear-gradient(135deg, ${t.success}, ${t.primary})`,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          fontSize: 48,
          color: "#FFF",
          boxShadow: `0 8px 30px ${t.success}40`,
          marginBottom: 20,
        }}
      >
        ✓
      </div>
      <h1 style={{ fontFamily: fonts.heading, fontSize: 28, color: t.text, margin: "0 0 4px" }}>Order Received!</h1>
      <p style={{ fontFamily: fonts.body, fontSize: 14, color: t.textMuted, margin: "0 0 20px" }}>Order #AH-8092 • Order Placed</p>

      <a
        href={`https://wa.me/${ARCADE_HUB_CONFIG.whatsappNumber.replace("+", "")}?text=Hi%20Arcade%20Hub!%20I%20just%20placed%20Order%20%23AH-8092.`}
        target="_blank"
        rel="noreferrer"
        style={{
          display: "inline-flex",
          alignItems: "center",
          gap: 8,
          padding: "14px 20px",
          borderRadius: radii.l,
          background: "#25D366",
          color: "#FFF",
          textDecoration: "none",
          fontFamily: fonts.body,
          fontWeight: 700,
          marginBottom: 28,
        }}
      >
        💬 Track / Share on WhatsApp
      </a>

      <PrimaryButton onClick={() => onNavigate("home")}>Back to Arcade Hub Home</PrimaryButton>
    </div>
  );
}

/* ─────────────────────────────────────────────────────────────
   DISCOUNTS & PROMOS INFO SCREEN
   ───────────────────────────────────────────────────────────── */
function DiscountsInfoScreen({ onNavigate }) {
  const t = useTheme();
  const active = isDiscountActiveNow();

  return (
    <div style={{ minHeight: "100vh", background: t.scaffold, padding: "16px 20px 100px" }}>
      <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 20 }}>
        <AppBackButton onClick={() => onNavigate("home")} />
        <h1 style={{ fontFamily: fonts.heading, fontSize: 24, color: t.text, margin: 0 }}>App Discounts & Offers</h1>
      </div>

      <div style={{ background: t.surface, borderRadius: radii.xxl, padding: 20, border: `1.5px solid ${t.primary}`, marginBottom: 20 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 12 }}>
          <span style={{ fontSize: 28 }}>⚡</span>
          <div>
            <h3 style={{ fontFamily: fonts.heading, fontSize: 18, color: t.text, margin: 0 }}>
              {ARCADE_HUB_CONFIG.discount.percentage}% Daily App Discount
            </h3>
            <span style={{ fontFamily: fonts.body, fontSize: 12, color: active ? t.success : t.accent, fontWeight: 700 }}>
              {active ? "● ACTIVE RIGHT NOW" : "Active Daily 5:00 PM – 8:00 PM"}
            </span>
          </div>
        </div>
        <p style={{ fontFamily: fonts.body, fontSize: 13, color: t.textMuted, lineHeight: 1.6, margin: 0 }}>
          Enjoy {ARCADE_HUB_CONFIG.discount.percentage}% off any food or beverage order placed directly through the Arcade Hub app during active hours.
        </p>
      </div>

      <PrimaryButton onClick={() => onNavigate("home")}>Browse Menu & Order</PrimaryButton>
    </div>
  );
}

/* ─────────────────────────────────────────────────────────────
   PROFILE & SETTINGS SCREEN
   ───────────────────────────────────────────────────────────── */
function ProfileScreen({ onNavigate }) {
  const t = useTheme();
  return (
    <div style={{ padding: "16px 20px 100px", background: t.scaffold, minHeight: "100vh" }}>
      <h1 style={{ fontFamily: fonts.heading, fontSize: 26, color: t.text, margin: "0 0 16px" }}>Guest Profile</h1>

      <div style={{ background: `linear-gradient(135deg, ${t.primary}, ${t.secondary})`, borderRadius: radii.xxl, padding: 20, color: "#FFF", marginBottom: 24 }}>
        <h3 style={{ fontFamily: fonts.heading, fontSize: 20, margin: "0 0 4px" }}>Arcade Hub Guest</h3>
        <p style={{ fontFamily: fonts.body, fontSize: 12, opacity: 0.8, margin: 0 }}>Lakeside Pokhara Member</p>
      </div>

      <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
        <button
          onClick={() => onNavigate("discounts")}
          style={{
            padding: "14px 16px",
            borderRadius: radii.l,
            background: t.surface,
            border: `1px solid ${t.border}`,
            color: t.text,
            fontFamily: fonts.body,
            fontSize: 15,
            fontWeight: 600,
            textAlign: "left",
            display: "flex",
            justifyContent: "space-between",
            cursor: "pointer",
          }}
        >
          <span>⚡ App Discount Info</span>
          <span>›</span>
        </button>
        <button
          onClick={() => onNavigate("ps5-rental")}
          style={{
            padding: "14px 16px",
            borderRadius: radii.l,
            background: t.surface,
            border: `1px solid ${t.border}`,
            color: t.text,
            fontFamily: fonts.body,
            fontSize: 15,
            fontWeight: 600,
            textAlign: "left",
            display: "flex",
            justifyContent: "space-between",
            cursor: "pointer",
          }}
        >
          <span>🎮 PS5 Overnight Booking</span>
          <span>›</span>
        </button>
      </div>
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════
   APP SHELL & MAIN CONTAINER
   ═══════════════════════════════════════════════════════════════ */
export default function AppUI() {
  const [screen, setScreen] = useState("home");
  const [cart, setCart] = useState({});
  const [favs, setFavs] = useState({});
  const [selectedExp, setSelectedExp] = useState(null);
  const [drawerOpen, setDrawerOpen] = useState(false);

  const cartCount = Object.values(cart).reduce((s, q) => s + q, 0);

  const navigate = useCallback((s, payload) => {
    if (payload) setSelectedExp(payload);
    setScreen(s);
  }, []);

  const renderScreen = () => {
    switch (screen) {
      case "home":
        return (
          <HomeScreen
            products={SAMPLE_PRODUCTS}
            cart={cart}
            setCart={setCart}
            favs={favs}
            setFavs={setFavs}
            onNavigate={navigate}
            onOpenDrawer={() => setDrawerOpen(true)}
          />
        );
      case "experience-detail":
        return <ExperienceDetailScreen experience={selectedExp} products={SAMPLE_PRODUCTS} cart={cart} setCart={setCart} onNavigate={navigate} />;
      case "ps5-rental":
        return <PS5RentalScreen onNavigate={navigate} />;
      case "cart":
        return <CartScreen products={SAMPLE_PRODUCTS} cart={cart} setCart={setCart} onNavigate={navigate} />;
      case "checkout":
        return <CheckoutScreen products={SAMPLE_PRODUCTS} cart={cart} onNavigate={navigate} />;
      case "order-success":
        return <OrderSuccessScreen onNavigate={navigate} />;
      case "discounts":
        return <DiscountsInfoScreen onNavigate={navigate} />;
      case "profile":
        return <ProfileScreen onNavigate={navigate} />;
      default:
        return <HomeScreen products={SAMPLE_PRODUCTS} cart={cart} setCart={setCart} favs={favs} setFavs={setFavs} onNavigate={navigate} onOpenDrawer={() => setDrawerOpen(true)} />;
    }
  };

  return (
    <ThemeContext.Provider value={darkTheme}>
      <CartContext.Provider value={{ cart, setCart }}>
        <div
          style={{
            fontFamily: fonts.body,
            background: darkTheme.scaffold,
            color: darkTheme.text,
            minHeight: "100vh",
            maxWidth: 480,
            margin: "0 auto",
            position: "relative",
            overflow: "hidden",
            boxShadow: "0 0 50px rgba(0,0,0,0.8)",
          }}
        >
          <style>{`
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { background: #050508; }
            ::-webkit-scrollbar { display: none; }
            .icon-btn { display: inline-flex; align-items: center; justify-content: center; border: none; cursor: pointer; border-radius: 50%; transition: transform 0.15s ease; }
            .icon-btn:hover { transform: scale(1.1); }
            .icon-btn-solid { display: inline-flex; align-items: center; justify-content: center; border: none; cursor: pointer; border-radius: 50%; transition: transform 0.15s ease; }
            .icon-btn-solid:hover { transform: scale(1.1); }
            .icon-btn-ghost { display: inline-flex; align-items: center; justify-content: center; background: transparent; border: none; cursor: pointer; }
            .fav-btn { display: inline-flex; align-items: center; justify-content: center; background: transparent; border: none; cursor: pointer; transition: transform 0.2s ease; }
            .fav-btn:hover { transform: scale(1.25); }
            .back-btn { display: inline-flex; align-items: center; justify-content: center; border: none; cursor: pointer; border-radius: 50%; transition: transform 0.15s ease; }
            .back-btn:hover { transform: scale(1.1); }
            .spinner { width: 20px; height: 20px; border: 2px solid rgba(255,255,255,0.3); border-top-color: #fff; border-radius: 50%; animation: spin 0.8s linear infinite; display: inline-block; }
            @keyframes spin { to { transform: rotate(360deg); } }
          `}</style>

          {renderScreen()}

          <DrawerMenu isOpen={drawerOpen} onClose={() => setDrawerOpen(false)} onNavigate={navigate} />

          <BottomNavBar current={screen} onNavigate={(s) => navigate(s)} cartCount={cartCount} />
        </div>
      </CartContext.Provider>
    </ThemeContext.Provider>
  );
}

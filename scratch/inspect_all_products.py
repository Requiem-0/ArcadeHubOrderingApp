import requests
import json

def inspect_all(url):
    r = requests.get(url, headers={"Accept": "application/json", "app": "user"}, timeout=10)
    data = r.json()
    products = data.get("products", []) if isinstance(data, dict) else data
    for p in products:
        print(f"[{p.get('name')}] Price: {p.get('price')} | UsesOffer: {p.get('usesOfferPrice')} | OfferPrice: {p.get('offerPrice')} | Discounts: {p.get('discounts')} | Addons: {len(p.get('addons', []))} | Variants: {bool(p.get('variants'))}")

print("=== BETA ===")
inspect_all("https://api.beta.order.rebuzzpos.com/api/businesses/6a8a87631d9c3a6661f3bb12/products")
print("=== PROD ===")
inspect_all("https://api.order.rebuzzpos.com/api/businesses/65db0f54d0199c9b3dc7ab15/products")
